import 'package:flutter/material.dart';
import 'firestore_service.dart';
import 'theme.dart';

class ReservaFormScreen extends StatefulWidget {
  final List<Map<String, dynamic>> vuelosDisponibles;
  final List<Map<String, dynamic>> hotelesDisponibles;
  final List<Map<String, dynamic>> cochesDisponibles;
  final List<Map<String, dynamic>> trenesDisponibles;
  final List<Map<String, dynamic>> actividadesDisponibles;

  const ReservaFormScreen({
    super.key,
    required this.vuelosDisponibles,
    required this.hotelesDisponibles,
    required this.cochesDisponibles,
    required this.trenesDisponibles,
    required this.actividadesDisponibles,
  });

  @override
  State<ReservaFormScreen> createState() => _ReservaFormScreenState();
}

class _ReservaFormScreenState extends State<ReservaFormScreen> with SingleTickerProviderStateMixin {
  Map<String, dynamic>? vueloSeleccionado;
  Map<String, dynamic>? hotelSeleccionado;
  Map<String, dynamic>? cocheSeleccionado;
  Map<String, dynamic>? trenSeleccionado;
  Map<String, dynamic>? actividadSeleccionada;

  int numPersonas = 1;
  bool _isLoading = false;
  final List<Map<String, TextEditingController>> usuariosControllers = [];
  late TabController _tabController;
  int _activeTab = 0;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(
      length: 5,
      vsync: this,
    );
    _tabController.addListener(() {
      setState(() {
        _activeTab = _tabController.index;
      });
    });
  }

  @override
  void dispose() {
    _tabController.dispose();
    // Dispose all existing controllers in the list
    for (final controllerMap in usuariosControllers) {
      for (final controller in controllerMap.values) {
        controller.dispose();
      }
    }
    super.dispose();
  }

  void _confirmarReserva() {
    if (vueloSeleccionado == null &&
        hotelSeleccionado == null &&
        cocheSeleccionado == null &&
        trenSeleccionado == null &&
        actividadSeleccionada == null) {
      _mostrarMensaje('Selecciona al menos un servicio.');
      return;
    }

    _mostrarFormularioUsuarios();
  }

  void _mostrarMensaje(String mensaje) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(mensaje),
        backgroundColor: AppTheme.primaryColor.withAlpha((255 * 0.8).round()), // Ya corregido
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(AppTheme.getSpacing(context, mobile: 10)),
        ),
      ),
    );
  }

  void _mostrarFormularioUsuarios() {
    for (final controllerMap in usuariosControllers) {
      for (final controller in controllerMap.values) {
        controller.dispose();
      }
    }
    usuariosControllers.clear();
    for (int i = 0; i < numPersonas; i++) {
      usuariosControllers.add({
        'nombre': TextEditingController(),
        'apellidos': TextEditingController(),
        'dni': TextEditingController(),
        'edad': TextEditingController(),
        'email': TextEditingController(),
      });
    }

    showDialog(
      context: context,
      builder: (context) {
        return Dialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(AppTheme.getSpacing(context, mobile: 16, tablet: 20, desktop: 24)),
          ),
          child: StatefulBuilder(
            builder: (context, setStateDialog) {
              return Container(
                padding: EdgeInsets.all(AppTheme.getSpacing(context, mobile: 16, tablet: 20, desktop: 24)),
                width: double.maxFinite,
                constraints: BoxConstraints(maxWidth: AppTheme.getMaxWidth(context), maxHeight: 600),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Expanded (
                         child: Text(
                          'Datos de los pasajeros',
                          style: AppTheme.subtitleStyle.copyWith(
                            color: AppTheme.primaryColor,
                            fontSize: AppTheme.getFontSize(context, mobile: 20, tablet: 22),
                            fontWeight: FontWeight.bold,
                          ),
                          overflow: TextOverflow.ellipsis, // Añadir ellipsis si el texto es muy largo
                          maxLines: 1,
                        ),
                        ),
                        IconButton(
                          icon: Icon(Icons.close, color: AppTheme.secondaryColor),
                          onPressed: () => Navigator.pop(context),
                        ),
                      ],
                    ),
                    Divider(height: AppTheme.getSpacing(context, mobile: 24), color: AppTheme.primaryColor.withAlpha((255 * 0.5).round())), // Corregido
                    Row(
                      children: [
                        Expanded( 
                          flex: 2, 
                          child: FittedBox(
                            fit: BoxFit.scaleDown,
                            alignment: Alignment.centerLeft,
                            child: Text(
                              'Número de personas:',
                              style: AppTheme.bodyStyle.copyWith(
                                fontWeight: FontWeight.w500,
                                fontSize: AppTheme.getFontSize(context, mobile: 15, tablet: 16),
                              ),
                            ),
                          ),
                        ),
                        SizedBox(width: AppTheme.getSpacing(context)),
                        Container(
                          padding: EdgeInsets.symmetric(horizontal: AppTheme.getSpacing(context, mobile: 12)),
                          decoration: BoxDecoration(
                            color: AppTheme.backgroundColor, // Color de fondo del Dropdown
                            borderRadius: BorderRadius.circular(AppTheme.getSpacing(context, mobile: 8, tablet: 12)), // Reducir un poco el radio
                            border: Border.all(color: AppTheme.primaryColor.withAlpha((255 * 0.3).round())), // Corregido
                            boxShadow: [
                              BoxShadow(
                                color: Colors.black.withAlpha((255 * 0.05).round()), // Corregido
                                blurRadius: 4,
                                offset: const Offset(0, 2),
                              ),
                            ], // Sombra
                          ),
                          child: DropdownButtonHideUnderline( 
                            child: DropdownButton<int>(
                                value: numPersonas,
                                icon: Icon(Icons.arrow_drop_down, color: AppTheme.primaryColor),
                                style: AppTheme.bodyStyle.copyWith(color: AppTheme.primaryColor, fontWeight: FontWeight.w500),
                                items: List.generate(10, (i) => i + 1)
                                    .map((e) => DropdownMenuItem<int>(
                                          value: e,
                                          child: Text(
                                            e.toString(),
                                          ),
                                        ))
                                    .toList(),
                                onChanged: (value) { 
                                  if (value != null) {
                                    setState(() { 
                                      numPersonas = value;
                                    });
                                    setStateDialog(() { 
                                      for (final controllerMap_ in usuariosControllers) { // Use different name to avoid conflict
                                        for (final controller in controllerMap_.values) {
                                          controller.dispose();
                                        }
                                      }
                                      usuariosControllers.clear();

                                      for (int i = 0; i < value; i++) {
                                        usuariosControllers.add({
                                          'nombre': TextEditingController(),
                                          'apellidos': TextEditingController(),
                                          'dni': TextEditingController(),
                                          'edad': TextEditingController(),
                                          'email': TextEditingController(),
                                        });
                                      }
                                    });
                                  }
                                },
                              ),
                          ),
                        ),
                      ],
                    ),
                    SizedBox(height: AppTheme.getSpacing(context)),
                    Expanded(
                      child: ListView.builder(
                        itemCount: numPersonas,
                        itemBuilder: (context, i) {
                          return Container(
                            margin: EdgeInsets.only(bottom: AppTheme.getSpacing(context)),
                            padding: EdgeInsets.all(AppTheme.getSpacing(context)),
                            decoration: BoxDecoration(
                              color: AppTheme.cardColor, // Color de fondo de la tarjeta de pasajero
                              borderRadius: BorderRadius.circular(AppTheme.getSpacing(context, mobile: 16)),
                              border: Border.all(color: AppTheme.primaryColor.withAlpha((255 * 0.2).round())), // Corregido
                              boxShadow: [
                                BoxShadow(
                                  color: Colors.black.withAlpha((255 * 0.05).round()), // Corregido
                                  blurRadius: 4,
                                  offset: const Offset(0, 2),
                                ),
                              ], // Sombra
                            ),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Row(
                                  children: [ // Icono y título del pasajero
                                    Icon(Icons.person, color: AppTheme.primaryColor.withAlpha((255 * 0.7).round())), // Corregido
                                    SizedBox(width: AppTheme.getSpacing(context, mobile: 8)), // Espacio entre icono y texto
                                    Text( // Título del pasajero
                                      'Pasajero ${i + 1}',
                                      style: AppTheme.subtitleStyle.copyWith(
                                        color: AppTheme.primaryColor,
                                        fontSize: AppTheme.getFontSize(context, mobile: 18),
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                  ],
                                ),
                                SizedBox(height: AppTheme.getSpacing(context, mobile: 12)),
                                _buildTextField(
                                  usuariosControllers[i]['nombre'],
                                  'Nombre',
                                  Icons.badge,
                                ),
                                SizedBox(height: AppTheme.getSpacing(context, mobile: 12)),
                                _buildTextField(
                                  usuariosControllers[i]['apellidos'],
                                  'Apellidos',
                                  Icons.person_outline,
                                ),
                                SizedBox(height: AppTheme.getSpacing(context, mobile: 12)),
                                _buildTextField(
                                  usuariosControllers[i]['dni'],
                                  'DNI',
                                  Icons.credit_card,
                                ),
                                SizedBox(height: AppTheme.getSpacing(context, mobile: 12)),
                                _buildTextField(
                                  usuariosControllers[i]['edad'],
                                  'Edad',
                                  Icons.cake,
                                  inputType: TextInputType.number,
                                  onChanged: (_) {
                                    setStateDialog(() {}); // This setStateDialog is fine for local dialog state
                                  },
                                ),
                                if ((int.tryParse(usuariosControllers[i]['edad']?.text ?? '') ?? 0) >= 18)
                                  Padding(
                                    padding: EdgeInsets.only(top: AppTheme.getSpacing(context, mobile: 12)),
                                    child: _buildTextField(
                                      usuariosControllers[i]['email'],
                                      'Email',
                                      Icons.email,
                                      inputType: TextInputType.emailAddress,
                                    ),
                                  ),
                              ],
                            ),
                          );
                        },
                      ),
                    ),
                    SizedBox(height: AppTheme.getSpacing(context)),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.end,
                      children: [
                        Expanded( 
                          flex: 1,
                          child: OutlinedButton(
                            onPressed: () => Navigator.pop(context),
                            style: OutlinedButton.styleFrom(
                              foregroundColor: AppTheme.primaryColor,
                              side: BorderSide(color: AppTheme.primaryColor),
                              padding: EdgeInsets.symmetric(horizontal: AppTheme.getSpacing(context, mobile: 16, tablet: 20), vertical: AppTheme.getSpacing(context, mobile: 10, tablet: 12)),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(AppTheme.getSpacing(context, mobile: 10, tablet: 12)),
                              ),
                            ),
                            child: const FittedBox(fit: BoxFit.scaleDown, child: Text('Cancelar')),
                          ),
                        ),
                        SizedBox(width: AppTheme.getSpacing(context, mobile: 8, tablet: 12)),
                        Expanded(
                          flex: 1,
                          child: ElevatedButton(
                            onPressed: _isLoading ? null : _guardarDatosEnFirestore,
                            style: ElevatedButton.styleFrom(
                              backgroundColor: AppTheme.primaryColor,
                              foregroundColor: Colors.white,
                              padding: EdgeInsets.symmetric(horizontal: AppTheme.getSpacing(context, mobile: 16, tablet: 20), vertical: AppTheme.getSpacing(context, mobile: 10, tablet: 12)),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(AppTheme.getSpacing(context, mobile: 10, tablet: 12)),
                              ),
                            ),
                            child: _isLoading
                                ? const SizedBox(
                                    height: 20,
                                    width: 20,
                                    child: CircularProgressIndicator(
                                      color: Colors.white,
                                      strokeWidth: 2,
                                    ),
                                  )
                                : const FittedBox(fit: BoxFit.scaleDown, child: Text('Finalizar reserva')),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              );
            },
          ),
        );
      },
    );
  }

  Widget _buildTextField(
    TextEditingController? controller,
    String label,
    IconData icon, {
    TextInputType? inputType,
    void Function(String)? onChanged,
  }) {
    return TextField(
      controller: controller,
      keyboardType: inputType,
      onChanged: onChanged,
      decoration: AppTheme.getInputDecoration(context, label: Text(label)).copyWith(
        prefixIcon: Icon(icon, color: AppTheme.primaryColor.withAlpha((255 * 0.8).round()), size: 20), // Corregido
      ).copyWith(prefixIcon: Icon(icon, color: AppTheme.primaryColor.withAlpha((255 * 0.8).round()), size: 20)), // Corregido
    );
  }

  Future<void> _guardarDatosEnFirestore() async {
    try {
      setState(() {
        _isLoading = true;
      });
      
      await FirestoreService.crearReserva(
        vueloSeleccionado: vueloSeleccionado,
        hotelSeleccionado: hotelSeleccionado,
        cocheSeleccionado: cocheSeleccionado,
        trenSeleccionado: trenSeleccionado,
        actividadSeleccionada: actividadSeleccionada,
        usuariosControllers: usuariosControllers,
      );

      setState(() {
        _isLoading = false;
      });

      if (!mounted) return;
      Navigator.pop(context); // Cierra el diálogo
      _mostrarMensaje('Reserva realizada con éxito');
    } catch (e) {
      setState(() {
        _isLoading = false;
      });
      _mostrarMensaje('Error: $e');
    }
  }

  Widget _tabIndicator(String text, IconData icon, int index) {
    final isSelected = _activeTab == index;
    
    return Expanded(
      child: GestureDetector(
        onTap: () {
          _tabController.animateTo(index);
        },
        child: Container(
          decoration: BoxDecoration(
            color: isSelected ? AppTheme.cardColor : Colors.transparent,
            borderRadius: BorderRadius.circular(AppTheme.getSpacing(context, mobile: 16)),
            boxShadow: isSelected ? [
              BoxShadow(
                color: Colors.black.withAlpha((255 * 0.1).round()), // Corregido
                blurRadius: 4,
                offset: const Offset(0, 2),
              ),
            ] : null,
          ),
          margin: EdgeInsets.symmetric(horizontal: AppTheme.getSpacing(context, mobile: 2, tablet: 3)),
          padding: EdgeInsets.symmetric(
            horizontal: AppTheme.getSpacing(context, mobile: 4, tablet: 8), // Padding horizontal
            vertical: AppTheme.getSpacing(context, mobile: 4, tablet: 6)
          ),
          child: LayoutBuilder(
            builder: (context, constraints) {
              // Calcular si tenemos suficiente espacio para mostrar icono y texto
              final hasSpaceForBoth = constraints.maxHeight > 40;
              
              if (hasSpaceForBoth) {
                // Layout normal: icono arriba, texto abajo
                return Column(
                  mainAxisSize: MainAxisSize.min,
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Flexible(
                      child: Icon( // Icono de la pestaña
                        icon,
                        color: isSelected ? AppTheme.primaryColor : AppTheme.secondaryColor,
                        size: AppTheme.getFontSize(context, mobile: 14, tablet: 16, desktop: 18),
                      ),
                    ),
                    if (constraints.maxHeight > 30) // Solo mostrar texto si hay espacio suficiente
                      Flexible(
                        child: Padding(
                          padding: EdgeInsets.only(top: AppTheme.getSpacing(context, mobile: 2, tablet: 4)),
                          child: FittedBox(
                            fit: BoxFit.scaleDown, // Ajustar texto
                            child: Text(
                              text,
                              style: (isSelected ? AppTheme.bodyStyle : AppTheme.captionStyle).copyWith(
                                fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                                color: isSelected ? AppTheme.primaryColor : AppTheme.secondaryColor,
                                fontSize: AppTheme.getFontSize(context, mobile: 8, tablet: 10, desktop: 12),
                              ),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              textAlign: TextAlign.center,
                            ),
                          ),
                        ),
                      ),
                  ],
                );
              } else {
                // Layout compacto: solo icono centrado
                return Center(
                  child: Icon( // Icono de la pestaña (compacto)
                    icon,
                    color: isSelected ? AppTheme.primaryColor : AppTheme.secondaryColor,
                    size: AppTheme.getFontSize(context, mobile: 16, tablet: 18, desktop: 20),
                  ),
                );
              }
            },
          ),
        ),
      ),
    );
  }

  Widget _buildServiceList(String title, List<Map<String, dynamic>> items, Map<String, dynamic>? selected, void Function(Map<String, dynamic>?) onChanged) {
    if (items.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.search_off, size: 64, color: AppTheme.secondaryColor.withAlpha((255 * 0.6).round())), // Corregido
            SizedBox(height: AppTheme.getSpacing(context)),
            Text(
              'No se encontraron $title disponibles',
              style: AppTheme.subtitleStyle.copyWith(color: AppTheme.secondaryColor),
            ),
          ],
        ),
      );
    }
    
    return ListView.builder(
      padding: EdgeInsets.only(top: AppTheme.getSpacing(context), bottom: 100), // bottom padding for FAB
      itemCount: items.length,
      itemBuilder: (context, index) {
        final item = items[index];
        final isSelected = selected == item;
        
        return Container(
          margin: EdgeInsets.only(bottom: AppTheme.getSpacing(context), left: AppTheme.getSpacing(context), right: AppTheme.getSpacing(context)),
          decoration: BoxDecoration(
            color: AppTheme.cardColor,
            borderRadius: BorderRadius.circular(AppTheme.getSpacing(context, mobile: 16)),
            border: Border.all(
              color: isSelected ? AppTheme.primaryColor : AppTheme.dividerColor,
              width: isSelected ? 2 : 1,
            ),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withAlpha((255 * 0.05).round()), // Corregido
                blurRadius: 4,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          child: InkWell(
            onTap: () => onChanged(isSelected ? null : item),
            borderRadius: BorderRadius.circular(AppTheme.getSpacing(context, mobile: 16)),
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Row(
                children: [
                  Radio<Map<String, dynamic>>(
                    value: item,
                    groupValue: selected,
                    onChanged: (_) => onChanged(isSelected ? null : item),
                    activeColor: AppTheme.primaryColor,
                  ),
                  SizedBox(width: AppTheme.getSpacing(context, mobile: 8)),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            _getIconForService(_activeTab),
                            SizedBox(width: AppTheme.getSpacing(context, mobile: 8)),
                            Expanded(
                              child: Text(
                                _getServiceDisplayName(item, _activeTab), // Using the helper
                                style: AppTheme.bodyStyle.copyWith(
                                  fontWeight: FontWeight.bold,
                                ),
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                              ),
                            ),
                          ],
                        ),
                        SizedBox(height: AppTheme.getSpacing(context, mobile: 8)),
                        Row(
                          children: [
                            Icon(Icons.people, size: 16, color: AppTheme.secondaryColor),
                            SizedBox(width: AppTheme.getSpacing(context, mobile: 2, tablet: 4)), // Reducir espacio
                            Expanded( // Permitir que el texto se ajuste
                              child: Text(
                                'Plazas disponibles: ${item['plazas']}',
                                style: AppTheme.captionStyle.copyWith(
                                  color: AppTheme.secondaryColor,
                                  fontSize: AppTheme.getFontSize(context, mobile: 11, tablet: 12), // Reducir tamaño de fuente
                                ),
                                overflow: TextOverflow.ellipsis, // Añadir ellipsis si aún desborda
                              ),
                            ),
                          ],
                        ),
                        if (item['precio'] != null)
                          Padding(
                            padding: EdgeInsets.only(top: AppTheme.getSpacing(context, mobile: 8)),
                            child: Row(
                              children: [
                                Icon(Icons.euro, size: 16, color: AppTheme.secondaryColor),
                                SizedBox(width: AppTheme.getSpacing(context, mobile: 4)),
                                Text(
                                  'Precio: ${item['precio']}€',
                                  style: AppTheme.captionStyle.copyWith(
                                    color: AppTheme.secondaryColor,
                                  ),
                                ),
                              ],
                            ),
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
  }

  String _getServiceDisplayName (Map<String, dynamic> item, int tabIndex) {
    switch (tabIndex) {
      case 0:
        return '${item['origen'] ?? ''} → ${item['destino'] ?? ''}';
      case 1:
        return item['nombre'] ?? 'Hotel';
      case 2:
        return item['modelo'] ?? 'Coche';
      case 3:
        return '${item['origen'] ?? ''} → ${item['destino'] ?? ''}';
      case 4:
        return item['nombre'] ?? 'Actividad';
      default:
        return item['nombre'] ?? 'Opción';
    }
  }

  Icon _getIconForService(int tabIndex) {
    switch (tabIndex) {
      case 0:
        return Icon(Icons.flight, color: AppTheme.primaryColor);
      case 1:
        return Icon(Icons.hotel, color: AppTheme.primaryColor);
      case 2:
        return Icon(Icons.directions_car, color: AppTheme.primaryColor);
      case 3:
        return Icon(Icons.train, color: AppTheme.primaryColor);
      case 4:
        return Icon(Icons.attractions, color: AppTheme.primaryColor);
      default:
        return Icon(Icons.circle, color: AppTheme.primaryColor);
    }
  }

  @override
  Widget build(BuildContext context) {
    final screenSize = MediaQuery.of(context).size;
    final isMobile = AppTheme.isMobile(context);

    return Scaffold(
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        title: Text(
          'Selecciona tus opciones',
          style: AppTheme.titleStyle.copyWith(
            fontWeight: FontWeight.bold,
            color: Colors.white,
            fontSize : AppTheme.getFontSize(context, mobile: 18, tablet: 20, desktop: 22),
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
            colors: [Color.fromARGB(255, 214, 190, 231), AppTheme.primaryColor], // Using AppTheme.primaryColor for one end of gradient
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
        ),
        child: SafeArea(
          child: Column(
            children: [
              Padding(
                padding: EdgeInsets.symmetric(
                  horizontal: AppTheme.getSpacing(context, mobile: 12, tablet: 16), 
                  vertical: AppTheme.getSpacing(context, mobile: 6, tablet: 8)
                ),
                child: Container(
                  constraints: BoxConstraints(
                    minHeight: screenSize.height * 0.06, // Altura mínima
                    maxHeight: screenSize.height * 0.12, // Altura máxima
                  ),
                  padding: EdgeInsets.all(AppTheme.getSpacing(context, mobile: 6, tablet: 8)),
                  decoration: BoxDecoration( // Decoración del contenedor de pestañas
                    color: Colors.white.withAlpha((255 * 0.2).round()), // Corregido
                    borderRadius: BorderRadius.circular(AppTheme.getSpacing(context, mobile: 20)),
                  ),
                  child: Row(
                    children: [
                      _tabIndicator('Vuelos', Icons.flight, 0),
                      _tabIndicator('Hoteles', Icons.hotel, 1),
                      _tabIndicator('Coches', Icons.directions_car, 2),
                      _tabIndicator('Trenes', Icons.train, 3),
                      _tabIndicator('Actividades', Icons.attractions, 4),
                    ],
                  ),
                ),
              ),
              Expanded(
                child: TabBarView(
                  controller: _tabController,
                  physics: const NeverScrollableScrollPhysics(),
                  children: [
                    _buildServiceList('vuelos', widget.vuelosDisponibles, vueloSeleccionado,
                        (val) => setState(() => vueloSeleccionado = val)),
                    _buildServiceList('hoteles', widget.hotelesDisponibles, hotelSeleccionado,
                        (val) => setState(() => hotelSeleccionado = val)),
                    _buildServiceList('coches', widget.cochesDisponibles, cocheSeleccionado,
                        (val) => setState(() => cocheSeleccionado = val)),
                    _buildServiceList('trenes', widget.trenesDisponibles, trenSeleccionado,
                        (val) => setState(() => trenSeleccionado = val)),
                    _buildServiceList('actividades', widget.actividadesDisponibles, actividadSeleccionada,
                        (val) => setState(() => actividadSeleccionada = val)),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
      floatingActionButton: Container(
        width: isMobile ? double.infinity : 300,
        margin: EdgeInsets.symmetric(horizontal: AppTheme.getSpacing(context, mobile: 24)),
        child: FloatingActionButton.extended(
          onPressed: _confirmarReserva,
          backgroundColor: AppTheme.primaryColor,
          foregroundColor: Colors.white,
          elevation: 8,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(AppTheme.getSpacing(context, mobile: 16))),
          icon: const Icon(Icons.check_circle),
          label: Text(
            'Confirmar reserva',
            style: AppTheme.bodyStyle.copyWith(fontSize: AppTheme.getFontSize(context, mobile: 16), fontWeight: FontWeight.bold, color: Colors.white),
          ),
        ),
      ),
      floatingActionButtonLocation: isMobile
          ? FloatingActionButtonLocation.centerFloat
          : FloatingActionButtonLocation.endFloat,
    );
  }
}