import 'package:flutter/material.dart';
import 'package:roffinspection/Container.dart';
import 'package:roffinspection/joystickexample.dart';

class ControlPage extends StatefulWidget {
  const ControlPage({super.key});

  @override
  State<ControlPage> createState() => _ControlPageState();
}

class _ControlPageState extends State<ControlPage> {
  @override
  Widget build(BuildContext context) {
    double screenWidth = MediaQuery.of(context).size.width;
    double screenHeight = MediaQuery.of(context).size.height;
    return Scaffold(
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            GestureDetector(
              child: ContainerCam(
                  singleElement: Text(
                    "Görüntü burada gösterilecek.",
                    textAlign: TextAlign.center,
                  ),
                  containerWidth: screenWidth * 0.5,
                  containerHeight: screenHeight * 0.5),
            ),
            ElevatedButton(
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => MainPage()),
                );
              },
              child: Text('Joystick Örneğine git.'),
            )
          ],
        ),
      ),
    );
  }
}
