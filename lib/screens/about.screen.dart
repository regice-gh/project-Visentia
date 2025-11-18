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
              'Eindopdracht MAD',
              style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
            ),
            SizedBox(height: 12),
            Text(
              'Deze app demonstreert hoe je consistente theming, formulieren met validatie en spelelementen bouwt in Flutter.',
            ),
            SizedBox(height: 24),
            Text(
              'Functionaliteiten:',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            SizedBox(height: 8),
            Text('• Weer-overzicht met detailpagina'),
            Text('• Studentformulier met validatie en feedback'),
            Text('• Dobbelspel met dice-poker ranking'),
            SizedBox(height: 24),
            Text(
              'Assets:',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            SizedBox(height: 8),
            Text('• Dice-afbeeldingen gevonden op internet'),
            Text('• Weather api gevonden op internet'),
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
