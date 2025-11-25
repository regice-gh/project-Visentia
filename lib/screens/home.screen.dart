import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

import '../theme/app_theme.dart';
import 'weather_detail.screen.dart';

class MainScreen extends StatefulWidget {
  const MainScreen({super.key});

  @override
  State<MainScreen> createState() => _MainScreenState();
}

class _MainScreenState extends State<MainScreen> {
  //Variables Weather API
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
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Main Screen'),
      ),
      body: Padding(
        padding: AppSpacing.screenPadding,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: <Widget>[
            Padding(
              padding: const EdgeInsets.only(bottom: AppSpacing.section),
              child: Text(
                'Current weather',
                style: theme.textTheme.headlineSmall,
                textAlign: TextAlign.center,
              ),
            ),
            if (_isLoadingWeather)
              const Center(child: CircularProgressIndicator())
            else if (_weatherError != null)
              Center(
                child: Text(
                  _weatherError!,
                  style: theme.textTheme.bodyLarge?.copyWith(
                    color: theme.colorScheme.error,
                  ),
                  textAlign: TextAlign.center,
                ),
              )
            else
              Card(
                child: Padding(
                  padding: const EdgeInsets.all(AppSpacing.section),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        _temperature != null
                            ? 'Temperature: ${_temperature!.toStringAsFixed(1)}°C'
                            : 'Temperature: N/A',
                        style: theme.textTheme.titleMedium,
                      ),
                      const SizedBox(height: AppSpacing.item),
                      Text(
                        _isDay != null
                            ? 'Daytime: ${_isDay! ? 'Yes' : 'No'}'
                            : 'Daytime: N/A',
                        style: theme.textTheme.bodyLarge,
                      ),
                      const SizedBox(height: AppSpacing.item),
                      Text(
                        'Time: ${_formatUnixTime(_weatherTimeUnix)}',
                        style: theme.textTheme.bodyMedium,
                      ),
                      const SizedBox(height: AppSpacing.section),
                      ElevatedButton(
                        onPressed: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (_) => WeatherDetailScreen(
                                temperature: _temperature,
                                isDay: _isDay,
                                weatherTimeUnix: _weatherTimeUnix,
                              ),
                            ),
                          );
                        },
                        child: const Text('View details'),
                      ),
                    ],
                  ),
                ),
              ),
            const Spacer(),
          ],
        ),
      ),
    );
  }
}
