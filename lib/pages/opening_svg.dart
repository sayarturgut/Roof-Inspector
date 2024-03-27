import 'package:flutter/material.dart';
import 'package:svg_flutter/svg_flutter.dart';

import 'main_page.dart';
import '../svgs/svg.dart';

class RoofInspector extends StatefulWidget {
  const RoofInspector({Key? key}) : super(key: key);

  @override
  State<RoofInspector> createState() => _RoofInspectorState();
}

class _RoofInspectorState extends State<RoofInspector> {
  @override
  void initState() {
    super.initState();

    Future.delayed(const Duration(seconds: 3), () {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) => const ControlPage()),
      );
    });
  }

  @override
  Widget build(BuildContext context) {
    double screenWidth = MediaQuery.of(context).size.width;
    double screenHeight = MediaQuery.of(context).size.height;
    return Scaffold(
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            SvgPicture.string(
              AnasayfaSVG,
              width: (screenWidth * 0.1),
              height: (screenHeight * 0.1),
            ),
          ],
        ),
      ),
    );
  }
}
