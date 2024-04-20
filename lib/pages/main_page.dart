import 'dart:convert';
import 'dart:io';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_joystick/flutter_joystick.dart';
import 'package:roffinspection/Models/models.dart';
import 'package:roffinspection/constants/asset_extension.dart';
import 'package:roffinspection/constants/coctext_extension.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:http/http.dart';

class ControlPage extends StatefulWidget {
  const ControlPage({super.key});

  @override
  State<ControlPage> createState() => _ControlPageState();
}

class _ControlPageState extends State<ControlPage> {
  WorkPackageClass? workPackage;
  @override
  void initState() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      workPackageModalPopUp();
    });
    super.initState();
  }

  ///////////////////////////////////Text Controllers//////////////////////
  final ipTextController = TextEditingController();
  final portTextController = TextEditingController();
  final workPackageTextController = TextEditingController();
  final taskTextController = TextEditingController();
  ///////////////////////////////////Colors////////////////////////////////
  final Color mainYellow = const Color.fromARGB(255, 255, 204, 51);
  final Color mainGrey = const Color.fromARGB(255, 76, 68, 68);
  ///////////////////////////////////joystick vars.////////////////////////
  double _y = 100;
  double _x = 100;
  double step = 10.0;
  /////////////////////////////////////////////////////////////////////////
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
        onPressed: () {
          connectionSettingsModalPopUp();
        },
        child: Row(
          children: [
            Icon(
              Icons.cast_outlined,
              color: mainYellow,
            ),
            SizedBox(
              height: context.customHeigthValue(0.01),
              width: context.customWidthValue(0.01),
            ),
            Text(
              'Connect',
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
        width: context.customWidthValue(0.02),
      ),
      ElevatedButton(
        onPressed: () {
          workPackageModalPopUp();
        },
        child: Row(
          children: [
            Icon(
              Icons.work_outlined,
              color: mainYellow,
            ),
          ],
        ),
      ),
      SizedBox(
        height: context.customHeigthValue(0.02),
        width: context.customWidthValue(0.13),
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
              height: context.customHeigthValue(0.005),
              width: context.customWidthValue(0.005),
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

  SingleChildScrollView camViewColumn(BuildContext context) {
    return SingleChildScrollView(
      child: Center(
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
              snackBar(context, 'The button will align');
              testHttp();
            },
            child: Row(
              children: [
                Icon(
                  Icons.settings,
                  color: mainYellow,
                ),
                SizedBox(
                  height: context.customHeigthValue(0.01),
                  width: context.customWidthValue(0.01),
                ),
                Text(
                  'File Settings',
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
            width: context.customWidthValue(0.032),
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
            width: context.customWidthValue(0.7),
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

  void workPackageModalPopUp() {
    showCupertinoModalPopup<String>(
      context: context,
      builder: (BuildContext context) => SingleChildScrollView(
        child: AnimatedAlign(
          alignment: Alignment.topCenter,
          duration: const Duration(milliseconds: 1000),
          curve: Easing.emphasizedDecelerate,
          child: Padding(
            padding: EdgeInsets.only(
                bottom: MediaQuery.of(context).viewInsets.bottom),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                Padding(
                  padding: context.paddingLowSymetric,
                  child: Card(
                    child: SizedBox(
                      width: context.customWidthValue(0.5),
                      height: context.customHeigthValue(0.5),
                      child: Padding(
                        padding: context.paddingUltraULowSymetric,
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            TextFormField(
                              controller: workPackageTextController,
                              decoration: InputDecoration(
                                prefixIcon: Icon(
                                  Icons.work_outlined,
                                  color: mainYellow,
                                ),
                                label: Text(
                                  'Enter a Work Package Name',
                                  style: GoogleFonts.openSans(
                                    textStyle: TextStyle(
                                      color: mainYellow,
                                    ),
                                  ),
                                ),
                                border: OutlineInputBorder(
                                    borderRadius: BorderRadius.circular(30),
                                    borderSide: BorderSide(
                                      color: mainYellow,
                                    )),
                              ),
                            ),
                            SizedBox(
                              height: context.customHeigthValue(0.05),
                              width: context.customWidthValue(0.05),
                            ),
                            TextFormField(
                              controller: taskTextController,
                              decoration: InputDecoration(
                                prefixIcon: Icon(
                                  Icons.task_rounded,
                                  color: mainYellow,
                                ),
                                label: Text(
                                  'Enter a Task Name',
                                  style: GoogleFonts.openSans(
                                    textStyle: TextStyle(
                                      color: mainYellow,
                                    ),
                                  ),
                                ),
                                border: OutlineInputBorder(
                                    borderRadius: BorderRadius.circular(30),
                                    borderSide: BorderSide(
                                      color: mainYellow,
                                    )),
                              ),
                            ),
                            SizedBox(
                              height: context.customHeigthValue(0.05),
                              width: context.customWidthValue(0.05),
                            ),
                            Container(
                              width: context.customWidthValue(0.18),
                              decoration: BoxDecoration(
                                  borderRadius: BorderRadius.circular(30),
                                  border: Border.all(color: mainYellow)),
                              child: ElevatedButton(
                                onPressed: () {
                                  workPackage = WorkPackageClass(
                                      workPackage:
                                          workPackageTextController.text,
                                      taskName: taskTextController.text);
                                  workPackageSend();
                                  snackBar(context, 'Work package is saved');
                                  Navigator.pop(context, 'OK');
                                },
                                child: Row(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    Icon(
                                      Icons.save_alt_outlined,
                                      color: mainYellow,
                                    ),
                                    SizedBox(
                                      height: context.customHeigthValue(0.01),
                                      width: context.customWidthValue(0.01),
                                    ),
                                    Text(
                                      'Save Work Package',
                                      style: GoogleFonts.openSans(
                                        textStyle: TextStyle(
                                          color: mainYellow,
                                          fontWeight: FontWeight.bold,
                                        ),
                                      ),
                                    )
                                  ],
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  void connectionSettingsModalPopUp() {
    showCupertinoModalPopup<String>(
      context: context,
      builder: (BuildContext context) => SingleChildScrollView(
        child: AnimatedAlign(
          alignment: Alignment.topCenter,
          duration: const Duration(milliseconds: 1000),
          curve: Easing.emphasizedDecelerate,
          child: Padding(
            padding: EdgeInsets.only(
                bottom: MediaQuery.of(context).viewInsets.bottom),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                Padding(
                  padding: context.paddingLowSymetric,
                  child: Card(
                    child: SizedBox(
                      width: context.customWidthValue(0.5),
                      height: context.customHeigthValue(0.5),
                      child: Padding(
                        padding: context.paddingUltraULowSymetric,
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            TextFormField(
                              controller: ipTextController,
                              decoration: InputDecoration(
                                prefixIcon: Icon(
                                  Icons.wifi_find_rounded,
                                  color: mainYellow,
                                ),
                                label: Text(
                                  'Enter Ip Adress',
                                  style: GoogleFonts.openSans(
                                    textStyle: TextStyle(
                                      color: mainYellow,
                                    ),
                                  ),
                                ),
                                border: OutlineInputBorder(
                                    borderRadius: BorderRadius.circular(30),
                                    borderSide: BorderSide(
                                      color: mainYellow,
                                    )),
                              ),
                            ),
                            SizedBox(
                              height: context.customHeigthValue(0.05),
                              width: context.customWidthValue(0.05),
                            ),
                            TextFormField(
                              controller: portTextController,
                              decoration: InputDecoration(
                                prefixIcon: Icon(
                                  Icons.settings_input_antenna_rounded,
                                  color: mainYellow,
                                ),
                                label: Text(
                                  'Enter Port',
                                  style: GoogleFonts.openSans(
                                    textStyle: TextStyle(
                                      color: mainYellow,
                                    ),
                                  ),
                                ),
                                border: OutlineInputBorder(
                                    borderRadius: BorderRadius.circular(30),
                                    borderSide: BorderSide(
                                      color: mainYellow,
                                    )),
                              ),
                            ),
                            SizedBox(
                              height: context.customHeigthValue(0.05),
                              width: context.customWidthValue(0.05),
                            ),
                            Container(
                              width: context.customWidthValue(0.15),
                              decoration: BoxDecoration(
                                  borderRadius: BorderRadius.circular(30),
                                  border: Border.all(color: mainYellow)),
                              child: ElevatedButton(
                                onPressed: () {
                                  snackBar(context, 'Settings are saved');
                                  Navigator.pop(context, 'OK');
                                },
                                child: Row(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    Icon(
                                      Icons.save_alt_outlined,
                                      color: mainYellow,
                                    ),
                                    SizedBox(
                                      height: context.customHeigthValue(0.01),
                                      width: context.customWidthValue(0.01),
                                    ),
                                    Text(
                                      'Save Settings',
                                      style: GoogleFonts.openSans(
                                        textStyle: TextStyle(
                                          color: mainYellow,
                                          fontWeight: FontWeight.bold,
                                        ),
                                      ),
                                    )
                                  ],
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
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

  Future<void> testHttp() async {
    Socket socket = await Socket.connect(
      '192.168.1.160',
      8088,
    );

    print('connected');

    socket.listen((List<int> event) {
      print(utf8.decode(event));
    });

    socket.add(utf8.encode('100000001'));

    socket.close();
  }

  void workPackageSend() {}
}
