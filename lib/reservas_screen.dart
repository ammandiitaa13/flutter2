import 'package:flutter/material.dart';
import 'firestore_service.dart';
import 'package:intl/intl.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'theme.dart';
import 'package:logger/logger.dart';

class ReservasScreen extends StatefulWidget {
  const ReservasScreen({super.key});

  @override
  State<ReservasScreen> createState() => _ReservasScreenState();
}

class _ReservasScreenState extends State<ReservasScreen> {
  final Logger _logger = Logger();

  Stream<List<Map<String, dynamic>>> _getReservas() {
    return FirestoreService.obtenerReservas();
  }

  Future<void> _eliminarReserva(String id) async {
    try {
      await FirestoreService.eliminarReserva(id);
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: const Text('Reserva eliminada con éxito'),
          backgroundColor: AppTheme.primaryColor.withAlpha((255 * 0.8).round()), // Ya corregido
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(10),
          ),
        ),
      );
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Error al eliminar la reserva: $e'),
          backgroundColor: Theme.of(context).colorScheme.error,
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(10),
          ),
        ),
      );
    }
  }

  void _confirmarEliminacion(String id, String titulo) {
    showDialog(
      context: context,
      builder: (context) => Dialog(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(AppTheme.getSpacing(context, desktop: 24, tablet: 20, mobile: 16)),
        ),
        child: Padding(
          padding: EdgeInsets.all(AppTheme.getSpacing(context, desktop: 24, tablet: 20, mobile: 16)),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Icon(
                Icons.warning_amber_rounded,
                color: Colors.amber,
                size: 64,
              ),
              SizedBox(height: AppTheme.getSpacing(context)),
              Text(
                '¿Eliminar reserva?',
                style: AppTheme.subtitleStyle.copyWith(
                  color: AppTheme.primaryColor,
                  fontSize: AppTheme.getFontSize(context, mobile: 20, tablet: 22),
                  fontWeight: FontWeight.bold,
                ),
              ),
              SizedBox(height: AppTheme.getSpacing(context, mobile: 8, tablet: 10)),
              Text(
                'Estás a punto de eliminar "$titulo". Esta acción no se puede deshacer.',
                textAlign: TextAlign.center,
                style: AppTheme.bodyStyle.copyWith(
                  color: AppTheme.secondaryColor,
                ),
              ),
              SizedBox(height: AppTheme.getSpacing(context, mobile: 24, tablet: 28)),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  OutlinedButton(
                    onPressed: () => Navigator.pop(context),
                    style: OutlinedButton.styleFrom(
                      foregroundColor: AppTheme.primaryColor,
                      side: const BorderSide(color: AppTheme.primaryColor),
                      padding: EdgeInsets.symmetric(horizontal: AppTheme.getSpacing(context, mobile: 20), vertical: AppTheme.getSpacing(context, mobile: 12)),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(AppTheme.getSpacing(context, mobile: 12)),
                      ),
                    ),
                    child: const Text('Cancelar'),
                  ),
                  ElevatedButton(
                    onPressed: () {
                      _eliminarReserva(id);
                      Navigator.pop(context);
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Theme.of(context).colorScheme.error,
                      foregroundColor: Colors.white,
                      padding: EdgeInsets.symmetric(horizontal: AppTheme.getSpacing(context, mobile: 20), vertical: AppTheme.getSpacing(context, mobile: 12)),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(AppTheme.getSpacing(context, mobile: 12)),
                      ),
                    ),
                    child: const Text('Eliminar'),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  String _formatearFecha(dynamic fecha) {
    var logger = Logger();
    if (fecha == null) return 'Fecha no disponible';
    
    try {
      if (fecha is Timestamp) {
        return DateFormat('dd/MM/yyyy HH:mm').format(fecha.toDate());
      } else if (fecha is DateTime) {
        return DateFormat('dd/MM/yyyy HH:mm').format(fecha);
      } else if (fecha is String) {
        final parsedDate = DateTime.tryParse(fecha);
        if (parsedDate != null) {
          return DateFormat('dd/MM/yyyy HH:mm').format(parsedDate);
        }
      }
    } catch (e) {
      logger.e('Error formateando fecha: $e');
    }
    
    return 'Fecha no disponible';
  }

  @override
  Widget build(BuildContext context) {
    final isTabletOrLarger = AppTheme.isTablet(context) || AppTheme.isDesktop(context);
    final double horizontalPadding = AppTheme.getSpacing(context, mobile: 16, tablet: 24, desktop: 32);
    final double maxCardWidth = AppTheme.getMaxWidth(context);

    return Scaffold(
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        title: Text(
          'Mis Reservas',
          style: AppTheme.titleStyle.copyWith(color: Colors.white, fontSize: AppTheme.getFontSize(context, mobile: 20, tablet: 22, desktop: 24)),
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
          child: StreamBuilder<List<Map<String, dynamic>>>(
            stream: _getReservas(),
            builder: (context, snapshot) {
              if (snapshot.connectionState == ConnectionState.waiting) {
                return const Center(
                  child: CircularProgressIndicator(
                    color: Colors.white,
                  ),
                );
              }

              if (snapshot.hasError) {
                return Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(Icons.error_outline, size: 64, color: Colors.white.withAlpha((255 * 0.8).round())), // Corregido
                      SizedBox(height: AppTheme.getSpacing(context)), // Espacio vertical
                      Text(
                        'Error al cargar los datos',
                        style: AppTheme.subtitleStyle.copyWith(
                          color: Colors.white.withAlpha((255 * 0.9).round()), // Corregido
                        ),
                      ),
                      SizedBox(height: AppTheme.getSpacing(context, mobile: 8)),
                      Text(
                        '${snapshot.error}',
                        style: AppTheme.bodyStyle.copyWith(
                          color: Colors.white.withAlpha((255 * 0.7).round()), // Corregido
                        ),
                        textAlign: TextAlign.center,
                      ),
                    ],
                  ),
                );
              }

              if (!snapshot.hasData || snapshot.data!.isEmpty) {
                return Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(Icons.search_off, size: 80, color: Colors.white.withAlpha((255 * 0.8).round())), // Corregido
                      SizedBox(height: AppTheme.getSpacing(context)), // Espacio vertical
                      Text(
                        'No tienes reservas',
                        style: AppTheme.subtitleStyle.copyWith(
                          color: Colors.white.withAlpha((255 * 0.9).round()), // Corregido
                        ),
                      ),
                      SizedBox(height: AppTheme.getSpacing(context, mobile: 8)),
                      Text(
                        'Tus futuras reservas aparecerán aquí',
                        style: AppTheme.bodyStyle.copyWith(
                          color: Colors.white.withAlpha((255 * 0.7).round()), // Corregido
                        ),
                      ),
                    ],
                  ),
                );
              }

              final reservas = snapshot.data!;

              return ListView.builder(
                padding: EdgeInsets.symmetric(horizontal: horizontalPadding, vertical: AppTheme.getSpacing(context)),
                itemCount: reservas.length,
                itemBuilder: (context, index) {
                  final reserva = reservas[index];
                  
                  // Las referencias ya están resueltas por el servicio
                  final String tituloReserva = _obtenerTituloReserva(reserva, index);
                  final total = _obtenerTotal(reserva);

                  return Center(
                    child: Container(
                      constraints: BoxConstraints(maxWidth: maxCardWidth),
                      margin: EdgeInsets.only(bottom: AppTheme.getSpacing(context)),
                      child: Card(
                        elevation: 4,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(AppTheme.getSpacing(context, mobile: 16, tablet: 20, desktop: 24)),
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            _buildReservaHeader(tituloReserva, total, reserva['fecha']), // Encabezado de la reserva
                            Divider(color: AppTheme.primaryColor.withAlpha((255 * 0.2).round()), thickness: 1), // Corregido
                            Padding(
                              padding: EdgeInsets.all(AppTheme.getSpacing(context)),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  // Servicios contratados
                                  _buildServiciosContratados(reserva),

                                  SizedBox(height: AppTheme.getSpacing(context)),
                                  
                                  // Información de personas
                                  _buildInfoPersonas(reserva),

                                  SizedBox(height: AppTheme.getSpacing(context, mobile: 24, tablet: 28)),
                                  
                                  // Botones de acción
                                  Row(
                                    mainAxisAlignment: MainAxisAlignment.end,
                                    children: [
                                      ElevatedButton.icon(
                                        onPressed: () => _confirmarEliminacion(reserva['id'], tituloReserva),
                                        icon: const Icon(Icons.delete),
                                        label: const Text('Eliminar'),
                                        style: ElevatedButton.styleFrom(
                                          backgroundColor: Theme.of(context).colorScheme.error,
                                          foregroundColor: Colors.white,
                                          shape: RoundedRectangleBorder(
                                            borderRadius: BorderRadius.circular(AppTheme.getSpacing(context, mobile: 12)),
                                          ),
                                          padding: EdgeInsets.symmetric(horizontal: AppTheme.getSpacing(context, mobile: 16), vertical: AppTheme.getSpacing(context, mobile: 12)),
                                        ),
                                      ),
                                    ],
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  );
                },
              );
            },
          ),
        ),
      ),
    );
  }

  String _obtenerTituloReserva(Map<String, dynamic> reserva, int index) {
    try {
      // Verificar vuelo
      if (reserva['vuelo'] != null && reserva['vuelo'] is Map) {
        final vuelo = reserva['vuelo'] as Map<String, dynamic>;
        if (vuelo['destino'] != null && vuelo['destino'].toString().isNotEmpty) {
          return 'Viaje a ${vuelo['destino']}';
        }
      }
      
      // Verificar hotel
      if (reserva['hotel'] != null && reserva['hotel'] is Map) {
        final hotel = reserva['hotel'] as Map<String, dynamic>;
        if (hotel['nombre'] != null && hotel['nombre'].toString().isNotEmpty) {
          return 'Estancia en ${hotel['nombre']}';
        }
      }
      
      // Verificar actividad
      if (reserva['actividad'] != null && reserva['actividad'] is Map) {
        final actividad = reserva['actividad'] as Map<String, dynamic>;
        if (actividad['nombre'] != null && actividad['nombre'].toString().isNotEmpty) {
          return actividad['nombre'];
        }
      }
      
      // Verificar tren
      if (reserva['tren'] != null && reserva['tren'] is Map) {
        final tren = reserva['tren'] as Map<String, dynamic>;
        if (tren['destino'] != null && tren['destino'].toString().isNotEmpty) {
          return 'Viaje en tren a ${tren['destino']}';
        }
      }
      
      // Verificar coche
      if (reserva['coche'] != null && reserva['coche'] is Map) {
        final coche = reserva['coche'] as Map<String, dynamic>;
        if (coche['modelo'] != null && coche['modelo'].toString().isNotEmpty) {
          return 'Alquiler de ${coche['modelo']}';
        }
      }
    } catch (e) {
      _logger.e('Error obteniendo título de reserva: $e');
    }
    
    return 'Reserva ${index + 1}';
  }

  double _obtenerTotal(Map<String, dynamic> reserva) {
    try {
      final precioTotal = reserva['precio_total'];
      if (precioTotal is num) {
        return precioTotal.toDouble();
      } else if (precioTotal is String) {
        return double.tryParse(precioTotal) ?? 0.0;
      }
    } catch (e) {
      _logger.e('Error obteniendo total: $e');
    }
    return 0.0;
  }

  Widget _buildReservaHeader(String titulo, double total, dynamic fecha) {
    return Container(
      padding: EdgeInsets.all(AppTheme.getSpacing(context)),
      decoration: BoxDecoration(
        color: AppTheme.primaryColor.withAlpha((255 * 0.05).round()), // Corregido
        borderRadius: BorderRadius.only(
          topLeft: Radius.circular(AppTheme.getSpacing(context, mobile: 16, tablet: 20, desktop: 24)),
          topRight: Radius.circular(AppTheme.getSpacing(context, mobile: 16, tablet: 20, desktop: 24)),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Expanded(
                child: Text(
                  titulo,
                  style: AppTheme.subtitleStyle.copyWith(
                    color: AppTheme.primaryColor,
                    fontSize: AppTheme.getFontSize(context, mobile: 20, tablet: 22),
                    fontWeight: FontWeight.bold,
                  ),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
              Container(
                padding: EdgeInsets.symmetric(horizontal: AppTheme.getSpacing(context, mobile: 16), vertical: AppTheme.getSpacing(context, mobile: 8)),
                decoration: BoxDecoration(
                  color: AppTheme.primaryColor, // Color de fondo para el precio
                  borderRadius: BorderRadius.circular(AppTheme.getSpacing(context, mobile: 16)),
                ),
                child: Text(
                  '${total.toStringAsFixed(2)}€',
                  style: AppTheme.bodyStyle.copyWith(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                    fontSize: AppTheme.getFontSize(context, mobile: 16, tablet: 18),
                  ),
                ),
              ),
            ],
          ),
          if (fecha != null)
            Padding(
              padding: EdgeInsets.only(top: AppTheme.getSpacing(context, mobile: 8)),
              child: Row(
                children: [
                  Icon(Icons.calendar_today, size: 16, color: AppTheme.primaryColor.withAlpha((255 * 0.7).round())),
                  SizedBox(width: AppTheme.getSpacing(context, mobile: 8)),
                  Expanded( // Allow text to wrap or take available space
                    child: Text(
                      'Reservado el ${_formatearFecha(fecha)}',
                      style: AppTheme.captionStyle.copyWith(
                        color: AppTheme.primaryColor.withAlpha((255 * 0.9).round()), // Corregido
                        fontSize: AppTheme.getFontSize(context, mobile: 13, tablet: 14),
                      ),
                    ),
                  ),
                ],
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildServiciosContratados(Map<String, dynamic> reserva) {
    List<Widget> servicios = [];
    
    try {
      // Verificar vuelo
      if (reserva['vuelo'] != null && reserva['vuelo'] is Map) {
        final vuelo = reserva['vuelo'] as Map<String, dynamic>;
        if (vuelo.isNotEmpty) {
          servicios.add(_buildServicioCard(
            icon: Icons.flight,
            title: 'Vuelo',
            detail: '${vuelo['origen'] ?? 'N/A'} → ${vuelo['destino'] ?? 'N/A'}',
            company: vuelo['compania']?.toString() ?? 'N/A',
            price: _formatearPrecio(vuelo['precio']),
          ));
        }
      }
      
      // Verificar hotel
      if (reserva['hotel'] != null && reserva['hotel'] is Map) {
        final hotel = reserva['hotel'] as Map<String, dynamic>;
        if (hotel.isNotEmpty) {
          servicios.add(_buildServicioCard(
            icon: Icons.hotel,
            title: 'Alojamiento',
            detail: hotel['nombre']?.toString() ?? 'N/A',
            company: 'Ciudad: ${hotel['ciudad']?.toString() ?? 'N/A'}',
            price: _formatearPrecio(hotel['precio']),
          ));
        }
      }
      
      // Verificar coche
      if (reserva['coche'] != null && reserva['coche'] is Map) {
        final coche = reserva['coche'] as Map<String, dynamic>;
        if (coche.isNotEmpty) {
          servicios.add(_buildServicioCard(
            icon: Icons.directions_car,
            title: 'Alquiler de coche',
            detail: coche['modelo']?.toString() ?? 'N/A',
            company: coche['empresa']?.toString() ?? 'N/A',
            price: _formatearPrecio(coche['precio']),
          ));
        }
      }
      
      // Verificar tren
      if (reserva['tren'] != null && reserva['tren'] is Map) {
        final tren = reserva['tren'] as Map<String, dynamic>;
        if (tren.isNotEmpty) {
          servicios.add(_buildServicioCard(
            icon: Icons.train,
            title: 'Tren',
            detail: '${tren['origen'] ?? 'N/A'} → ${tren['destino'] ?? 'N/A'}',
            company: tren['compania']?.toString() ?? 'N/A',
            price: _formatearPrecio(tren['precio']),
          ));
        }
      }
      
      // Verificar actividad
      if (reserva['actividad'] != null && reserva['actividad'] is Map) {
        final actividad = reserva['actividad'] as Map<String, dynamic>;
        if (actividad.isNotEmpty) {
          servicios.add(_buildServicioCard(
            icon: Icons.attractions,
            title: 'Actividad',
            detail: actividad['nombre']?.toString() ?? 'N/A',
            company: actividad['descripcion']?.toString() ?? 'N/A',
            price: _formatearPrecio(actividad['precio']),
          ));
        }
      }
    } catch (e) {
      _logger.e('Error construyendo servicios: $e');
    }
    
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Servicios contratados',
          style: AppTheme.subtitleStyle.copyWith(
            color: AppTheme.primaryColor,
            fontSize: AppTheme.getFontSize(context, mobile: 18),
            fontWeight: FontWeight.bold,
          ),
        ),
        SizedBox(height: AppTheme.getSpacing(context, mobile: 12)),
        if (servicios.isEmpty)
          Container(
            padding: EdgeInsets.all(AppTheme.getSpacing(context)),
            decoration: BoxDecoration(
              color: Theme.of(context).colorScheme.surfaceContainerHighest, // Usando un color del tema para el fondo de advertencia
              borderRadius: BorderRadius.circular(AppTheme.getSpacing(context, mobile: 12)),
              border: Border.all(color: Theme.of(context).colorScheme.outlineVariant),
            ),
            child: Row(
              children: [
                Icon(Icons.warning_amber_rounded, color: Colors.amber), // Using a consistent warning icon color
                SizedBox(width: AppTheme.getSpacing(context, mobile: 12)),
                Expanded( // Permite que el texto de advertencia se ajuste
                  child: Text(
                    'No se pudieron cargar los servicios contratados',
                    style: AppTheme.bodyStyle.copyWith(
                      color: Theme.of(context).colorScheme.onSurfaceVariant, // Usando un color del tema para el texto de advertencia
                      fontWeight: FontWeight.w500, // Peso de fuente
                    ),
                  ),
                ),
              ],
            ),
          )
        else
          ...servicios,
      ],
    );
  }

  String _formatearPrecio(dynamic precio) {
    try {
      if (precio is num) {
        return precio.toStringAsFixed(2);
      } else if (precio is String) {
        final parsed = double.tryParse(precio);
        if (parsed != null) {
          return parsed.toStringAsFixed(2);
        }
      }
    } catch (e) {
      _logger.e('Error formateando precio: $e');
    }
    return '0.00';
  }

  Widget _buildServicioCard({
    required IconData icon,
    required String title,
    required String detail,
    required String company,
    required String price,
  }) {
    return Container(
      margin: EdgeInsets.only(bottom: AppTheme.getSpacing(context, mobile: 12)),
      padding: EdgeInsets.all(AppTheme.getSpacing(context)),
      decoration: BoxDecoration(
        color: AppTheme.cardColor, // Color de fondo de la tarjeta
        borderRadius: BorderRadius.circular(AppTheme.getSpacing(context, mobile: 16)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withAlpha((255 * 0.05).round()), // Corregido
            blurRadius: 4, // Consistent with AppTheme.boxDecoration
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: EdgeInsets.all(AppTheme.getSpacing(context, mobile: 10)),
            decoration: BoxDecoration( // Decoración del icono del servicio
              color: AppTheme.primaryColor.withAlpha((255 * 0.1).round()), // Corregido
              borderRadius: BorderRadius.circular(AppTheme.getSpacing(context, mobile: 12)),
            ),
            child: Icon(
              icon,
              color: AppTheme.primaryColor,
              size: 24,
            ),
          ),
          SizedBox(width: AppTheme.getSpacing(context)),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: AppTheme.bodyStyle.copyWith(
                    fontWeight: FontWeight.bold,
                    color: AppTheme.primaryColor,
                    fontSize: AppTheme.getFontSize(context, mobile: 16)
                  ),
                ),
                SizedBox(height: AppTheme.getSpacing(context, mobile: 4)),
                Text(
                  detail,
                  style: AppTheme.bodyStyle.copyWith(fontSize: AppTheme.getFontSize(context, mobile: 15)),
                ),
                Text(
                  company,
                  style: AppTheme.captionStyle.copyWith(
                    color: AppTheme.secondaryColor,
                     fontSize: AppTheme.getFontSize(context, mobile: 14)
                  ),
                ),
              ],
            ),
          ),
          Container(
            padding: EdgeInsets.symmetric(horizontal: AppTheme.getSpacing(context, mobile: 12), vertical: AppTheme.getSpacing(context, mobile: 6)),
            decoration: BoxDecoration(
              color: Colors.green.shade50, // Manteniendo color específico para indicación de precio
              borderRadius: BorderRadius.circular(AppTheme.getSpacing(context, mobile: 12)),
              border: Border.all(color: Colors.green.shade200),
            ),
            child: Text(
              '$price€',
              style: TextStyle(
                fontWeight: FontWeight.bold,
                color: Colors.green.shade800,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildInfoPersonas(Map<String, dynamic> reserva) {
    try {
      final usuarios = reserva['usuarios'];
      
      if (usuarios == null || (usuarios is List && usuarios.isEmpty)) {
        return Container();
      }
      
      List<dynamic> listaUsuarios = [];
      if (usuarios is List) {
        listaUsuarios = usuarios;
      }
      
      if (listaUsuarios.isEmpty) {
        return Container();
      }
      
      return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Pasajeros',
            style: AppTheme.subtitleStyle.copyWith(
              color: AppTheme.primaryColor,
              fontSize: AppTheme.getFontSize(context, mobile: 18),
              fontWeight: FontWeight.bold,
            ),
          ),
          SizedBox(height: AppTheme.getSpacing(context, mobile: 12)),
          Container(
            padding: EdgeInsets.all(AppTheme.getSpacing(context)),
            decoration: BoxDecoration(
              color: AppTheme.cardColor, // Color de fondo de la tarjeta de pasajeros
              borderRadius: BorderRadius.circular(AppTheme.getSpacing(context, mobile: 16)),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withAlpha((255 * 0.05).round()), // Corregido
                  blurRadius: 4,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
            child: Column(
              children: listaUsuarios.map<Widget>((usuario) {
                if (usuario is! Map) return Container();
                
                final usuarioMap = usuario as Map<String, dynamic>;
                
                return Padding(
                  padding: EdgeInsets.only(bottom: AppTheme.getSpacing(context, mobile: 8)),
                  child: Row(
                    children: [
                      Container(
                        padding: EdgeInsets.all(AppTheme.getSpacing(context, mobile: 8)),
                        decoration: BoxDecoration(
                          color: AppTheme.primaryColor.withAlpha((255 * 0.1).round()), // Corregido
                          shape: BoxShape.circle,
                        ), // Decoración del icono de pasajero
                        child: Icon(
                          Icons.person,
                          size: 20,
                          color: AppTheme.primaryColor.withAlpha((255 * 0.7).round()), // Corregido
                        ),
                      ),
                      SizedBox(width: AppTheme.getSpacing(context, mobile: 12)),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              '${usuarioMap['nombre'] ?? 'N/A'} ${usuarioMap['apellidos'] ?? ''}',
                              style: AppTheme.bodyStyle.copyWith(
                                fontWeight: FontWeight.w500,
                                fontSize: AppTheme.getFontSize(context, mobile: 16),
                              ),
                            ), // Nombre completo del pasajero
                            Row(
                              children: [
                                Flexible( // Allow DNI to take available space
                                  child: Text(
                                    'DNI: ${usuarioMap['dni'] ?? 'N/A'}',
                                    style: AppTheme.captionStyle.copyWith(
                                      color: AppTheme.secondaryColor,
                                      fontSize: AppTheme.getFontSize(context, mobile: 14),
                                    ),
                                    overflow: TextOverflow.ellipsis, // Add overflow handling
                                  ), // DNI del pasajero
                                ),
                                if (usuarioMap['edad'] != null) ...[
                                  Text(
                                    ' • ',
                                    style: AppTheme.captionStyle.copyWith(
                                      color: AppTheme.secondaryColor,
                                      fontSize: AppTheme.getFontSize(context, mobile: 14),
                                    ),
                                  ),
                                  Flexible( // Allow Edad to take available space
                                    child: Text(
                                      'Edad: ${usuarioMap['edad']}',
                                      style: AppTheme.captionStyle.copyWith(
                                        color: AppTheme.secondaryColor,
                                        fontSize: AppTheme.getFontSize(context, mobile: 14),
                                      ),
                                      overflow: TextOverflow.ellipsis, // Add overflow handling
                                    ), // Edad del pasajero
                                  ),
                                ],
                              ],
                            ),
                            if (usuarioMap['email'] != null && usuarioMap['email'].toString().isNotEmpty)
                              Row(
                                children: [
                                  Icon(
                                    Icons.email,
                                    size: 14,
                                    color: AppTheme.secondaryColor,
                                  ),
                                  SizedBox(width: AppTheme.getSpacing(context, mobile: 4)),
                                  Expanded( // Allow email to take available space
                                    child: Text(
                                      usuarioMap['email'].toString(),
                                      style: AppTheme.captionStyle.copyWith(
                                        color: AppTheme.secondaryColor,
                                        fontSize: AppTheme.getFontSize(context, mobile: 14),
                                      ),
                                      overflow: TextOverflow.ellipsis, // Add overflow handling
                                  ), // Email del pasajero
                                  ),
                                ],
                              ),
                          ],
                        ),
                      ),
                    ],
                  ),
                );
              }).toList(),
            ),
          ),
        ],
      );
    } catch (e) {
      _logger.e('Error construyendo info de personas: $e');
      return Container();
    }
  }
}