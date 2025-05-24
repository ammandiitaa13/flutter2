import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:intl/intl.dart';
import 'package:intl/date_symbol_data_local.dart';
import 'theme.dart';

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

  Widget _buildForecastRow(Map<String, dynamic> forecast) {
    final dateTime = DateTime.parse(forecast['dt_txt']);
    final hour = DateFormat.Hm().format(dateTime);
    final temp = forecast['main']['temp'];
    final desc = forecast['weather'][0]['description'];
    final icon = forecast['weather'][0]['icon'];
    
    final fontSize = AppTheme.getFontSize(context, mobile: 14, tablet: 16, desktop: 18);
    final spacing = AppTheme.getSpacing(context, mobile: 8, tablet: 12, desktop: 16);

    return Container(
      margin: EdgeInsets.symmetric(vertical: spacing / 2),
      padding: EdgeInsets.all(spacing),
      decoration: AppTheme.getBoxDecoration(context).copyWith(
        color: AppTheme.cardColor,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        children: [
          SizedBox(
            width: AppTheme.isDesktop(context) ? 80 : 60,
            child: FittedBox(
              fit: BoxFit.scaleDown,
              child: Text(
                hour,
                style: TextStyle(
                  fontSize: fontSize,
                  fontWeight: FontWeight.bold,
                  color: AppTheme.primaryColor,
                ),
              ),
            ),
          ),
          SizedBox(width: spacing),
          Image.network(
            'https://openweathermap.org/img/wn/$icon@2x.png',
            width: AppTheme.isDesktop(context) ? 60 : AppTheme.isTablet(context) ? 50 : 40,
            height: AppTheme.isDesktop(context) ? 60 : AppTheme.isTablet(context) ? 50 : 40,
            errorBuilder: (context, error, stackTrace) => Icon(
              Icons.cloud,
              size: AppTheme.isDesktop(context) ? 40 : 30,
              color: AppTheme.secondaryColor,
            ),
          ),
          SizedBox(width: spacing),
          Expanded(
            flex: 3,
            child: FittedBox(
              fit: BoxFit.scaleDown,
              alignment: Alignment.centerLeft,
              child: Text(
                desc,
                style: TextStyle(
                  fontSize: fontSize,
                  color: AppTheme.textColor,
                ),
              ),
            ),
          ),
          SizedBox(width: spacing),
          Container(
            padding: EdgeInsets.symmetric(
              horizontal: spacing,
              vertical: spacing / 2,
            ),
            decoration: BoxDecoration(
              color: AppTheme.primaryColor.withOpacity(0.1),
              borderRadius: BorderRadius.circular(20),
            ),
            child: FittedBox(
              fit: BoxFit.scaleDown,
              child: Text(
                '${temp.toStringAsFixed(1)}°C',
                style: TextStyle(
                  fontSize: fontSize,
                  color: AppTheme.primaryColor,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSearchForm() {
    return Container(
      constraints: BoxConstraints(maxWidth: AppTheme.getMaxWidth(context)),
      padding: AppTheme.getPadding(context),
      decoration: AppTheme.getBoxDecoration(context).copyWith(
        color: AppTheme.cardColor,
        borderRadius: BorderRadius.circular(20),
      ),
      child: Column(
        children: [
          Row(
            children: [
              Icon(
                Icons.location_on,
                color: AppTheme.primaryColor,
                size: AppTheme.isDesktop(context) ? 28 : 24,
              ),
              SizedBox(width: AppTheme.getSpacing(context)),
              Expanded(
                child: TextField(
                  controller: _cityController,
                  style: TextStyle(
                    fontSize: AppTheme.getFontSize(context, mobile: 16, tablet: 18, desktop: 20),
                  ),
                  decoration: AppTheme.getInputDecoration(
                    context,
                    label: Text('Ciudad'),
                    hintText: 'Ingresa el nombre de una ciudad',
                  ),
                ),
              ),
            ],
          ),
          SizedBox(height: AppTheme.getSpacing(context, mobile: 16, tablet: 20, desktop: 24)),
          SizedBox(
            width: double.infinity,
            height: AppTheme.isDesktop(context) ? 60 : 50,
            child: ElevatedButton.icon(
              onPressed: _isLoading ? null : () => fetchForecast(_cityController.text),
              style: AppTheme.getButtonStyle(context).copyWith(
                backgroundColor: WidgetStateProperty.resolveWith((states) {
                  if (states.contains(WidgetState.disabled)) {
                    return Colors.grey.shade400;
                  }
                  return AppTheme.primaryColor;
                }),
                elevation: WidgetStateProperty.all(3),
                shape: WidgetStateProperty.all(
                  RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
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
                  : const Icon(Icons.search),
              label: FittedBox( // Ensure text fits
                fit: BoxFit.scaleDown,
                child: Text(
                  _isLoading ? 'Buscando...' : 'Buscar pronóstico',
                  style: TextStyle(
                    fontSize: AppTheme.getFontSize(context, mobile: 16, tablet: 18, desktop: 20),
                  ),
                ),
              ),
            ),
          ),
          if (_errorMessage != null)
            Padding(
              padding: EdgeInsets.only(top: AppTheme.getSpacing(context)),
              child: Text(
                _errorMessage!,
                style: TextStyle(
                  color: Colors.red,
                  fontSize: AppTheme.getFontSize(context, mobile: 14, tablet: 16, desktop: 18),
                ),
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            _hasSearched ? Icons.cloud_off : Icons.cloud_queue,
            size: AppTheme.isDesktop(context) ? 100 : AppTheme.isTablet(context) ? 90 : 80,
            color: AppTheme.primaryColor.withOpacity(0.6),
          ),
          SizedBox(height: AppTheme.getSpacing(context, mobile: 16, tablet: 20, desktop: 24)),
          Text(
            _hasSearched ? "No se encontraron datos" : "Sin datos aún",
            textAlign: TextAlign.center, // Centrar texto
            style: TextStyle(
              fontSize: AppTheme.getFontSize(context, mobile: 18, tablet: 20, desktop: 22),
              color: AppTheme.textColor,
              fontWeight: FontWeight.w500,
            ),
          ),
          SizedBox(height: AppTheme.getSpacing(context, mobile: 8, tablet: 10)),
          Padding( // Añadir padding horizontal al texto inferior
            padding: const EdgeInsets.symmetric(horizontal: 16.0),
            child: Text(
              _hasSearched
                  ? "Intenta con otra ciudad o revisa la conexión"
                  : "Busca el pronóstico de una ciudad para ver los resultados aquí",
              textAlign: TextAlign.center, // Centrar texto
              style: TextStyle(
                fontSize: AppTheme.getFontSize(context, mobile: 14, tablet: 16, desktop: 18),
                color: AppTheme.secondaryColor,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildForecastList() {
    return ListView(
      padding: AppTheme.getPadding(context),
      children: groupedForecasts.entries.map((entry) {
        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              margin: EdgeInsets.only(
                top: AppTheme.getSpacing(context),
                bottom: AppTheme.getSpacing(context, mobile: 12, tablet: 16, desktop: 20),
              ),
              padding: EdgeInsets.symmetric(
                horizontal: AppTheme.getSpacing(context, mobile: 16, tablet: 20, desktop: 24),
                vertical: AppTheme.getSpacing(context, mobile: 8, tablet: 12, desktop: 16),
              ),
              decoration: BoxDecoration(
                color: AppTheme.primaryColor.withOpacity(0.1),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Text(
                entry.key,
                style: TextStyle(
                  fontSize: AppTheme.getFontSize(context, mobile: 18, tablet: 20, desktop: 22),
                  fontWeight: FontWeight.bold,
                  color: AppTheme.primaryColor,
                ),
              ),
            ),
            ...entry.value.map((item) => _buildForecastRow(item)),
            SizedBox(height: AppTheme.getSpacing(context, mobile: 16, tablet: 20, desktop: 24)),
          ],
        );
      }).toList(),
    );
  }

  @override
  Widget build(BuildContext context) {
    final titleSize = AppTheme.getFontSize(context, mobile: 22, tablet: 26, desktop: 30);

    return Scaffold(
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        title: Text(
          'Pronóstico del clima',
          style: TextStyle(
            fontWeight: FontWeight.bold,
            color: Colors.white,
            fontSize: titleSize,
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
                padding: AppTheme.getPadding(context),
                child: AppTheme.centerContent(
                  context: context,
                  child: _buildSearchForm(),
                ),
              ),
              SizedBox(height: AppTheme.getSpacing(context, mobile: 16, tablet: 20, desktop: 24)),
              Expanded(
                child: Container(
                  margin: AppTheme.getHorizontalPadding(context),
                  decoration: AppTheme.getBoxDecoration(context).copyWith(
                    color: AppTheme.backgroundColor.withOpacity(0.95),
                    borderRadius: BorderRadius.circular(24),
                  ),
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(24),
                    child: groupedForecasts.isEmpty
                        ? _buildEmptyState()
                        : _buildForecastList(),
                  ),
                ),
              ),
              SizedBox(height: AppTheme.getSpacing(context)),
            ],
          ),
        ),
      ),
    );
  }
}