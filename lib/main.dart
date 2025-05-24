import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:tripmap/weather_screen.dart';
import 'home_screen.dart';
import 'reservas_screen.dart';
import 'firebase_options.dart';
import 'firestore_service.dart';
import 'galeria_screen.dart';
import 'map_screen.dart';
import 'feedback_screen.dart';
import 'theme.dart';

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
        primaryColor: AppTheme.primaryColor,
        scaffoldBackgroundColor: AppTheme.backgroundColor,
        textTheme: const TextTheme(
          headlineLarge: AppTheme.titleStyle,
          headlineMedium: AppTheme.subtitleStyle,
          bodyLarge: AppTheme.bodyStyle,
          bodyMedium: AppTheme.bodyStyle,
        ),
        elevatedButtonTheme: ElevatedButtonThemeData(
          style: AppTheme.buttonStyle,
        ),
        inputDecorationTheme: InputDecorationTheme(
          border: AppTheme.inputDecoration.border,
          focusedBorder: AppTheme.inputDecoration.focusedBorder,
          enabledBorder: AppTheme.inputDecoration.border,
        ),
        bottomNavigationBarTheme: const BottomNavigationBarThemeData(
          backgroundColor: Colors.white,
          selectedItemColor: AppTheme.primaryColor,
          unselectedItemColor: AppTheme.secondaryColor,
          type: BottomNavigationBarType.fixed,
          elevation: 8,
        ),
        appBarTheme: const AppBarTheme(
          backgroundColor: AppTheme.primaryColor,
          foregroundColor: Colors.white,
          elevation: 4,
          titleTextStyle: TextStyle(
            fontSize: 24,
            fontWeight: FontWeight.bold,
            color: Colors.white,
          ),
        ),
        cardTheme: CardTheme(
          elevation: 4,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(8),
          ),
          margin: const EdgeInsets.all(8),
        ),
        colorScheme: ColorScheme.fromSeed(
          seedColor: AppTheme.primaryColor,
          brightness: Brightness.light,
        ).copyWith(
          surface: Colors.white,
        ),
      ),
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
    // Obtener información sobre el tamaño de pantalla
    final isTablet = AppTheme.isTablet(context);
    final isDesktop = AppTheme.isDesktop(context);

    return Scaffold(
      body: _buildBody(isTablet, isDesktop),
      bottomNavigationBar: _buildBottomNavigation(isTablet),
    );
  }

  Widget _buildBody(bool isTablet, bool isDesktop) {
    if (AppTheme.isDesktop(context)) {
      // Layout para desktop con navegación lateral
      return Row(
        children: [
          NavigationRail(
            selectedIndex: _index,
            onDestinationSelected: (i) => setState(() => _index = i),
            labelType: NavigationRailLabelType.all,
            backgroundColor: Colors.white,
            selectedIconTheme: const IconThemeData(color: AppTheme.primaryColor),
            selectedLabelTextStyle: const TextStyle(color: AppTheme.primaryColor),
            destinations: const [
              NavigationRailDestination(
                icon: Icon(Icons.home_outlined),
                selectedIcon: Icon(Icons.home),
                label: Text('Inicio'),
              ),
              NavigationRailDestination(
                icon: Icon(Icons.list_outlined),
                selectedIcon: Icon(Icons.list),
                label: Text('Reservas'),
              ),
              NavigationRailDestination(
                icon: Icon(Icons.map_outlined),
                selectedIcon: Icon(Icons.map),
                label: Text('Mapa'),
              ),
              NavigationRailDestination(
                icon: Icon(Icons.cloud_outlined),
                selectedIcon: Icon(Icons.cloud),
                label: Text('Clima'),
              ),
              NavigationRailDestination(
                icon: Icon(Icons.photo_outlined),
                selectedIcon: Icon(Icons.photo),
                label: Text('Galería'),
              ),
              NavigationRailDestination(
                icon: Icon(Icons.feedback_outlined),
                selectedIcon: Icon(Icons.feedback),
                label: Text('Feedback'),
              ),
            ],
          ),
          const VerticalDivider(thickness: 1, width: 1),
          Expanded(
            child: _buildIndexedStack(),
          ),
        ],
      );
    } else {
      // Layout normal para móvil y tablet
      return _buildIndexedStack();
    }
  }

  Widget _buildIndexedStack() {
    return IndexedStack(
      index: _index,
      children: const [
        KeyedSubtree(key: ValueKey('HomePage'), child: HomeScreen()),
        KeyedSubtree(key: ValueKey('ReservasPage'), child: ReservasScreen()),
        KeyedSubtree(key: ValueKey('MapPage'), child: MapScreen()),
        KeyedSubtree(key: ValueKey('WeatherPage'), child: WeatherTableScreen()),
        KeyedSubtree(key: ValueKey('GaleriaPage'), child: CrossPlatformImagePicker()),
        KeyedSubtree(key: ValueKey('FeedbackPage'), child: FeedbackScreen()),
      ],
    );
  }

  Widget? _buildBottomNavigation(bool isTablet) {
    // En desktop no mostramos bottom navigation
    if (AppTheme.isDesktop(context)) {
      return null;
    }

    return BottomNavigationBar(
      currentIndex: _index,
      onTap: (i) => setState(() => _index = i),
      type: BottomNavigationBarType.fixed,
      items: const [
        BottomNavigationBarItem(
          icon: Icon(Icons.home_outlined),
          activeIcon: Icon(Icons.home),
          label: 'Inicio',
        ),
        BottomNavigationBarItem(
          icon: Icon(Icons.list_outlined),
          activeIcon: Icon(Icons.list),
          label: 'Reservas',
        ),
        BottomNavigationBarItem(
          icon: Icon(Icons.map_outlined),
          activeIcon: Icon(Icons.map),
          label: 'Mapa',
        ),
        BottomNavigationBarItem(
          icon: Icon(Icons.cloud_outlined),
          activeIcon: Icon(Icons.cloud),
          label: 'Clima',
        ),
        BottomNavigationBarItem(
          icon: Icon(Icons.photo_outlined),
          activeIcon: Icon(Icons.photo),
          label: 'Galería',
        ),
        BottomNavigationBarItem(
          icon: Icon(Icons.feedback_outlined),
          activeIcon: Icon(Icons.feedback),
          label: 'Feedback',
        ),
      ],
    );
  }
}