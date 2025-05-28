import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:logger/logger.dart';

class FirestoreService {
  static final FirebaseFirestore _db = FirebaseFirestore.instance;
  static final Logger _logger = Logger();


  //Lógica para Hoteles
  static final List<Map<String, dynamic>> listaHoteles = [
    {'id': '1', 'nombre': 'Hotel Central', 'ciudad': 'Madrid', 'plazas': 120, 'precio': 95.0, 'estrellas': 4, 'fecha': Timestamp.fromDate(DateTime.parse('2025-07-01T00:00:00.000Z'))},
    {'id': '2', 'nombre': 'Gran Vía Inn', 'ciudad': 'Madrid', 'plazas': 80, 'precio': 110.0, 'estrellas': 5, 'fecha': Timestamp.fromDate(DateTime.parse('2025-07-15T00:00:00.000Z'))},
    {'id': '3', 'nombre': 'Mediterráneo Suites', 'ciudad': 'Barcelona', 'plazas': 100, 'precio': 85.0, 'estrellas': 4, 'fecha': Timestamp.fromDate(DateTime.parse('2025-08-01T00:00:00.000Z'))},
    {'id': '4', 'nombre': 'Vista Alegre', 'ciudad': 'Barcelona', 'plazas': 90, 'precio': 70.0, 'estrellas': 3, 'fecha': Timestamp.fromDate(DateTime.parse('2025-08-07T00:00:00.000Z'))},
    {'id': '5', 'nombre': 'Hotel del Puerto', 'ciudad': 'Valencia', 'plazas': 70, 'precio': 60.0, 'estrellas': 3, 'fecha': Timestamp.fromDate(DateTime.parse('2025-09-03T00:00:00.000Z'))},
    {'id': '6', 'nombre': 'Costa Azul Hotel', 'ciudad': 'Valencia', 'plazas': 100, 'precio': 75.0, 'estrellas': 4, 'fecha': Timestamp.fromDate(DateTime.parse('2025-11-25T00:00:00.000Z'))},
    {'id': '7', 'nombre': 'Hotel Flamenco', 'ciudad': 'Sevilla', 'plazas': 110, 'precio': 88.0, 'estrellas': 4, 'fecha': Timestamp.fromDate(DateTime.parse('2025-10-05T00:00:00.000Z'))},
    {'id': '8', 'nombre': 'Palacio Andaluz', 'ciudad': 'Sevilla', 'plazas': 95, 'precio': 120.0, 'estrellas': 5, 'fecha': Timestamp.fromDate(DateTime.parse('2025-10-12T00:00:00.000Z'))},
    {'id': '9', 'nombre': 'Sunset View', 'ciudad': 'Málaga', 'plazas': 85, 'precio': 78.0, 'estrellas': 4, 'fecha': Timestamp.fromDate(DateTime.parse('2025-09-03T00:00:00.000Z'))},
    {'id': '10', 'nombre': 'Marina Resort', 'ciudad': 'Málaga', 'plazas': 130, 'precio': 98.0, 'estrellas': 4, 'fecha': Timestamp.fromDate(DateTime.parse('2025-09-10T00:00:00.000Z'))},
    {'id': '11', 'nombre': 'Hotel Eiffel', 'ciudad': 'París', 'plazas': 120, 'precio': 150.0, 'estrellas': 5, 'fecha': Timestamp.fromDate(DateTime.parse('2025-08-01T00:00:00.000Z'))},
    {'id': '12', 'nombre': 'Boutique du Louvre', 'ciudad': 'París', 'plazas': 60, 'precio': 130.0, 'estrellas': 4, 'fecha': Timestamp.fromDate(DateTime.parse('2025-06-08T00:00:00.000Z'))},
    {'id': '13', 'nombre': 'Hotel Colosseum', 'ciudad': 'Roma', 'plazas': 100, 'precio': 140.0, 'estrellas': 4, 'fecha': Timestamp.fromDate(DateTime.parse('2025-11-18T00:00:00.000Z'))},
    {'id': '14', 'nombre': 'Vía Augusta Inn', 'ciudad': 'Roma', 'plazas': 75, 'precio': 110.0, 'estrellas': 3, 'fecha': Timestamp.fromDate(DateTime.parse('2025-08-09T00:00:00.000Z'))},
    {'id': '15', 'nombre': 'SkyView Berlin', 'ciudad': 'Berlín', 'plazas': 80, 'precio': 90.0, 'estrellas': 4, 'fecha': Timestamp.fromDate(DateTime.parse('2025-07-01T00:00:00.000Z'))},
    {'id': '16', 'nombre': 'Panorama Hotel', 'ciudad': 'Berlín', 'plazas': 100, 'precio': 105.0, 'estrellas': 5, 'fecha': Timestamp.fromDate(DateTime.parse('2025-08-09T00:00:00.000Z'))},
    {'id': '17', 'nombre': 'Canal View', 'ciudad': 'Amsterdam', 'plazas': 70, 'precio': 115.0, 'estrellas': 4, 'fecha': Timestamp.fromDate(DateTime.parse('2025-10-05T00:00:00.000Z'))},
    {'id': '18', 'nombre': 'Old Town Lodge', 'ciudad': 'Amsterdam', 'plazas': 60, 'precio': 95.0, 'estrellas': 3, 'fecha': Timestamp.fromDate(DateTime.parse('2025-06-08T00:00:00.000Z'))},
    {'id': '19', 'nombre': 'Atlantic Dreams', 'ciudad': 'Lisboa', 'plazas': 90, 'precio': 80.0, 'estrellas': 4, 'fecha': Timestamp.fromDate(DateTime.parse('2025-09-03T00:00:00.000Z'))},
    {'id': '20', 'nombre': 'Río Tejo Inn', 'ciudad': 'Lisboa', 'plazas': 85, 'precio': 92.0, 'estrellas': 4, 'fecha': Timestamp.fromDate(DateTime.parse('2025-09-10T00:00:00.000Z'))},
  ];

  static Future<void> crearHoteles() async {
    final hotelesSnapshot = await _db.collection('hoteles').limit(1).get();
    if (hotelesSnapshot.docs.isEmpty) {
      for (var hotel in listaHoteles) { await _db.collection('hoteles').doc(hotel['id']).set(hotel);}
    } else {_logger.i("La colección 'hoteles' ya existe. No se crearán nuevos datos.");}
  }

  static Future<List<Map<String, dynamic>>> obtenerHotelesDisponibles({
    required String ciudad,
    required DateTime fecha,
    required int numPersonas,
  }) async {
    final startDate = Timestamp.fromDate(DateTime(fecha.year, fecha.month, fecha.day, 0, 0, 0));
    final endDate = Timestamp.fromDate(DateTime(fecha.year, fecha.month, fecha.day, 23, 59, 59));
    final hoteles = await _db
        .collection('hoteles')
        .where('ciudad', isEqualTo: ciudad)
        .where('fecha', isGreaterThan: startDate)
        .where('fecha', isLessThan: endDate)
        .get();
    List<Map<String, dynamic>> hDisponibles = [];
    for (var doc in hoteles.docs) {
      final data = doc.data();
      final plazas = data['plazas'] ?? 0;
      if (plazas >= numPersonas) {
        hDisponibles.add({
          'id': doc.id,
          ...data,
        });
      }
    } return hDisponibles;
  }


  //Lógica para Vuelos
  static final List<Map<String, dynamic>> listaVuelos = [
    {'id': '1', 'origen': 'Madrid', 'destino': 'Berlín', 'fecha': Timestamp.fromDate(DateTime.parse('2025-07-01T10:00:00.000Z')), 'compania': 'Iberia', 'plazas': 180, 'precio': 120.0, 'tiempo': 170,},
    {'id': '2', 'origen': 'Berlín', 'destino': 'Madrid', 'fecha': Timestamp.fromDate(DateTime.parse('2025-07-15T17:00:00.000Z')), 'compania': 'Lufthansa', 'plazas': 160, 'precio': 125.5, 'tiempo': 170,},
    {'id': '3', 'origen': 'Barcelona', 'destino': 'París', 'fecha': Timestamp.fromDate(DateTime.parse('2025-08-01T08:00:00.000Z')), 'compania': 'Vueling', 'plazas': 150, 'precio': 90.0, 'tiempo': 105,},
    {'id': '4', 'origen': 'París', 'destino': 'Barcelona', 'fecha': Timestamp.fromDate(DateTime.parse('2025-08-07T11:45:00.000Z')), 'compania': 'Air France', 'plazas': 170, 'precio': 95.0, 'tiempo': 110,},
    {'id': '5', 'origen': 'Lisboa', 'destino': 'Málaga', 'fecha': Timestamp.fromDate(DateTime.parse('2025-09-03T15:00:00.000Z')), 'compania': 'Aer Lingus', 'plazas': 160, 'precio': 115.0, 'tiempo': 180,},
    {'id': '6', 'origen': 'Málaga', 'destino': 'Lisboa', 'fecha': Timestamp.fromDate(DateTime.parse('2025-09-10T19:30:00.000Z')), 'compania': 'Ryanair', 'plazas': 190, 'precio': 110.0, 'tiempo': 175,},
    {'id': '7', 'origen': 'Sevilla', 'destino': 'Amsterdam', 'fecha': Timestamp.fromDate(DateTime.parse('2025-10-05T07:45:00.000Z')), 'compania': 'KLM', 'plazas': 170, 'precio': 140.0, 'tiempo': 170,},
    {'id': '8', 'origen': 'Amsterdam', 'destino': 'Sevilla', 'fecha': Timestamp.fromDate(DateTime.parse('2025-10-12T13:15:00.000Z')), 'compania': 'Transavia', 'plazas': 165, 'precio': 135.0, 'tiempo': 165,},
    {'id': '9', 'origen': 'Roma', 'destino': 'Valencia', 'fecha': Timestamp.fromDate(DateTime.parse('2025-11-18T06:30:00.000Z')), 'compania': 'Alitalia', 'plazas': 155, 'precio': 100.0, 'tiempo': 145,},
    {'id': '10', 'origen': 'Valencia', 'destino': 'Roma', 'fecha': Timestamp.fromDate(DateTime.parse('2025-11-25T18:00:00.000Z')), 'compania': 'Vueling', 'plazas': 160, 'precio': 105.0, 'tiempo': 140,},
    {'id': '11', 'origen': 'Madrid', 'destino': 'Roma', 'fecha': Timestamp.fromDate(DateTime.parse('2025-08-09T14:30:00.000Z')), 'compania': 'Iberia', 'plazas': 140, 'precio': 135.0, 'tiempo': 160,},
    {'id': '12', 'origen': 'París', 'destino': 'Amsterdam', 'fecha': Timestamp.fromDate(DateTime.parse('2025-06-08T16:20:00.000Z')), 'compania': 'Air France', 'plazas': 130, 'precio': 80.0, 'tiempo': 90,},
  ];

  static Future<void> crearVuelos() async {
    final snapshot = await _db.collection('vuelos').limit(1).get();
    if (snapshot.docs.isEmpty) {
      for (var vuelo in listaVuelos) {await _db.collection('vuelos').doc(vuelo['id']).set(vuelo);}
    } else { _logger.i("La colección 'vuelos' ya existe. No se crearán nuevos datos.");}
  }

  static Future<List<Map<String, dynamic>>> obtenerVuelosDisponibles({
    required String origen,
    required String destino,
    required DateTime fecha,
    required int numPersonas,
  }) async {
    final startDate = Timestamp.fromDate(DateTime(fecha.year, fecha.month, fecha.day, 0, 0, 0));
    final endDate = Timestamp.fromDate(DateTime(fecha.year, fecha.month, fecha.day, 23, 59, 59));
    final vuelos = await _db
        .collection('vuelos')
        .where('origen', isEqualTo: origen)
        .where('destino', isEqualTo: destino)
        .where('fecha', isGreaterThanOrEqualTo: startDate)
        .where('fecha', isLessThan: endDate)
        .get();
    List<Map<String, dynamic>> vDisponibles = [];
    for (var doc in vuelos.docs) {
      final data = doc.data();
      final plazas = data['plazas'] ?? 0;
      if (plazas >= numPersonas) {
        vDisponibles.add({
          'id': doc.id,
          ...data,
        });
      }
    } return vDisponibles;
  }


  //Lógica para Trenes
  static final List<Map<String, dynamic>> listaTrenes = [
    {'id': '1', 'origen': 'Madrid', 'destino': 'Barcelona', 'fecha': Timestamp.fromDate(DateTime.parse('2025-08-01T09:00:00.000Z')), 'compania': 'Renfe AVE', 'tiempo': 150, 'precio': 65.0, 'plazas': 200,},
    {'id': '2', 'origen': 'Barcelona', 'destino': 'Madrid', 'fecha': Timestamp.fromDate(DateTime.parse('2025-08-07T18:00:00.000Z')), 'compania': 'Renfe AVE', 'tiempo': 150, 'precio': 65.0, 'plazas': 200,},
    {'id': '3', 'origen': 'Lisboa', 'destino': 'Sevilla', 'fecha': Timestamp.fromDate(DateTime.parse('2025-10-05T12:00:00.000Z')), 'compania': 'Renfe AVE', 'tiempo': 160, 'precio': 59.0, 'plazas': 180,},
    {'id': '4', 'origen': 'Sevilla', 'destino': 'Lisboa', 'fecha': Timestamp.fromDate(DateTime.parse('2025-10-12T20:00:00.000Z')), 'compania': 'Renfe AVE', 'tiempo': 160, 'precio': 59.0, 'plazas': 180,},
    {'id': '5', 'origen': 'Málaga', 'destino': 'Valencia', 'fecha': Timestamp.fromDate(DateTime.parse('2025-09-03T08:30:00.000Z')), 'compania': 'Renfe Media Distancia', 'tiempo': 100, 'precio': 22.0, 'plazas': 120,},
    {'id': '6', 'origen': 'Valencia', 'destino': 'Málaga', 'fecha': Timestamp.fromDate(DateTime.parse('2025-11-25T16:00:00.000Z')), 'compania': 'Renfe Media Distancia', 'tiempo': 100, 'precio': 22.0, 'plazas': 120,},
    {'id': '7', 'origen': 'París', 'destino': 'Berlín', 'fecha': Timestamp.fromDate(DateTime.parse('2025-07-01T09:30:00.000Z')), 'compania': 'TGV', 'tiempo': 120, 'precio': 50.0, 'plazas': 150,},
    {'id': '8', 'origen': 'Berlín', 'destino': 'París', 'fecha': Timestamp.fromDate(DateTime.parse('2025-07-15T17:30:00.000Z')), 'compania': 'TGV', 'tiempo': 120, 'precio': 50.0, 'plazas': 150,},
    {'id': '9', 'origen': 'Roma', 'destino': 'Amsterdam', 'fecha': Timestamp.fromDate(DateTime.parse('2025-11-18T11:00:00.000Z')), 'compania': "Trenitalia", "tiempo": 90, "precio": 30.0, "plazas": 100,},
    {'id': '10', 'origen': 'Amsterdam', 'destino': 'Roma', 'fecha': Timestamp.fromDate(DateTime.parse('2025-06-08T11:00:00.000Z')), 'compania': "Trenitalia", "tiempo": 90, "precio": 30.0, "plazas": 100,},
    {'id': '11', 'origen': 'Madrid', 'destino': 'Roma', 'fecha': Timestamp.fromDate(DateTime.parse('2025-08-09T13:00:00.000Z')), 'compania': 'Renfe', 'tiempo': 180, 'precio': 85.0, 'plazas': 160,},
  ];

  static Future<void> crearTrenes() async {
    final snapshot = await _db.collection('trenes').limit(1).get();
    if (snapshot.docs.isEmpty) {
      for (var tren in listaTrenes) {await _db.collection('trenes').doc(tren['id']).set(tren);}
    } else { _logger.i("La colección 'trenes' ya existe. No se crearán nuevos datos.");}
  }

  static Future<List<Map<String, dynamic>>> obtenerTrenesDisponibles({
    required String origen,
    required String destino,
    required DateTime fecha,
    required int numPersonas,
  }) async {
    final startDate = Timestamp.fromDate(DateTime(fecha.year, fecha.month, fecha.day, 0, 0, 0));
    final endDate = Timestamp.fromDate(DateTime(fecha.year, fecha.month, fecha.day, 23, 59, 59));
    final trenes = await _db
        .collection('trenes')
        .where('origen', isEqualTo: origen)
        .where('destino', isEqualTo: destino)
        .where('fecha', isGreaterThanOrEqualTo: startDate)
        .where('fecha', isLessThan: endDate)
        .get();
    List<Map<String, dynamic>> tDisponibles = [];
    for (var doc in trenes.docs) {
      final data = doc.data();
      final plazas = data['plazas'] ?? 0;
      if (plazas >= numPersonas) {
        tDisponibles.add({
          'id': doc.id,
          ...data,
        });
      }
    } return tDisponibles;
  }


  // Lógica para Coches entre ciudades
  static final List<Map<String, dynamic>> cochesEntreCiudades = [
    {'id': '1', 'origen': 'Madrid', 'destino': 'Sevilla', 'empresa': 'Avis', 'modelo': 'Renault Megane', 'precio': 120.0, 'tiempo': 330, 'plazas': 3, 'fecha': Timestamp.fromDate(DateTime.parse('2025-10-05T08:00:00.000Z')),},
    {'id': '2', 'origen': 'Sevilla', 'destino': 'Madrid', 'empresa': 'Avis', 'modelo': 'Renault Megane', 'precio': 120.0, 'tiempo': 330, 'plazas': 3, 'fecha': Timestamp.fromDate(DateTime.parse('2025-10-12T08:00:00.000Z')),},
    {'id': '3', 'origen': 'Barcelona', 'destino': 'Valencia', 'empresa': 'Hertz', 'modelo': 'Peugeot 308', 'precio': 95.0, 'tiempo': 210, 'plazas': 5, 'fecha': Timestamp.fromDate(DateTime.parse('2025-11-25T10:00:00.000Z')),},
    {'id': '4', 'origen': 'Valencia', 'destino': 'Barcelona', 'empresa': 'Hertz', 'modelo': 'Peugeot 308', 'precio': 95.0, 'tiempo': 210, 'plazas': 5, 'fecha': Timestamp.fromDate(DateTime.parse('2025-08-07T10:00:00.000Z')),},
    {'id': '5', 'origen': 'París', 'destino': 'Amsterdam', 'empresa': 'Europcar', 'modelo': 'Citroën C4', 'precio': 160.0, 'tiempo': 360, 'plazas': 5, 'fecha': Timestamp.fromDate(DateTime.parse('2025-06-08T12:00:00.000Z')),},
    {'id': '6', 'origen': 'Amsterdam', 'destino': 'París', 'empresa': 'Europcar', 'modelo': 'Citroën C4', 'precio': 160.0, 'tiempo': 360, 'plazas': 5, 'fecha': Timestamp.fromDate(DateTime.parse('2025-10-05T12:00:00.000Z')),},
    {'id': '7', 'origen': 'Roma', 'destino': 'Berlín', 'empresa': 'Sixt', 'modelo': 'Fiat Tipo', 'precio': 85.0, 'tiempo': 180, 'plazas': 5, 'fecha': Timestamp.fromDate(DateTime.parse('2025-08-09T14:00:00.000Z')),},
    {'id': '8', 'origen': 'Berlín', 'destino': 'Roma', 'empresa': 'Sixt', 'modelo': 'Fiat Tipo', 'precio': 85.0, 'tiempo': 180, 'plazas': 5, 'fecha': Timestamp.fromDate(DateTime.parse('2025-07-01T14:00:00.000Z')),},
    {'id': '9', 'origen': 'Lisboa', 'destino': 'Málaga', 'empresa': 'Enterprise', 'modelo': 'Volkswagen Golf', 'precio': 110.0, 'tiempo': 210, 'plazas': 7, 'fecha': Timestamp.fromDate(DateTime.parse('2025-09-03T16:00:00.000Z')),},
    {'id': '10', 'origen': 'Málaga', 'destino': 'Lisboa', 'empresa': 'Enterprise', 'modelo': 'Volkswagen Golf', 'precio': 110.0, 'tiempo': 210, 'plazas': 7, 'fecha': Timestamp.fromDate(DateTime.parse('2025-09-10T16:00:00.000Z')),},
    {'id': '11', 'origen': 'Madrid', 'destino': 'Roma', 'empresa': 'Hertz', 'modelo': 'BMW Serie 3', 'precio': 180.0, 'tiempo': 420, 'plazas': 5, 'fecha': Timestamp.fromDate(DateTime.parse('2025-08-09T12:00:00.000Z')),},
    {'id': '12', 'origen': 'Barcelona', 'destino': 'París', 'empresa': 'Avis', 'modelo': 'Audi A4', 'precio': 150.0, 'tiempo': 380, 'plazas': 5, 'fecha': Timestamp.fromDate(DateTime.parse('2025-08-01T11:00:00.000Z')),},
  ];

  static final List<Map<String, dynamic>> cochesPorCiudad = [
    {'id': '11', 'ciudad': 'Madrid', 'empresa': 'Hertz', 'modelo': 'Toyota Corolla', 'precio': 45.0, 'plazas': 5, 'fecha': Timestamp.fromDate(DateTime.parse('2025-07-01T10:00:00.000Z'))},
    {'id': '12', 'ciudad': 'Barcelona', 'empresa': 'Avis', 'modelo': 'Volkswagen Polo', 'precio': 40.0, 'plazas': 5, 'fecha': Timestamp.fromDate(DateTime.parse('2025-08-01T12:00:00.000Z'))},
    {'id': '13', 'ciudad': 'Sevilla', 'empresa': 'Sixt', 'modelo': 'Seat Ibiza', 'precio': 38.0, 'plazas': 7, 'fecha': Timestamp.fromDate(DateTime.parse('2025-10-05T14:00:00.000Z'))},
    {'id': '14', 'ciudad': 'Valencia', 'empresa': 'Europcar', 'modelo': 'Ford Focus', 'precio': 42.0, 'plazas': 5, 'fecha': Timestamp.fromDate(DateTime.parse('2025-09-03T14:00:00.000Z'))},
    {'id': '15', 'ciudad': 'París', 'empresa': 'Hertz', 'modelo': 'Peugeot 208', 'precio': 50.0, 'plazas': 3, 'fecha': Timestamp.fromDate(DateTime.parse('2025-08-01T14:00:00.000Z'))},
    {'id': '16', 'ciudad': 'Roma', 'empresa': 'Avis', 'modelo': 'Fiat Panda', 'precio': 39.0, 'plazas': 4, 'fecha': Timestamp.fromDate(DateTime.parse('2025-08-09T14:00:00.000Z'))},
    {'id': '17', 'ciudad': 'Amsterdam', 'empresa': 'Sixt', 'modelo': 'Opel Corsa', 'precio': 44.0, 'plazas': 7, 'fecha': Timestamp.fromDate(DateTime.parse('2025-06-08T14:00:00.000Z'))},
    {'id': '18', 'ciudad': 'Berlín', 'empresa': 'Enterprise', 'modelo': 'BMW Serie 1', 'precio': 60.0, 'plazas': 5, 'fecha': Timestamp.fromDate(DateTime.parse('2025-07-01T14:00:00.000Z'))},
    {'id': '19', 'ciudad': 'Málaga', 'empresa': 'Europcar', 'modelo': 'Nissan Micra', 'precio': 35.0, 'plazas': 4, 'fecha': Timestamp.fromDate(DateTime.parse('2025-09-03T12:00:00.000Z'))},
    {'id': '20', 'ciudad': 'Lisboa', 'empresa': 'Avis', 'modelo': 'Hyundai i20', 'precio': 38.0, 'plazas': 5, 'fecha': Timestamp.fromDate(DateTime.parse('2025-09-10T11:00:00.000Z'))},
  ];

  static Future<void> crearCochesCiudad() async {
    final snapshot = await _db.collection('coches_ciudad').limit(1).get();
    final snapshot2 = await _db.collection('coches_ciudades').limit(1).get();
    if (snapshot.docs.isEmpty) {
      for (var coche in cochesPorCiudad) { await _db.collection('coches_ciudad').doc(coche['id']).set(coche); }
    } else {  _logger.i("La colección 'coches_ciudad' ya existe. No se crearán nuevos datos.");  }
    if (snapshot2.docs.isEmpty) {
      for (var coche in cochesEntreCiudades) { await _db.collection('coches_ciudades').doc(coche['id']).set(coche); }
    } else {  _logger.i("La colección 'coches_ciudades' ya existe. No se crearán nuevos datos.");  }
  }

  static Future<List<Map<String, dynamic>>> obtenerCochesDisponibles({
    required String origen,
    String? destino,
    required int numPersonas,
    required DateTime fecha,
  }) async {
    final startDate = Timestamp.fromDate(DateTime(fecha.year, fecha.month, fecha.day, 0, 0, 0));
    final endDate = Timestamp.fromDate(DateTime(fecha.year, fecha.month, fecha.day, 23, 59, 59));
    List<Map<String, dynamic>> cDisponibles = [];
    if (destino != null && destino.isNotEmpty) {
    final cochesLocales = await _db
        .collection('coches_ciudad')
        .where('ciudad', isEqualTo: destino)
        .where('fecha', isGreaterThanOrEqualTo: startDate)
        .where('fecha', isLessThan: endDate)
        .get();
    for (var doc in cochesLocales.docs) {
      final data = doc.data();
      final plazas = data['plazas'] ?? 0;
      if (plazas >= numPersonas) {
        cDisponibles.add({
          'id': doc.id,
          ...data,
          'tipo': 'local',
        });
      }
    }
  }
  if (destino != null && destino.isNotEmpty) {
    final cochesTrayecto = await _db
        .collection('coches_ciudades')
        .where('origen', isEqualTo: origen)
        .where('destino', isEqualTo: destino)
        .where('fecha', isGreaterThanOrEqualTo: startDate)
        .where('fecha', isLessThan: endDate)
        .get();
    for (var doc in cochesTrayecto.docs) {
      final data = doc.data();
      final plazas = data['plazas'] ?? 0;
      if (plazas >= numPersonas) {
        cDisponibles.add({
          'id': doc.id,
          ...data,
          'tipo': 'trayecto',
        });
      }
    }
  } return cDisponibles;
  }


  // Lógica para actividades
  static final List<Map<String, dynamic>> listaActividades = [
    {'id': '1', 'ciudad': 'Madrid', 'nombre': 'Museo del Prado', 'precio': 15.0, 'descripcion': 'Una de las pinacotecas más importantes del mundo.', 'plazas': 100, 'fecha': Timestamp.fromDate(DateTime.parse('2025-07-01T10:00:00.000Z')),},
    {'id': '2', 'ciudad': 'Madrid', 'nombre': 'Sobrino de Botín', 'precio': 40.0, 'descripcion': 'Restaurante más antiguo del mundo, famoso por su cochinillo asado.', 'plazas': 20, 'fecha': Timestamp.fromDate(DateTime.parse('2025-07-02T12:00:00.000Z')),},
    {'id': '3', 'ciudad': 'Barcelona', 'nombre': 'Parque Güell', 'precio': 10.0, 'descripcion': 'Obra maestra de Gaudí con vistas a la ciudad.', 'plazas': 50, 'fecha': Timestamp.fromDate(DateTime.parse('2025-07-03T14:00:00.000Z')),},
    {'id': '4', 'ciudad': 'Barcelona', 'nombre': 'Tour Sagrada Familia', 'precio': 25.0, 'descripcion': 'Visita guiada por el templo más famoso de Gaudí.', 'plazas': 30, 'fecha': Timestamp.fromDate(DateTime.parse('2025-07-04T16:00:00.000Z')),},
    {'id': '5', 'ciudad': 'Sevilla', 'nombre': 'Flamenco en La Carbonería', 'precio': 20.0, 'descripcion': 'Espectáculo de flamenco tradicional en un local mítico.', 'plazas': 10, 'fecha': Timestamp.fromDate(DateTime.parse('2025-07-05T20:00:00.000Z')),},
    {'id': '6', 'ciudad': 'Sevilla', 'nombre': 'Catedral y Giralda', 'precio': 12.0, 'descripcion': 'Visita a una de las catedrales más grandes del mundo y su torre.', 'plazas': 50, 'fecha': Timestamp.fromDate(DateTime.parse('2025-07-06T11:00:00.000Z')),},
    {'id': '7', 'ciudad': 'París', 'nombre': 'Tour Torre Eiffel', 'precio': 25.0, 'descripcion': 'Acceso a la Torre Eiffel con guía y vistas panorámicas.', 'plazas': 30, 'fecha': Timestamp.fromDate(DateTime.parse('2025-07-07T14:00:00.000Z')),},
    {'id': '8', 'ciudad': 'Roma', 'nombre': 'Coliseo y Foro Romano', 'precio': 30.0, 'descripcion': 'Entrada y recorrido por las ruinas más emblemáticas de Roma.', 'plazas': 50, 'fecha': Timestamp.fromDate(DateTime.parse('2025-07-08T10:00:00.000Z')), },
    {'id': '9', 'ciudad': 'Ámsterdam', 'nombre': 'Crucero por los canales', 'precio': 18.0, 'descripcion': 'Recorrido en barco por los canales de la ciudad.', 'plazas': 50, 'fecha': Timestamp.fromDate(DateTime.parse('2025-07-09T16:00:00.000Z')),},
    {'id': '10', 'ciudad': 'Lisboa', 'nombre': 'Tranvía 28', 'precio': 3.0, 'descripcion': 'Ruta clásica por los barrios históricos en tranvía.', 'plazas': 30, 'fecha': Timestamp.fromDate(DateTime.parse('2025-07-10T12:00:00.000Z')),},
  ];

  static Future<void> crearActividades() async {
    final snapshot = await _db.collection('actividades').limit(1).get();
    if (snapshot.docs.isEmpty) {
      for (var actividad in listaActividades) { await _db.collection('actividades').doc(actividad['id']).set(actividad); }
    } else { _logger.i("La colección 'actividades' ya existe. No se crearán nuevos datos."); }
  }

  static Future<List<Map<String, dynamic>>> obtenerActividadesDisponibles({
    required String ciudad,
    required DateTime fecha,
    required int numPersonas,
  }) async {
    final startDate = Timestamp.fromDate(DateTime(fecha.year, fecha.month, fecha.day, 0, 0, 0));
    final endDate = Timestamp.fromDate(DateTime(fecha.year, fecha.month, fecha.day, 23, 59, 59));
    final actividades = await _db
        .collection('actividades')
        .where('ciudad', isEqualTo: ciudad)
        .where('fecha', isGreaterThanOrEqualTo: startDate)
        .where('fecha', isLessThan: endDate)
        .get();
    List<Map<String, dynamic>> aDisponibles = [];
    for (var doc in actividades.docs) {
      final data = doc.data();
      final plazas = data['plazas'] ?? 0;
      if (plazas >= numPersonas) {
      aDisponibles.add({
        'id': doc.id,
        ...data,
      });
    }} return aDisponibles;
  }


  // Inicializa las colecciones si no existen
  static Future<void> inicializarDatos() async {
    try {
      await crearHoteles();
      await crearVuelos();
      await crearTrenes();
      await crearCochesCiudad();
      await crearActividades();
    } catch (e, stackTrace) {
        _logger.e("Error al inicializar datos", error: e, stackTrace: stackTrace);
        throw Exception("No se pudieron inicializar los datos");
      }
  }


  //Logica reservas
  static Future<void> crearReserva({
    Map<String, dynamic>? vueloSeleccionado,
    Map<String, dynamic>? hotelSeleccionado,
    Map<String, dynamic>? cocheSeleccionado,
    Map<String, dynamic>? trenSeleccionado,
    Map<String, dynamic>? actividadSeleccionada,
    required List<Map<String, TextEditingController>> usuariosControllers,
  }) async {
    try {
      final reservaRef = _db.collection('reservas').doc();
      Map<String, dynamic> reservaData = {
        'fecha_reserva': FieldValue.serverTimestamp(),
        'precio_total': _calcularPrecioTotal([
          vueloSeleccionado,
          hotelSeleccionado,
          cocheSeleccionado,
          trenSeleccionado,
          actividadSeleccionada,
        ]),
      };
      if (vueloSeleccionado != null) {
        final vueloRef = _db.collection('vuelos').doc(vueloSeleccionado['id']);
        reservaData['vuelo'] = vueloRef;
      }
      if (hotelSeleccionado != null) {
        final hotelRef = _db.collection('hoteles').doc(hotelSeleccionado['id']);
        reservaData['hotel'] = hotelRef;
      }
      if (cocheSeleccionado != null) {
        String coleccion = cocheSeleccionado['tipo'] == 'local' ? 'coches_ciudad' : 'coches_ciudades';
        final cocheRef = _db.collection(coleccion).doc(cocheSeleccionado['id']);
        reservaData['coche'] = cocheRef;
      }
      if (trenSeleccionado != null) {
        final trenRef = _db.collection('trenes').doc(trenSeleccionado['id']);
        reservaData['tren'] = trenRef;
      }
      if (actividadSeleccionada != null) {
        final actividadRef = _db.collection('actividades').doc(actividadSeleccionada['id']);
        reservaData['actividad'] = actividadRef;
      }
      await reservaRef.set(reservaData);

      // Añadir subcolección 'usuarios'
      for (int i = 0; i < usuariosControllers.length; i++) {
        final usuario = usuariosControllers[i];
        final userData = {
          'nombre': usuario['nombre']?.text ?? '',
          'apellidos': usuario['apellidos']?.text ?? '',
          'dni': usuario['dni']?.text ?? '',
          'edad': int.tryParse(usuario['edad']?.text ?? '0') ?? 0,
          'email': usuario['email']?.text ?? '',
        };
        await reservaRef.collection('usuarios').add(userData);
      }
    } catch (e, stackTrace) {
        _logger.e('❌ Error al crear la reserva: $e', error: e, stackTrace: stackTrace);
        rethrow;
      }
  }

  static double _calcularPrecioTotal(List<Map<String, dynamic>?> items) {
    double total = 0.0;
    for (var item in items) {
      if (item != null && item['precio'] != null) {
        final precio = item['precio'];
        if (precio is num) {
          total += precio.toDouble();
          _logger.i('💰 Agregando precio: $precio (total actual: $total)');
        } else if (precio is String) {
          final parsedPrice = double.tryParse(precio) ?? 0.0;
          total += parsedPrice;
          _logger.i('💰 Agregando precio (string): $precio -> $parsedPrice (total actual: $total)');
        }
      }
    } return total;
  }

  static Future<void> eliminarReserva(String reservaId) async {
    try {
      final reservaRef = _db.collection('reservas').doc(reservaId);
      await reservaRef.delete();
    } catch (e) {
        _logger.e('Error al eliminar la reserva: $e');
      }
  }

  static Future<void> actualizarReserva(String reservaId, Map<String, dynamic> reservaData) async {
    try {
      final reservaRef = _db.collection('reservas').doc(reservaId);
      await reservaRef.update(reservaData);
    } catch (e) {
        _logger.e('Error al actualizar la reserva: $e');
      }
  }

  static Stream<List<Map<String, dynamic>>> obtenerReservas() {
    return _db.collection('reservas').snapshots().asyncMap((snapshot) async { 
      final reservas = await Future.wait(snapshot.docs.map((doc) async {
        final data = doc.data();
        final Map<String, dynamic> reservaData = {
          'id': doc.id,
          'fecha': data['fecha_reserva'],
          'precio_total': data['precio_total'] ?? 0.0,
        };
        Future<Map<String, dynamic>?> resolverReferencia(dynamic ref, String tipo) async {
          try {
            if (ref == null) {return null;}
            DocumentReference? docRef;
            if (ref is DocumentReference) {docRef = ref;}
            else if (ref is String) {docRef = _db.doc(ref);}
            else {
              _logger.w('❌ $tipo tiene tipo desconocido: ${ref.runtimeType}');
              return null;
            }
            final snap = await docRef.get();
            if (snap.exists) {
              final result = snap.data() as Map<String, dynamic>?;
              return result;
            } else { _logger.w('❌ Documento de $tipo no existe: ${docRef.path}');}
          } catch (e, stackTrace) {
              _logger.e('💥 Error resolviendo $tipo: $e', error: e, stackTrace: stackTrace);
            }return null;
        }
        final vuelo = await resolverReferencia(data['vuelo'], 'vuelo');
        final hotel = await resolverReferencia(data['hotel'], 'hotel');
        final coche = await resolverReferencia(data['coche'], 'coche');
        final tren = await resolverReferencia(data['tren'], 'tren');
        final actividad = await resolverReferencia(data['actividad'], 'actividad');
        reservaData.addAll({
          'vuelo': vuelo,
          'hotel': hotel,
          'coche': coche,
          'tren': tren,
          'actividad': actividad,
        });
        try {
          final usuariosSnapshot = await doc.reference.collection('usuarios').get();
          final usuarios = usuariosSnapshot.docs.map((u) => u.data()).toList();
          reservaData['usuarios'] = usuarios;
        } catch (e) {
          _logger.e('❌ Error obteniendo usuarios: $e');
          reservaData['usuarios'] = [];
        } return reservaData;
      }));
      final reservasFinales = reservas.where((r) => r != null).cast<Map<String, dynamic>>().toList();
      return reservasFinales;
    });
  }
}