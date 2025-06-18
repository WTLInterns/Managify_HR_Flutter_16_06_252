import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:managify_hr/screens/splash/splash.dart';
import 'package:managify_hr/services/background_location_services.dart';
import 'package:managify_hr/services/location_service.dart';
import 'package:managify_hr/theme/app_theme.dart';
import 'package:managify_hr/theme/colors.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  try {
    await LocationService.instance.initialize();
    await BackgroundLocationService.initialize();
  } catch (e) {
    print("Initialization error: $e");
  }

  SystemChrome.setSystemUIOverlayStyle(
    const SystemUiOverlayStyle(
      statusBarColor: AppColor.black,
      statusBarIconBrightness: Brightness.light,
    ),
  );

  runApp(const MyApp());
}

class MyApp extends StatefulWidget {
  const MyApp({super.key});

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  final AppLifecycleObserver _lifecycleObserver = AppLifecycleObserver();
  bool _isDarkMode = false;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(_lifecycleObserver);
    Future.delayed(const Duration(seconds: 2), () {
      _startLocationTracking();
    });
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(_lifecycleObserver);
    LocationService.instance.dispose();
    super.dispose();
  }

  Future<void> _startLocationTracking() async {
    try {
      await LocationService.instance.startLocationTracking();
      await BackgroundLocationService.startBackgroundTracking();
    } catch (e) {
      print('Tracking error: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      theme: AppTheme.lightTheme,
      darkTheme: AppTheme.darkTheme,
      themeMode: _isDarkMode ? ThemeMode.dark : ThemeMode.light,
      home: const SplashScreen(),
    );
  }
}
