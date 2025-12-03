import 'package:flutter/material.dart';

class AboutScreen extends StatefulWidget {
  const AboutScreen({super.key});

  @override
  State<AboutScreen> createState() => _AboutScreenState();
}

class _AboutScreenState extends State<AboutScreen> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('About this app'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: const [
            Text(
              'MAD final assessment',
              style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
            ),
            SizedBox(height: 12),
            Text(
              'This app demonstrates how to build consistent theming, forms with validation, and game elements in Flutter.',
            ),
            SizedBox(height: 24),
            Text(
              'Features:',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            SizedBox(height: 8),
            Text('• Weather overview with detail page'),
            Text('• Student form with validation and feedback'),
            Text('• Dice game with dice-poker ranking'),
            SizedBox(height: 24),
            Text(
              'Assets:',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            SizedBox(height: 8),
            Text('• Dice images found online'),
            Text('• Weather API found online'),
            SizedBox(height: 24),
            Text('weather API license:\n'
                '• CC BY 4.0 License Requirement\n'
                '• https://open-meteo.com\n'),
            Text('This project is for educational purposes only.\n'),
            Text(
              'Made by: Gijs Lueb (2025)',
              style: TextStyle(fontStyle: FontStyle.italic),
            ),
          ],
        ),
      ),
    );
  }
}
