import 'package:flutter/services.dart';

class SentimentService {
  static final SentimentService _sentimentService =
      SentimentService._internal();

  factory SentimentService() {
    return _sentimentService;
  }
  SentimentService._internal();

  static const platform =
      MethodChannel('com.example.eindopdrachtmad/sentiment');

  Future<String?> predictSentiment(String text) async {
    print("[SentimentService] predictSentiment called for text: $text");
    try {
      final String result =
          await platform.invokeMethod('predictSentiment', {'text': text});
      print("[SentimentService] Received result from native: $result");
      return result;
    } on PlatformException catch (e) {
      print(
          "[SentimentService] Failed to get sentiment: '${e.message}'. Details: ${e.details}");
      return null;
    }
  }
}
