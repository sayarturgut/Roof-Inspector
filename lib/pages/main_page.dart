import 'package:flutter/material.dart';
import 'package:flutter_joystick/flutter_joystick.dart';
import 'package:roffinspection/constants/asset_extension.dart';
import 'package:roffinspection/constants/coctext_extension.dart';
import 'package:google_fonts/google_fonts.dart';

class ControlPage extends StatefulWidget {
  const ControlPage({super.key});

  @override
  State<ControlPage> createState() => _ControlPageState();
}

class _ControlPageState extends State<ControlPage> {
  final Color mainYellow = const Color.fromARGB(255, 255, 204, 51);
  final Color mainGrey = const Color.fromARGB(255, 76, 68, 68);
  double _y = 100;
  double _x = 100;
  double step = 10.0;
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: mainGrey,
      appBar: AppBar(
        backgroundColor: mainYellow,
        actions: appBarButtons(context),
        actionsIconTheme: const IconThemeData(
          color: Colors.black,
          size: 30,
        ),
      ),
      body: Stack(
        children: [
          camViewColumn(context),
          joystickRow(context),
        ],
      ),
    );
  }

  List<Widget> appBarButtons(BuildContext context) {
    return [
      ElevatedButton(
        onPressed: () {},
        child: Row(
          children: [
            const Icon(
              Icons.cast_outlined,
              color: Colors.red,
            ),
            SizedBox(
              height: context.customHeigthValue(0.01),
              width: context.customWidthValue(0.01),
            ),
            Text(
              'Disconnect',
              style: GoogleFonts.openSans(
                textStyle: TextStyle(
                  color: mainYellow,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ],
        ),
      ),
      SizedBox(
        height: context.customHeigthValue(0.02),
        width: context.customWidthValue(0.21),
      ),
      ElevatedButton(
        onPressed: () {},
        child: Text(
          'Roof Inspector Connected',
          style: GoogleFonts.openSans(
            textStyle: const TextStyle(
                color: Colors.green, fontWeight: FontWeight.bold, fontSize: 24),
          ),
        ),
      ),
      SizedBox(
        height: context.customHeigthValue(0.02),
        width: context.customWidthValue(0.18),
      ),
      ElevatedButton(
        onPressed: () {},
        child: Icon(
          Icons.network_wifi_3_bar_outlined,
          color: mainYellow,
        ),
      ),
      SizedBox(
        height: context.customHeigthValue(0.02),
        width: context.customWidthValue(0.02),
      ),
      ElevatedButton(
        onPressed: () {},
        child: Row(
          children: [
            Text(
              '%75',
              style: GoogleFonts.openSans(
                textStyle:
                    TextStyle(color: mainYellow, fontWeight: FontWeight.bold),
              ),
            ),
            SizedBox(
              height: context.customHeigthValue(0.01),
              width: context.customWidthValue(0.01),
            ),
            Icon(
              Icons.battery_5_bar_outlined,
              color: mainYellow,
            ),
          ],
        ),
      ),
      SizedBox(
        height: context.customHeigthValue(0.02),
        width: context.customWidthValue(0.02),
      ),
    ];
  }

  Center camViewColumn(BuildContext context) {
    return Center(
      child: Column(
        children: [
          SizedBox(
            height: context.customHeigthValue(0.05),
            width: context.customWidthValue(0.05),
          ),
          SizedBox(
            height: context.customHeigthValue(0.115),
            width: context.customWidthValue(0.65),
            child: Card(
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(50)),
              child: buttonSetRow(context),
            ),
          ),
          SizedBox(
            height: context.customHeigthValue(0.03),
            width: context.customWidthValue(0.03),
          ),
          GestureDetector(
            onHorizontalDragEnd: (details) {
              if (details.primaryVelocity! > 0) {
                snackBar(context, 'Camera is being turned to the left');
              } else if (details.primaryVelocity! < 0) {
                snackBar(context, 'Camera is being turned to the right');
              }
            },
            onVerticalDragEnd: (details) {
              if (details.primaryVelocity! > 0) {
                snackBar(context, 'Camera is being turned to the up');
              } else if (details.primaryVelocity! < 0) {
                snackBar(context, 'Camera is being turned to the down');
              }
            },
            child: SizedBox(
              height: context.customHeigthValue(0.65),
              width: context.customWidthValue(0.65),
              child: Padding(
                padding: const EdgeInsets.all(3.0),
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(50),
                  child: Image(
                    fit: BoxFit.fill,
                    image: AssetImage('damaged_roof'.toJpg),
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Row buttonSetRow(BuildContext context) {
    return Row(
      children: [
        SizedBox(
          height: context.customHeigthValue(0.02),
          width: context.customWidthValue(0.02),
        ),
        Container(
          decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(30),
              border: Border.all(color: mainYellow)),
          child: ElevatedButton(
            onPressed: () {
              snackBar(context, 'Video Recording has started');
            },
            child: Row(
              children: [
                Icon(
                  Icons.play_circle_fill_outlined,
                  color: mainYellow,
                ),
                SizedBox(
                  height: context.customHeigthValue(0.01),
                  width: context.customWidthValue(0.01),
                ),
                Text(
                  'Start Recording',
                  style: GoogleFonts.openSans(
                    textStyle: TextStyle(
                        color: mainYellow, fontWeight: FontWeight.bold),
                  ),
                )
              ],
            ),
          ),
        ),
        SizedBox(
          height: context.customHeigthValue(0.01),
          width: context.customWidthValue(0.01),
        ),
        Container(
          decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(30),
              border: Border.all(color: mainYellow)),
          child: ElevatedButton(
            onPressed: () {
              snackBar(context, 'Video Recording has stoped');
            },
            child: Row(
              children: [
                Icon(
                  Icons.pause_circle_filled_outlined,
                  color: mainYellow,
                ),
                SizedBox(
                  height: context.customHeigthValue(0.01),
                  width: context.customWidthValue(0.01),
                ),
                Text(
                  'Stop Recording',
                  style: GoogleFonts.openSans(
                    textStyle: TextStyle(
                        color: mainYellow, fontWeight: FontWeight.bold),
                  ),
                )
              ],
            ),
          ),
        ),
        SizedBox(
          height: context.customHeigthValue(0.01),
          width: context.customWidthValue(0.01),
        ),
        Container(
          decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(30),
              border: Border.all(color: mainYellow)),
          child: ElevatedButton(
            onPressed: () {
              snackBar(context, 'Photo has been taken and saved.');
            },
            child: Row(
              children: [
                Icon(
                  Icons.photo_camera_rounded,
                  color: mainYellow,
                ),
                SizedBox(
                  height: context.customHeigthValue(0.01),
                  width: context.customWidthValue(0.01),
                ),
                Text(
                  'Take a Photo',
                  style: GoogleFonts.openSans(
                    textStyle: TextStyle(
                        color: mainYellow, fontWeight: FontWeight.bold),
                  ),
                )
              ],
            ),
          ),
        ),
      ],
    );
  }

  Positioned joystickRow(BuildContext context) {
    return Positioned(
      top: context.customHeigthValue(0.58),
      child: Row(
        children: [
          SizedBox(
            width: context.customWidthValue(0.043),
          ),
          Joystick(
            mode: JoystickMode.vertical,
            listener: (details) {
              setState(() {
                _y = _y + step * details.y;
              });
            },
          ),
          SizedBox(
            width: context.customWidthValue(0.68),
          ),
          Joystick(
            mode: JoystickMode.horizontal,
            listener: (details) {
              setState(() {
                _x = _x + step * details.x;
              });
            },
          ),
        ],
      ),
    );
  }

  void snackBar(BuildContext context, String text) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        duration: const Duration(seconds: 2),
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
