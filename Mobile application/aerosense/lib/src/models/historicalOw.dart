// {
//     "highestTemperature": 301.27,
//     "lowestTemperature": 289.27,
//     "highestPM25": 81.82,
//     "lowestPM25": 35.34,
//     "highestHumidity": 77,
//     "lowestHumidity": 32
// }
import 'package:http/http.dart' as http;
import 'dart:convert';

class HistoricalData {
  static const String baseUrl =
      'https://meteorological-data-collection-using-wh35.onrender.com';
  static late List<HistoricalWeather> weatherData;
  Future<void> fetchData() async {
    final response = await http.get(Uri.parse('$baseUrl/historicalowData'));
    if (response.statusCode == 200) {
      final jsonData = json.decode(response.body);

      // Create a single HistoricalWeather instance from the JSON data
      final historicalWeather = HistoricalWeather.fromJson(jsonData);

      // Store the single HistoricalWeather instance in the weatherData list
      weatherData = [historicalWeather];
    } else {
      throw Exception('Failed to fetch data');
    }
  }
}

class HistoricalWeather {
  final double highestTemperatureCelsius;
  final double lowestTemperatureCelsius;
  final double highestPM25;
  final double lowestPM25;
  final int highestHumidity;
  final int lowestHumidity;

  HistoricalWeather({
    required this.highestTemperatureCelsius,
    required this.lowestTemperatureCelsius,
    required this.highestPM25,
    required this.lowestPM25,
    required this.highestHumidity,
    required this.lowestHumidity,
  });

  factory HistoricalWeather.fromJson(Map<String, dynamic> json) {
    final double highestTemperatureCelsius =
        json['highestTemperature'] - 273.15;
    final double lowestTemperatureCelsius = json['lowestTemperature'] - 273.15;

    return HistoricalWeather(
      highestTemperatureCelsius: highestTemperatureCelsius,
      lowestTemperatureCelsius: lowestTemperatureCelsius,
      highestPM25: json['highestPM25'],
      lowestPM25: json['lowestPM25'],
      highestHumidity: json['highestHumidity'],
      lowestHumidity: json['lowestHumidity'],
    );
  }
}
