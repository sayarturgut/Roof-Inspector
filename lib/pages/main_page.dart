import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'dart:typed_data';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_joystick/flutter_joystick.dart';
import 'package:roffinspection/Models/models.dart';
import 'package:roffinspection/constants/asset_extension.dart';
import 'package:roffinspection/constants/coctext_extension.dart';
import 'package:google_fonts/google_fonts.dart';

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
      ipTextController.text = '192.168.1.160';
      portTextController.text = '8088';
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
  double _y = 0;
  double oldY = 0;
  double realY = 0;
  double _x = 0;
  double oldX = 0;
  double realX = 0;
  double step = 10.1;
  /////////////////////////////////////////////////////////////////////////
  bool conStsFlag = false;
  Uint8List receivedData = Uint8List(0);
  late Socket socket;
  late Timer timer;
  String streamingCamData = '';
  String lastCamData = '';
  List<String> dataList = [];
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
      conStsFlag == false
          ? ElevatedButton(
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
            )
          : ElevatedButton(
              onPressed: () {
                tcpDisconnect();
              },
              child: Row(
                children: [
                  Icon(
                    Icons.wifi_off_outlined,
                    color: mainYellow,
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
        width: context.customWidthValue(0.11),
      ),
      Center(
        child: AnimatedSize(
          duration: const Duration(milliseconds: 500),
          curve: Curves.decelerate,
          child: ElevatedButton(
            onPressed: () {},
            child: conStsFlag == true
                ? Text(
                    'Roof Inspector Connected',
                    style: GoogleFonts.openSans(
                      textStyle: const TextStyle(
                          color: Colors.green,
                          fontWeight: FontWeight.bold,
                          fontSize: 24),
                    ),
                  )
                : Text(
                    'Roof Inspector not Connected',
                    style: GoogleFonts.openSans(
                      textStyle: const TextStyle(
                          color: Colors.red,
                          fontWeight: FontWeight.bold,
                          fontSize: 24),
                    ),
                  ),
          ),
        ),
      ),
      SizedBox(
        height: context.customHeigthValue(0.02),
        width: context.customWidthValue(0.16),
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
                camLeftRightFunc(details, context);
              },
              onVerticalDragEnd: (details) {
                camUpDownFunc(details, context);
              },
              child: SizedBox(
                height: context.customHeigthValue(0.65),
                width: context.customWidthValue(0.65),
                child: Padding(
                  padding: const EdgeInsets.all(3.0),
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(50),
                    child: Image.memory(
                      base64Decode(lastCamData),
                      fit: BoxFit.fill,
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
              checkConnectionFunc();
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
              robotForBacwardFunc(details);
            },
          ),
          SizedBox(
            width: context.customWidthValue(0.7),
          ),
          Joystick(
            mode: JoystickMode.horizontal,
            listener: (details) {
              robotLeftRightFunc(details);
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
                              width: context.customWidthValue(0.20),
                              decoration: BoxDecoration(
                                  borderRadius: BorderRadius.circular(30),
                                  border: Border.all(color: mainYellow)),
                              child: ElevatedButton(
                                onPressed: () {
                                  checkConnectionFunc();
                                  snackBar(context, 'Connecting to Robot');
                                  Navigator.pop(context, 'OK');
                                },
                                child: Row(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    Icon(
                                      Icons.cast_connected,
                                      color: mainYellow,
                                    ),
                                    SizedBox(
                                      height: context.customHeigthValue(0.01),
                                      width: context.customWidthValue(0.01),
                                    ),
                                    Text(
                                      'Connect to Robot',
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

  void checkConnectionFunc() async {
    setState(() {
      conStsFlag = true;
    });
    await tcpConnect(); // Hemen yeniden bağlanmayı dener
  }

  Future<void> tcpConnect() async {
    String ip = ipTextController.text;
    String port = portTextController.text;

    try {
      socket = await Socket.connect(
        ip,
        int.parse(port),
        timeout: const Duration(seconds: 10),
      );

      socket.add(utf8.encode('1\n'));
      takeAndPushDataFunc();
    } catch (e) {
      snackBar(context, 'Connection Failed.\n Error: $e');
    }
  }

  void takeAndPushDataFunc() {
    socket.listen(
      (Uint8List event) {
        streamingCamData += utf8.decode(event);
        streamingCamData =
            streamingCamData.replaceAll(RegExp(r'[^A-Za-z0-9+/=]'), '');
      },
      onDone: () {
        if (conStsFlag) {
          tcpReconnect();
          lastCamData = streamingCamData;
          streamingCamData = '';
        }
      },
      onError: (error) {
        setState(() {
          socket.close();
          socket.destroy();
          conStsFlag = false;
          snackBar(context, 'Connection Failed.\n Error: $error');
        });
      },
    );
  }

  void tcpReconnect() async {
    socket.destroy();
    await tcpConnect(); // Hemen yeniden bağlanmayı dener
  }

  void tcpDisconnect() {
    setState(() {
      socket.close();
      socket.destroy();
      conStsFlag = false;
      snackBar(context, 'Disconnected Successfully');
    });
  }

  void workPackageSend() {}

  void camUpDownFunc(DragEndDetails details, BuildContext context) {
    if (details.primaryVelocity! > 0) {
      snackBar(context, 'Camera is being turned to the up');
      print(details.primaryVelocity! ~/ 400);
    } else if (details.primaryVelocity! < 0) {
      snackBar(context, 'Camera is being turned to the down');
    }
  }

  void camLeftRightFunc(DragEndDetails details, BuildContext context) {
    if (details.primaryVelocity! > 0) {
      snackBar(context, 'Camera is being turned to the left');
    } else if (details.primaryVelocity! < 0) {
      snackBar(context, 'Camera is being turned to the right');
    }
  }

  void robotLeftRightFunc(StickDragDetails details) {
    return setState(() {
      _x = _x + (step * details.x);
      realX = -(_x - oldX);
      oldX = _x;
    });
  }

  void robotForBacwardFunc(StickDragDetails details) {
    return setState(() {
      _y = _y + (step * details.y);
      realY = -(_y - oldY);
      realY.toInt();
      oldY = _y;
    });
  }
}
