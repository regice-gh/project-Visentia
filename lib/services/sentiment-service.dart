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
    try {
      final String result =
          await platform.invokeMethod('predictSentiment', {'text': text});
      return result;
    } on PlatformException catch (e) {
      return null;
    }
  }
}
