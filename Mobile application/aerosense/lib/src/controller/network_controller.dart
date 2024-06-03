import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../screens/splash.dart';

class NetworkController extends GetxController {
  final Connectivity _connectivity = Connectivity();
  final GlobalKey<NavigatorState> navigatorKey = GlobalKey<NavigatorState>();
  late final String accessToken;
  @override
  void onInit() {
    super.onInit();
    _connectivity.onConnectivityChanged.listen(_updateConnectionStatus);
  }

  void _updateConnectionStatus(
      List<ConnectivityResult> connectivityResultList) {
    ConnectivityResult connectivityResult = connectivityResultList.first;

    if (connectivityResult == ConnectivityResult.none) {
      _showSnackbar();
    } else {
      if (Get.isSnackbarOpen) {
        Get.closeCurrentSnackbar();

        reloadAppContent();
      }
    }
  }

  void _showSnackbar() {
    Get.rawSnackbar(
      messageText: const Text(
        'Please connect to the internet',
        style: TextStyle(color: Colors.white, fontSize: 16),
      ),
      isDismissible: false,
      duration: const Duration(days: 1),
      backgroundColor: const Color.fromARGB(255, 0, 0, 0).withOpacity(0.1),
      icon: const Icon(
        Icons.wifi_off,
        color: Colors.white,
        size: 40,
      ),
      margin: EdgeInsets.zero,
      borderRadius: 20,
      snackStyle: SnackStyle.FLOATING,
      barBlur: 20,
      forwardAnimationCurve: Curves.easeInOut,
      reverseAnimationCurve: Curves.easeInOut,
      animationDuration: const Duration(milliseconds: 500),
    );
  }

  void reloadAppContent() {
    Get.offAll(() => const Splash());
  }
}
