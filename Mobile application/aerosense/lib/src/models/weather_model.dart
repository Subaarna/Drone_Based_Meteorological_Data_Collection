class Weather {
  final String id;
  final double temperature;
  final int timestamp;
  final int humidity;
  final String cityName;
  final String weatherMain;
  final double pm25;
  final double pm10;
  final double longitude;

  Weather({
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

  factory Weather.fromJson(Map<String, dynamic> json) {
    return Weather(
      id: json['_id'],
      temperature: (json['temperature'] - 273.15).toDouble(),
      timestamp: json['timestamp'],
      humidity: json['humidity'],
      cityName: json['cityName'],
      weatherMain: json['weatherMain'],
      pm25: json['pm2_5'],
      pm10: json['pm10'],
      longitude: json['longitude'],
    );
  }

  Map<String, dynamic> toJson() {
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
