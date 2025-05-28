import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'firestore_service.dart';
import 'reserva_form_screen.dart';
import 'package:logger/logger.dart';
import 'theme.dart';

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
            colorScheme: ColorScheme.light(
              primary: AppTheme.primaryColor,
              onPrimary: Colors.white,
              onSurface: AppTheme.textColor,
            ),
            textButtonTheme: TextButtonThemeData(
              style: TextButton.styleFrom(
                foregroundColor: AppTheme.primaryColor,
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
        backgroundColor: AppTheme.primaryColor.withAlpha((255 * 0.8).round()), // Ya corregido
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(10),
        ),
      ),
    );
  }

  Widget _buildFormField({
    required String label,
    required IconData icon,
    required TextEditingController controller,
    TextInputType? inputType,
    VoidCallback? onTap,
    String? value,
    bool readOnly = false,
  }) {
    return Container(
      margin: EdgeInsets.only(bottom: AppTheme.getSpacing(context, mobile: 16, tablet: 20, desktop: 24)),
      child: TextField(
        controller: controller,
        keyboardType: inputType,
        readOnly: readOnly,
        onTap: onTap,
        style: TextStyle(
          fontSize: AppTheme.getFontSize(context, mobile: 16, tablet: 18, desktop: 20),
        ),
        decoration: AppTheme.getInputDecoration(
          context,
          label: Text(label), // Usar Text widget para el label
          hintText: value ?? (readOnly ? controller.text : null), // Mostrar valor si es readOnly y no hay hint específico
        ).copyWith(
          prefixIcon: Icon(icon, color: AppTheme.primaryColor),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    // Inicializar el controlador para el campo de fecha si es necesario
    // Esto es para que _buildFormField pueda tener un controller no nulo.
    final TextEditingController fechaController = TextEditingController(text: fechaSeleccionada != null ? DateFormat('dd/MM/yyyy').format(fechaSeleccionada!) : 'Seleccionar fecha');

    final formatter = DateFormat('dd/MM/yyyy');
    final titleSize = AppTheme.getFontSize(context, mobile: 22, tablet: 26, desktop: 30);
    final subtitleSize = AppTheme.getFontSize(context, mobile: 20, tablet: 24, desktop: 28);

    return Scaffold(
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        title: FittedBox(
          fit: BoxFit.scaleDown,
          child: Text(
            'Planifica tu viaje',
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
        child: SafeArea(
          child: AppTheme.centerContent(
            context: context,
            child: SingleChildScrollView(
              padding: AppTheme.getPadding(context),
              child: Card(
                elevation: 10,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(24),
                ),
                child: Container(
                  padding: AppTheme.getPadding(context),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      Icon(
            Icons.public, // Icono para la sección principal
                        size: AppTheme.isDesktop(context) ? 80 : AppTheme.isTablet(context) ? 70 : 60,
                        color: AppTheme.primaryColor,
                      ),
                      SizedBox(height: AppTheme.getSpacing(context, mobile: 16, tablet: 20, desktop: 24)),
                      Text(
                        '¿A dónde quieres ir?',
                        style: TextStyle(
                          fontSize: subtitleSize,
                          fontWeight: FontWeight.bold,
                          color: AppTheme.primaryColor,
                        ),
                      ),
                      SizedBox(height: AppTheme.getSpacing(context, mobile: 24, tablet: 32, desktop: 40)),
                      _buildFormField(
                        label: 'Origen',
                        icon: Icons.place,
                        controller: origenController,
                      ),
                      _buildFormField(
                        label: 'Destino',
                        icon: Icons.explore,
                        controller: destinoController,
                      ),
                      _buildFormField(
                        label: 'Número de personas',
                        icon: Icons.people,
                        controller: numPersonasController,
                        inputType: TextInputType.number,
                      ),
                      _buildFormField(
                        label: 'Fecha de viaje',
                        icon: Icons.calendar_today,
                        readOnly: true,
                        controller: fechaController, // Pasar el controlador
                        onTap: () => _seleccionarFecha(context),
                      ),
                      SizedBox(height: AppTheme.getSpacing(context, mobile: 16, tablet: 20, desktop: 24)),
                      AnimatedContainer(
                        duration: const Duration(milliseconds: 300),
                        width: AppTheme.isDesktop(context) ? 400 : double.infinity,
                        height: AppTheme.isDesktop(context) ? 60 : 55,
                        child: ElevatedButton(
                          onPressed: _isLoading ? null : _buscarDisponibilidad,
                          style: AppTheme.getButtonStyle(context).copyWith(
                            backgroundColor: WidgetStateProperty.resolveWith((states) {
                              if (states.contains(WidgetState.disabled)) {
                                return Colors.grey.shade400;
                              }
                              return AppTheme.primaryColor;
                            }),
                            elevation: WidgetStateProperty.all(5),
                            shape: WidgetStateProperty.all(
                              RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(16),
                              ),
                            ),
                          ),
                          child: _isLoading
                              ? SizedBox(
                                  height: 24,
                                  width: 24,
                                  child: CircularProgressIndicator(
                                    color: Colors.white,
                                    strokeWidth: 2,
                                  ),
                                )
                              : FittedBox( // Asegura que el texto quepa en el botón
                                  fit: BoxFit.scaleDown,
                                  child: Text(
                                    'Buscar disponibilidad',
                                    style: TextStyle(
                                      fontSize: AppTheme.getFontSize(context, mobile: 16, tablet: 18, desktop: 20),
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                ),
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