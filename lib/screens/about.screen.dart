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
              'Licenties voor assets:',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            SizedBox(height: 8),
            Text('• assets/sentiment/model.onnx – HuggingFace sentiment model'),
            Text('• assets/sentiment/tokenizer.json – HuggingFace tokenizer\n'),
            Text('Creator: Tabularis.ai\n'
                'License Type: CC BY-NC 4.0\n'
                'https://huggingface.co/tabularisai/multilingual-sentiment-analysis'),
            SizedBox(height: 24),
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
