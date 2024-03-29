import 'package:flutter/material.dart';
import 'package:roffinspection/constants/asset_extension.dart';
import 'package:roffinspection/constants/coctext_extension.dart';

import 'main_page.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({Key? key}) : super(key: key);

  @override
  SplashScreenState createState() => SplashScreenState();
}

class SplashScreenState extends State<SplashScreen>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> animation;

  @override
  void initState() {
    super.initState();

    _controller = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 1), // Geçiş animasyonunun süresi
    );

    animation = CurvedAnimation(parent: _controller, curve: Curves.easeInOut);

    _controller.forward();

    Future.delayed(const Duration(seconds: 3), () {
      Navigator.pushReplacement(
        context,
        PageRouteBuilder(
          pageBuilder: (_, __, ___) => const ControlPage(),
          transitionsBuilder: (_, animation, __, child) {
            return FadeTransition(
              opacity: animation,
              child: child,
            );
          },
        ),
      );
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Image.asset(
              'example_logo'.toPng,
              width: context.customWidthValue(0.4),
              height: context.customHeigthValue(0.4),
            )
          ],
        ),
      ),
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }
}
