import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'firestore_service.dart';
import 'reserva_form_screen.dart';
import 'package:logger/logger.dart';
import 'package:responsive_framework/responsive_framework.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final Logger _logger = Logger();
  final TextEditingController origenController = TextEditingController();
  final TextEditingController destinoController = TextEditingController();
  final TextEditingController numPersonasController = TextEditingController();
  DateTime? fechaSeleccionada;
  bool _isLoading = false;

  Future<void> _seleccionarFecha(BuildContext context) async {
    final DateTime? fecha = await showDatePicker(
      context: context,
      initialDate: fechaSeleccionada ?? DateTime.now(),
      firstDate: DateTime.now(),
      lastDate: DateTime(2035),
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: const ColorScheme.light(
              primary: Colors.deepPurple,
              onPrimary: Colors.white,
              onSurface: Colors.black,
            ),
            textButtonTheme: TextButtonThemeData(
              style: TextButton.styleFrom(
                foregroundColor: Colors.deepPurple,
              ),
            ),
          ),
          child: child!,
        );
      },
    );
    if (fecha != null) {
      setState(() {
        fechaSeleccionada = fecha;
      });
    }
  }

  Future<void> _buscarDisponibilidad() async {
    final origen = origenController.text.trim();
    final destino = destinoController.text.trim();
    final numPersonas = int.tryParse(numPersonasController.text.trim()) ?? 1;

    if (origen.isEmpty || destino.isEmpty || fechaSeleccionada == null || numPersonas <= 0) {
      _mostrarMensaje('Por favor, completa todos los campos.');
      return;
    }

    try {
      setState(() {
        _isLoading = true;
      });

      final vuelos = await FirestoreService.obtenerVuelosDisponibles(
        origen: origen,
        destino: destino,
        fecha: fechaSeleccionada!,
        numPersonas: numPersonas,
      );

      final hoteles = await FirestoreService.obtenerHotelesDisponibles(
        ciudad: destino,
        fecha: fechaSeleccionada!,
        numPersonas: numPersonas,
      );

      final coches = await FirestoreService.obtenerCochesDisponibles(
        origen: origen,
        destino: destino,
        fecha: fechaSeleccionada!,
        numPersonas: numPersonas,
      );

      final trenes = await FirestoreService.obtenerTrenesDisponibles(
        origen: origen,
        destino: destino,
        fecha: fechaSeleccionada!,
        numPersonas: numPersonas,
      );

      final actividades = await FirestoreService.obtenerActividadesDisponibles(
        ciudad: destino,
        fecha: fechaSeleccionada!,
        numPersonas: numPersonas,
      );

      setState(() {
        _isLoading = false;
      });

      if ([vuelos, hoteles, coches, trenes, actividades].every((list) => list.isEmpty)) {
        _mostrarMensaje('No se encontraron opciones disponibles.');
        return;
      }

      if (!mounted) return;
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (_) => ReservaFormScreen(
            vuelosDisponibles: vuelos,
            hotelesDisponibles: hoteles,
            cochesDisponibles: coches,
            trenesDisponibles: trenes,
            actividadesDisponibles: actividades,
          ),
        ),
      );
    } catch (e) {
      setState(() {
        _isLoading = false;
      });
      _logger.e("Error al buscar disponibilidad", error: e);
      _mostrarMensaje('Error: $e');
    }
  }

  void _mostrarMensaje(String mensaje) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(mensaje),
        backgroundColor: Colors.deepPurple.shade300,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(10),
        ),
      ),
    );
  }

  InputDecoration _inputDecoration(String label, IconData icon) {
    return InputDecoration(
      prefixIcon: Icon(icon, color: Colors.deepPurple),
      labelText: label,
      labelStyle: const TextStyle(color: Colors.deepPurple),
      filled: true,
      fillColor: Colors.white,
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(16),
        borderSide: BorderSide(color: Colors.deepPurple.shade200),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(16),
        borderSide: const BorderSide(color: Colors.deepPurple, width: 2),
      ),
      errorBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(16),
        borderSide: const BorderSide(color: Colors.red, width: 1),
      ),
      focusedErrorBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(16),
        borderSide: const BorderSide(color: Colors.red, width: 2),
      ),
    );
  }

  Widget _formField({
    required String label,
    required IconData icon,
    TextEditingController? controller,
    TextInputType? inputType,
    VoidCallback? onTap,
    String? value,
    bool readOnly = false,
  }) {
    final height = MediaQuery.of(context).size.height * 0.075;
    final bottomMargin = MediaQuery.of(context).size.height * 0.02;
  
    return Container(
      height: height,
      margin: EdgeInsets.only(bottom: bottomMargin),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: TextField(
        controller: controller,
        keyboardType: inputType,
        readOnly: readOnly,
        onTap: onTap,
        style: TextStyle(fontSize: MediaQuery.of(context).size.width * 0.04),
        decoration: _inputDecoration(label, icon).copyWith(
          hintText: value,
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final formatter = DateFormat('dd/MM/yyyy');
    final isTablet = ResponsiveBreakpoints.of(context).isTablet;
    final screenSize = MediaQuery.of(context).size;
    final titleSize = screenSize.width * 0.05;
    final subtitleSize = screenSize.width * 0.04;
    final buttonPadding = screenSize.height * 0.015;

    return Scaffold(
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        title: FittedBox (
          fit: BoxFit.scaleDown,
          child: Text ('Planifica tu viaje',
          style: TextStyle(
            fontWeight: FontWeight.bold,
            color: Colors.white,
            fontSize: titleSize,
          ),
        ),
        ), 
        backgroundColor: Colors.transparent,
        elevation: 0,
        centerTitle: true,
      ),
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            colors: [Color.fromARGB(255, 214, 190, 231), Color.fromARGB(255, 148, 111, 205)],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
        ),
        child: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(24),
            child: ConstrainedBox(
              constraints: BoxConstraints(
                maxWidth: isTablet ? 600 : screenSize.width,
              ),
              child: Card(
                elevation: 10,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
                child: Padding(
                  padding: const EdgeInsets.all(24),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      const Icon(
                        Icons.public,
                        size: 60,
                        color: Colors.deepPurple,
                      ),
                      const SizedBox(height: 16),
                      const Text(
                        '¿A dónde quieres ir?',
                        style: TextStyle(
                          fontSize: 24,
                          fontWeight: FontWeight.bold,
                          color: Colors.deepPurple,
                        ),
                      ),
                      const SizedBox(height: 32),
                      _formField(
                        label: 'Origen',
                        icon: Icons.place,
                        controller: origenController,
                      ),
                      _formField(
                        label: 'Destino',
                        icon: Icons.explore,
                        controller: destinoController,
                      ),
                      _formField(
                        label: 'Número de personas',
                        icon: Icons.people,
                        controller: numPersonasController,
                        inputType: TextInputType.number,
                      ),
                      _formField(
                        label: 'Fecha de viaje',
                        icon: Icons.calendar_today,
                        readOnly: true,
                        onTap: () => _seleccionarFecha(context),
                        value: fechaSeleccionada != null
                            ? formatter.format(fechaSeleccionada!)
                            : 'Seleccionar fecha',
                      ),
                      const SizedBox(height: 8),
                      AnimatedContainer(
                        duration: const Duration(milliseconds: 300),
                        width: isTablet ? 300 : double.infinity,
                        height: 55,
                        child: ElevatedButton(
                          onPressed: _isLoading ? null : _buscarDisponibilidad,
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.deepPurple,
                            foregroundColor: Colors.white,
                            disabledBackgroundColor: Colors.grey.shade400,
                            elevation: 5,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(16),
                            ),
                            textStyle: const TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          child: _isLoading
                              ? const SizedBox(
                                  height: 24,
                                  width: 24,
                                  child: CircularProgressIndicator(
                                    color: Colors.white,
                                    strokeWidth: 2,
                                  ),
                                )
                              : const Text('Buscar disponibilidad'),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}