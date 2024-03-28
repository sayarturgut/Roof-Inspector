import 'package:flutter/material.dart';
import 'init/theme/app_theme_dark.dart';
import 'pages/main_page.dart';

void main() {
  runApp(const RF());
}

class RF extends StatelessWidget {
  const RF({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      theme: appTheme(context),
      home: const ControlPage(),
    );
  }
}
