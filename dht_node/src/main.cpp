//************************************************************
// this is a simple example that uses the painlessMesh library to 
// setup a node that logs to a central logging node
// The logServer example shows how to configure the central logging nodes
//************************************************************
#include "painlessMesh.h"
#include "DHT.h"
#include "math.h"

#define   MESH_PREFIX     "tung"
#define   MESH_PASSWORD   "phuongtung0801"
#define   MESH_PORT       5555

#define DHTTYPE DHT11
#define DHTPin 14
#define LED D0
//const int DHTPin = 5;
DHT dht(DHTPin, DHTTYPE);

Scheduler     userScheduler; // to control your personal task
painlessMesh  mesh;

// Prototype
void receivedCallback( uint32_t from, String &msg );

size_t logServerId = 0;
size_t test = 0;

// Send message to the logServer every 10 seconds 
Task myLoggingTask(5000, TASK_FOREVER, []() {
#if ARDUINOJSON_VERSION_MAJOR==6
        DynamicJsonDocument jsonBuffer(1024);
        JsonObject msg = jsonBuffer.to<JsonObject>();
#else
        DynamicJsonBuffer jsonBuffer;
        JsonObject& msg = jsonBuffer.createObject();
#endif
    float h = dht.readHumidity();
    float t = dht.readTemperature();
  
//    msg["nodename"] = "dht11_sensor";
    msg["nodeID"] = mesh.getNodeId();
    msg["topic"] = "dht11";
    msg["temperature"] = String(t);
    msg["humidity"] = String(h);

    String str;
#if ARDUINOJSON_VERSION_MAJOR==6
    serializeJson(msg, str);
#else
    msg.printTo(str);
#endif
    if (logServerId == 0) // If we don't know the logServer yet
        mesh.sendBroadcast(str);
    else
        mesh.sendSingle(logServerId, str);

    // log to serial
#if ARDUINOJSON_VERSION_MAJOR==6
    serializeJson(msg, Serial);
#else
    msg.printTo(Serial);
#endif
    Serial.printf("\n");
});

void setup() {
  Serial.begin(9600);
  dht.begin();
  delay(10);
  pinMode(4, OUTPUT);
  pinMode(LED, OUTPUT);
    
  mesh.setDebugMsgTypes( ERROR | STARTUP | CONNECTION );  // set before init() so that you can see startup messages

  mesh.init( MESH_PREFIX, MESH_PASSWORD, &userScheduler, MESH_PORT, WIFI_AP_STA, 6 );
  mesh.onReceive(&receivedCallback);

  // Add the task to the your scheduler
  userScheduler.addTask(myLoggingTask);
  myLoggingTask.enable();
}

void loop() {
    userScheduler.execute(); // it will run mesh scheduler as well
    mesh.update();
}

void receivedCallback( uint32_t from, String &msg ) {
  Serial.printf("logClient: Received from %u msg=%s\n", from, msg.c_str());
  if (msg == "on")
  {
    digitalWrite(LED, LOW);
  }
  if (msg == "off")
  {
    digitalWrite(LED, HIGH);
  }
}
