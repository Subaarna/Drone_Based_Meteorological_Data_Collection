import 'package:aerosense/src/models/drone_weather_model.dart';
import 'package:aerosense/src/models/historicalOw.dart';
import 'package:aerosense/src/utils/theme/socket_utils.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import 'package:lottie/lottie.dart';
import '../models/weather_model.dart';
import 'package:logger/logger.dart';
import './home.dart';
import '../models/initial_utils.dart';
import 'package:geocoding/geocoding.dart';
import 'package:geolocator/geolocator.dart';
import './archivedrone.dart';

class HomeDrone extends StatefulWidget {
  final String accessToken;

  const HomeDrone({super.key, required this.accessToken});

  @override
  HomeDroneState createState() => HomeDroneState();
}

class HomeDroneState extends State<HomeDrone> {
  Weather? currentHumidity;
  DroneWeather? currentWeather;
  double pm25Value = 0;
  double temperature = 0;
  String condition = '';
  int humidity = 0;
  String header = 'Drone';
  String city = '';
  double highestTemperature = 0;
  double lowestTemperature = 0;
  double highestPM25 = 0;
  double lowestPM25 = 0;
  int highestHumidity = 0;
  int lowestHumidity = 0;
  int uvIndex = 0;

  final Logger logger = Logger();
  final historicalData = HistoricalData();
  String getWeatherAnimation(String condition) {
    switch (condition.toLowerCase()) {
      case 'cloudy':
      case 'mist':
      case 'smoke':
      case 'foggy':
      case 'dust':
        return 'assets/lottie/cloudy.json';
      case 'rainy':
      case 'drizzle':
      case 'shower rain':
        return 'assets/lottie/rainy.json';
      case 'thunderstorm':
        return 'assets/lottie/thunder.json';
      case 'sunny':
        return 'assets/lottie/sunny.json';
      case 'snowy':
        return 'assets/lottie/snow.json';
      default:
        return 'assets/lottie/cloudy.json';
    }
  }

  @override
  void initState() {
    super.initState();
    _getCurrentLocation();
    InitialData.fetchData().then((_) {
      if (mounted) {
        setState(() {
          logger.d('Access Token: ${widget.accessToken}');

          humidity = InitialData.weatherData.first.humidity;

          // Print fetched data
          logger.d('Fetched data: ${InitialData.weatherData}');
        });
      }
    }).catchError((error) {
      logger.d('Failed to fetch initial data: $error');
    });
    historicalData.fetchData().then((_) {
      if (mounted) {
        setState(() {
          // Update state variables with the fetched historical data
          highestTemperature =
              HistoricalData.weatherData.first.highestTemperatureCelsius;
          lowestTemperature =
              HistoricalData.weatherData.first.lowestTemperatureCelsius;
          highestPM25 = HistoricalData.weatherData.first.highestPM25;
          lowestPM25 = HistoricalData.weatherData.first.lowestPM25;
          highestHumidity = HistoricalData.weatherData.first.highestHumidity;
          lowestHumidity = HistoricalData.weatherData.first.lowestHumidity;

          // Print fetched data
          logger.d('Fetched historical data: ${HistoricalData.weatherData}');
        });
      }
    }).catchError((error) {
      logger.d('Failed to fetch historical data: $error');
    });

    SocketUtils.socket.on('connect', (_) {
      logger.d('connect');
    });

    // SocketUtils.socket.on('dataUpdate', (data) {
    //   logger.i(data);
    //   updateHumidity(Weather.fromJson(data.humidity.first));
    // });
    SocketUtils.socket.on('DroneDataUpdate', (dronedata) {
      if (mounted) {
        logger.i(dronedata);
        updateWeather(DroneWeather.fromJson(dronedata.first));
      }
    });
  }

  // Function to calculate slider value based on air quality index
  double calculateSliderValue(double airQualityIndex) {
    if (airQualityIndex >= 0 && airQualityIndex <= 30) {
      return 20; // for "good" AQI range
    } else if (airQualityIndex > 30 && airQualityIndex <= 60) {
      return 40; //for "satisfactory" AQI range
    } else if (airQualityIndex > 60 && airQualityIndex <= 90) {
      return 60; //for "moderately polluted" AQI range
    } else if (airQualityIndex > 90 && airQualityIndex <= 120) {
      return 80; //for "poor" AQI range
    } else if (airQualityIndex > 120 && airQualityIndex <= 250) {
      return 90; //"very poor" AQI range
    } else {
      return 100; //for "severe" AQI range
    }
  }

  String getHealthEffect(double pm25Value) {
    if (pm25Value >= 0 && pm25Value <= 30) {
      return 'Low Health Risk';
    } else if (pm25Value > 30 && pm25Value <= 60) {
      return 'Moderate Health Risk';
    } else if (pm25Value > 60 && pm25Value <= 90) {
      return 'High Health Risk';
    } else if (pm25Value > 90 && pm25Value <= 120) {
      return 'Very High Health Risk';
    } else {
      return 'Severe Health Risk';
    }
  }

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        Image.asset(
          'assets/icons/blur.png',
          width: MediaQuery.of(context).size.width,
          height: MediaQuery.of(context).size.height,
          fit: BoxFit.fill,
          filterQuality: FilterQuality.high,
        ),
        Scaffold(
          backgroundColor: Colors.transparent,
          extendBodyBehindAppBar: true,
          body: CustomScrollView(
            slivers: [
              SliverAppBar(
                title: Row(
                  children: [
                    const Padding(padding: EdgeInsets.only(left: 20)),
                    Text(
                      header,
                      style: GoogleFonts.raleway(
                        textStyle: const TextStyle(
                          fontSize: 24,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    ),
                    const Spacer(),
                    IconButton(
                      icon: Image.asset('assets/icons/park.png'),
                      onPressed: () {
                        Get.to(() => Home(accessToken: widget.accessToken),
                            transition: Transition.fadeIn);
                      },
                      padding: EdgeInsets.zero,
                    ),
                  ],
                ),
                automaticallyImplyLeading: false,
                backgroundColor: Colors.transparent,
                elevation: 0,
                pinned: false, // Set to false to hide AppBar when scrolling
                systemOverlayStyle: const SystemUiOverlayStyle(
                  statusBarColor: Colors.transparent,
                  statusBarBrightness: Brightness.dark,
                ),
              ),
              SliverList(
                delegate: SliverChildListDelegate(
                  [
                    Padding(
                      padding: const EdgeInsets.only(left: 10, right: 10),
                      child: Column(
                        children: [
                          const SizedBox(height: 10),
                          Row(
                            children: [
                              const SizedBox(width: 20),
                              Image.asset(
                                'assets/icons/Map.png',
                              ),
                              const SizedBox(width: 10),
                              Text(
                                city,
                                style: const TextStyle(
                                  color: Colors.white,
                                  fontSize: 16,
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                            ],
                          ),
                          Lottie.asset(
                            getWeatherAnimation(condition),
                            width: 180,
                            height: 180,
                          ),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Text(
                                '${temperature.toInt()}',
                                style: GoogleFonts.reemKufiFun(
                                  textStyle: const TextStyle(
                                    fontSize: 70,
                                    fontWeight: FontWeight.w600,
                                    color: Colors.white,
                                  ),
                                ),
                              ),
                              Text(
                                '°',
                                style: GoogleFonts.reemKufiFun(
                                  textStyle: const TextStyle(
                                    fontSize: 60,
                                    fontWeight: FontWeight.w100,
                                    color: Colors.white,
                                  ),
                                ),
                              ),
                            ],
                          ),
                          Text(
                            condition,
                            style: GoogleFonts.raleway(
                              textStyle: const TextStyle(
                                fontSize: 20,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                          ),
                          Text(
                            DateFormat('EEEE, d MMM').format(DateTime.now()),
                            style: GoogleFonts.raleway(
                              textStyle: const TextStyle(
                                fontSize: 20,
                                fontWeight: FontWeight.w300,
                              ),
                            ),
                          ),
                          const Divider(
                            color: Colors.white,
                            thickness: 1,
                          ),
                          Text(
                            'Humidity: $humidity%',
                            style: GoogleFonts.raleway(
                              textStyle: const TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                          ),
                          const SizedBox(height: 15),
                          Container(
                            padding: const EdgeInsets.only(
                                left: 15, top: 15, right: 15),
                            width: MediaQuery.of(context).size.width * 0.9,
                            height: MediaQuery.of(context).size.height * 0.17,
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(30),
                              color: Colors.white.withOpacity(0.1),
                            ),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Row(
                                  children: [
                                    const Icon(Icons.air_outlined),
                                    const SizedBox(width: 2),
                                    Text("AIR QUALITY",
                                        style: GoogleFonts.raleway(
                                          fontSize: 13,
                                          fontWeight: FontWeight.w600,
                                        )),
                                  ],
                                ),
                                const SizedBox(height: 3.5),
                                Text(
                                  '$pm25Value µg/m³ - ${getHealthEffect(pm25Value)}',
                                  style: GoogleFonts.raleway(
                                    fontSize: 14,
                                    fontWeight: FontWeight.w700,
                                  ),
                                ),
                                SliderTheme(
                                  data: SliderTheme.of(context).copyWith(
                                    thumbColor: Colors.white, // Thumb color
                                    disabledThumbColor:
                                        Colors.white, // Disabled thumb color
                                    trackHeight:
                                        3.0, //height of the slider track
                                    activeTrackColor:
                                        Colors.red, // Color when active
                                    inactiveTrackColor:
                                        Colors.red, // Color when inactive
                                    disabledInactiveTrackColor: Colors.grey,
                                    disabledActiveTrackColor: Colors.red,
                                    thumbShape: const RoundSliderThumbShape(
                                      enabledThumbRadius:
                                          5.0, // Adjust the size of the thumb
                                    ),
                                  ),
                                  child: Slider(
                                    value: calculateSliderValue(
                                        pm25Value), // Dynamic value based on air quality index
                                    min: 0,
                                    max: 100,
                                    onChanged: null, // Disable user interaction
                                  ),
                                ),
                              ],
                            ),
                          ),
                          const SizedBox(height: 10),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.start,
                            children: [
                              Padding(
                                padding:
                                    const EdgeInsets.only(bottom: 70, left: 10),
                                child: Container(
                                  padding: const EdgeInsets.only(
                                    left: 15,
                                    top: 15,
                                    right: 15,
                                  ),
                                  width:
                                      MediaQuery.of(context).size.width * 0.4,
                                  height:
                                      MediaQuery.of(context).size.height * 0.17,
                                  decoration: BoxDecoration(
                                    borderRadius: BorderRadius.circular(30),
                                    color: Colors.white.withOpacity(0.1),
                                  ),
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Row(
                                        children: [
                                          const Icon(Icons.unarchive_rounded),
                                          const SizedBox(width: 2),
                                          Text("UV Index",
                                              style: GoogleFonts.raleway(
                                                fontSize: 13,
                                                fontWeight: FontWeight.w600,
                                              )),
                                        ],
                                      ),
                                      const SizedBox(height: 3.5),
                                      Text(
                                        '$uvIndex',
                                        style: GoogleFonts.raleway(
                                          fontSize: 14,
                                          fontWeight: FontWeight.w700,
                                        ),
                                      ),
                                      SliderTheme(
                                        data: SliderTheme.of(context).copyWith(
                                          thumbColor:
                                              Colors.white, // Thumb color
                                          disabledThumbColor: Colors
                                              .white, // Disabled thumb color
                                          trackHeight:
                                              3.0, //height of the slider track
                                          activeTrackColor:
                                              Colors.red, // Color when active
                                          inactiveTrackColor:
                                              Colors.red, // Color when inactive
                                          disabledInactiveTrackColor:
                                              Colors.grey,
                                          disabledActiveTrackColor: Colors.red,
                                          thumbShape:
                                              const RoundSliderThumbShape(
                                            enabledThumbRadius:
                                                5.0, // Adjust the size of the thumb
                                          ),
                                        ),
                                        child: Slider(
                                          value: calculateSliderValue(
                                              pm25Value), // Dynamic value based on air quality index
                                          min: 0,
                                          max: 100,
                                          onChanged:
                                              null, // Disable user interaction
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                              const SizedBox(width: 5),
                              Padding(
                                padding: const EdgeInsets.only(bottom: 10),
                                child: Container(
                                  padding: const EdgeInsets.only(
                                    left: 15,
                                    top: 15,
                                    right: 15,
                                  ),
                                  width:
                                      MediaQuery.of(context).size.width * 0.5,
                                  height:
                                      MediaQuery.of(context).size.height * 0.26,
                                  decoration: BoxDecoration(
                                    borderRadius: BorderRadius.circular(30),
                                    color: Colors.white.withOpacity(0.1),
                                  ),
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Row(
                                        children: [
                                          const Icon(Icons.archive_outlined),
                                          const SizedBox(width: 2),
                                          Text("Weather Archives",
                                              style: GoogleFonts.raleway(
                                                fontSize: 13,
                                                fontWeight: FontWeight.w600,
                                              )),
                                        ],
                                      ),
                                      const SizedBox(height: 1),
                                      Text("Yesterday",
                                          style: GoogleFonts.raleway(
                                            fontSize: 12,
                                            fontWeight: FontWeight.w600,
                                          )),
                                      const Divider(
                                        color: Colors.white,
                                        thickness: 1,
                                      ),
                                      Text(
                                          "Temperature: H:${highestTemperature.toInt()}C L:${lowestTemperature.toInt()}C",
                                          style: GoogleFonts.inter(
                                            fontSize: 11,
                                            fontWeight: FontWeight.w600,
                                          )),
                                      Text(
                                          "Humidity: H:${highestHumidity.toInt()}% L:${lowestHumidity.toInt()}%",
                                          style: GoogleFonts.raleway(
                                            fontSize: 12,
                                            fontWeight: FontWeight.w600,
                                          )),
                                      Text(
                                          "Air Quality: H:${highestPM25.toInt()}% L:${lowestPM25.toInt()}%",
                                          style: GoogleFonts.raleway(
                                            fontSize: 12,
                                            fontWeight: FontWeight.w600,
                                          )),
                                      const Divider(
                                        color: Colors.white,
                                        thickness: 1,
                                      ),
                                      Center(
                                        child: TextButton(
                                          onPressed: () {
                                            Get.to(
                                                () => ArchiveDrone(
                                                    accessToken:
                                                        widget.accessToken),
                                                transition: Transition.fadeIn);
                                          },
                                          style: ButtonStyle(
                                            padding: MaterialStateProperty.all<
                                                EdgeInsetsGeometry>(
                                              EdgeInsets.zero,
                                            ),
                                          ),
                                          child: Text(
                                            "See more >>>",
                                            style: GoogleFonts.raleway(
                                              fontSize: 12,
                                              fontWeight: FontWeight.w600,
                                            ),
                                          ),
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

// Callback function to update weather data
  void updateHumidity(Weather weather) {
    setState(() {
      humidity = weather.humidity;
    });
  }

  void updateWeather(DroneWeather droneWeather) {
    setState(() {
      currentWeather = droneWeather;
      condition = droneWeather.weatherMain;
      temperature = droneWeather.temperature;
      pm25Value = droneWeather.pm25;
      uvIndex = droneWeather.uvIndex;
    });
  }

  void _getCurrentLocation() async {
    try {
      LocationPermission permission = await Geolocator.checkPermission();
      if (permission == LocationPermission.denied) {
        permission = await Geolocator.requestPermission();
        if (permission == LocationPermission.denied) {
          throw Exception('Location permissions are denied');
        }
      }

      Position position = await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.high,
      );

      List<Placemark> placemarks = await placemarkFromCoordinates(
        position.latitude,
        position.longitude,
      );

      setState(() {
        city = placemarks.first.locality ?? 'Unknown';
      });
    } catch (e) {
      logger.d('Error getting location: $e');
    }
  }
}
