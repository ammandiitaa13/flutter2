import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:tripmap/weather_screen.dart';
import 'home_screen.dart';
import 'reservas_screen.dart';
import 'firebase_options.dart';
import 'firestore_service.dart';
import 'galeria_screen.dart';
import 'feedback_screen.dart';
import 'package:responsive_framework/responsive_framework.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);
  await FirestoreService.inicializarDatos();
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'TripMap',
      theme: ThemeData(
        primarySwatch: Colors.deepPurple,
        textTheme: Typography.material2018().black.copyWith(
          // Definir estilos de texto adaptables
          bodyLarge: TextStyle(fontSize: 16, fontFamily: 'Roboto'),
          bodyMedium: TextStyle(fontSize: 14, fontFamily: 'Roboto'),
          titleLarge: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, fontFamily: 'Roboto'),
        ),
        bottomNavigationBarTheme: const BottomNavigationBarThemeData(
          backgroundColor: Colors.white,
          selectedItemColor: Colors.deepPurple,
          unselectedItemColor: Colors.grey,
        ),
      ),
      builder: (context, child) {
        return MediaQuery(
          // Establece un límite de escala de texto para evitar textos demasiado grandes
          data: MediaQuery.of(context).copyWith(textScaler: TextScaler.linear(MediaQuery.of(context).textScaleFactor.clamp(0.8, 1.3))),
          child: ResponsiveBreakpoints.builder(
            child: child!,
            breakpoints: [
              const Breakpoint(start: 0, end: 450, name: MOBILE),
              const Breakpoint(start: 451, end: 800, name: TABLET),
              const Breakpoint(start: 801, end: 1920, name: DESKTOP),
              const Breakpoint(start: 1921, end: double.infinity, name: '4K'),
            ],
          ),
        );
      },
      home: const BottomNavController(),
    );
  }
}

class BottomNavController extends StatefulWidget {
  const BottomNavController({super.key});

  @override
  BottomNavControllerState createState() => BottomNavControllerState();
}

class BottomNavControllerState extends State<BottomNavController> {
  int _index = 0;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: IndexedStack(
        index: _index,
        children: [
          const KeyedSubtree(key: ValueKey('HomePage'), child: HomeScreen()),
          const KeyedSubtree(key: ValueKey('ReservasPage'), child: ReservasScreen()),
          const KeyedSubtree(key: ValueKey('WeatherPage'), child: WeatherTableScreen()),
          const KeyedSubtree(key: ValueKey('GaleriaPage'), child: CrossPlatformImagePicker()),
          const KeyedSubtree(key: ValueKey('FeedbackPage'), child: FeedbackScreen()),
        ],
      ),
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _index,
        onTap: (i) {
          setState(() => _index = i);
        },
        items: const [
          BottomNavigationBarItem(icon: Icon(Icons.home), label: 'Inicio'),
          BottomNavigationBarItem(icon: Icon(Icons.list), label: 'Reservas'),
          BottomNavigationBarItem(icon: Icon(Icons.cloud), label: 'Clima'),
          BottomNavigationBarItem(icon: Icon(Icons.photo), label: 'Galería'),
          BottomNavigationBarItem(icon: Icon(Icons.feedback), label: 'Feedback'),
        ],
      ),
    );
  }
}