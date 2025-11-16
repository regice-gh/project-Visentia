import 'package:flutter/material.dart';

import '../services/sentiment-service.dart';

class SentimentScreen extends StatefulWidget {
  const SentimentScreen({super.key});

  @override
  State<SentimentScreen> createState() => _SentimentScreenState();
}

class _SentimentScreenState extends State<SentimentScreen> {
  final _formKey = GlobalKey<FormState>();
  final _textController = TextEditingController();
  String? _sentiment;
  bool _isLoading = false;
  String? _error;
  final SentimentService _sentimentService = SentimentService();

  @override
  void dispose() {
    _textController.dispose();
    super.dispose();
  }

  void _predictSentiment() async {
    if (!(_formKey.currentState?.validate() ?? false)) {
      return;
    }
    setState(() {
      _isLoading = true;
      _error = null;
      _sentiment = null;
    });
    final prediction =
        await _sentimentService.predictSentiment(_textController.text);

    setState(() {
      _isLoading = false;
      if (prediction != null) {
        _sentiment = prediction;
      } else {
        _error = "Failed to analyze sentiment. Check logs for details.";
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          title: const Text('Sentiment Analysis'),
        ),
        body: SingleChildScrollView(
          padding: const EdgeInsets.all(16.0),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                TextFormField(
                  controller: _textController,
                  decoration: const InputDecoration(
                    labelText: 'Enter a message',
                    border: OutlineInputBorder(),
                  ),
                  minLines: 3,
                  maxLines: 5,
                  validator: (value) {
                    if (value == null || value.trim().isEmpty) {
                      return 'Please enter some text to analyze';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 16),
                ElevatedButton(
                  onPressed: _isLoading ? null : _predictSentiment,
                  child: _isLoading
                      ? const SizedBox(
                          height: 20,
                          width: 20,
                          child: CircularProgressIndicator(
                            strokeWidth: 2,
                            valueColor:
                                AlwaysStoppedAnimation<Color>(Colors.white),
                          ),
                        )
                      : const Text('Analyze Sentiment'),
                ),
                const SizedBox(height: 24),
                if (_error != null)
                  Card(
                    elevation: 4.0,
                    color: Colors.red.shade50,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10.0),
                    ),
                    margin: const EdgeInsets.all(16.0),
                    child: Padding(
                      padding: const EdgeInsets.all(16.0),
                      child: Row(
                        children: [
                          const Icon(Icons.error_outline, color: Colors.red),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Text(
                              _error!,
                              style: const TextStyle(
                                fontSize: 16,
                                color: Colors.red,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
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
                            'Sentiment: $_sentiment',
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
        ));
  }
}
