import 'package:camera/camera.dart';
import 'package:flutter/material.dart';
import 'package:eindopdrachtmad/screens/home.screen.dart';
import 'package:eindopdrachtmad/screens/camera/home.dart';
import 'package:eindopdrachtmad/screens/sentiment.screen.dart';
import 'package:eindopdrachtmad/screens/about.screen.dart';

late List<CameraDescription> cameras;

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // List of cameras on device.
  cameras = await availableCameras();

  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Eindopdracht MAD',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.brown),
        useMaterial3: true,
      ),
      home: const MainNavigation(),
    );
  }
}

class MainNavigation extends StatefulWidget {
  const MainNavigation({super.key});

  @override
  State<MainNavigation> createState() => _MainNavigationState();
}

class _MainNavigationState extends State<MainNavigation> {
  int selectedIndex = 0;

  // Using late to initialize after cameras are available, and making it mutable
  late List<Widget> _widgetOptions;

  @override
  void initState() {
    super.initState();
    _initializeWidgetOptions();
  }

  void _initializeWidgetOptions() {
    _widgetOptions = <Widget>[
      const MainScreen(),
      const SentimentScreen(),
      Home(camera: cameras[0], isActive: selectedIndex == 2),
      const AboutScreen(),
    ];
  }

  void _onItemTapped(int index) {
    setState(() {
      selectedIndex = index;
      _initializeWidgetOptions();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: IndexedStack(
        index: selectedIndex,
        children: _widgetOptions,
      ),
      bottomNavigationBar: BottomNavigationBar(
        items: const <BottomNavigationBarItem>[
          BottomNavigationBarItem(icon: Icon(Icons.house), label: 'Main'),
          BottomNavigationBarItem(
            icon: Icon(Icons.sentiment_satisfied_alt),
            label: 'sentiment',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.camera_alt),
            label: 'Camera',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.info_outline),
            label: 'About',
          ),
        ],
        currentIndex: selectedIndex,
        selectedItemColor: Colors.purpleAccent[100],
        unselectedItemColor: Colors.purple[200],
        onTap: _onItemTapped,
      ),
    );
  }
}
