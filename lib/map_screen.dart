import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:geolocator/geolocator.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:latlong2/latlong.dart';
import 'theme.dart'; 
import 'package:flutter_map_cancellable_tile_provider/flutter_map_cancellable_tile_provider.dart';

class MapScreen extends StatefulWidget {
  const MapScreen({super.key});

  @override
  State<MapScreen> createState() => _MapScreenState();
}

class _MapScreenState extends State<MapScreen> {
  final MapController _mapController = MapController();
  LatLng _currentCenter = const LatLng(51.509865, -0.118092); // Centro inicial (Londres)
  final double _currentZoom = 13.0;
  final TextEditingController _searchController = TextEditingController();
  List<dynamic> _searchResults = [];
  bool _isLoadingLocation = false;
  bool _isSearching = false;

  Marker? _currentLocationMarker;
  Marker? _selectedPoiMarker;

  @override
  void initState() {
    super.initState();
    _determinePosition(); 
  }

  Future<void> _determinePosition() async {
    setState(() => _isLoadingLocation = true);
    bool serviceEnabled;
    LocationPermission permission;

    serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
            content: Text('Los servicios de ubicación están desactivados.')));
      }
      setState(() => _isLoadingLocation = false);
      return;
    }

    permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
      if (permission == LocationPermission.denied) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(content: Text('Permisos de ubicación denegados.')));
        }
        setState(() => _isLoadingLocation = false);
        return;
      }
    }

    if (permission == LocationPermission.deniedForever) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
            content: Text(
                'Los permisos de ubicación están denegados permanentemente, no podemos solicitar permisos.')));
      }
      setState(() => _isLoadingLocation = false);
      return;
    }

    try {
      Position position = await Geolocator.getCurrentPosition();
      setState(() {
        _currentCenter = LatLng(position.latitude, position.longitude);
        _updateCurrentLocationMarker(_currentCenter);
        _mapController.move(_currentCenter, _currentZoom);
        _isLoadingLocation = false;
      });
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Error al obtener la ubicación: $e')));
      }
      setState(() => _isLoadingLocation = false);
    }
  }

  void _updateCurrentLocationMarker(LatLng position) {
    _currentLocationMarker = Marker(
      point: position,
      width: 80.0,
      height: 80.0,
      child: const Icon(Icons.person_pin_circle, color: Colors.blue, size: 40.0),
    );
  }

  void _updateSelectedPoiMarker(LatLng point, String osmType, int osmId, String displayName) {
    _selectedPoiMarker = Marker(
      point: point,
      width: 80.0,
      height: 80.0,
      child: GestureDetector(
        onTap: () => _handleMarkerTap(osmType, osmId, displayName),
        child: const Icon(Icons.location_pin, color: Colors.red, size: 40.0),
      ),
    );
    setState(() {
      _mapController.move(point, 15.0); // Mover el mapa al lugar seleccionado
      _searchResults = []; // Limpiar resultados de búsqueda al seleccionar un marcador
      _searchController.clear(); // Limpiar campo de búsqueda
      _isSearching = false; // Terminar estado de búsqueda
    });
  }

  Future<void> _searchPlace(String query) async {
    if (query.isEmpty) return;
    setState(() => _isSearching = true);

    final url = Uri.parse(
        'https://nominatim.openstreetmap.org/search?q=${Uri.encodeComponent(query)}&format=json&limit=5&addressdetails=1&extratags=1'); 
    try {
      final response = await http.get(url, headers: {
        // Priorizar español, luego inglés como fallback general para Nominatim
        'Accept-Language': 'es,en;q=0.9', 
        'User-Agent': 'com.example.tripmap' 
      });
      if (response.statusCode == 200) {
        final data = json.decode(response.body) as List;
        setState(() {
          _searchResults = data;
          _isSearching = false;
        });
      } else {
        throw Exception('Error al buscar lugares: ${response.reasonPhrase}');
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context)
            .showSnackBar(SnackBar(content: Text('Error: $e')));
      }
      setState(() {
        _searchResults = [];
        _isSearching = false;
      });
    }
  }

  void _goToPlace(dynamic place) {
    final lat = double.tryParse(place['lat'].toString());
    final lon = double.tryParse(place['lon'].toString());
    final displayName = place['display_name']?.toString() ?? 'Lugar Desconocido';
    final osmIdString = place['osm_id']?.toString();
    final osmType = place['osm_type']?.toString().toLowerCase(); // e.g., "node", "way", "relation"

    if (lat != null && lon != null && osmIdString != null && osmType != null) {
      final osmId = int.tryParse(osmIdString);
      if (osmId == null) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('ID de lugar inválido.')),
          );
        }
        return;
      }

      final point = LatLng(lat, lon);
      _mapController.move(point, 15.0);
      _updateSelectedPoiMarker(point, osmType, osmId, displayName);

      setState(() {
        _searchResults = []; 
        _searchController.clear();
      });
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Mostrando: $displayName. Toca el marcador para más detalles.')),
        );
      }
    } else {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('No se pudo obtener la información completa del lugar.')),
        );
      }
    }
  }

  Future<void> _handleMarkerTap(String osmType, int osmId, String displayName) async {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) => _buildLoadingPoiSheetContent(displayName),
    );

    try {
      final poiDetails = await _fetchPoiDetails(osmType, osmId);
      if (mounted) {
        Navigator.pop(context); 
        _showPoiDetailsBottomSheet(poiDetails..['display_name_from_search'] = displayName);
      }
    } catch (e) {
      if (mounted) {
        Navigator.pop(context); 
        _showPoiDetailsBottomSheet({
          'display_name_from_search': displayName,
          'error': e.toString(),
        });
      }
    }
  }

  Future<Map<String, dynamic>> _fetchPoiDetails(String osmType, int osmId) async {
    String queryOsmType = osmType.toLowerCase();
    if (!["node", "way", "relation"].contains(queryOsmType)) {
      throw Exception("Tipo OSM desconocido: $osmType");
    }

    const String overpassUrl = 'https://overpass-api.de/api/interpreter';
    final String query = '[out:json][timeout:25];($queryOsmType($osmId););out meta;';

    final response = await http.post(
      Uri.parse(overpassUrl),
      body: {'data': query},
      headers: {'User-Agent': 'com.example.tripmap/1.0'}, 
    );

    if (response.statusCode == 200) {
      final data = json.decode(response.body);
      if (data['elements'] != null && (data['elements'] as List).isNotEmpty) {
        final element = data['elements'][0];
        Map<String, dynamic> details = {
          'osm_id': element['id'],
          'osm_type': element['type'],
        };
        if (element['tags'] != null) {
          details.addAll(Map<String, String>.from(element['tags']));
        }
        if (element['type'] == 'node' && element['lat'] != null && element['lon'] != null) {
          details['lat'] = element['lat'];
          details['lon'] = element['lon'];
        }
        return details;
      } else { return {'osm_id': osmId, 'osm_type': osmType, 'message': 'No se encontraron detalles adicionales.'};}
    } else {
      throw Exception('Error de Overpass API (${response.statusCode}): ${response.body}');
    }
  }

  Widget _buildLoadingPoiSheetContent(String displayName) {
    return Container(
      height: 200,
      padding: const EdgeInsets.all(20),
      child: Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const CircularProgressIndicator(),
            const SizedBox(height: 20),
            Text("Cargando detalles de\n$displayName...",
              style: AppTheme.bodyStyle, 
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }

  String _formatTagName(String key) {
    if (key.isEmpty) return '';
    List<String> parts = key.split('_');
    parts = parts.map((part) {
      if (part.isEmpty) return '';
      return part[0].toUpperCase() + part.substring(1);
    }).toList();
    return parts.join(' ');
  }

  void _showPoiDetailsBottomSheet(Map<String, dynamic> poiData) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true, 
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) => _buildPoiSheetContent(poiData),
    );
  }

  Widget _buildPoiSheetContent(Map<String, dynamic> poiData) {
    // Priorizar nombre en español, luego nombre genérico, luego el nombre de la búsqueda
    final name = poiData['name:es'] ?? poiData['name'] ?? poiData['display_name_from_search'] ?? 'Lugar Desconocido';
    
    final tags = Map<String, dynamic>.from(poiData)
      ..remove('osm_id')
      ..remove('osm_type')
      ..remove('lat')
      ..remove('lon')
      ..remove('display_name_from_search')
      ..remove('error') // Ya se maneja
      ..remove('message') // Ya se maneja
      ..remove('name') // Ya se usa para el título
      ..remove('name:es'); // Ya se usa para el título


    List<Widget> detailWidgets = [
      Padding(
        padding: const EdgeInsets.symmetric(vertical: 8.0),
        child: Text(
          name,
          style: AppTheme.titleStyle.copyWith(fontSize: 20, color: AppTheme.primaryColor),
          textAlign: TextAlign.center,
        ),
      ),
      const Divider(height: 10, thickness: 1),
    ];

    if (poiData['error'] != null) {
      detailWidgets.add(
        Padding(
          padding: const EdgeInsets.all(8.0),
          child: Text("Error al cargar detalles: ${poiData['error']}", style: AppTheme.bodyStyle.copyWith(color: Colors.red)),
        )
      );
    } else if (poiData['message'] != null) {
        detailWidgets.add(
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: Text(poiData['message'], style: AppTheme.bodyStyle),
          )
        );
    } else {
      Map<String, String> displayTags = {}; // Clave: nombre de etiqueta formateado, Valor: valor de etiqueta

      // Poblar con etiquetas genéricas primero
      tags.forEach((key, value) {
        if (value != null && value.toString().isNotEmpty && !key.endsWith(':es') && !key.startsWith('name') && !key.startsWith('alt_name') && !key.startsWith('old_name') && !key.startsWith('int_name')) {
          displayTags[_formatTagName(key)] = value.toString();
        }
      });

      // Sobrescribir/Añadir con etiquetas específicas en español si existen y no son nombres alternativos ya cubiertos
      tags.forEach((key, value) {
        if (value != null && value.toString().isNotEmpty && key.endsWith(':es') && !key.startsWith('name:') && !key.startsWith('alt_name:') && !key.startsWith('old_name:') && !key.startsWith('int_name:')) {
          String baseKey = key.substring(0, key.length - 3); // ej. 'description' de 'description:es'
          displayTags[_formatTagName(baseKey)] = value.toString(); // El valor ahora es en español
        }
      });

      if (displayTags.isEmpty) {
        detailWidgets.add(Padding(
          padding: const EdgeInsets.all(8.0),
          child: Text("No hay detalles adicionales disponibles.", style: AppTheme.bodyStyle),
        ));
      } else {
        List<String> sortedDisplayKeys = displayTags.keys.toList()..sort();
        for (String formattedKey in sortedDisplayKeys) {
          String displayValue = displayTags[formattedKey]!;
        detailWidgets.add(
          Padding(
            padding: const EdgeInsets.symmetric(vertical: 6.0, horizontal: 8.0),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('$formattedKey: ', style: AppTheme.bodyStyle.copyWith(fontWeight: FontWeight.bold)),
                Expanded(child: Text(displayValue, style: AppTheme.bodyStyle)),
              ],
            ),
          )
        );
      }
    }
    }
    return DraggableScrollableSheet(
        initialChildSize: 0.4, 
        minChildSize: 0.2, 
        maxChildSize: 0.75,
        expand: false,
        builder: (_, scrollController) {
          return Container(
            padding: const EdgeInsets.only(top: 10, left: 16, right: 16, bottom: 16),
            child: ListView(
              controller: scrollController,
              children: detailWidgets,
            ),
          );
        }
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Mapa Interactivo'), // El estilo se hereda de ThemeData
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: TextField(
              controller: _searchController,
              decoration: AppTheme.getInputDecoration(
                context,
                hintText: 'Buscar lugar...', 
                label: null, // No necesitamos un label flotante aquí
              ).copyWith( // Usamos copyWith para añadir el suffixIcon específico
                suffixIcon: IconButton(
                    icon: _isSearching
                        ? const SizedBox(width: 20, height: 20, child: CircularProgressIndicator(strokeWidth: 2, color: AppTheme.primaryColor))
                        : const Icon(Icons.search, color: AppTheme.primaryColor),
                    onPressed: () => _searchPlace(_searchController.text),
                ),
              ),
              onSubmitted: _searchPlace,
            ),
          ),
          if (_searchResults.isNotEmpty)
            SizedBox(
              height: 150,
              child: ListView.builder(
                itemCount: _searchResults.length,
                itemBuilder: (context, index) {
                  final place = _searchResults[index];
                  return ListTile(
                    title: Text(place['display_name'] ?? 'Lugar desconocido', style: AppTheme.bodyStyle),
                    onTap: () => _goToPlace(place),
                  );
                },
              ),
            ),
          // Mapa
          Expanded(
            child: FlutterMap(
              mapController: _mapController,
              options: MapOptions(
                initialCenter: _currentCenter,
                initialZoom: _currentZoom,
                onTap: (tapPosition, point) {
                  if (_selectedPoiMarker != null) {
                    setState(() {
                      _selectedPoiMarker = null; // Limpiar marcador seleccionado al tocar el mapa
                    });
                  }
                },
              ),
              children: [
                TileLayer(
                  urlTemplate: 'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
                  userAgentPackageName: 'com.example.tripmap',
                  tileProvider: CancellableNetworkTileProvider(), // Use the cancellable tile provider
                ), // Capa de tiles del mapa
                MarkerLayer(markers: [_ifNotNull(_currentLocationMarker), _ifNotNull(_selectedPoiMarker)].where((m) => m != null).cast<Marker>().toList()), // Capa de marcadores
              ],
            ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: _isLoadingLocation ? null : _determinePosition,
        // El color de fondo y del icono se hereda de ThemeData (colorScheme.secondary o primary)
        // Si quieres forzarlo, puedes hacerlo: backgroundColor: AppTheme.primaryColor,
        child: _isLoadingLocation
            ? const SizedBox(
                width: 24,
                height: 24,
                child: CircularProgressIndicator(color: Colors.white))
            : const Icon(Icons.my_location, color: Colors.white),
      ),
    );
  }
  T? _ifNotNull<T>(T? value) => value;
}