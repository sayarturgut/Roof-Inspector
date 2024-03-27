import 'package:flutter/material.dart';
import 'package:flutter_joystick/flutter_joystick.dart';
import 'package:roffinspection/constants/coctext_extension.dart';

class ControlPage extends StatefulWidget {
  const ControlPage({super.key});

  @override
  State<ControlPage> createState() => _ControlPageState();
}

class _ControlPageState extends State<ControlPage> {
  double _y = 100;
  double step = 10.0;
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color.fromARGB(255, 76, 68, 68),
      appBar: AppBar(
        backgroundColor: const Color.fromARGB(255, 255, 204, 51),
      ),
      body: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          GestureDetector(
            onHorizontalDragUpdate: (details) {
              double xThreshold = 20.0;
              if (details.delta.dx.abs() > details.delta.dy.abs() &&
                  details.delta.dx.abs() > xThreshold) {
                if (details.delta.dx > 0) {
                  snackBar(context, 'Kamera Sola Donduruluyor');
                } else {
                  snackBar(context, 'Kamera Saga Donduruluyor');
                }
              }
            },
            onVerticalDragUpdate: (details) {
              double yThreshold = 20.0;
              if (details.delta.dy.abs() > details.delta.dx.abs() &&
                  details.delta.dy.abs() > yThreshold) {
                if (details.delta.dy > 0) {
                  snackBar(context, 'Kamera Yukariya Donduruluyor');
                } else {
                  snackBar(context, 'Kamera Asagiya Donduruluyor');
                }
              }
            },
            child: SizedBox(
              height: context.customHeigthValue(0.6),
              width: context.customWidthValue(0.6),
              child: const Card(),
            ),
          ),
          Row(
            children: [
              Joystick(
                mode: JoystickMode.vertical,
                listener: (details) {
                  setState(() {
                    _y = _y + step * details.y;
                  });
                },
              ),
            ],
          )
        ],
      ),
    );
  }

  void snackBar(BuildContext context, String text) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        duration: const Duration(milliseconds: 500),
        content: Text(
          text,
          textAlign: TextAlign.center,
          style: const TextStyle(
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
    );
  }
}
