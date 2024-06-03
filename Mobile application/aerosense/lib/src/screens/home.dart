import 'package:aerosense/src/models/historicalOw.dart';
import 'package:aerosense/src/utils/theme/socket_utils.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import 'package:lottie/lottie.dart';
import '../models/weather_model.dart';
import 'package:logger/logger.dart';
import '../models/initial_utils.dart';
import 'package:get/get.dart';
import './homeDrone.dart';
import './archive.dart';

class Home extends StatefulWidget {
  final String accessToken;

  const Home({super.key, required this.accessToken});

  @override
  HomeState createState() => HomeState();
}

class HomeState extends State<Home> {
  Weather? currentWeather;
  double pm25Value = 0;
  double temperature = 0;
  String condition = '';
  int humidity = 0;
  String header = 'OpenWeather';
  String city = '';
  double highestTemperature = 0;
  double lowestTemperature = 0;
  double highestPM25 = 0;
  double lowestPM25 = 0;
  int highestHumidity = 0;
  int lowestHumidity = 0;

  final Logger logger = Logger();
  final historicalData = HistoricalData();
  String getWeatherAnimation(String condition) {
    switch (condition.toLowerCase()) {
      case 'clouds':
      case 'mist':
      case 'smoke':
      case 'fog':
      case 'dust':
      case 'haze':
        return 'assets/lottie/cloudy.json';
      case 'rain':
      case 'drizzle':
      case 'shower rain':
        return 'assets/lottie/rainy.json';
      case 'thunderstorm':
        return 'assets/lottie/thunder.json';
      case 'clear':
        return 'assets/lottie/sunny.json';
      case 'snow':
        return 'assets/lottie/snow.json';
      default:
        return 'assets/lottie/thunder.json';
    }
  }

  @override
  void initState() {
    super.initState();
    logger.d('Access Token: ${widget.accessToken}');
    // Fetch initial data when the app starts
    InitialData.fetchData().then((_) {
      setState(() {
        logger.d('Access Token: ${widget.accessToken}');
        // Update state variables with the fetched data
        pm25Value = InitialData.weatherData.first.pm25;
        temperature = InitialData.weatherData.first.temperature;
        humidity = InitialData.weatherData.first.humidity;
        condition = InitialData.weatherData.first.weatherMain;
        city = InitialData.weatherData.first.cityName;

        // Print fetched data
        logger.d('Fetched data: ${InitialData.weatherData}');
      });
    }).catchError((error) {
      logger.d('Failed to fetch initial data: $error');
    });
    // Fetch initial data when the app starts
    historicalData.fetchData().then((_) {
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
    }).catchError((error) {
      logger.d('Failed to fetch historical data: $error');
    });

    SocketUtils.socket.on('connect', (_) {
      logger.d('connect');
    });

    SocketUtils.socket.on('dataUpdate', (data) {
      logger.i(data);
      updateWeather(Weather.fromJson(data.first));
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
                        Get.to(() => HomeDrone(accessToken: widget.accessToken),
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
                              const SizedBox(width: 2),
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
                            width: 200,
                            height: 200,
                            // fit: BoxFit.fill,
                            // filterQuality: FilterQuality.high,
                            // repeat: true,
                            // animate: true,
                            // reverse: false,
                            // alignment: Alignment.center,
                            // frameRate: FrameRate.max
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
                                    inactiveTrackColor: const Color.fromARGB(
                                        255, 0, 0, 0), // Color when inactive
                                    disabledInactiveTrackColor:
                                        const Color.fromARGB(
                                            255, 158, 158, 158),
                                    disabledActiveTrackColor: Colors.red,
                                    thumbShape: const RoundSliderThumbShape(
                                      enabledThumbRadius:
                                          3.0, // Adjust the size of the thumb
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
                                        '2 - Low',
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
                                                3.0, // Adjust the size of the thumb
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
                                                () => Archive(
                                                    accessToken:
                                                        widget.accessToken),
                                                transition: Transition.fadeIn);
                                          }, // Add onPressed callback function
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
  void updateWeather(Weather weather) {
    if (!mounted) return;
    setState(() {
      currentWeather = weather;
      condition = weather.weatherMain;
      humidity = weather.humidity;
      city = weather.cityName;
      temperature = weather.temperature;
      pm25Value = weather.pm25;
    });
  }
}
