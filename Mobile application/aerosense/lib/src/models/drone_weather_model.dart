class DroneWeather {
  final String id;
  final double temperature;
  final String weatherMain;
  final double pm25;
  final double pm10;
  final int uvIndex;

  DroneWeather({
    required this.id,
    required this.temperature,
    required this.weatherMain,
    required this.pm25,
    required this.pm10,
    required this.uvIndex,
  });

  factory DroneWeather.fromJson(Map<String, dynamic> json) {
    return DroneWeather(
      id: json['_id'].toString(),
      temperature: json['temperature'] as double,
      weatherMain: json['weatherMain'][0] as String,
      pm25: (json['pm2_5'] as num).toDouble(),
      pm10: (json['pm10'] as num).toDouble(),
      uvIndex: json['uvIndex'] as int,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      '_id': id,
      'temperature': temperature,
      'weatherMain': [weatherMain],
      'pm2_5': pm25,
      'pm10': pm10,
      'uvIndex': uvIndex,
    };
  }
}
