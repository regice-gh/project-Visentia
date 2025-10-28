import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

class MainScreen extends StatefulWidget {
  const MainScreen({super.key});

  @override
  State<MainScreen> createState() => _MainScreenState();
}

class _MainScreenState extends State<MainScreen> {
  //State Variables Weather API
  bool _isLoadingWeather = true;
  String? _weatherError;
  double? _temperature;
  bool? _isDay;
  int? _weatherTimeUnix;

  @override
  void initState() {
    super.initState();
    _callWeatherApi();
  }

  void _callWeatherApi() async {
    setState(() {
      _isLoadingWeather = true;
      _weatherError = null;
    });

    try {
      const url =
          'https://api.open-meteo.com/v1/forecast?latitude=51.4408&longitude=5.4778&models=best_match&current=temperature_2m,is_day,rain&timeformat=unixtime&timezone=auto&past_days=5';
      final response = await http.get(Uri.parse(url));

      if (response.statusCode == 200) {
        final decodedJson = jsonDecode(response.body) as Map<String, dynamic>;
        final currentWeather = decodedJson['current'] as Map<String, dynamic>;

        setState(() {
          _temperature = currentWeather['temperature_2m'] as double?;
          _isDay = (currentWeather['is_day'] as int?) == 1;
          _weatherTimeUnix = currentWeather['time'] as int?;
          _isLoadingWeather = false;
        });
      } else {
        setState(() {
          _weatherError = "Failed to load weather data: ${response.statusCode}";
          _isLoadingWeather = false;
        });
      }
    } catch (e) {
      setState(() {
        _weatherError = "An error occurred: ${e.toString()}";
        _isLoadingWeather = false;
      });
    }
  }

  String _formatUnixTime(int? unixTime) {
    if (unixTime == null) return 'N/A';
    final dateTime = DateTime.fromMillisecondsSinceEpoch(
      unixTime * 1000,
    ).toLocal();

    final hour = dateTime.hour.toString().padLeft(2, '0');
    final minute = dateTime.minute.toString().padLeft(2, '0');
    return '$hour:$minute';
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Main Screen'),
        centerTitle: true,
        backgroundColor: Colors.purple[200],
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: <Widget>[
            const Padding(
              padding: EdgeInsets.symmetric(vertical: 16.0),
              child: Text(
                'Current Weather:',
                style: TextStyle(fontSize: 24.0, fontWeight: FontWeight.bold),
                textAlign: TextAlign.center,
              ),
            ),
            if (_isLoadingWeather)
              const Center(child: CircularProgressIndicator())
            else if (_weatherError != null)
              Center(
                child: Text(
                  _weatherError!,
                  style: const TextStyle(color: Colors.red, fontSize: 16),
                  textAlign: TextAlign.center,
                ),
              )
            else
              Card(
                elevation: 4,
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        _temperature != null
                            ? 'Temperature: $_temperature°C'
                            : 'Temperature: N/A',
                        style: const TextStyle(fontSize: 18),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        _isDay != null
                            ? 'Daytime: ${_isDay! ? 'Yes' : 'No'}'
                            : 'Daytime: N/A',
                        style: const TextStyle(fontSize: 18),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        'Time: ${_formatUnixTime(_weatherTimeUnix)}',
                        style: const TextStyle(
                          fontSize: 16,
                          color: Colors.grey,
                        ),
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
