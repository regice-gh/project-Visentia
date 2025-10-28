import 'package:flutter/material.dart';

import '../services/sentiment-service.dart';

class SentimentScreen extends StatefulWidget {
  const SentimentScreen({super.key});

  @override
  State<SentimentScreen> createState() => _SentimentScreenState();
}

class _SentimentScreenState extends State<SentimentScreen> {
  final _textController = TextEditingController();
  String? _sentiment;
  final SentimentService _sentimentService = SentimentService();

  @override
  void dispose() {
    _textController.dispose();
    super.dispose();
  }

  void _predictSentiment() async {
    print("[_SentimentScreenState] _predictSentiment called.");
    if (_textController.text.isEmpty) {
      print("[_SentimentScreenState] Text is empty.");
      return;
    }
    print(
        "[_SentimentScreenState] Invoking sentiment prediction for text: ${_textController.text}");
    final prediction =
        await _sentimentService.predictSentiment(_textController.text);
    print("[_SentimentScreenState] Received prediction: $prediction");
    setState(() {
      _sentiment = prediction;
    });
    if (_sentiment == null) {
      print(
          "[_SentimentScreenState] Sentiment is null, UI not updated with result.");
    } else {
      print("[_SentimentScreenState] Sentiment updated: $_sentiment");
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Sentiment Analysis'),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            TextField(
              controller: _textController,
              decoration: const InputDecoration(
                labelText: 'Enter a message',
                border: OutlineInputBorder(),
              ),
              minLines: 3,
              maxLines: 5,
            ),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: _predictSentiment,
              child: const Text('Analyze Sentiment'),
            ),
            const SizedBox(height: 24),
            if (_sentiment != null)
              Card(
                elevation: 4.0,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10.0),
                ),
                margin: const EdgeInsets.all(16.0),
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'Analysis Result:',
                        style: TextStyle(
                            fontSize: 20,
                            fontWeight: FontWeight.bold,
                            color: Colors.blueGrey),
                      ),
                      const SizedBox(height: 12),
                      Text(
                        'Sentiment Score: $_sentiment',
                        style: const TextStyle(
                            fontSize: 18, color: Colors.black87),
                      ),
                    ],
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }
}
