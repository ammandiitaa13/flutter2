import 'package:flutter/material.dart';
import 'package:responsive_framework/responsive_framework.dart';
import 'firestore_service.dart';
import 'package:intl/intl.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class ReservasScreen extends StatefulWidget {
  const ReservasScreen({super.key});

  @override
  State<ReservasScreen> createState() => _ReservasScreenState();
}

class _ReservasScreenState extends State<ReservasScreen> {
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
          backgroundColor: Colors.deepPurple.shade300,
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
          backgroundColor: Colors.red.shade400,
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
          borderRadius: BorderRadius.circular(24),
        ),
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Icon(
                Icons.warning_amber_rounded,
                color: Colors.amber,
                size: 64,
              ),
              const SizedBox(height: 16),
              Text(
                '¿Eliminar reserva?',
                style: TextStyle(
                  fontSize: 22,
                  fontWeight: FontWeight.bold,
                  color: Colors.deepPurple.shade700,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                'Estás a punto de eliminar "$titulo". Esta acción no se puede deshacer.',
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 16,
                  color: Colors.grey.shade700,
                ),
              ),
              const SizedBox(height: 24),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  OutlinedButton(
                    onPressed: () => Navigator.pop(context),
                    style: OutlinedButton.styleFrom(
                      foregroundColor: Colors.deepPurple,
                      side: const BorderSide(color: Colors.deepPurple),
                      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
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
                      backgroundColor: Colors.red,
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
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

  String _formatearFecha(Timestamp timestamp) {
    return DateFormat('dd/MM/yyyy HH:mm').format(timestamp.toDate());
  }

  @override
  Widget build(BuildContext context) {
    final isTabletOrLarger = ResponsiveBreakpoints.of(context).largerThan(MOBILE);
    final double horizontalPadding = isTabletOrLarger ? 24 : 16;
    final double maxCardWidth = isTabletOrLarger ? 800 : double.infinity;

    return Scaffold(
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        title: const Text(
          'Mis Reservas',
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
                      Icon(Icons.error_outline, size: 64, color: Colors.white.withOpacity(0.8)),
                      const SizedBox(height: 16),
                      Text(
                        'Error al cargar los datos',
                        style: TextStyle(
                          fontSize: 20,
                          color: Colors.white.withOpacity(0.9),
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        '${snapshot.error}',
                        style: TextStyle(
                          fontSize: 16,
                          color: Colors.white.withOpacity(0.7),
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
                      Icon(Icons.search_off, size: 80, color: Colors.white.withOpacity(0.8)),
                      const SizedBox(height: 16),
                      Text(
                        'No tienes reservas',
                        style: TextStyle(
                          fontSize: 22,
                          color: Colors.white.withOpacity(0.9),
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        'Tus futuras reservas aparecerán aquí',
                        style: TextStyle(
                          fontSize: 16,
                          color: Colors.white.withOpacity(0.7),
                        ),
                      ),
                    ],
                  ),
                );
              }

              final reservas = snapshot.data!;

              return ListView.builder(
                padding: EdgeInsets.symmetric(horizontal: horizontalPadding, vertical: 16),
                itemCount: reservas.length,
                itemBuilder: (context, index) {
                  final reserva = reservas[index];
                  final String tituloReserva = _obtenerTituloReserva(reserva, index);
                  final total = reserva['precio_total'] ?? 0;

                  return Center(
                    child: Container(
                      constraints: BoxConstraints(maxWidth: maxCardWidth),
                      margin: const EdgeInsets.only(bottom: 16),
                      child: Card(
                        elevation: 4,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(24),
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            _buildReservaHeader(tituloReserva, total, reserva['fecha']),
                            Divider(color: Colors.deepPurple.withOpacity(0.2), thickness: 1),
                            Padding(
                              padding: const EdgeInsets.all(16),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  // Servicios contratados
                                  _buildServiciosContratados(reserva),

                                  const SizedBox(height: 16),
                                  
                                  // Información de personas
                                  _buildInfoPersonas(reserva),

                                  const SizedBox(height: 24),
                                  
                                  // Botones de acción
                                  Row(
                                    mainAxisAlignment: MainAxisAlignment.end,
                                    children: [
                                      ElevatedButton.icon(
                                        onPressed: () => _confirmarEliminacion(reserva['id'], tituloReserva),
                                        icon: const Icon(Icons.delete),
                                        label: const Text('Eliminar'),
                                        style: ElevatedButton.styleFrom(
                                          backgroundColor: Colors.red,
                                          foregroundColor: Colors.white,
                                          shape: RoundedRectangleBorder(
                                            borderRadius: BorderRadius.circular(12),
                                          ),
                                          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
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
    if (reserva['vuelo'] != null) {
      return 'Viaje a ${reserva['vuelo']['destino']}';
    } else if (reserva['hotel'] != null) {
      return 'Estancia en ${reserva['hotel']['nombre']}';
    } else if (reserva['actividad'] != null) {
      return reserva['actividad']['nombre'];
    } else if (reserva['tren'] != null) {
      return 'Viaje en tren a ${reserva['tren']['destino']}';
    } else if (reserva['coche'] != null) {
      return 'Alquiler de ${reserva['coche']['modelo']}';
    } else {
      return 'Reserva ${index + 1}';
    }
  }

  Widget _buildReservaHeader(String titulo, dynamic total, Timestamp? fecha) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.deepPurple.shade50,
        borderRadius: const BorderRadius.only(
          topLeft: Radius.circular(24),
          topRight: Radius.circular(24),
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
                  style: TextStyle(
                    fontSize: 22,
                    fontWeight: FontWeight.bold,
                    color: Colors.deepPurple.shade800,
                  ),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                decoration: BoxDecoration(
                  color: Colors.deepPurple.shade700,
                  borderRadius: BorderRadius.circular(16),
                ),
                child: Text(
                  '$total€',
                  style: const TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                    fontSize: 18,
                  ),
                ),
              ),
            ],
          ),
          if (fecha != null)
            Padding(
              padding: const EdgeInsets.only(top: 8),
              child: Row(
                children: [
                  Icon(Icons.calendar_today, size: 16, color: Colors.deepPurple.shade400),
                  const SizedBox(width: 8),
                  Text(
                    'Reservado el ${_formatearFecha(fecha)}',
                    style: TextStyle(
                      color: Colors.deepPurple.shade600,
                      fontSize: 14,
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
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Servicios contratados',
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
            color: Colors.deepPurple.shade700,
          ),
        ),
        const SizedBox(height: 12),
        if (reserva['vuelo'] != null)
          _buildServicioCard(
            icon: Icons.flight,
            title: 'Vuelo',
            detail: '${reserva['vuelo']['origen']} → ${reserva['vuelo']['destino']}',
            company: reserva['vuelo']['compania'],
            price: reserva['vuelo']['precio'],
          ),
        if (reserva['hotel'] != null)
          _buildServicioCard(
            icon: Icons.hotel,
            title: 'Alojamiento',
            detail: reserva['hotel']['nombre'],
            company: 'Ciudad: ${reserva['hotel']['ciudad']}',
            price: reserva['hotel']['precio'],
          ),
        if (reserva['coche'] != null)
          _buildServicioCard(
            icon: Icons.directions_car,
            title: 'Alquiler de coche',
            detail: reserva['coche']['modelo'],
            company: reserva['coche']['empresa'],
            price: reserva['coche']['precio'],
          ),
        if (reserva['tren'] != null)
          _buildServicioCard(
            icon: Icons.train,
            title: 'Tren',
            detail: '${reserva['tren']['origen']} → ${reserva['tren']['destino']}',
            company: reserva['tren']['compania'],
            price: reserva['tren']['precio'],
          ),
        if (reserva['actividad'] != null)
          _buildServicioCard(
            icon: Icons.attractions,
            title: 'Actividad',
            detail: reserva['actividad']['nombre'],
            company: reserva['actividad']['descripcion'] ?? '',
            price: reserva['actividad']['precio'],
          ),
      ],
    );
  }

  Widget _buildServicioCard({
    required IconData icon,
    required String title,
    required String detail,
    required String company,
    required dynamic price,
  }) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 5,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: Colors.deepPurple.shade50,
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(
              icon,
              color: Colors.deepPurple,
              size: 24,
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: Colors.deepPurple.shade800,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  detail,
                  style: const TextStyle(fontSize: 15),
                ),
                Text(
                  company,
                  style: TextStyle(
                    fontSize: 14,
                    color: Colors.grey.shade700,
                  ),
                ),
              ],
            ),
          ),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
            decoration: BoxDecoration(
              color: Colors.green.shade50,
              borderRadius: BorderRadius.circular(12),
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
    final usuarios = reserva['usuarios'] as List?;
    
    if (usuarios == null || usuarios.isEmpty) {
      return Container();
    }
    
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Pasajeros',
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
            color: Colors.deepPurple.shade700,
          ),
        ),
        const SizedBox(height: 12),
        Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(16),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.05),
                blurRadius: 5,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          child: Column(
            children: usuarios.map<Widget>((usuario) {
              return Padding(
                padding: const EdgeInsets.only(bottom: 8),
                child: Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        color: Colors.deepPurple.shade50,
                        shape: BoxShape.circle,
                      ),
                      child: Icon(
                        Icons.person,
                        size: 20,
                        color: Colors.deepPurple.shade400,
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            '${usuario['nombre']} ${usuario['apellidos']}',
                            style: const TextStyle(
                              fontWeight: FontWeight.w500,
                              fontSize: 16,
                            ),
                          ),
                          Row(
                            children: [
                              Text(
                                'DNI: ${usuario['dni']}',
                                style: TextStyle(
                                  color: Colors.grey.shade700,
                                  fontSize: 14,
                                ),
                              ),
                              if (usuario['edad'] != null) ...[
                                Text(
                                  ' • ',
                                  style: TextStyle(
                                    color: Colors.grey.shade700,
                                    fontSize: 14,
                                  ),
                                ),
                                Text(
                                  'Edad: ${usuario['edad']}',
                                  style: TextStyle(
                                    color: Colors.grey.shade700,
                                    fontSize: 14,
                                  ),
                                ),
                              ],
                            ],
                          ),
                          if (usuario['email'] != null)
                            Row(
                              children: [
                                Icon(
                                  Icons.email,
                                  size: 14,
                                  color: Colors.grey.shade600,
                                ),
                                const SizedBox(width: 4),
                                Text(
                                  usuario['email'],
                                  style: TextStyle(
                                    color: Colors.grey.shade600,
                                    fontSize: 14,
                                  ),
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
  }
}