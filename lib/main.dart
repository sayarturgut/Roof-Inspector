import 'package:flutter/material.dart';
import 'init/theme/app_theme_dark.dart';
import 'pages/splash_page.dart';

void main() {
  runApp(const RoofInspector());
}

class RoofInspector extends StatelessWidget {
  const RoofInspector({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      theme: appTheme(context),
      home: const SplashScreen(),
    );
  }
}
