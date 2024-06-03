import 'package:flutter/material.dart';
import 'package:lottie/lottie.dart';

import '../utils/theme/socket_utils.dart';
import 'login.dart';
import 'dart:async';
import 'home.dart';
import 'package:hive/hive.dart';

class Splash extends StatefulWidget {
  const Splash({super.key});

  @override
  State<Splash> createState() => _SplashState();
}

class _SplashState extends State<Splash> {
  @override
  void initState() {
    super.initState();

    startTimer();
    SocketUtils.connect();
  }

  startTimer() {
    var duration = const Duration(seconds: 5);
    return Timer(duration, route);
  }

  route() async {
    var box = Hive.box('localData');
    var accessTokenBox = Hive.box('userData');

    bool isFirstTime = box.get("isFirstTime") ?? true;
    String? accessToken = accessTokenBox.get("accessToken");
    logger.d("accessToken: $accessToken");
    Navigator.of(context).pushReplacement(
      PageRouteBuilder(
        pageBuilder: (context, animation, secondaryAnimation) =>
            isFirstTime || accessToken == null
                ? const Login()
                : Home(accessToken: accessToken),
        transitionsBuilder: (context, animation, secondaryAnimation, child) {
          return FadeTransition(opacity: animation, child: child);
        },
        transitionDuration: const Duration(milliseconds: 300),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Theme(
      data: ThemeData.dark(),
      child: Scaffold(
        body: content(),
      ),
    );
  }

  Widget content() {
    return Center(
      child: Container(
        child: Lottie.asset('assets/lottie/splash.json'),
      ),
    );
  }
}
