import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:http/http.dart' as http;
import 'package:logger/logger.dart';
import './login.dart';
import 'package:hive/hive.dart';

class Archive extends StatefulWidget {
  final String accessToken;

  const Archive({super.key, required this.accessToken});

  @override
  ArchiveState createState() => ArchiveState();
}

class ArchiveState extends State<Archive> {
  late List<Map<String, dynamic>> weekData = [];
  final Logger logger = Logger();

  @override
  void initState() {
    super.initState();
    fetchWeatherData();
  }

  void logout() {
    var box = Hive.box('localData');
    box.clear();
    var accessTokenBox = Hive.box('userData');
    accessTokenBox.clear();

    Get.off(() => const Login(), transition: Transition.fadeIn);
  }

  Future<void> _showLogoutConfirmationDialog(BuildContext context) async {
    return showDialog<void>(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Logout Confirmation'),
          content: const SingleChildScrollView(
            child: ListBody(
              children: <Widget>[
                Text('Are you sure you want to logout?'),
              ],
            ),
          ),
          actions: <Widget>[
            TextButton(
              child: const Text('Cancel'),
              onPressed: () {
                Navigator.of(context).pop(); // Close the dialog
              },
            ),
            TextButton(
              child: const Text('Logout'),
              onPressed: () {
                Navigator.of(context).pop();
                logout();
              },
            ),
          ],
        );
      },
    );
  }

  void fetchWeatherData() async {
    final response = await http.get(Uri.parse(
        'https://meteorological-data-collection-using-wh35.onrender.com/archiveow'));

    if (response.statusCode == 200) {
      final data = json.decode(response.body);
      logger.d('Fetched weather data: $data');

      // Clearing the week data if it exists
      setState(() {
        weekData.clear();
      });

      // Iterate over each weather data from url or API
      data.forEach((date, dayData) {
        // Extracting data from API
        final highestTemperature =
            (dayData['highestTemperature'] - 273.15).toStringAsFixed(1);
        final lowestTemperature =
            (dayData['lowestTemperature'] - 273.15).toStringAsFixed(1);
        final highestHumidity = dayData['highestHumidity'];
        final lowestHumidity = dayData['lowestHumidity'];
        final highestPM25 = dayData['highestPM25'];
        final lowestPM25 = dayData['lowestPM25'];

        // Map to store the day's data
        final dayMap = {
          'date': date,
          'temperature':
              'Temperature: H- $highestTemperature°C L- $lowestTemperature°C',
          'humidity': 'Humidity: H- $highestHumidity% L- $lowestHumidity%',
          'airQuality': 'Airquality: H- $highestPM25 L- $lowestPM25',
          'weatherMain': dayData['mostRepeatedWeatherMain']
        };

        //creating container or changing the state when data is fetched
        setState(() {
          weekData.add(dayMap);
        });
      });
    } else {
      logger.d('Failed to load weather data: ${response.statusCode}');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Row(
          children: [
            SizedBox(width: 50),
            Icon(Icons.calendar_today, size: 16),
            SizedBox(width: 7),
            Text(
              '7 days',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.w700,
              ),
            ),
          ],
        ),
      ),
      body: ListView(
        children: [
          Padding(
            padding: const EdgeInsets.all(20.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: weekData.map((data) {
                return Column(
                  children: [
                    Container(
                      padding:
                          const EdgeInsets.only(left: 15, top: 15, right: 15),
                      width: MediaQuery.of(context).size.width * 0.9,
                      height: MediaQuery.of(context).size.height * 0.18,
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(30),
                        color: Colors.white.withOpacity(0.1),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            mainAxisAlignment: MainAxisAlignment.start,
                            children: [
                              const SizedBox(height: 10),
                              Text(
                                data['date'] ?? '',
                                style: GoogleFonts.raleway(
                                  fontSize: 16,
                                  fontWeight: FontWeight.w300,
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 3.5),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              if (data['weatherMain'] == 'Rain')
                                const Icon(
                                  Icons.thunderstorm,
                                  size: 30,
                                  color: Colors.blue,
                                )
                              else if (data['weatherMain'] == 'Clouds')
                                const Icon(
                                  Icons.cloud,
                                  size: 30,
                                  color: Colors.grey,
                                )
                              else if (data['weatherMain'] == 'Haze')
                                const Icon(
                                  Icons.foggy,
                                  size: 30,
                                  color: Colors.white,
                                )
                              else if (data['weatherMain'] == 'Clear')
                                const Icon(
                                  Icons.sunny,
                                  size: 30,
                                  color: Colors.yellow,
                                )
                              else
                                const Icon(
                                  Icons.cloud,
                                  size: 30,
                                  color: Colors.grey,
                                ),
                              Text(
                                data['temperature'] ?? '',
                                style: GoogleFonts.raleway(
                                  fontSize: 12,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                            ],
                          ),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text(
                                data['weatherMain'] ?? '',
                                style: GoogleFonts.raleway(
                                  fontSize: 12,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                              Text(
                                data['humidity'] ?? '',
                                style: GoogleFonts.raleway(
                                  fontSize: 12,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                            ],
                          ),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.end,
                            children: [
                              Text(
                                data['airQuality'] ?? '',
                                style: GoogleFonts.raleway(
                                  fontSize: 12,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 10),
                  ],
                );
              }).toList(),
            ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          _showLogoutConfirmationDialog(
              context); // Show the confirmation dialog
        },
        child: const Icon(Icons.logout),
      ),
    );
  }
}
