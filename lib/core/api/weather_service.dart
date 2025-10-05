import 'dart:convert';
import 'package:http/http.dart' as http;

class WeatherData {
  final String location;
  final double temperature;
  final String condition;
  final String icon;
  final double humidity;
  final double windSpeed;

  WeatherData({
    required this.location,
    required this.temperature,
    required this.condition,
    required this.icon,
    required this.humidity,
    required this.windSpeed,
  });

  factory WeatherData.fromJson(Map<String, dynamic> json) {
    return WeatherData(
      location: json['name'] ?? 'Unknown',
      temperature: (json['main']['temp'] ?? 0).toDouble(),
      condition: json['weather'][0]['main'] ?? 'Unknown',
      icon: json['weather'][0]['icon'] ?? '01d',
      humidity: (json['main']['humidity'] ?? 0).toDouble(),
      windSpeed: (json['wind']['speed'] ?? 0).toDouble(),
    );
  }
}

class WeatherService {
  static const String _apiKey = 'your_openweather_api_key_here'; // Replace with your API key
  static const String _baseUrl = 'https://api.openweathermap.org/data/2.5/weather';

  Future<WeatherData?> getCurrentWeather(String location) async {
    try {
      final response = await http.get(
        Uri.parse('$_baseUrl?q=$location&appid=$_apiKey&units=metric'),
      );

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        return WeatherData.fromJson(data);
      }
    } catch (e) {
      print('Error fetching weather: $e');
    }
    return null;
  }

  // Mock data for development
  WeatherData getMockWeatherData() {
    return WeatherData(
      location: 'London, UK',
      temperature: 22.5,
      condition: 'Clear',
      icon: '01d',
      humidity: 65.0,
      windSpeed: 3.2,
    );
  }
}
