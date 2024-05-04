#include <WiFi.h>
const int ledPin = 4;
const char* ssid     = "RoofInspector";
const char* password     = "123456789";
const uint16_t portNumber = 8088; WiFiServer server(portNumber);
WiFiClient client;
bool connected = false;
IPAddress AP_LOCAL_IP(192, 168, 1, 160);
IPAddress AP_GATEWAY_IP(192, 168, 1, 4);
IPAddress AP_NETWORK_MASK(255, 255, 255, 0);
float  t=14.6;
void setup() {
  pinMode(ledPin, OUTPUT);
  Serial.begin(115200); Serial.println();
  Serial.print("Setting AP (Access Point)…");
  WiFi.softAP(ssid,password);
    if (!WiFi.softAPConfig(AP_LOCAL_IP, AP_GATEWAY_IP, AP_NETWORK_MASK)) {
    Serial.println("AP Config Failed");
    return;
  }
  IPAddress IP = WiFi.softAPIP();
  Serial.print(" -> IP address: "); Serial.println(IP);
  server.begin();
}
 
void loop() {   
    WiFiClient client = server.available(); 
    uint8_t data[30]; 
    if (client) {
      Serial.println("new client");

      while (client.connected()) {
        digitalWrite(ledPin, HIGH);
          if (client.available()) {
              int len = client.read(data, 30);
              if(len < 30){
                  data[len] = '\0';
              }else {
                  data[30] = '\0';
              }
              Serial.print("client sent: ");
              Serial.println((char *)data);
              client.println("aaa");
          }
      }
      
       digitalWrite(ledPin, LOW);
    }
}
