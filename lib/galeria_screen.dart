import 'dart:io';
import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:file_picker/file_picker.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'theme.dart';

// Modelo para las fotos
class PhotoModel {
  final String id;
  final String path; // Path en móvil/desktop o base64 en web
  final String name;
  final DateTime dateAdded;
  final String albumId;
  final bool isBase64; // Para distinguir entre path y base64

  PhotoModel({
    required this.id,
    required this.path,
    required this.name,
    required this.dateAdded,
    this.albumId = 'default',
    this.isBase64 = false,
  });

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'path': path,
      'name': name,
      'dateAdded': dateAdded.toIso8601String(),
      'albumId': albumId,
      'isBase64': isBase64,
    };
  }

  factory PhotoModel.fromJson(Map<String, dynamic> json) {
    return PhotoModel(
      id: json['id'],
      path: json['path'],
      name: json['name'],
      dateAdded: DateTime.parse(json['dateAdded']),
      albumId: json['albumId'] ?? 'default',
      isBase64: json['isBase64'] ?? false,
    );
  }
}

// Modelo para álbumes
class AlbumModel {
  final String id;
  final String name;
  final DateTime dateCreated;
  final String coverPhotoId;

  AlbumModel({
    required this.id,
    required this.name,
    required this.dateCreated,
    this.coverPhotoId = '',
  });

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'dateCreated': dateCreated.toIso8601String(),
      'coverPhotoId': coverPhotoId,
    };
  }

  factory AlbumModel.fromJson(Map<String, dynamic> json) {
    return AlbumModel(
      id: json['id'],
      name: json['name'],
      dateCreated: DateTime.parse(json['dateCreated']),
      coverPhotoId: json['coverPhotoId'] ?? '',
    );
  }
}

class CrossPlatformImagePicker extends StatefulWidget {
  const CrossPlatformImagePicker({super.key});

  @override
  State<CrossPlatformImagePicker> createState() => CrossPlatformImagePickerState();
}

class CrossPlatformImagePickerState extends State<CrossPlatformImagePicker> {
  List<PhotoModel> _photos = [];
  List<AlbumModel> _albums = [];
  String _currentAlbumId = 'default';
  bool _isLoading = false;
  bool _isSelectionMode = false;
  final Set<String> _selectedPhotos = {};
  bool _isGridView = true;

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  // Cargar datos desde SharedPreferences
  Future<void> _loadData() async {
    final prefs = await SharedPreferences.getInstance();
    
    // Cargar fotos
    final photosJson = prefs.getStringList('gallery_photos') ?? [];
    _photos = photosJson.map((json) => PhotoModel.fromJson(jsonDecode(json))).toList();
    
    // Cargar álbumes
    final albumsJson = prefs.getStringList('gallery_albums') ?? [];
    _albums = albumsJson.map((json) => AlbumModel.fromJson(jsonDecode(json))).toList();
    
    // Crear álbum por defecto si no existe
    if (_albums.isEmpty) {
      _albums.add(AlbumModel(
        id: 'default',
        name: 'Todas las fotos',
        dateCreated: DateTime.now(),
      ));
      await _saveAlbums();
    }
    
    setState(() {});
  }

  // Guardar fotos
  Future<void> _savePhotos() async {
    final prefs = await SharedPreferences.getInstance();
    final photosJson = _photos.map((photo) => jsonEncode(photo.toJson())).toList();
    await prefs.setStringList('gallery_photos', photosJson);
  }

  // Guardar álbumes
  Future<void> _saveAlbums() async {
    final prefs = await SharedPreferences.getInstance();
    final albumsJson = _albums.map((album) => jsonEncode(album.toJson())).toList();
    await prefs.setStringList('gallery_albums', albumsJson);
  }

  // Seleccionar imágenes
  Future<void> _pickImages() async {
    setState(() => _isLoading = true);

    try {
      List<PhotoModel> newPhotos = [];

      if (kIsWeb) {
        FilePickerResult? result = await FilePicker.platform.pickFiles(
          allowMultiple: true,
          type: FileType.image,
          withData: true,
        );

        if (result != null) {
          for (var file in result.files) {
            if (file.bytes != null) {
              final base64String = base64Encode(file.bytes!);
              newPhotos.add(PhotoModel(
                id: DateTime.now().millisecondsSinceEpoch.toString() + file.name,
                path: base64String,
                name: file.name,
                dateAdded: DateTime.now(),
                albumId: _currentAlbumId,
                isBase64: true,
              ));
            }
          }
        }
      } else if (Platform.isMacOS || Platform.isWindows || Platform.isLinux) {
        FilePickerResult? result = await FilePicker.platform.pickFiles(
          allowMultiple: true,
          type: FileType.image,
        );
        if (result != null) {
          for (var path in result.paths.whereType<String>()) {
            final fileName = path.split('/').last;
            newPhotos.add(PhotoModel(
              id: DateTime.now().millisecondsSinceEpoch.toString() + fileName,
              path: path,
              name: fileName,
              dateAdded: DateTime.now(),
              albumId: _currentAlbumId,
            ));
          }
        }
      } else if (Platform.isAndroid || Platform.isIOS) {
        final ImagePicker picker = ImagePicker();
        final List<XFile> pickedFiles = await picker.pickMultiImage();
        for (var file in pickedFiles) {
          final fileName = file.name;
          newPhotos.add(PhotoModel(
            id: DateTime.now().millisecondsSinceEpoch.toString() + fileName,
            path: file.path,
            name: fileName,
            dateAdded: DateTime.now(),
            albumId: _currentAlbumId,
          ));
        }
      }

      _photos.addAll(newPhotos);
      await _savePhotos();
      setState(() => _isLoading = false);

      if (newPhotos.isNotEmpty) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('${newPhotos.length} foto(s) añadida(s)'),
            backgroundColor: AppTheme.primaryColor,
            behavior: SnackBarBehavior.floating,
          ),
        );
      }
    } catch (e) {
      setState(() => _isLoading = false);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Error al seleccionar imágenes: $e'),
          backgroundColor: Colors.red,
          behavior: SnackBarBehavior.floating,
        ),
      );
    }
  }

  // Eliminar fotos seleccionadas
  Future<void> _deleteSelectedPhotos() async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Eliminar fotos'),
        content: Text('¿Estás seguro de que quieres eliminar ${_selectedPhotos.length} foto(s)?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: const Text('Cancelar'),
          ),
          TextButton(
            onPressed: () => Navigator.of(context).pop(true),
            style: TextButton.styleFrom(foregroundColor: Colors.red),
            child: const Text('Eliminar'),
          ),
        ],
      ),
    );

    if (confirmed == true) {
      _photos.removeWhere((photo) => _selectedPhotos.contains(photo.id));
      await _savePhotos();
      setState(() {
        _selectedPhotos.clear();
        _isSelectionMode = false;
      });
      
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Fotos eliminadas'),
          backgroundColor: Colors.green,
          behavior: SnackBarBehavior.floating,
        ),
      );
    }
  }

  // Crear nuevo álbum
  Future<void> _createAlbum() async {
    final controller = TextEditingController();
    final albumName = await showDialog<String>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Crear álbum'),
        content: TextField(
          controller: controller,
          decoration: const InputDecoration(
            labelText: 'Nombre del álbum',
          ),
          autofocus: true,
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Cancelar'),
          ),
          TextButton(
            onPressed: () => Navigator.of(context).pop(controller.text),
            child: const Text('Crear'),
          ),
        ],
      ),
    );

    if (albumName != null && albumName.isNotEmpty) {
      final newAlbum = AlbumModel(
        id: DateTime.now().millisecondsSinceEpoch.toString(),
        name: albumName,
        dateCreated: DateTime.now(),
      );
      
      _albums.add(newAlbum);
      await _saveAlbums();
      setState(() {});
    }
  }

  // Ver foto en tamaño completo
  void _viewPhoto(PhotoModel photo) {
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (context) => PhotoViewScreen(photo: photo),
      ),
    );
  }

  // Obtener fotos del álbum actual
  List<PhotoModel> get _currentPhotos {
    if (_currentAlbumId == 'default') {
      return _photos;
    }
    return _photos.where((photo) => photo.albumId == _currentAlbumId).toList();
  }

  @override
  Widget build(BuildContext context) {
    final isTabletOrLarger = AppTheme.isTablet(context) || AppTheme.isDesktop(context);
    final crossAxisCount = AppTheme.isDesktop(context) ? 4 : (isTabletOrLarger ? 3 : 2);

    return Scaffold(
      appBar: AppBar(
        title: Text(
          _albums.isNotEmpty
              ? _albums.firstWhere(
                  (a) => a.id == _currentAlbumId,
                  // Si _currentAlbumId no se encuentra (lo cual no debería pasar si 'default' siempre existe y es el inicial),
                  // se recurre a un AlbumModel que representa el álbum "Todas las fotos".
                  orElse: () => AlbumModel(id: 'default', name: 'Todas las fotos', dateCreated: DateTime.now()),
                ).name
              : 'Galería', // Muestra 'Galería' si _albums está inicialmente vacío (ej. durante la carga)
        ),
        backgroundColor: AppTheme.primaryColor,
        foregroundColor: Colors.white,
        actions: [
          if (_isSelectionMode) ...[
            IconButton(
              icon: const Icon(Icons.delete),
              onPressed: _selectedPhotos.isNotEmpty ? _deleteSelectedPhotos : null,
            ),
            IconButton(
              icon: const Icon(Icons.close),
              onPressed: () {
                setState(() {
                  _isSelectionMode = false;
                  _selectedPhotos.clear();
                });
              },
            ),
          ] else ...[
            IconButton(
              icon: Icon(_isGridView ? Icons.view_list : Icons.grid_view),
              onPressed: () => setState(() => _isGridView = !_isGridView),
            ),
            PopupMenuButton<String>(
              icon: const Icon(Icons.more_vert),
              onSelected: (value) {
                switch (value) {
                  case 'create_album':
                    _createAlbum();
                    break;
                  case 'select_mode':
                    setState(() => _isSelectionMode = true);
                    break;
                }
              },
              itemBuilder: (context) => [
                const PopupMenuItem(
                  value: 'create_album',
                  child: Row(
                    children: [
                      Icon(Icons.create_new_folder),
                      SizedBox(width: 8),
                      Text('Crear álbum'),
                    ],
                  ),
                ),
                const PopupMenuItem(
                  value: 'select_mode',
                  child: Row(
                    children: [
                      Icon(Icons.select_all),
                      SizedBox(width: 8),
                      Text('Seleccionar'),
                    ],
                  ),
                ),
              ],
            ),
          ],
        ],
      ),
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            colors: [Color.fromARGB(255, 248, 245, 252), Color.fromARGB(255, 237, 231, 246)],
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
          ),
        ),
        child: Column(
          children: [
            // Selector de álbumes
            Container(
              height: 60,
              padding: const EdgeInsets.symmetric(vertical: 8.0),
              child: ListView.builder(
                scrollDirection: Axis.horizontal,
                padding: const EdgeInsets.symmetric(horizontal: 16),
                itemCount: _albums.length,
                itemBuilder: (context, index) {
                  final album = _albums[index];
                  final isSelected = album.id == _currentAlbumId;
                  final photoCount = album.id == 'default' 
                      ? _photos.length 
                      : _photos.where((p) => p.albumId == album.id).length;

                  return Padding(
                    padding: const EdgeInsets.only(right: 8),
                    child: FilterChip(
                      label: FittedBox( // Para que el texto del chip se ajuste si es muy largo
                        fit: BoxFit.scaleDown,
                        child: Text('${album.name} ($photoCount)'),
                      ),
                      labelStyle: TextStyle(color: isSelected ? AppTheme.primaryColor : AppTheme.textColor),
                      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                      selected: isSelected,
                      onSelected: (selected) {
                        setState(() {
                          _currentAlbumId = album.id;
                          _selectedPhotos.clear();
                          _isSelectionMode = false;
                        });
                      },
                      backgroundColor: Colors.white,
                      selectedColor: AppTheme.primaryColor.withOpacity(0.3),
                      checkmarkColor: AppTheme.primaryColor,
                    ),
                  );
                },
              ),
            ),
            
            // Grid/Lista de fotos
            Expanded(
              child: Padding( // Añadir padding alrededor de la lista/grid de fotos
                padding: AppTheme.getPadding(context).copyWith(top: 8, bottom: 8), // Ajustar padding vertical
                child: _currentPhotos.isEmpty
                    ? _buildEmptyState()
                    : _isGridView
                        ? _buildGridView(crossAxisCount)
                        : _buildListView(),
              ),
            ),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: _isLoading ? null : _pickImages,
        backgroundColor: AppTheme.primaryColor,
        foregroundColor: Colors.white,
        child: _isLoading 
            ? const SizedBox(
                width: 20,
                height: 20,
                child: CircularProgressIndicator(
                  color: Colors.white,
                  strokeWidth: 2,
                ),
              )
            : const Icon(Icons.add_a_photo),
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.photo_library_outlined,
            size: 80,
            color: AppTheme.primaryColor.withOpacity(0.5),
          ),
          const SizedBox(height: 16),
          Text(
            'No hay fotos en este álbum',
            style: AppTheme.subtitleStyle.copyWith(
              color: Colors.grey.shade600,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Toca el botón + para añadir fotos',
            style: AppTheme.bodyStyle.copyWith(
              color: Colors.grey.shade500,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildGridView(int crossAxisCount) {
    return GridView.builder(
      padding: const EdgeInsets.all(16),
      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: crossAxisCount,
        crossAxisSpacing: 8,
        mainAxisSpacing: 8,
        childAspectRatio: 1,
      ),
      itemCount: _currentPhotos.length,
      itemBuilder: (context, index) {
        final photo = _currentPhotos[index];
        final isSelected = _selectedPhotos.contains(photo.id);

        return GestureDetector(
          onTap: () {
            if (_isSelectionMode) {
              setState(() {
                if (isSelected) {
                  _selectedPhotos.remove(photo.id);
                } else {
                  _selectedPhotos.add(photo.id);
                }
              });
            } else {
              _viewPhoto(photo);
            }
          },
          onLongPress: () {
            setState(() {
              _isSelectionMode = true;
              _selectedPhotos.add(photo.id);
            });
          },
          child: Container(
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(12),
              border: isSelected 
                  ? Border.all(color: AppTheme.primaryColor, width: 3)
                  : null,
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.1),
                  blurRadius: 4,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(12),
              child: Stack(
                fit: StackFit.expand,
                children: [
                  photo.isBase64
                      ? Image.memory(
                          base64Decode(photo.path),
                          fit: BoxFit.cover,
                        )
                      : Image.file(
                          File(photo.path),
                          fit: BoxFit.cover,
                        ),
                  if (_isSelectionMode)
                    Positioned(
                      top: 8,
                      right: 8,
                      child: Container(
                        width: 24,
                        height: 24,
                        decoration: BoxDecoration(
                          color: isSelected ? AppTheme.primaryColor : Colors.white,
                          border: Border.all(color: AppTheme.primaryColor),
                          shape: BoxShape.circle,
                        ),
                        child: isSelected
                            ? const Icon(Icons.check, color: Colors.white, size: 16)
                            : null,
                      ),
                    ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _buildListView() {
    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: _currentPhotos.length,
      itemBuilder: (context, index) {
        final photo = _currentPhotos[index];
        final isSelected = _selectedPhotos.contains(photo.id);

        return Card(
          margin: const EdgeInsets.only(bottom: 8),
          child: ListTile(
            leading: ClipRRect(
              borderRadius: BorderRadius.circular(8),
              child: SizedBox(
                width: 60,
                height: 60,
                child: photo.isBase64
                    ? Image.memory(
                        base64Decode(photo.path),
                        fit: BoxFit.cover,
                      )
                    : Image.file(
                        File(photo.path),
                        fit: BoxFit.cover,
                      ),
              ),
            ),
            title: Text(photo.name),
            subtitle: Text(
              '${photo.dateAdded.day}/${photo.dateAdded.month}/${photo.dateAdded.year}',
            ),
            trailing: _isSelectionMode
                ? Checkbox(
                    value: isSelected,
                    onChanged: (value) {
                      setState(() {
                        if (value == true) {
                          _selectedPhotos.add(photo.id);
                        } else {
                          _selectedPhotos.remove(photo.id);
                        }
                      });
                    },
                  )
                : const Icon(Icons.arrow_forward_ios),
            onTap: () {
              if (_isSelectionMode) {
                setState(() {
                  if (isSelected) {
                    _selectedPhotos.remove(photo.id);
                  } else {
                    _selectedPhotos.add(photo.id);
                  }
                });
              } else {
                _viewPhoto(photo);
              }
            },
            onLongPress: () {
              setState(() {
                _isSelectionMode = true;
                _selectedPhotos.add(photo.id);
              });
            },
          ),
        );
      },
    );
  }
}

// Pantalla para ver foto en tamaño completo
class PhotoViewScreen extends StatelessWidget {
  final PhotoModel photo;

  const PhotoViewScreen({super.key, required this.photo});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        foregroundColor: Colors.white,
        title: Text(photo.name),
      ),
      body: Center(
        child: InteractiveViewer(
          child: photo.isBase64
              ? Image.memory(
                  base64Decode(photo.path),
                  fit: BoxFit.contain,
                )
              : Image.file(
                  File(photo.path),
                  fit: BoxFit.contain,
                ),
        ),
      ),
    );
  }
}