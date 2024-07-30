/**************************************************************************************************************************************************

Project Name      : A mobile web-cam robot for roof inspection
Writer            : Turgut Sayar, Yunus Berke Demirtaş, Begüm Çimenlidağ
Advisor           : Asst. Prof. Dr. Gökhan Dındış
Date              : June 2, 2024
Description       : This project has been developed to enable easier observation of hard-to-reach areas. It includes a camera, 2 DC Motors for
                    rover movement, and 2 servo motors for adjusting the camera angle. Communication is achieved via TCP/IP, with the rover
                    operating as a client. Users can control the rover using an Android device with the specially developed Android application
                    for this project. This project is part of the graduation project for the Electrical and Electronics Engineering Department at
                    Eskişehir Osmangazi University.

Hardware:
  - ESP32-CAM module
  - Two DC motors
  - L298N motor driver
  - Two servo motors
  - Power supply
  - Android device (API 29)

Software:
  - Arduino IDE 2.3.2
  - Flutter SDK 3.22.0
                  
***************************************************************************************************************************************************/

#include <WiFi.h>
#include "esp_camera.h"
#include "soc/soc.h"
#include "soc/rtc_cntl_reg.h"
#include <base64.h>
//#include <WiFiUdp.h>
#include "Arduino.h"
#include "fb_gfx.h"
#include "OV2640.h"
#include <ESP32Servo.h>
#include "esp_timer.h"
#include <Arduino.h>
#include "esp_system.h"
#include "soc/timer_group_reg.h"                                                                  // Timer Group register definitions
#include "driver/periph_ctrl.h"                                                                   // Peripheral control definitions
#include "soc/rtc_wdt.h"
#include "esp_int_wdt.h"
#include "esp_task_wdt.h"

const int camFlash = 4;
const char* ssid     = "RoofInspector1";
const char* password     = "123456789";
const uint16_t portNumber = 8088; WiFiServer server(portNumber);
WiFiClient client;
OV2640 cam;
bool connected = false;

IPAddress AP_LOCAL_IP(192, 168, 1, 160);
IPAddress AP_GATEWAY_IP(192, 168, 1, 4);
IPAddress AP_NETWORK_MASK(255, 255, 255, 0);

#define PWDN_GPIO_NUM     32
#define RESET_GPIO_NUM    -1
#define XCLK_GPIO_NUM      0
#define SIOD_GPIO_NUM     26
#define SIOC_GPIO_NUM     27

#define Y9_GPIO_NUM       35
#define Y8_GPIO_NUM       34
#define Y7_GPIO_NUM       39
#define Y6_GPIO_NUM       36
#define Y5_GPIO_NUM       21
#define Y4_GPIO_NUM       19
#define Y3_GPIO_NUM       18
#define Y2_GPIO_NUM        5
#define VSYNC_GPIO_NUM    25
#define HREF_GPIO_NUM     23
#define PCLK_GPIO_NUM     22
#define SERVO_1 14
#define SERVO_2 15
#define MOTOR_RIGHT_DIR   3                                                                               //IN1 IN2 direction both. if 1 motor forward if 0 backward
#define MOTOR_LEFT_DIR    2                                                                               //IN4 IN3 direction both. if 1 motor forward if 0 backward
#define MOTOR_EN_RIGHT    12
#define MOTOR_EN_LEFT     13
           
Servo panServo;
Servo tiltServo;

struct actionParameters {
  String rightMotorSpeed;
  String leftMotorSpeed;
  String panServoAngle;
  String tiltServoAngle;
  String flashMode;
};
actionParameters actionParams = {
  "0",  // Örnek değerler
  "0",
  "90",
  "90",
  "0"
};

void setup() {
  pinMode(MOTOR_RIGHT_DIR, OUTPUT);
  pinMode(MOTOR_LEFT_DIR, OUTPUT);
  pinMode(MOTOR_EN_LEFT, OUTPUT);
  pinMode(MOTOR_EN_RIGHT, OUTPUT);
  WRITE_PERI_REG(RTC_CNTL_BROWN_OUT_REG,0); // disable brownout
  pinMode(camFlash, OUTPUT);

  Serial.begin(115200);Serial.setDebugOutput(false); Serial.println();
  Serial.print("Setting AP (Access Point)…");

  WiFi.softAP(ssid,password);
    if (!WiFi.softAPConfig(AP_LOCAL_IP, AP_GATEWAY_IP, AP_NETWORK_MASK)) {
    Serial.println("AP Config Failed");
    return;
  }

  IPAddress IP = WiFi.softAPIP();

  Serial.print(" -> IP address: "); Serial.println(IP);

  server.begin();

  camera_config_t config;
  config.ledc_channel = LEDC_CHANNEL_0;
  config.ledc_timer = LEDC_TIMER_0;
  config.pin_d0 = Y2_GPIO_NUM;
  config.pin_d1 = Y3_GPIO_NUM;
  config.pin_d2 = Y4_GPIO_NUM;
  config.pin_d3 = Y5_GPIO_NUM;
  config.pin_d4 = Y6_GPIO_NUM;
  config.pin_d5 = Y7_GPIO_NUM;
  config.pin_d6 = Y8_GPIO_NUM;
  config.pin_d7 = Y9_GPIO_NUM;
  config.pin_xclk = XCLK_GPIO_NUM;
  config.pin_pclk = PCLK_GPIO_NUM;
  config.pin_vsync = VSYNC_GPIO_NUM;
  config.pin_href = HREF_GPIO_NUM;
  config.pin_sccb_sda = SIOD_GPIO_NUM;
  config.pin_sccb_scl = SIOC_GPIO_NUM;
  config.pin_pwdn = PWDN_GPIO_NUM;
  config.pin_reset = RESET_GPIO_NUM;
  config.xclk_freq_hz = 20000000;
  config.frame_size = FRAMESIZE_UXGA;
  config.pixel_format = PIXFORMAT_JPEG;                                                                    // for streaming
  //config.pixel_format = PIXFORMAT_RGB565;                                                                // for face detection/recognition
  config.grab_mode = CAMERA_GRAB_WHEN_EMPTY;
  config.fb_location = CAMERA_FB_IN_PSRAM;
  config.jpeg_quality = 12;
  config.fb_count = 1;
  // Configure camera settings (resolution, frame rate, etc.)
  if(psramFound()){
    config.frame_size = FRAMESIZE_VGA;                                                                     // FRAMESIZE_ + QVGA|CIF|VGA|SVGA|XGA|SXGA|UXGA
    config.jpeg_quality = 10;
    config.fb_count = 2;
  } else {
    config.frame_size = FRAMESIZE_VGA;
    config.jpeg_quality = 12;
    config.fb_count = 1;
  }
  esp_err_t res = esp_camera_init(&config);
  if (res != ESP_OK) {
    Serial.println("Failed to initialize camera");
    ESP.restart();
    return;
  }
  Serial.println("Camera initialized");

  panServo.setPeriodHertz(50);                                                                            // standard 50 hz servo
  tiltServo.setPeriodHertz(50);                                                                           // standard 50 hz servo
  
  panServo.attach(SERVO_1, 1000, 2000);
  tiltServo.attach(SERVO_2, 1000, 2000);
  
  panServo.write(90);
  tiltServo.write(90);
}
 
void loop() {
  WiFiClient client = server.available();
  if (client) {
    while (client.connected()) {
      if (client.available()) {
        String receivedData = client.readStringUntil('\n');
        if (!receivedData.isEmpty()) {
          // Parse and process the received data
          int firstAsterisk = receivedData.indexOf('*');
          int lastAsterisk = receivedData.lastIndexOf('*');
          String firstBracket = receivedData.substring(0,firstAsterisk);
          String lastBracket = receivedData.substring (lastAsterisk+1);
          if(firstBracket == "BB" and lastBracket == "CC"){
            int secondAsterisk = receivedData.indexOf('*', firstAsterisk + 1);
            int thirdAsterisk  =  receivedData.indexOf('*', secondAsterisk + 1);
            int fourthAsterisk  =  receivedData.indexOf('*', thirdAsterisk + 1);
            int fifthAsterisk  =  receivedData.indexOf('*', fourthAsterisk + 1);
            int sixthAsterisk  =  receivedData.indexOf('*', fifthAsterisk + 1);
            String imageRequest = receivedData.substring(firstAsterisk+1,secondAsterisk);
            actionParams.rightMotorSpeed =  receivedData.substring(secondAsterisk+1,thirdAsterisk);
            actionParams.leftMotorSpeed =  receivedData.substring(thirdAsterisk+1,fourthAsterisk);
            actionParams.panServoAngle = receivedData.substring(fourthAsterisk+1,fifthAsterisk);
            actionParams.tiltServoAngle = receivedData.substring(fifthAsterisk+1,sixthAsterisk);
            actionParams.flashMode = receivedData.substring(sixthAsterisk+1,lastAsterisk);
            if(imageRequest == "1"){
              int camSize;
              cam.run();
              camSize = cam.getSize();
              String base64String = base64::encode(cam.getfb(), camSize);
              client.println(base64String);
              client.stop();
            }
            int rightMotorDataInteger = actionParams.rightMotorSpeed.toInt();
            int leftMotorDataInteger = actionParams.leftMotorSpeed.toInt();
            if(rightMotorDataInteger >= 0){
              digitalWrite(MOTOR_RIGHT_DIR,0);
              analogWrite(MOTOR_EN_RIGHT, rightMotorDataInteger);
            }
            if(rightMotorDataInteger < 0){
              digitalWrite(MOTOR_RIGHT_DIR,1);            // Change DIRECTION
              rightMotorDataInteger = -1*rightMotorDataInteger;
              analogWrite(MOTOR_EN_RIGHT, rightMotorDataInteger);
            }
            if(leftMotorDataInteger >= 0){
              digitalWrite(MOTOR_LEFT_DIR,0);
              analogWrite(MOTOR_EN_LEFT, leftMotorDataInteger);
            }
            if(leftMotorDataInteger < 0){
              digitalWrite(MOTOR_LEFT_DIR,1);
              leftMotorDataInteger = -1*leftMotorDataInteger;
              analogWrite(MOTOR_EN_LEFT, leftMotorDataInteger);
            }
            panServo.write(actionParams.panServoAngle.toInt());
            tiltServo.write(actionParams.tiltServoAngle.toInt());
            if(actionParams.flashMode == "1"){
              digitalWrite(camFlash, 1);
            }
            else{
              digitalWrite(camFlash, 0);
            }
            }
          }
          else {
          client.println("NO DATA");
        }
      }
    }
  }
}                                                             
