import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:file_picker/file_picker.dart';
import 'package:responsive_framework/responsive_framework.dart';

class CrossPlatformImagePicker extends StatefulWidget {
  const CrossPlatformImagePicker({super.key});

  @override
  State<CrossPlatformImagePicker> createState() => CrossPlatformImagePickerState();
}

class CrossPlatformImagePickerState extends State<CrossPlatformImagePicker> {
  // En Web serán Uint8List, en otras plataformas serán String (path)
  List<dynamic> images = [];
  bool _isLoading = false;

  Future<void> pickImages() async {
    setState(() {
      _isLoading = true;
    });

    List<dynamic> selectedImages = [];

    try {
      if (kIsWeb) {
        FilePickerResult? result = await FilePicker.platform.pickFiles(
          allowMultiple: true,
          type: FileType.image,
          withData: true, // Muy importante para obtener los bytes
        );

        if (result != null) {
          selectedImages = result.files
              .where((file) => file.bytes != null)
              .map((file) => file.bytes!) // Uint8List
              .toList();
        }
      } else if (Platform.isMacOS || Platform.isWindows || Platform.isLinux) {
        FilePickerResult? result = await FilePicker.platform.pickFiles(
          allowMultiple: true,
          type: FileType.image,
        );
        if (result != null) {
          selectedImages = result.paths.whereType<String>().toList();
        }
      } else if (Platform.isAndroid || Platform.isIOS) {
        final ImagePicker picker = ImagePicker();
        final List<XFile> pickedFiles = await picker.pickMultiImage();
        selectedImages = pickedFiles.map((file) => file.path).toList();
            }

      setState(() {
        images = selectedImages;
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _isLoading = false;
      });
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Error al seleccionar imágenes: $e'),
          backgroundColor: Colors.deepPurple.shade300,
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(10),
          ),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final isTabletOrLarger = ResponsiveBreakpoints.of(context).largerThan(MOBILE);
    final double imageHeight = isTabletOrLarger ? 250 : 180;

    return Scaffold(
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        title: const Text(
          "Galería de imágenes",
          style: TextStyle(
            fontWeight: FontWeight.bold,
            color: Colors.white,
          ),
        ),
        backgroundColor: Colors.transparent,
        elevation: 0,
        centerTitle: true,
        iconTheme: const IconThemeData(color: Colors.white),
      ),
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            colors: [Color.fromARGB(255, 214, 190, 231), Color.fromARGB(255, 148, 111, 205)],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
        ),
        child: SafeArea(
          child: Padding(
            padding: const EdgeInsets.all(24.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Container(
                  width: isTabletOrLarger ? 400 : double.infinity,
                  decoration: BoxDecoration(
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.2),
                        blurRadius: 10,
                        offset: const Offset(0, 4),
                      ),
                    ],
                  ),
                  child: ElevatedButton.icon(
                    onPressed: _isLoading ? null : pickImages,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.white,
                      foregroundColor: Colors.deepPurple,
                      padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 24),
                      elevation: 0,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(16),
                      ),
                      textStyle: const TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                      disabledBackgroundColor: Colors.grey.shade200,
                    ),
                    icon: _isLoading 
                        ? SizedBox(
                            height: 24,
                            width: 24,
                            child: CircularProgressIndicator(
                              color: Colors.deepPurple,
                              strokeWidth: 2,
                            ),
                          )
                        : const Icon(Icons.photo_library, size: 28),
                    label: Text(_isLoading ? "Cargando..." : "Seleccionar fotos"),
                  ),
                ),
                const SizedBox(height: 24),
                Expanded(
                  child: Container(
                    decoration: BoxDecoration(
                      color: Colors.white.withOpacity(0.9),
                      borderRadius: BorderRadius.circular(24),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.1),
                          blurRadius: 10,
                          offset: const Offset(0, 4),
                        ),
                      ],
                    ),
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(24),
                      child: images.isEmpty
                          ? Center(
                              child: Column(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Icon(
                                    Icons.photo_album_outlined,
                                    size: 80,
                                    color: Colors.deepPurple.shade300,
                                  ),
                                  const SizedBox(height: 16),
                                  Text(
                                    "No hay imágenes seleccionadas",
                                    style: TextStyle(
                                      fontSize: 18,
                                      color: Colors.grey.shade700,
                                      fontWeight: FontWeight.w500,
                                    ),
                                  ),
                                  const SizedBox(height: 8),
                                  Text(
                                    "Toca el botón arriba para seleccionar fotos",
                                    style: TextStyle(
                                      fontSize: 14,
                                      color: Colors.grey.shade500,
                                    ),
                                  ),
                                ],
                              ),
                            )
                          : ListView.builder(
                              padding: const EdgeInsets.all(16),
                              itemCount: images.length,
                              itemBuilder: (context, index) {
                                final image = images[index];
                                return Container(
                                  margin: const EdgeInsets.only(bottom: 16),
                                  decoration: BoxDecoration(
                                    borderRadius: BorderRadius.circular(16),
                                    boxShadow: [
                                      BoxShadow(
                                        color: Colors.black.withOpacity(0.1),
                                        blurRadius: 8,
                                        offset: const Offset(0, 2),
                                      ),
                                    ],
                                  ),
                                  child: ClipRRect(
                                    borderRadius: BorderRadius.circular(16),
                                    child: kIsWeb
                                        ? Image.memory(
                                            image,
                                            height: imageHeight,
                                            width: double.infinity,
                                            fit: BoxFit.cover,
                                          )
                                        : Image.file(
                                            File(image),
                                            height: imageHeight,
                                            width: double.infinity,
                                            fit: BoxFit.cover,
                                          ),
                                  ),
                                );
                              },
                            ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}