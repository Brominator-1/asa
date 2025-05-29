import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'screens/profile_screen.dart';
import 'screens/registration_screen.dart';
import 'screens/maintenance_calendar.dart';
import 'screens/maintenance_schedule.dart';
import 'package:intl/date_symbol_data_local.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await initializeDateFormatting('uk', null);
  final prefs = await SharedPreferences.getInstance();
  final bool isRegistered = prefs.getBool('isRegistered') ?? false;

  runApp(MyApp(isRegistered: isRegistered));
}

class MyApp extends StatelessWidget {
  final bool isRegistered;
  const MyApp({super.key, required this.isRegistered});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      theme: ThemeData(primarySwatch: Colors.blue),
      title: 'Авто-сервіс додаток (ASA)',
      home: isRegistered ? MyHomePage() : RegistrationScreen(),
    );
  }
}

class MyHomePage extends StatefulWidget {
  const MyHomePage({super.key});

  @override
  _MyHomePageState createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  int _selectedIndex = 0;
  late GoogleMapController mapController;
  late BitmapDescriptor customIcon;
  final Set<Marker> _markers = {};
  late List<Widget> _pages;

  @override
  void initState() {
    super.initState();
    _loadCustomIcon();
  }

  // Завантаження кастомної іконки
  _loadCustomIcon() async {
    customIcon = await BitmapDescriptor.fromAssetImage(
      const ImageConfiguration(size: Size(24, 24)),
      'assets/marker_icon.png',
    );
    _addMarkers();
  }

  // Додавання маркерів
  _addMarkers() {
    final marker1 = Marker(
      markerId: const MarkerId('1'),
      position: const LatLng(49.779916, 24.091899),
      infoWindow: const InfoWindow(
        title: 'Катівня',
        snippet: 'Тут можна заробити гроші (не точно)',
      ),
      icon: customIcon,
    );

    final marker2 = Marker(
      markerId: const MarkerId('2'),
      position: const LatLng(49.797439, 24.022795),
      infoWindow: const InfoWindow(
        title: 'Відпочивальня',
        snippet: 'Новий день починається тут',
      ),
      icon: customIcon,
    );

    setState(() {
      _markers.addAll([marker1, marker2]);
      _pages = [
        _buildMap(),
        MaintenanceCalendar(),
        MaintenanceCalendarScreen(),
        ProfileScreen(),
        const Text('П’ята кнопка'),
      ];
    });
  }

  // Побудова мапи
  Widget _buildMap() {
    return GoogleMap(
      initialCameraPosition: const CameraPosition(
        target: LatLng(49.8386, 24.0353),
        zoom: 10,
      ),
      markers: _markers,
      onMapCreated: (GoogleMapController controller) {
        mapController = controller;
      },
    );
  }

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Мій авто-додаток')),
      body: _pages.isNotEmpty ? _pages[_selectedIndex] : const Center(child: CircularProgressIndicator()),
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _selectedIndex,
        onTap: _onItemTapped,
        items: const [
          BottomNavigationBarItem(icon: Icon(Icons.map), label: 'Мапа'),
          BottomNavigationBarItem(icon: Icon(Icons.local_parking), label: 'Друга кнопка'),
          BottomNavigationBarItem(icon: Icon(Icons.car_rental), label: 'Третя кнопка'),
          BottomNavigationBarItem(icon: Icon(Icons.build), label: 'Профіль'),
          BottomNavigationBarItem(icon: Icon(Icons.settings), label: 'П’ята кнопка'),
        ],
        selectedItemColor: Colors.blue,
        unselectedItemColor: Colors.grey,
      ),
    );
  }
}
