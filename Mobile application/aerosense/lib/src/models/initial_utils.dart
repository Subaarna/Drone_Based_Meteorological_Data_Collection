import 'package:http/http.dart' as http;
import 'dart:convert';

class InitialData {
  static const String baseUrl =
      'https://drone-based-meteorological-data.onrender.com';
  static late List<InitialWeather> weatherData;
  static Future<void> fetchData() async {
    final response = await http.get(Uri.parse('$baseUrl/initialData'));
    if (response.statusCode == 200) {
      final jsonData = json.decode(response.body);
      weatherData = List<InitialWeather>.from(
          jsonData.map((data) => InitialWeather.fromJson(data)));
    } else {
      throw Exception('Failed to fetch data');
    }
  }
}

class InitialWeather {
  final String id;
  final double temperature;
  final int timestamp;
  final int humidity;
  final String cityName;
  final String weatherMain;
  final double pm25;
  final double pm10;
  final double longitude;

  InitialWeather({
    required this.id,
    required this.temperature,
    required this.timestamp,
    required this.humidity,
    required this.cityName,
    required this.weatherMain,
    required this.pm25,
    required this.pm10,
    required this.longitude,
  });

  factory InitialWeather.fromJson(Map<String, dynamic> json) {
    return InitialWeather(
      id: json['_id'],
      temperature: (json['temperature'] - 273.15).toDouble(),
      timestamp: json['timestamp'],
      humidity: json['humidity'],
      cityName: json['cityName'],
      weatherMain: json['weatherMain'],
      pm25: (json['pm2_5'] as num).toDouble(),
      pm10: (json['pm10'] as num).toDouble(),
      longitude: (json['longitude'] as num).toDouble(),
    );
  }

  Map<String, dynamic> toInitialJson() {
    return {
      '_id': id,
      'temperature': temperature,
      'timestamp': timestamp,
      'humidity': humidity,
      'cityName': cityName,
      'weatherMain': weatherMain,
      'pm2_5': pm25,
      'pm10': pm10,
      'longitude': longitude,
    };
  }
}
