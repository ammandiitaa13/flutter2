import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:intl/intl.dart';
import 'package:responsive_framework/responsive_framework.dart';
import 'package:intl/date_symbol_data_local.dart';

class WeatherTableScreen extends StatefulWidget {
  const WeatherTableScreen({super.key});

  @override
  State<WeatherTableScreen> createState() => _WeatherTableScreenState();
}

class _WeatherTableScreenState extends State<WeatherTableScreen> {
  final TextEditingController _cityController = TextEditingController();
  final String apiKey = 'e0590e754dd4b43ae3d52aa2df0be550'; // Sustituye con tu clave
  Map<String, List<Map<String, dynamic>>> groupedForecasts = {};
  bool _isLoading = false;
  String? _errorMessage;
  bool _hasSearched = false;

  @override
  void initState() {
    super.initState();
    initializeDateFormatting('es_ES', null);
  }

  Future<void> fetchForecast(String city) async {
    if (city.isEmpty) {
      setState(() {
        _errorMessage = 'Por favor, ingresa el nombre de una ciudad';
      });
      return;
    }

    setState(() {
      _isLoading = true;
      _errorMessage = null;
      _hasSearched = true;
    });

    try {
      final url = Uri.parse(
        'https://api.openweathermap.org/data/2.5/forecast?q=$city&appid=$apiKey&units=metric&lang=es',
      );

      final response = await http.get(url);

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        final List<dynamic> forecasts = data['list'];

        Map<String, List<Map<String, dynamic>>> grouped = {};

        for (var item in forecasts) {
          final dateTime = DateTime.parse(item['dt_txt']);
          final dayKey = DateFormat('EEEE, d MMMM', 'es_ES').format(dateTime);
          grouped.putIfAbsent(dayKey, () => []).add(item);
        }

        setState(() {
          groupedForecasts = grouped;
          _isLoading = false;
        });
      } else {
        final data = json.decode(response.body);
        setState(() {
          _errorMessage = data['message'] ?? 'Error al cargar los datos del clima';
          _isLoading = false;
        });
      }
    } catch (e) {
      setState(() {
        _errorMessage = 'Error de conexión: $e';
        _isLoading = false;
      });
    }
  }

  Widget buildForecastRow(Map<String, dynamic> forecast, double fontSize) {
    final dateTime = DateTime.parse(forecast['dt_txt']);
    final hour = DateFormat.Hm().format(dateTime);
    final temp = forecast['main']['temp'];
    final desc = forecast['weather'][0]['description'];
    final icon = forecast['weather'][0]['icon'];
    final rowHeight = MediaQuery.of(context).size.height * 0.07;

    return Container(
      margin: EdgeInsets.symmetric(vertical: MediaQuery.of(context).size.height * 0.006),
      padding: EdgeInsets.symmetric(horizontal: MediaQuery.of(context).size.width * 0.04, vertical: MediaQuery.of(context).size.width * 0.012),
      height: rowHeight,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 4,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        children: [
          SizedBox(
            width: MediaQuery.of(context).size.width * 0.15, 
            child: FittedBox ( fit: BoxFit.scaleDown,
            child:  Text (
              hour, 
              style: TextStyle(
                fontSize: fontSize,
                fontWeight: FontWeight.bold,
                color: Colors.deepPurple.shade700,
              )
            )
          ),
          ),
          Image.network(
            'https://openweathermap.org/img/wn/$icon@2x.png',
            width: MediaQuery.of(context).size.width * 0.1,
            height: rowHeight * 0.8,
          ),
          SizedBox(width: MediaQuery.of(context).size.width * 0.02),
          Expanded(
            child: FittedBox (
              fit: BoxFit.scaleDown,
              child: Text(
                desc,
                style: TextStyle(
                  fontSize: fontSize, 
                  color: Colors.grey.shade800
                ),
              overflow: TextOverflow.ellipsis,
            ),
          ),
          ),
          SizedBox(width: MediaQuery.of(context).size.width * 0.02),
          Container(
            padding: EdgeInsets.symmetric(horizontal: MediaQuery.of(context).size.width * 0.03,
           vertical: MediaQuery.of(context).size.height * 0.006,),
            decoration: BoxDecoration(
              color: Colors.deepPurple.shade50,
              borderRadius: BorderRadius.circular(20),
            ),
            child: FittedBox(
              fit: BoxFit.scaleDown,
              child: Text(
                '${temp.toStringAsFixed(1)}°C',
                style: TextStyle(
                  fontSize: fontSize,
                  color: Colors.deepPurple.shade700,
              ),  
            )
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final isTablet = ResponsiveBreakpoints.of(context).isTablet;
    final titleFontSize = isTablet ? 22.0 : 18.0;
    final itemFontSize = isTablet ? 18.0 : 14.0;
    final screenWidth = MediaQuery.of(context).size.width;
    final double formWidth = isTablet ? 500 : screenWidth - 48;

    return Scaffold(
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        title: const Text(
          'Pronóstico del clima',
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
              children: [
                Center(
                  child: Container(
                    width: formWidth,
                    padding: const EdgeInsets.all(20),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(20),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.1),
                          blurRadius: 10,
                          offset: const Offset(0, 4),
                        ),
                      ],
                    ),
                    child: Column(
                      children: [
                        Row(
                          children: [
                            Icon(
                              Icons.location_on, 
                              color: Colors.deepPurple,
                              size: 24,
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              child: TextField(
                                controller: _cityController,
                                decoration: InputDecoration(
                                  labelText: 'Ciudad',
                                  labelStyle: TextStyle(color: Colors.deepPurple),
                                  hintText: 'Ingresa el nombre de una ciudad',
                                  border: OutlineInputBorder(
                                    borderRadius: BorderRadius.circular(12),
                                    borderSide: BorderSide(color: Colors.deepPurple.shade200),
                                  ),
                                  enabledBorder: OutlineInputBorder(
                                    borderRadius: BorderRadius.circular(12),
                                    borderSide: BorderSide(color: Colors.deepPurple.shade200),
                                  ),
                                  focusedBorder: OutlineInputBorder(
                                    borderRadius: BorderRadius.circular(12),
                                    borderSide: BorderSide(color: Colors.deepPurple, width: 2),
                                  ),
                                ),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 16),
                        SizedBox(
                          width: double.infinity,
                          height: 50,
                          child: ElevatedButton.icon(
                            onPressed: _isLoading ? null : () => fetchForecast(_cityController.text),
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.deepPurple,
                              foregroundColor: Colors.white,
                              disabledBackgroundColor: Colors.grey.shade400,
                              elevation: 3,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(12),
                              ),
                            ),
                            icon: _isLoading
                                ? SizedBox(
                                    height: 24,
                                    width: 24,
                                    child: CircularProgressIndicator(
                                      color: Colors.white,
                                      strokeWidth: 2,
                                    ),
                                  )
                                : Icon(Icons.search),
                            label: Text(_isLoading ? 'Buscando...' : 'Buscar pronóstico'),
                          ),
                        ),
                        if (_errorMessage != null)
                          Padding(
                            padding: const EdgeInsets.only(top: 12.0),
                            child: Text(
                              _errorMessage!,
                              style: const TextStyle(color: Colors.red),
                            ),
                          ),
                      ],
                    ),
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
                      child: groupedForecasts.isEmpty
                          ? Center(
                              child: Column(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Icon(
                                    _hasSearched ? Icons.cloud_off : Icons.cloud_queue,
                                    size: 80,
                                    color: Colors.deepPurple.shade300,
                                  ),
                                  const SizedBox(height: 16),
                                  Text(
                                    _hasSearched ? "No se encontraron datos" : "Sin datos aún",
                                    style: TextStyle(
                                      fontSize: 18,
                                      color: Colors.grey.shade700,
                                      fontWeight: FontWeight.w500,
                                    ),
                                  ),
                                  const SizedBox(height: 8),
                                  Text(
                                    _hasSearched
                                        ? "Intenta con otra ciudad"
                                        : "Busca el pronóstico de una ciudad",
                                    style: TextStyle(
                                      fontSize: 14,
                                      color: Colors.grey.shade500,
                                    ),
                                  ),
                                ],
                              ),
                            )
                          : ListView(
                              padding: const EdgeInsets.all(16),
                              children: groupedForecasts.entries.map((entry) {
                                return Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Container(
                                      margin: const EdgeInsets.only(top: 8, bottom: 16),
                                      padding: const EdgeInsets.symmetric(
                                          horizontal: 16, vertical: 8),
                                      decoration: BoxDecoration(
                                        color: Colors.deepPurple.shade100,
                                        borderRadius: BorderRadius.circular(12),
                                      ),
                                      child: Text(
                                        entry.key,
                                        style: TextStyle(
                                          fontSize: titleFontSize,
                                          fontWeight: FontWeight.bold,
                                          color: Colors.deepPurple.shade800,
                                        ),
                                      ),
                                    ),
                                    ...entry.value
                                        .map((item) =>
                                            buildForecastRow(item, itemFontSize))
                                        ,
                                    const SizedBox(height: 16),
                                  ],
                                );
                              }).toList(),
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