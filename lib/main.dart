import 'package:flutter/material.dart';

import 'package:eindopdrachtmad/screens/about.screen.dart';
import 'package:eindopdrachtmad/screens/gamble.screen.dart';
import 'package:eindopdrachtmad/screens/home.screen.dart';
import 'package:eindopdrachtmad/screens/form.screen.dart';
import 'package:eindopdrachtmad/theme/app_theme.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Eindopdracht MAD',
      theme: AppTheme.light,
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

  static const List<Widget> _widgetOptions = <Widget>[
    const MainScreen(),
    const GambleScreen(),
    const FormScreen(),
    const AboutScreen(),
  ];

  void _onItemTapped(int index) {
    setState(() {
      selectedIndex = index;
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
              icon: Icon(Icons.casino_outlined), label: 'gambling'),
          BottomNavigationBarItem(
            icon: Icon(Icons.collections_bookmark),
            label: 'Form',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.info_outline),
            label: 'About',
          ),
        ],
        currentIndex: selectedIndex,
        selectedItemColor: Colors.purpleAccent[100],
        unselectedItemColor: Colors.purple[200],
        iconSize: 25,
        elevation: 5,
        onTap: _onItemTapped,
      ),
    );
  }
}
