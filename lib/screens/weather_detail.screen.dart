import 'package:flutter/material.dart';

class WeatherDetailScreen extends StatelessWidget {
  final double? temperature;
  final bool? isDay;
  final int? weatherTimeUnix;

  const WeatherDetailScreen({
    super.key,
    required this.temperature,
    required this.isDay,
    required this.weatherTimeUnix,
  });

  String _formatUnixTime(int? unixTime) {
    if (unixTime == null) return 'Onbekend';
    final dateTime = DateTime.fromMillisecondsSinceEpoch(unixTime * 1000)
        .toLocal();
    final hour = dateTime.hour.toString().padLeft(2, '0');
    final minute = dateTime.minute.toString().padLeft(2, '0');
    return '$hour:$minute';
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Weerdetails'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Card(
          elevation: 4,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          child: Padding(
            padding: const EdgeInsets.all(20.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Text(
                  'Temperatuur: ${temperature != null ? '${temperature!.toStringAsFixed(1)}°C' : 'Onbekend'}',
                  style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 12),
                Text(
                  'Is het dag? ${isDay == null ? 'Onbekend' : (isDay! ? 'Ja' : 'Nee')}',
                  style: const TextStyle(fontSize: 16),
                ),
                const SizedBox(height: 12),
                Text(
                  'Gemeten om: ${_formatUnixTime(weatherTimeUnix)}',
                  style: const TextStyle(fontSize: 16),
                ),
                const Spacer(),
                ElevatedButton.icon(
                  onPressed: () => Navigator.pop(context),
                  icon: const Icon(Icons.arrow_back),
                  label: const Text('Terug naar hoofdscherm'),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
