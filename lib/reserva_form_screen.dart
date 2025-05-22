import 'package:flutter/material.dart';
import 'package:responsive_framework/responsive_framework.dart';
import 'firestore_service.dart';

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
    for (var usuario in usuariosControllers) {
      for (var controller in usuario.values) {
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
        backgroundColor: Colors.deepPurple.shade300,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(10),
        ),
      ),
    );
  }

  void _mostrarFormularioUsuarios() {
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
            borderRadius: BorderRadius.circular(24),
          ),
          child: StatefulBuilder(
            builder: (context, setStateDialog) {
              return Container(
                padding: const EdgeInsets.all(24),
                width: double.maxFinite,
                constraints: const BoxConstraints(maxWidth: 600, maxHeight: 600),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const Text(
                          'Datos de los pasajeros',
                          style: TextStyle(
                            fontSize: 22,
                            fontWeight: FontWeight.bold,
                            color: Colors.deepPurple,
                          ),
                        ),
                        IconButton(
                          icon: const Icon(Icons.close, color: Colors.grey),
                          onPressed: () => Navigator.pop(context),
                        ),
                      ],
                    ),
                    const Divider(height: 24, color: Colors.deepPurple),
                    Row(
                      children: [
                        const Text(
                          'Número de personas:',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                        const SizedBox(width: 16),
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 12),
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(12),
                            border: Border.all(color: Colors.deepPurple.shade200),
                            boxShadow: [
                              BoxShadow(
                                color: Colors.black.withOpacity(0.05),
                                blurRadius: 5,
                                offset: const Offset(0, 2),
                              ),
                            ],
                          ),
                          child: DropdownButton<int>(
                            value: numPersonas,
                            underline: Container(),
                            icon: const Icon(Icons.arrow_drop_down, color: Colors.deepPurple),
                            items: List.generate(10, (i) => i + 1)
                                .map((e) => DropdownMenuItem<int>(
                                      value: e,
                                      child: Text(
                                        e.toString(),
                                        style: const TextStyle(
                                          color: Colors.deepPurple,
                                          fontWeight: FontWeight.w500,
                                        ),
                                      ),
                                    ))
                                .toList(),
                            onChanged: (value) {
                              if (value != null) {
                                setState(() {
                                  numPersonas = value;
                                });
                                setStateDialog(() {
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
                                });
                              }
                            },
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),
                    Expanded(
                      child: ListView.builder(
                        itemCount: numPersonas,
                        itemBuilder: (context, i) {
                          return Container(
                            margin: const EdgeInsets.only(bottom: 16),
                            padding: const EdgeInsets.all(16),
                            decoration: BoxDecoration(
                              color: Colors.white,
                              borderRadius: BorderRadius.circular(16),
                              border: Border.all(color: Colors.deepPurple.shade100),
                              boxShadow: [
                                BoxShadow(
                                  color: Colors.black.withOpacity(0.05),
                                  blurRadius: 8,
                                  offset: const Offset(0, 2),
                                ),
                              ],
                            ),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Row(
                                  children: [
                                    Icon(Icons.person, color: Colors.deepPurple.shade300),
                                    const SizedBox(width: 8),
                                    Text(
                                      'Pasajero ${i + 1}',
                                      style: TextStyle(
                                        fontSize: 18,
                                        fontWeight: FontWeight.bold,
                                        color: Colors.deepPurple.shade700,
                                      ),
                                    ),
                                  ],
                                ),
                                const SizedBox(height: 12),
                                _buildTextField(
                                  usuariosControllers[i]['nombre'],
                                  'Nombre',
                                  Icons.badge,
                                ),
                                const SizedBox(height: 12),
                                _buildTextField(
                                  usuariosControllers[i]['apellidos'],
                                  'Apellidos',
                                  Icons.person_outline,
                                ),
                                const SizedBox(height: 12),
                                _buildTextField(
                                  usuariosControllers[i]['dni'],
                                  'DNI',
                                  Icons.credit_card,
                                ),
                                const SizedBox(height: 12),
                                _buildTextField(
                                  usuariosControllers[i]['edad'],
                                  'Edad',
                                  Icons.cake,
                                  inputType: TextInputType.number,
                                  onChanged: (_) {
                                    setStateDialog(() {});
                                  },
                                ),
                                if ((int.tryParse(usuariosControllers[i]['edad']?.text ?? '') ?? 0) >= 18)
                                  Padding(
                                    padding: const EdgeInsets.only(top: 12),
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
                    const SizedBox(height: 16),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.end,
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
                        const SizedBox(width: 16),
                        ElevatedButton(
                          onPressed: _isLoading ? null : _guardarDatosEnFirestore,
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.deepPurple,
                            foregroundColor: Colors.white,
                            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
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
                              : const Text('Finalizar reserva'),
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
      decoration: InputDecoration(
        labelText: label,
        labelStyle: TextStyle(color: Colors.deepPurple.shade600),
        prefixIcon: Icon(icon, color: Colors.deepPurple.shade400, size: 20),
        filled: true,
        fillColor: Colors.white,
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: Colors.deepPurple.shade200),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: Colors.deepPurple, width: 2),
        ),
        contentPadding: const EdgeInsets.symmetric(vertical: 12, horizontal: 12),
      ),
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
    final screenSize = MediaQuery.of(context).size;
    
    return Expanded(
      child: GestureDetector(
        onTap: () {
          _tabController.animateTo(index);
        },
        child: Container(
          height: screenSize.height * 0.07,
          decoration: BoxDecoration(
            color: isSelected ? Colors.white : Colors.transparent,
            borderRadius: BorderRadius.circular(16),
            boxShadow: isSelected ? [
              BoxShadow(
                color: Colors.black.withOpacity(0.1),
                blurRadius: 8,
                offset: const Offset(0, 2),
              ),
            ] : null,
          ),
          margin: EdgeInsets.symmetric(horizontal: screenSize.width * 0.01),
          padding: EdgeInsets.symmetric(horizontal: screenSize.width * 0.01, 
          vertical: screenSize.height * 0.003),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                icon,
                color: isSelected ? Colors.deepPurple : Colors.grey.shade600,
                size: screenSize.width * 0.04,
              ),
              SizedBox(height: screenSize.height * 0.003),
              FittedBox (
                fit : BoxFit.scaleDown,
                child :
                  Text(
                    text,
                    style: TextStyle(
                      fontSize: screenSize.width * 0.025,
                      fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                      color: isSelected ? Colors.deepPurple : Colors.grey.shade600,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
              ),
            ],
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
            Icon(Icons.search_off, size: 64, color: Colors.grey.shade400),
            const SizedBox(height: 16),
            Text(
              'No se encontraron $title disponibles',
              style: TextStyle(
                fontSize: 18,
                color: Colors.grey.shade600,
              ),
            ),
          ],
        ),
      );
    }
    
    return ListView.builder(
      padding: const EdgeInsets.only(top: 16, bottom: 100),
      itemCount: items.length,
      itemBuilder: (context, index) {
        final item = items[index];
        final isSelected = selected == item;
        
        return Container(
          margin: const EdgeInsets.only(bottom: 16, left: 16, right: 16),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(
              color: isSelected ? Colors.deepPurple : Colors.grey.shade200,
              width: isSelected ? 2 : 1,
            ),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.05),
                blurRadius: 8,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          child: InkWell(
            onTap: () => onChanged(isSelected ? null : item),
            borderRadius: BorderRadius.circular(16),
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Row(
                children: [
                  Radio<Map<String, dynamic>>(
                    value: item,
                    groupValue: selected,
                    onChanged: (_) => onChanged(isSelected ? null : item),
                    activeColor: Colors.deepPurple,
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            _getIconForService(_activeTab),
                            const SizedBox(width: 8),
                            Expanded(
                              child: Text(
                                item['nombre'] ?? '${item['origen']} → ${item['destino']}' ?? 'Opción',
                                style: const TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.bold,
                                ),
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 8),
                        Row(
                          children: [
                            const Icon(Icons.people, size: 16, color: Colors.grey),
                            const SizedBox(width: 4),
                            Text(
                              'Plazas disponibles: ${item['plazas']}',
                              style: TextStyle(
                                color: Colors.grey.shade700,
                              ),
                            ),
                          ],
                        ),
                        if (item['precio'] != null)
                          Padding(
                            padding: const EdgeInsets.only(top: 8),
                            child: Row(
                              children: [
                                const Icon(Icons.euro, size: 16, color: Colors.grey),
                                const SizedBox(width: 4),
                                Text(
                                  'Precio: ${item['precio']}€',
                                  style: TextStyle(
                                    color: Colors.grey.shade700,
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
        return const Icon(Icons.flight, color: Colors.deepPurple);
      case 1:
        return const Icon(Icons.hotel, color: Colors.deepPurple);
      case 2:
        return const Icon(Icons.directions_car, color: Colors.deepPurple);
      case 3:
        return const Icon(Icons.train, color: Colors.deepPurple);
      case 4:
        return const Icon(Icons.attractions, color: Colors.deepPurple);
      default:
        return const Icon(Icons.circle, color: Colors.deepPurple);
    }
  }

  @override
  Widget build(BuildContext context) {
    final screenSize = MediaQuery.of(context).size;
    final isMobile = ResponsiveBreakpoints.of(context).isMobile;
    final isTablet = ResponsiveBreakpoints.of(context).isTablet;

    return Scaffold(
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        title: Text(
          'Selecciona tus opciones',
          style: TextStyle(
            fontWeight: FontWeight.bold,
            color: Colors.white,
            fontSize : MediaQuery.of(context).size.width * 0.05,
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
          child: Column(
            children: [
              Padding(
                padding: EdgeInsets.symmetric(horizontal: MediaQuery.of(context).size.width * 0.03, vertical: MediaQuery.of(context).size.height * 0.006,),
                child: Container(
                  height: screenSize.height * 0.07,
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.2),
                    borderRadius: BorderRadius.circular(20),
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
        margin: const EdgeInsets.symmetric(horizontal: 24),
        child: FloatingActionButton.extended(
          onPressed: _confirmarReserva,
          backgroundColor: Colors.deepPurple,
          foregroundColor: Colors.white,
          elevation: 8,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
          icon: const Icon(Icons.check_circle),
          label: const Text(
            'Confirmar reserva',
            style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
          ),
        ),
      ),
      floatingActionButtonLocation: isMobile
          ? FloatingActionButtonLocation.centerFloat
          : FloatingActionButtonLocation.endFloat,
    );
  }
}