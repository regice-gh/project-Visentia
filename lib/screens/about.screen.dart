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
              'Deze app laat zien hoe je weerdata en sentimentanalyse combineert in Flutter.',
            ),
            SizedBox(height: 24),
            Text(
              'Gebruikte packages:',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            SizedBox(height: 8),
            Text('- http (MIT License) – opgehaald van pub.dev'),
            SizedBox(height: 24),
            Text(
              'Licenties voor assets:',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            SizedBox(height: 8),
            Text(
                '• assets/sentiment/model.onnx – HuggingFace sentiment model, Apache 2.0'),
            Text(
                '• assets/sentiment/tokenizer.json – HuggingFace tokenizer, Apache 2.0'),
            SizedBox(height: 24),
            Text(
              'Ontwikkeld door: Gijs Lueb (2025)',
              style: TextStyle(fontStyle: FontStyle.italic),
            ),
          ],
        ),
      ),
    );
  }
}
