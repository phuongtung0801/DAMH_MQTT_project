
#include <painlessMesh.h>
#include <Arduino.h>

#define MESH_PREFIX "tung"
#define MESH_PASSWORD "phuongtung0801"
#define MESH_PORT 5555

#define LED D0
#define LED1 D3

Scheduler userScheduler; // to control your personal task
painlessMesh mesh;

// Prototype
void receivedCallback(uint32_t from, String &msg);

size_t logServerId = 0;

// Send message to the logServer every 10 seconds
Task myLoggingTask(3000, TASK_FOREVER, []()
                   {
#if ARDUINOJSON_VERSION_MAJOR == 6
                     DynamicJsonDocument jsonBuffer(1024);
                     JsonObject msg = jsonBuffer.to<JsonObject>();
#else
      DynamicJsonBuffer jsonBuffer;
      JsonObject &msg = jsonBuffer.createObject();
#endif
                     msg["nodename"] = "light_sensor";
                     msg["nodeID"] = mesh.getNodeId();
                     msg["topic"] = "light";
                     msg["light"] = String(analogRead(A0));

                     String str;
#if ARDUINOJSON_VERSION_MAJOR == 6
                     serializeJson(msg, str);
#else
      msg.printTo(str);
#endif
                     if (logServerId == 0) // If we don't know the logServer yet
                       mesh.sendBroadcast(str);
                     else
                       mesh.sendSingle(logServerId, str);

    // log to serial
#if ARDUINOJSON_VERSION_MAJOR == 6
                     serializeJson(msg, Serial);
#else
      msg.printTo(Serial);
#endif
                     Serial.printf("\n");
                   });

void setup()
{
  Serial.begin(9600);
  pinMode(A0, OUTPUT);
  pinMode(LED1, OUTPUT);
  pinMode(LED, OUTPUT);

  mesh.setDebugMsgTypes(ERROR | STARTUP | CONNECTION); // set before init() so that you can see startup messages

  mesh.init(MESH_PREFIX, MESH_PASSWORD, &userScheduler, MESH_PORT, WIFI_AP_STA, 6);
  mesh.onReceive(&receivedCallback);

  // Add the task to the your scheduler
  userScheduler.addTask(myLoggingTask);
  myLoggingTask.enable();
}

void loop()
{
  userScheduler.execute(); // it will run mesh scheduler as well
  mesh.update();
}

void receivedCallback(uint32_t from, String &msg)
{
  Serial.printf("logClient: Received from %u msg=%s\n", from, msg.c_str());
  //String cmd = String(msg);
  if (msg == "off")
  {
    digitalWrite(LED, HIGH);
  } // LED off
  if (msg == "on")
  {
    digitalWrite(LED, LOW);
  } // LED on
  // Saving logServer
#if ARDUINOJSON_VERSION_MAJOR == 6
  DynamicJsonDocument jsonBuffer(1024 + msg.length());
  DeserializationError error = deserializeJson(jsonBuffer, msg);
  if (error)
  {
    Serial.printf("DeserializationError\n");
    return;
  }
  JsonObject root = jsonBuffer.as<JsonObject>();
#else
  DynamicJsonBuffer jsonBuffer;
  JsonObject &root = jsonBuffer.parseObject(msg);
#endif
  if (root.containsKey("topic"))
  {
    if (String("logServer").equals(root["topic"].as<String>()))
    {
      // check for on: true or false
      logServerId = root["nodeId"];
      Serial.printf("logServer detected!!!\n");
    }
    else if (String("exeNode").equals(root["topic"].as<String>()))
    {
      String exeCmd = root["exeCmd"].as<String>();
      if (exeCmd == "1")
      {
        digitalWrite(4, HIGH);
        Serial.printf("Turn on LED !");
      }
      else
      {
        digitalWrite(4, LOW);
        Serial.printf("Turn off LED !");
      }
    }
    Serial.printf("Handled from %u msg=%s\n", from, msg.c_str());
  }
}