import 'dart:async';
import 'package:flutter/material.dart';
import 'package:managify_hr/screens/login/login.dart';
import 'package:managify_hr/screens/dashbord/dashboard_screen.dart';
import 'package:managify_hr/theme/colors.dart';
import 'package:shared_preferences/shared_preferences.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _animation;
  String companylogo = '';

  @override
  void initState() {
    super.initState();
    _loadUserData();

    _controller = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 2),
    );

    _animation = CurvedAnimation(parent: _controller, curve: Curves.easeIn);
    _controller.forward();

    Timer(const Duration(seconds: 2), () async {
      final prefs = await SharedPreferences.getInstance();
      final fullName = prefs.getString('fullName');

      final isLoggedIn = fullName != null && fullName.isNotEmpty;

      Navigator.pushReplacement(
        context,
        PageRouteBuilder(
          transitionDuration: const Duration(milliseconds: 1400),
          pageBuilder: (_, __, ___) =>
          isLoggedIn ? DashboardScreen() : const LoginScreen(),
            transitionsBuilder: (_, animation, __, child) {
              if (isLoggedIn) {
                // DashboardScreen: Slide from Right + Fade
                final slideTween = Tween<Offset>(
                  begin: const Offset(1.0, 0.0),
                  end: Offset.zero,
                ).chain(CurveTween(curve: Curves.fastOutSlowIn));

                final fadeTween = Tween<double>(begin: 0.0, end: 1.0);

                return SlideTransition(
                  position: animation.drive(slideTween),
                  child: FadeTransition(
                    opacity: animation.drive(fadeTween),
                    child: child,
                  ),
                );
              } else {
                // LoginScreen: Slide from Top + Fade
                final slideTween = Tween<Offset>(
                  begin: const Offset(0.0, -1.0),
                  end: Offset.zero,
                ).chain(CurveTween(curve: Curves.easeInOut));

                final fadeTween = Tween<double>(begin: 0.0, end: 1.0);

                return SlideTransition(
                  position: animation.drive(slideTween),
                  child: FadeTransition(
                    opacity: animation.drive(fadeTween),
                    child: child,
                  ),
                );
              }
            }
        ),
      );
    });
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  Future<void> _loadUserData() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      companylogo = prefs.getString('companylogo') ?? '';
    });
  }

  bool _isValidUrl(String url) {
    final uri = Uri.tryParse(url);
    return uri != null &&
        uri.hasAbsolutePath &&
        (uri.isScheme('http') || uri.isScheme('https'));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColor.black,
      body: Center(
        child: FadeTransition(
          opacity: _animation,
          child: _isValidUrl(companylogo)
              ? Image.network(
            companylogo,
            width: 200,
            height: 200,
            errorBuilder: (_, __, ___) => Image.asset(
              'assets/HRM_logo.jpg',
              width: 200,
              height: 200,
            ),
          )
              : Image.asset(
            'assets/HRM_logo.jpg',
            width: 200,
            height: 200,
          ),
        ),
      ),
    );
  }
}
