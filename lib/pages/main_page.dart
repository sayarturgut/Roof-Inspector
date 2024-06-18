import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'dart:typed_data';

import 'package:android_intent/android_intent.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_ffmpeg/flutter_ffmpeg.dart';
import 'package:flutter_internet_signal/flutter_internet_signal.dart';
import 'package:flutter_joystick/flutter_joystick.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:network_info_plus/network_info_plus.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:syncfusion_flutter_sliders/sliders.dart';
import 'package:roofinspecter/Models/models.dart';
import 'package:roofinspecter/constants/asset_extension.dart';
import 'package:roofinspecter/constants/coctext_extension.dart';

class ControlPage extends StatefulWidget {
  const ControlPage({super.key});

  @override
  State<ControlPage> createState() => _ControlPageState();
}

class _ControlPageState extends State<ControlPage>
    with TickerProviderStateMixin {
  /////////////////////////////////////////
  late WorkPackageClass workPackage;
  late AnimationController _controller;
  late Animation<double> _animation;
  /////////////////////////////////////////
  @override
  void initState() {
    /////////////////Recording dot animation defs.////////////////////////////
    _controller = AnimationController(
      duration: const Duration(milliseconds: 500),
      vsync: this,
    )..repeat(reverse: true);
    _animation = CurvedAnimation(
      parent: _controller,
      curve: Curves.easeIn,
    );
    WidgetsBinding.instance.addPostFrameCallback((_) {
      workPackageModalPopUp();
      alertDialog('Type Names',
          'Please type workpackage and task names before navigating to app');
      ///////////////Default ip, port, wp, task names for easy devolopment////
      ipTextController.text = '192.168.1.160';
      portTextController.text = '8088';
      workPackageTextController.text = 'Villa Roof';
      taskTextController.text = 'Villa Roof Damage';
    });

    super.initState();
  }

  ///////////////////Package Definitions//////////////////////////////////////
  final FlutterInternetSignal internetSignal = FlutterInternetSignal();
  final FlutterFFmpeg fFmpeg = FlutterFFmpeg();
  final info = NetworkInfo();
  String? wifiName;
  ///////////////////Text Controllers/////////////////////////////////////////
  final ipTextController = TextEditingController();
  final portTextController = TextEditingController();
  final workPackageTextController = TextEditingController();
  final taskTextController = TextEditingController();
  ///////////////////Colors///////////////////////////////////////////////////
  final Color mainYellow = const Color.fromARGB(255, 255, 204, 51);
  final Color mainGrey = const Color.fromARGB(255, 76, 68, 68);
  final Color darkGrey = const Color.fromARGB(255, 29, 27, 32);
  ///////////////////joystick veriables///////////////////////////////////////
  double _left = 0;
  double oldLeft = 0;
  double realLeft = 0;
  double _right = 0;
  double oldRight = 0;
  double realRight = 0;
  double step = 255.1;
  ///////////////////Motors veriables/////////////////////////////////////////
  int leftMotor = 0;
  int rightMotor = 0;
  int leftMotorInt = 0;
  int rightMotorInt = 0;
  ///////////////////Socket and camera veriables//////////////////////////////
  late Socket socket;
  bool conStsFlag = false;
  Uint8List receivedData = Uint8List(0);
  List<Uint8List> videoData = [];
  String streamingCamData = '';
  bool flashStsFlag = false;
  ////////////////////Data will send//////////////////////////////////////////
  String dataRx = '';
  ///////////////////Slider initial Values////////////////////////////////////
  double horSliderValue = 90;
  dynamic verSliderValue = 90;
  int verSliderValueInt = 90;
  int horSliderValueInt = 90;
  ///////////////////Folder parhs/////////////////////////////////////////////
  String pathOfWp = '';
  String pathOfTask = '';
  String pathOfPhotos = '';
  String pathOfVideos = '';
  bool rcrdFlag = false;
  bool lowPowerModeFlag = false;
  //////////////////Wi-Fi singal streght veriable/////////////////////////////
  late final int? dBm;
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
        width: context.customWidthValue(0.005),
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
        height: context.customHeigthValue(0.01),
        width: context.customWidthValue(0.005),
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
        height: context.customHeigthValue(0.01),
        width: context.customWidthValue(0.065),
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
        height: context.customHeigthValue(0.01),
        width: context.customWidthValue(0.005),
      ),
      ElevatedButton(
        onPressed: () {},
        child: buildSignalIcon(),
      ),
      SizedBox(
        height: context.customHeigthValue(0.01),
        width: context.customWidthValue(0.005),
      ),
      ElevatedButton(
        onPressed: () {
          if (conStsFlag) {
            flashStsFlag = !flashStsFlag;
          }
        },
        child: Row(
          children: [
            flashStsFlag
                ? Icon(
                    Icons.flash_on_outlined,
                    color: mainYellow,
                  )
                : Icon(
                    Icons.flash_off_outlined,
                    color: mainYellow,
                  ),
            SizedBox(
              height: context.customHeigthValue(0.005),
              width: context.customWidthValue(0.005),
            ),
            Text(
              'Flash',
              style: GoogleFonts.openSans(
                textStyle:
                    TextStyle(color: mainYellow, fontWeight: FontWeight.bold),
              ),
            ),
          ],
        ),
      ),
      SizedBox(
        height: context.customHeigthValue(0.02),
        width: context.customWidthValue(0.005),
      ),
      Container(
        height: context.customHeigthValue(0.071),
        width: context.customWidthValue(0.1),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(50),
          color: const Color.fromARGB(255, 34, 34, 34),
        ),
        child: Padding(
          padding: const EdgeInsets.all(2),
          child: AnimatedSize(
            duration: const Duration(milliseconds: 250),
            curve: Curves.decelerate,
            child: Row(
              children: [
                Switch(
                  activeColor: mainYellow,
                  inactiveThumbColor: Colors.black,
                  activeTrackColor: Colors.black,
                  inactiveTrackColor: Colors.black,
                  thumbColor: WidgetStatePropertyAll(mainYellow),
                  overlayColor: WidgetStatePropertyAll(mainYellow),
                  trackOutlineColor: WidgetStatePropertyAll(mainYellow),
                  value: lowPowerModeFlag,
                  onChanged: (value) {
                    setState(() {
                      if (!lowPowerModeFlag && conStsFlag) {
                        snackBar(context, 'Low Power Mode Enabled');
                      }
                      if (conStsFlag) {
                        lowPowerModeFlag = value;
                      }
                    });
                  },
                ),
                lowPowerModeFlag
                    ? Icon(
                        Icons.battery_saver_outlined,
                        color: mainYellow,
                      )
                    : Icon(
                        Icons.battery_charging_full_outlined,
                        color: mainYellow,
                      )
              ],
            ),
          ),
        ),
      ),
      SizedBox(
        height: context.customHeigthValue(0.02),
        width: context.customWidthValue(0.005),
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
                  min: 0.0,
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
                      horSliderValueInt = 180 - horSliderValue.round();
                    });
                  },
                ),
              ),
            ),
            Stack(
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    SizedBox(
                      height: context.customHeigthValue(0.65),
                      width: context.customWidthValue(0.03),
                    ),
                    SizedBox(
                      height: context.customHeigthValue(0.65),
                      width: context.customWidthValue(0.65),
                      child: Padding(
                        padding: const EdgeInsets.all(3.0),
                        child: ClipRRect(
                            borderRadius: BorderRadius.circular(50),
                            child: conStsFlag && receivedData.isNotEmpty
                                ? Image.memory(
                                    gaplessPlayback: true,
                                    filterQuality: FilterQuality.high,
                                    colorBlendMode: BlendMode.screen,
                                    receivedData,
                                    fit: BoxFit.fill,
                                  )
                                : Image(
                                    image: AssetImage('damaged_roof'.toJpg),
                                    fit: BoxFit.fill,
                                  )),
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
                            verSliderValueInt = (value as num).toInt();
                          });
                        },
                      ),
                    )
                  ],
                ),
                if (rcrdFlag && conStsFlag)
                  Positioned(
                    top: context.customHeigthValue(0.04),
                    left: context.customWidthValue(0.20),
                    child: FadeTransition(
                      opacity: _animation,
                      child: Container(
                        width: 16.0,
                        height: 16.0,
                        decoration: const BoxDecoration(
                          color: Colors.red,
                          shape: BoxShape.circle,
                        ),
                      ),
                    ),
                  ),
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
              if (conStsFlag) {
                rcrdFlag = true;
                snackBar(context, 'Video Recording has started');
              }
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
              if (conStsFlag) {
                stopRcrdSaveVideo();
                snackBar(context, 'Video recording has stoped.');
              }
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
              if (conStsFlag) {
                savePhoto();
                snackBar(context, 'Photo has been taken and saved.');
              }
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
            listener: (detailsRight) {
              if (lowPowerModeFlag) {
                setState(() {
                  step = 200;
                });
              } else {
                setState(() {
                  step = 255.1;
                });
              }
              _right = _right + (step * detailsRight.y);
              realRight = -(_right - oldRight);
              oldRight = _right;
              rightMotorInt = realRight.round();
            },
          ),
          SizedBox(
            width: context.customWidthValue(0.7),
          ),
          Joystick(
            mode: JoystickMode.vertical,
            listener: (details) {
              if (lowPowerModeFlag) {
                setState(() {
                  step = 200;
                });
              } else {
                setState(() {
                  step = 255.1;
                });
              }
              _left = _left + (step * details.y);
              realLeft = -(_left - oldLeft);
              oldLeft = _left;
              leftMotorInt = realLeft.round();
            },
          ),
        ],
      ),
    );
  }

  void workPackageModalPopUp() {
    showCupertinoModalPopup<String>(
      barrierDismissible: false,
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
                                  'Work Order Name',
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
                                  'Work Description',
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
                                  if (workPackage.workPackage != '' &&
                                      workPackage.taskName != '') {
                                    createFolder();
                                    Navigator.pop(context, 'OK');
                                  } else {
                                    alertDialog('Please Type Names.',
                                        'Please type workpackage and task names.');
                                  }
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

  void alertDialog(String title, String content) {
    showCupertinoDialog<String>(
      context: context,
      builder: (BuildContext context) => AlertDialog(
        backgroundColor: darkGrey,
        title: Text(
          title,
          style: TextStyle(color: mainYellow, fontSize: 20),
        ),
        content: Text(
          content,
          style: const TextStyle(fontSize: 15),
        ),
        actions: <Widget>[
          TextButton(
            style: ButtonStyle(
                backgroundColor: WidgetStatePropertyAll(mainYellow)),
            onPressed: () => Navigator.pop(context, 'OK'),
            child: Text(
              'OK',
              style: TextStyle(color: darkGrey),
            ),
          ),
        ],
      ),
    );
  }

  void alertDialogOpenWiFi(String title, String content) {
    showCupertinoDialog<String>(
      context: context,
      builder: (BuildContext context) => AlertDialog(
        backgroundColor: darkGrey,
        title: Text(
          title,
          style: TextStyle(color: mainYellow, fontSize: 20),
        ),
        content: Text(
          content,
          style: const TextStyle(fontSize: 15),
        ),
        actions: <Widget>[
          TextButton(
            style: ButtonStyle(
                backgroundColor: WidgetStatePropertyAll(mainYellow)),
            onPressed: () {
              Navigator.pop(context, 'OK');
              openWiFiSettings();
            },
            child: Text(
              'OK',
              style: TextStyle(color: darkGrey),
            ),
          ),
        ],
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
        alertDialogOpenWiFi('Connect to Wi-Fi',
            'Please connect to Roof Inspector Wi-Fi before connect with app.');
      }
    } else {
      alertDialogOpenWiFi('Connect to Wi-Fi',
          'Please connect to Roof Inspector Wi-Fi before connect with app.');
    }
  }

  Future<void> tcpConnect() async {
    try {
      socket = await Socket.connect(
        ipTextController.text,
        int.parse(portTextController.text),
        timeout: const Duration(seconds: 10),
      );
      socket.add(utf8.encode(
          'BB*${conStsFlag == true ? 1 : 0}*$rightMotorInt*$leftMotorInt*$horSliderValueInt*$verSliderValueInt*${flashStsFlag == true ? 1 : 0}*CC\n'));
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
      },
      onDone: () {
        if (conStsFlag) {
          setState(() {
            streamingCamData =
                streamingCamData.replaceAll(RegExp(r'[^A-Za-z0-9+/=]'), '');
            receivedData = base64Decode(streamingCamData);
          });
          tcpReconnect();
          if (rcrdFlag == true) {
            videoData.add(receivedData);
          }
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

  Future<void> createFolder() async {
    final bool strorageGranted = await Permission.storage.isGranted;
    final bool locationGranted = await Permission.location.isGranted;
    if (!locationGranted) {
      await Permission.location.request();
      snackBar(context, 'Please give permission.');
    } else {
      wifiName = await info.getWifiName();
    }
    if (!strorageGranted) {
      snackBar(context, 'Please give permission.');
      await Permission.storage.request();
    } else {
      final workPackagePath =
          Directory("/storage/emulated/0/${workPackage.workPackage}");
      final taskPath = Directory(
          "/storage/emulated/0/${workPackage.workPackage}/${workPackage.taskName}");
      final phtPath = Directory(
          "/storage/emulated/0/${workPackage.workPackage}/${workPackage.taskName}/pictures");
      final videosPath = Directory(
          "/storage/emulated/0/${workPackage.workPackage}/${workPackage.taskName}/videos");
      if ((await workPackagePath.exists())) {
        pathOfWp = workPackagePath.path;
      } else {
        workPackagePath.create();
        pathOfWp = workPackagePath.path;
      }
      if ((await taskPath.exists())) {
        pathOfTask = taskPath.path;
      } else {
        taskPath.create();
        pathOfTask = taskPath.path;
      }
      if ((await phtPath.exists())) {
        pathOfPhotos = phtPath.path;
      } else {
        phtPath.create();
        pathOfPhotos = phtPath.path;
      }
      if ((await videosPath.exists())) {
        pathOfVideos = videosPath.path;
      } else {
        videosPath.create();
        pathOfVideos = videosPath.path;
      }
      snackBar(context, 'Work package is saved');
    }
  }

  Future<void> savePhoto() async {
    String outputPhotoPath =
        '$pathOfPhotos/${DateTime.now().year}_${DateTime.now().month}_${DateTime.now().day}-${DateTime.now().hour}.${DateTime.now().minute}.${DateTime.now().second}.jpg';
    File(outputPhotoPath).writeAsBytes(receivedData);
  }

  Future<void> stopRcrdSaveVideo() async {
    rcrdFlag = false;

    String outputVideoPath =
        '$pathOfVideos/${DateTime.now().year}_${DateTime.now().month}_${DateTime.now().day}-${DateTime.now().hour}.${DateTime.now().minute}.${DateTime.now().second}.mp4';

    List<String> tempFilePaths = [];

    for (int i = 0; i < videoData.length; i++) {
      String tempFilePath = '$pathOfVideos/$i.jpg';
      await File(tempFilePath).writeAsBytes(videoData[i]);
      tempFilePaths.add(tempFilePath);
    }
    String command =
        '-framerate 8 -i $pathOfVideos/%d.jpg -vf "scale=1280:900,unsharp=luma_msize_x=7:luma_msize_y=7:luma_amount=1.5" -vcodec mpeg4 -b:v 5000k -pix_fmt yuv420p -r 30 -threads 3 -refs 1 -bf 0 -coder 0 -g 60 -keyint_min 15 -movflags +faststart $outputVideoPath';

    int returnCode = await fFmpeg.execute(command);
    if (returnCode == 0) {
      snackBar(context,
          'The video created and saved to ${workPackageTextController.text}/${taskTextController.text}/Videos folder');
      videoData.clear();
    } else {
      snackBar(context, 'An error occured while video creating.');
      videoData.clear();
    }
    // Geçici dosyaları temizleyin
    for (String tempFilePath in tempFilePaths) {
      File(tempFilePath).deleteSync();
    }
  }

  // void handleRobotTurn() {
  //   if (realLeft == 0 && realRight == 0) {
  //     leftMotor = 0; // stop
  //     rightMotor = 0;
  //   } else if (realRight == 0) {
  //     leftMotor = leftMotorInt.abs(); // just go forward or backward
  //     rightMotor = rightMotorInt.abs();
  //   } else if (realLeft == 0) {
  //     if (!realRight.isNegative) {
  //       leftMotor = 0; // tank turn left
  //       rightMotor = rightMotorInt.abs();
  //     } else if (realRight.isNegative) {
  //       leftMotor = rightMotorInt.abs(); // tank turn right
  //       rightMotor = 0;
  //     }
  //   } else if (realRight.isNegative) {
  //     leftMotor = leftMotorInt.abs();
  //     rightMotor = (leftMotorInt.abs() - (rightMotorInt ~/ 1.5).abs()).abs();
  //     // slow the right motor for turn right
  //   } else if (!realRight.isNegative) {
  //     leftMotor = (leftMotorInt.abs() - (rightMotorInt ~/ 1.5).abs())
  //         .abs(); // slow the left motor for turn left
  //     rightMotor = leftMotorInt.abs();
  //   }
  // }

  Future<void> openWiFiSettings() async {
    const AndroidIntent intent = AndroidIntent(
      action: 'android.settings.WIFI_SETTINGS',
    );
    await intent.launch();
  }

  Future<Widget?> getSignalIcon() async {
    int? dBm = await internetSignal.getWifiSignalStrength();
    if (conStsFlag) {
      if (dBm != null) {
        if (dBm >= -50) {
          return Icon(Icons.signal_wifi_statusbar_4_bar_outlined,
              color: mainYellow);
        } else if (dBm >= -65) {
          return Icon(Icons.network_wifi_3_bar_rounded, color: mainYellow);
        } else if (dBm >= -80) {
          return Icon(Icons.network_wifi_2_bar_rounded, color: mainYellow);
        } else {
          return Icon(Icons.network_wifi_1_bar_outlined, color: mainYellow);
        }
      } else {
        setState(() {});
        return Icon(Icons.signal_wifi_bad_outlined, color: mainYellow);
      }
    } else {
      setState(() {});
      return Icon(Icons.signal_wifi_bad_outlined, color: mainYellow);
    }
  }

  Widget buildSignalIcon() {
    return FutureBuilder<Widget?>(
      future: getSignalIcon(),
      builder: (context, snapshot) {
        return snapshot.data ?? Container();
      },
    );
  }
}
