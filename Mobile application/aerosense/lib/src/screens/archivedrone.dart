import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:http/http.dart' as http;
import 'package:logger/logger.dart';
import './login.dart';
import 'package:hive/hive.dart';

class ArchiveDrone extends StatefulWidget {
  final String accessToken;

  const ArchiveDrone({super.key, required this.accessToken});

  @override
  ArchiveState createState() => ArchiveState();
}

class ArchiveState extends State<ArchiveDrone> {
  late List<Map<String, dynamic>> weekData = [];
  final Logger logger = Logger();
  @override
  void initState() {
    super.initState();
    getDataForLastWeekDrone(); // Change to call the new function
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

  void getDataForLastWeekDrone() async {
    final response = await http.get(Uri.parse(
        'https://drone-based-meteorological-data.onrender.com/archivedr'));

    if (response.statusCode == 200) {
      final data = json.decode(response.body);
      logger.d('Fetched drone data: $data');

      setState(() {
        weekData.clear();
      });

      data.forEach((date, dayData) {
        final highestTemperature =
            (dayData['highestTemperature']).toStringAsFixed(1);
        final lowestTemperature =
            (dayData['lowestTemperature']).toStringAsFixed(1);
        final highestPM25 = dayData['highestPM25'].toDouble();
        final lowestPM25 = dayData['lowestPM25'].toDouble();

        final dayMap = {
          'date': date,
          'temperature':
              'Temperature: H- $highestTemperature°C L- $lowestTemperature°C',
          'airQuality': 'Airquality: H- $highestPM25 L- $lowestPM25',
          'weatherMain': dayData['mostRepeatedWeatherMain']
        };

        setState(() {
          weekData.add(dayMap);
        });
      });
    } else {
      logger.d('Failed to load drone data: ${response.statusCode}');
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
          _showLogoutConfirmationDialog(context);
        },
        child: const Icon(Icons.logout),
      ),
    );
  }
}
