

#include <Arduino.h>
#include <painlessMesh.h>
#include <PubSubClient.h>
#include <FirebaseESP8266.h>
#include <WiFiClient.h>

#define MESH_PREFIX "tung"
#define MESH_PASSWORD "phuongtung0801"
#define MESH_PORT 5555

#define STATION_SSID "TUNG"
#define STATION_PASSWORD "123456789"
//WiFiEventHandler wifiConnectHandler;
//WiFiEventHandler wifiDisconnectHandler;

#define HOSTNAME "MQTT_Bridge"

#define FIREBASE_HOST "fssss-2e7f5-default-rtdb.firebaseio.com"
#define FIREBASSE_AUTH "pgH2ib2xH2sWqkuA0Lg1EJWNEzfyHXFNtt9BFtsU"
FirebaseData firebaseData;
String path = "/";
FirebaseJson json;
unsigned long t1 = 0;
const unsigned long eventInterval = 5000;
unsigned long previousTime = 0;

const char *mqtt_server = "m14.cloudmqtt.com";
const char *mqtt_username = "bxpalvco";
const char *mqtt_password = "UUILhS73phGV";
const char *clientID = "TUNG";
const char *endTopic = "phuongtung0801/LWT";

// Prototypes
void receivedCallback(const uint32_t &from, const String &msg);
void mqttCallback(char *topic, byte *payload, unsigned int length);

IPAddress getlocalIP();

IPAddress myIP(0, 0, 0, 0);
//IPAddress mqttBroker("m2m.eclipse.org");

painlessMesh mesh;
WiFiClient wifiClient;
//tạo một instance để kết nối. Sử dụng cú pháp PubSubClient (server, port, [callback], client, [stream])

//PubSubClient mqttClient(wifiClient);
PubSubClient mqttClient(mqtt_server, 12321, mqttCallback, wifiClient);

void setup()
{
  Serial.begin(9600);

  mesh.setDebugMsgTypes(ERROR | STARTUP | CONNECTION); // set before init() so that you can see startup messages

  // Channel set to 6. Make sure to use the same channel for your mesh and for you other
  // network (STATION_SSID)
  mesh.init(MESH_PREFIX, MESH_PASSWORD, MESH_PORT, WIFI_AP_STA, 6);
  mesh.onReceive(&receivedCallback);

  mesh.stationManual(STATION_SSID, STATION_PASSWORD);
  mesh.setHostname(HOSTNAME);

  WiFi.begin(STATION_SSID, STATION_PASSWORD);

  while (WiFi.status() != WL_CONNECTED)
  {
    delay(500);
    Serial.println("Connecting to WiFi..");
  }
  Serial.println("Connected to the WiFi network");
  WiFi.setAutoReconnect(true);
  WiFi.persistent(true);
  //kết nối mqtt broker
  mqttClient.setServer(mqtt_server, 12321);
  mqttClient.setCallback(mqttCallback);
  //mqttClient.connect(clientID, "", "", "theEndTopic", 1, true, "offline");
  if (mqttClient.connect(
          clientID, mqtt_username, mqtt_password, endTopic, 1, true, "Sensor disconnected from mqtt"))
  {
    Serial.println("Connected to MQTT Broker!");
    mqttClient.publish(endTopic, "Sensor connected!", true);
  }
  else
  {
    Serial.println("Connection to MQTT Broker failed...");
  }

  mqttClient.subscribe("tungtran");
  mqttClient.subscribe(endTopic);

  //set up fire base
  Firebase.begin(FIREBASE_HOST, FIREBASSE_AUTH);
  Firebase.reconnectWiFi(true);
  if (!Firebase.beginStream(firebaseData, path))
  {
    Serial.println("Reason: " + firebaseData.errorReason());
    Serial.println();
  }
}

void loop()
{
  mesh.update();
  mqttClient.loop();

  /* Updates frequently */
  unsigned long currentTime = millis();

  //wifi checking
  if (currentTime - previousTime >= eventInterval)
  {
    switch (WiFi.status())
    {
    case WL_CONNECTED:
      //Serial.println("Wifi Connection successfully established");
      if (!mqttClient.connected())
      {
        Serial.println("Reconnecting to MQTT...");
        if (mqttClient.connect(
                clientID, mqtt_username, mqtt_password, endTopic, 1, true, "Sensor disconnected from mqtt"))
        {
          Serial.println("Reconnect to MQTT success!");
          mqttClient.setServer(mqtt_server, 12321);
          mqttClient.setCallback(mqttCallback);
          mqttClient.subscribe("tungtran");
          mqttClient.publish(endTopic, "Sensor connected!", true);
        }
        else
        {
          Serial.println("MQTT connection is lost!");
        }
      }
      break;

    default:
      Serial.println("Failed to connect Wifi");
      break;
    }
    //Update timing for next round
    previousTime = currentTime;
  }

  if (myIP != getlocalIP())
  {
    myIP = getlocalIP();
    Serial.println("My IP is " + myIP.toString());
  }
}

void receivedCallback(const uint32_t &from, const String &msg)
{
  Serial.printf("bridge: Received from %u msg=%s\n", from, msg.c_str());
  //String topic = "painlessMesh/from/2131961461";
  String topic = "painlessMesh/from/" + String(from);
  mqttClient.publish(topic.c_str(), msg.c_str());
  json.setJsonData(msg);
  Firebase.setJSON(firebaseData, path + "/node value", json);
  Serial.println("Data received");
}

void mqttCallback(char *topic, uint8_t *payload, unsigned int length)
{

  String cmd = "";

  Serial.print("Message arrived [");
  Serial.print(topic);
  Serial.print("] ");
  for (int i = 0; i < length; i++)
  {
    cmd += (char)payload[i];
  }
  Serial.println(cmd);
  if (cmd == "on")
  {
    mesh.sendSingle(110231767, cmd);
  }
  if (cmd == "off")
  {
    mesh.sendSingle(110231767, cmd);
  }
}
//end mqttCallback

IPAddress getlocalIP()
{
  return IPAddress(mesh.getStationIP());
}
