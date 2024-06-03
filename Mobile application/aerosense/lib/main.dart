import 'package:flutter/material.dart';
import './src/utils/theme/theme.dart';
import './src/screens/splash.dart';
import 'package:get/get.dart';
import 'package:hive_flutter/hive_flutter.dart';
import './src/dependency_injection.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Hive.initFlutter();
  await Hive.openBox("localData");
  await Hive.openBox("userData");
  var localDataBox = Hive.box('localData');
  var accessTokenBox = Hive.box('userData');

  // Check if the user has logged in before
  if (accessTokenBox.get("accessToken") != null) {
    // User has logged in before, so it's not their first time
    localDataBox.put("isFirstTime", false);
  }

  runApp(const App());
  DependencyInjection.init();
}

class App extends StatelessWidget {
  const App({super.key});

  @override
  Widget build(BuildContext context) {
    return GetMaterialApp(
      debugShowCheckedModeBanner: false,
      theme: TAppTheme.themeData,
      home: const Splash(),
    );
  }
}
