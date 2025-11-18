import 'package:flutter/material.dart';

import 'package:eindopdrachtmad/screens/about.screen.dart';
import 'package:eindopdrachtmad/screens/home.screen.dart';
import 'package:eindopdrachtmad/screens/sentiment.screen.dart';

void main() {
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

  static const List<Widget> _widgetOptions = <Widget>[
    const MainScreen(),
    const SentimentScreen(),
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
            icon: Icon(Icons.sentiment_satisfied_alt),
            label: 'sentiment',
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
