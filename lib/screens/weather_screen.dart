import 'package:flutter/material.dart';
import 'package:flutter_weather_app/services/weather_service.dart';
import 'package:lottie/lottie.dart';
import 'package:provider/provider.dart';

import '../models/theme.dart';
import '../models/weather_model.dart';
class WeatherScreen extends StatefulWidget {
  const WeatherScreen({super.key});

  @override
  State<WeatherScreen> createState() => _WeatherScreenState();
}

class _WeatherScreenState extends State<WeatherScreen> {
  final _WeatherService = WeatherService(apiKey: "afec2c92872c258881a63c6d94d88bee");
  Weather? _weather;
  bool _isLoading = true;
  String? _error;

  Future<void> _fetchWeather() async {
    try {
      String cityName = await _WeatherService.getCurrentCity();
      final weather = await _WeatherService.getWeather(cityName);
      setState(() {
        _weather = weather;
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _error = "Failed to fetch weather data.";
        _isLoading = false;
      });
      print("Weather fetch error: $e");
    }
  }

  // Get weather animation based on condition
  String getWeatherAnimations({
    required String? mainCondition,
    required String? iconCode,
    required int? cloudPercent,
  }) {
    if (mainCondition == null || iconCode == null) {
      return 'assets/notfound.json';
    }

    final isNight = iconCode.endsWith('n');
    final lowerCondition = mainCondition.toLowerCase();

    if (lowerCondition == 'clear' && isNight) {
      return 'assets/moon.json';
    }

    if (lowerCondition == 'clouds' &&
        (cloudPercent != null && cloudPercent <= 50)) {
      return 'assets/sunny_cloudy.json';
    }

    switch (lowerCondition) {
      case 'clouds':
        return 'assets/cloudy.json';
      case 'rain':
        return 'assets/rain.json';
      case 'drizzle':
        return 'assets/drizzle.json';
      case 'thunderstorm':
        return 'assets/thunder.json';
      case 'clear':
        return 'assets/sunny.json';
      case 'mist':
      case 'haze':
      case 'fog':
        return 'assets/foggy.json';
      default:
        return 'assets/notfound.json';
    }
  }

  String _getGreetings() {
    int hour = DateTime.now().hour;
    if (hour < 12) {
      return 'Bonjour! Good Morning 🌄';
    } else if (hour < 17) {
      return 'Bonjour! Good Afternoon 🕑';
    } else if (hour < 20) {
      return 'Bonjour! Good Evening 🌆';
    } else {
      return 'Gute Nacht 🌃';
    }
  }

  @override
  void initState() {
    super.initState();
    _fetchWeather();
  }

  @override
  Widget build(BuildContext context) {
    final themeProvider = Provider.of<ThemeProvider>(context);

    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      body: Container(
        padding: const EdgeInsets.only(top: 50, left: 20, right: 20),
        child: _isLoading
            ? const Center(child: CircularProgressIndicator())
            : _error != null
            ? Center(
          child: Text(
            _error!,
            style: const TextStyle(
                fontSize: 18, color: Colors.redAccent),
          ),
        )
            : Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Row: Greeting + Theme toggle
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  _getGreetings(),
                  style: TextStyle(
                    fontSize: 24,
                    color: Colors.grey,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                IconButton(
                  onPressed: () {
                    themeProvider.toggleTheme();
                  },
                  icon: Icon(
                    themeProvider.isDarkMode
                        ? Icons.wb_sunny_outlined
                        : Icons.nightlight_round,
                    color: Colors.grey[700],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 100),

            // City
            Center(
              child: Column(
                children: [
                  Icon(
                    Icons.location_on_rounded,
                    size: 30,
                    color: Colors.grey.shade500,
                  ),
                  Text(
                    _weather!.cityName,
                    style: const TextStyle(
                      fontSize: 28,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 30),

            // Animation
            Center(
              child: Lottie.asset(
                getWeatherAnimations(
                  mainCondition: _weather!.mainCondition,
                  iconCode: _weather!.iconCode,
                  cloudPercent: _weather!.cloudPercentage,
                ),
              ),
            ),

            const SizedBox(height: 70),

            // Temperature
            Center(
              child: Text(
                '${_weather!.temperature.round()}℃',
                style: const TextStyle(fontSize: 40),
              ),
            ),
            const SizedBox(height: 10),

            // Condition
            Center(
              child: Text(
                _weather!.mainCondition,
                style: const TextStyle(
                  fontSize: 28,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
