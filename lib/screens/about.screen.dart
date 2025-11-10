import 'package:flutter/material.dart';
import 'package:path/path.dart';

class AboutScreen extends StatefulWidget {
  const AboutScreen({super.key});

  @override
  State<AboutScreen> createState() => _AboutScreenState();
}

class _AboutScreenState extends State<AboutScreen> {
  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Text('About Screen'),
            const Text("Licenses:"),
            const Text("assets/sentiment/model.onnx"),
            const Text("assets/sentiment/tokenizer.json"),
          ],
        ),
      ),
    );
  }
}
