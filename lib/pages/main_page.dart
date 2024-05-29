import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'dart:typed_data';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:syncfusion_flutter_sliders/sliders.dart';
import 'package:flutter_joystick/flutter_joystick.dart';
import 'package:roffinspection/Models/models.dart';
import 'package:roffinspection/constants/asset_extension.dart';
import 'package:roffinspection/constants/coctext_extension.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:network_info_plus/network_info_plus.dart';

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

  @override
  void dispose() {
    super.dispose();
  }

  /////////////////////////////////////////////////////////////////////////
  final info = NetworkInfo();
  String? wifiName;
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
  double leftMotor = 0;
  double rightMotor = 0;
  double step = 10.1;
  /////////////////////////////////////////////////////////////////////////
  late Socket socket;
  bool conStsFlag = false;
  Uint8List receivedData = Uint8List(0);
  /////////////////////////////////////////////////////////////////////////
  String streamingCamData = '';
  List<String> dataList = [];
  List<String> camDataList = [];
  /////////////////////////////////////////////////////////////////////////
  String dataRx = '';
  /////////////////////////////////////////////////////////////////////////
  double horSliderValue = 90;
  dynamic verSliderValue = 90;
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
      SizedBox(
        height: context.customHeigthValue(0.02),
        width: context.customWidthValue(0.01),
      ),
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
        width: context.customWidthValue(0.06),
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
                          fontSize: 20),
                    ),
                  )
                : Text(
                    'Roof Inspector not Connected',
                    style: GoogleFonts.openSans(
                      textStyle: const TextStyle(
                          color: Colors.red,
                          fontWeight: FontWeight.bold,
                          fontSize: 20),
                    ),
                  ),
          ),
        ),
      ),
      SizedBox(
        height: context.customHeigthValue(0.02),
        width: context.customWidthValue(0.065),
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
              width: context.customWidthValue(0.65),
              child: SizedBox(
                height: context.customHeigthValue(0.06),
                width: context.customWidthValue(0.65),
                child: Slider(
                  value: horSliderValue,
                  max: 180,
                  divisions: 180,
                  activeColor: mainYellow,
                  inactiveColor: const Color.fromARGB(255, 91, 73, 20),
                  onChanged: (double value) {
                    setState(() {
                      if (value > 85 && value < 95) {
                        value = 90;
                      } else if (value > 0 && value < 5) {
                        value = 0;
                      } else if (value > 175) {
                        value = 180;
                      }
                      horSliderValue = value;
                    });
                  },
                ),
              ),
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                SizedBox(
                  height: context.customHeigthValue(0.65),
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
                          child: conStsFlag && receivedData.isNotEmpty
                              ? Image.memory(
                                  gaplessPlayback: true,
                                  receivedData,
                                  fit: BoxFit.fill,
                                )
                              : Image(
                                  image: AssetImage('damaged_roof'.toJpg),
                                  fit: BoxFit.fill,
                                )),
                    ),
                  ),
                ),
                SizedBox(
                  height: context.customHeigthValue(0.65),
                  width: context.customWidthValue(0.03),
                  child: SfSlider.vertical(
                    min: 0.0,
                    max: 180.0,
                    activeColor: mainYellow,
                    inactiveColor: const Color.fromARGB(255, 91, 73, 20),
                    value: verSliderValue,
                    interval: 180,
                    minorTicksPerInterval: 1,
                    onChanged: (dynamic value) {
                      setState(() {
                        if (value > 85 && value < 95) {
                          value = 90;
                        } else if (value > 0 && value < 5) {
                          value = 0;
                        } else if (value > 175) {
                          value = 180;
                        }
                        verSliderValue = value;
                      });
                    },
                  ),
                )
              ],
            ),
            SizedBox(
              height: context.customHeigthValue(0.01),
              width: context.customWidthValue(0.02),
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
                  'Start\nRecording',
                  style: GoogleFonts.openSans(
                    textStyle: TextStyle(
                        fontSize: 12,
                        color: mainYellow,
                        fontWeight: FontWeight.bold),
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
                  'Stop\nRecording',
                  style: GoogleFonts.openSans(
                    textStyle: TextStyle(
                        fontSize: 12,
                        color: mainYellow,
                        fontWeight: FontWeight.bold),
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
                  'Take\nPhoto',
                  style: GoogleFonts.openSans(
                    textStyle: TextStyle(
                        fontSize: 12,
                        color: mainYellow,
                        fontWeight: FontWeight.bold),
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
              // checkConnectionFunc();
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
                  'File\nSettings',
                  style: GoogleFonts.openSans(
                    textStyle: TextStyle(
                        fontSize: 12,
                        color: mainYellow,
                        fontWeight: FontWeight.bold),
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
      top: context.customHeigthValue(0.50),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          SizedBox(
            width: context.customWidthValue(0.02),
          ),
          Joystick(
            mode: JoystickMode.vertical,
            listener: (details) {
              _y = _y + (step * details.y);
              realY = -(_y - oldY);
              realY.toInt();
              oldY = _y;
            },
          ),
          SizedBox(
            width: context.customWidthValue(0.7),
          ),
          Joystick(
            mode: JoystickMode.horizontal,
            listener: (details) {
              _x = _x + (step * details.x);
              realX = -(_x - oldX);
              realX.toInt();
              oldX = _x;
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
                                      'Save Work\nPackage',
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
                                      'Connect to\nRobot',
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
    wifiName = await info.getWifiName();

    if (wifiName != null) {
      if (wifiName!.contains('Roof')) {
        setState(() {
          conStsFlag = true;
        });
        snackBar(context, 'Connected to Robot');
        await tcpConnect();
      } else {
        snackBar(context, 'Please Connect to Wi-Fi before.');
      }
    } else {
      snackBar(context, 'Please Connect to Wi-Fi before.');
    }
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
    } catch (error) {
      socket.close();
      socket.destroy();
      conStsFlag = false;
      snackBar(context, 'Connection Failed.\n Error: $error');
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
          setState(() {});
          tcpReconnect();
          receivedData = base64Decode(streamingCamData);
        }
        streamingCamData = '';
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
    await tcpConnect();
  }

  void tcpDisconnect() {
    setState(() {
      socket.close();
      socket.destroy();
      conStsFlag = false;
      streamingCamData = '';
      receivedData = Uint8List(0);
      snackBar(context, 'Disconnected Successfully');
    });
  }

  String packageSend() {
    handleRobotTurn();
    return dataRx =
        '${conStsFlag == true ? 1 : 0}${realY.isNegative ? 0 : 1}$rightMotor$leftMotor';
  }

  void camUpDownFunc(DragEndDetails details, BuildContext context) {
    if (details.primaryVelocity! > 0) {
      snackBar(context, 'Camera is being turned to the up');
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

  void handleRobotTurn() {
    if (realX.isNegative) {
      rightMotor = (realY.abs() - (realX / 1.5).abs()).abs();
      leftMotor = realY.abs();
    } else {
      leftMotor = (realY.abs() - (realX / 1.5).abs()).abs();
      rightMotor = realY.abs();
    }
  }
}
