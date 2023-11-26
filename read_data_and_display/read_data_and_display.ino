#include <DHT.h>
#include <LiquidCrystal_I2C.h>
#include <ESP8266WiFi.h>
#include <DNSServer.h>
#include <ESP8266WebServer.h>
#include "WiFiManager.h"
#include <ArduinoJson.h>
#include "secret.h"
#include <PubSubClient.h>

#include <ESP8266WebServer.h>
#include <WiFiManager.h>

#define DHT_PIN D4
#define MQ7_PIN_CONTROLL D7
#define MQ135_PIN_CONTROLL D6
#define DHTTYPE DHT22

DHT dht(DHT_PIN, DHTTYPE);
LiquidCrystal_I2C lcd(0x27, 16, 2);
WiFiClient askClient;
PubSubClient client(askClient);

long now = millis();
long lastMeasure = 0;
int t_delay = 5000;

ESP8266WebServer server(80);

String mqttServerInput = "";  // To store the user-input MQTT server IP address

void handleRoot() {
  String html = "<html><body>";
  html += "<h1>MQTT Server Configuration</h1>";
  html += "<form action='/save' method='get'>";
  html += "MQTT Server IP: <input type='text' name='mqttServer' value='" + mqttServerInput + "'><br>";
  html += "<input type='submit' value='Save'>";
  html += "</form></body></html>";

  server.send(200, "text/html", html);
}

void handleSave() {
  mqttServerInput = server.arg("mqttServer");
  server.send(200, "text/plain", "MQTT Server IP saved: " + mqttServerInput);
}

void configModeCallback(WiFiManager *myWiFiManager)
{
  Serial.println("Entered config mode");
  Serial.println(WiFi.softAPIP());
  Serial.println(myWiFiManager->getConfigPortalSSID());
}

void displayOnLCD(String line1, String line2)
{
  lcd.clear();
  lcd.setCursor(0, 0);
  lcd.print(line1);
  lcd.setCursor(0, 1);
  lcd.print(line2);
}

void setup()
{
  Serial.begin(115200);

  while (!Serial)
  {
  }

  byte count = 0;
  Wire.begin();
  for (byte i = 8; i < 120; i++)
  {
    Wire.beginTransmission(i);
    if (Wire.endTransmission() == 0)
    {
      count++;
      delay(1);
    }
  }
  lcd.init();
  lcd.backlight(); 
  
  displayOnLCD("Connecting to", "WiFi...");

  WiFiManager wifiManager;
  wifiManager.setAPCallback(configModeCallback);

  if (!wifiManager.autoConnect())
  {
    displayOnLCD("Failed to connect", "Resetting...");
    ESP.reset();
    delay(1000);
  }

  displayOnLCD("Connected to", WiFi.SSID());

  Serial.println("Connected to WiFi");

  client.setServer(mqtt_server, mqtt_port);
  client.setCallback(callback);

  displayOnLCD("Connecting to", "MQTT...");

  dht.begin();
  pinMode(DHT_PIN, INPUT);
  pinMode(A0, INPUT);
  pinMode(MQ7_PIN_CONTROLL, OUTPUT);
  pinMode(MQ135_PIN_CONTROLL, OUTPUT);

   // Setup WiFi and add custom parameters (MQTT server IP)
  WiFiManagerParameter custom_mqtt_server("mqttServer", "MQTT Server IP", mqttServerInput.c_str(), 40);

  wifiManager.addParameter(&custom_mqtt_server);

  // Setup web server routes
  server.on("/", HTTP_GET, handleRoot);
  server.on("/save", HTTP_GET, handleSave);
  
  displayOnLCD("IP: ", WiFi.localIP().toString());
  
  server.begin();

  // reconnect();
  // publicData();
}
int analogReadMQ7() {
    delay(100);
    digitalWrite(MQ7_PIN_CONTROLL, HIGH); // Turn MQ7 On
    delay(200);
    digitalWrite(MQ135_PIN_CONTROLL, LOW); // Turn MQ135 Off
    delay(200);
    return analogRead(A0);
}
 
int analogReadMQ135() {
    delay(100);
    digitalWrite(MQ7_PIN_CONTROLL, LOW); //  Turn MQ7 Off
    delay(200);
    digitalWrite(MQ135_PIN_CONTROLL, HIGH); // Turn MQ135 On
    delay(200);
    return analogRead(A0);
}

void loop() {
  server.handleClient();
  now = millis();
  // Check if the MQTT server address is available
  if (mqttServerInput.length() > 0) {
    // Publishes new temperature and humidity every 30 seconds
    if (now - lastMeasure > t_delay - 400) {
      reconnect();
      publicData();
   }
  }
}

 
//MQTT callback
void callback(char* topic, byte * payload, unsigned int length) {

  for (int i = 0; i < length; i++) {
    Serial.println(topic);
    Serial.print(" has send ");
    Serial.print((char)payload[i]);
  }

}
 
//MQTT reconnect
void reconnect()
{
  // Loop until we're reconnected
  while (!client.connected())
  {
    displayOnLCD("Connecting to", "MQTT...");

    Serial.println("********** Attempting MQTT connection...");

    if (client.connect(ClientID, username, mqttpass, lastwill, 1, 1, lastwillmsg))
    {
      Serial.println("-> MQTT client connected");
      client.subscribe(topic);
      Serial.print("Subscribed to: ");
      Serial.println(topic);
      displayOnLCD("Connected to", "MQTT");
    }
    else
    {
      Serial.print("failed, rc=");
      Serial.print(client.state());
      Serial.println("-> try again in 5 seconds");
      // Wait 5 seconds before retrying
      delay(5000);
    }
  }
}

void publicData()
{
  lastMeasure = now;

  // Read DHT22
  float T_inC, H_inPer, Gas, Co;
  T_inC = dht.readTemperature();
  H_inPer = dht.readHumidity();

  Co = analogReadMQ7(); // Read Analog value of the first sensor
  Gas = analogReadMQ135(); // Read Analog value of the second sensor

  Serial.print(T_inC);
  Serial.println(" C");
  Serial.print(H_inPer);
  Serial.println(" P");
  Serial.print(Co);
  Serial.println(" Co");
  Serial.print(Gas);
  Serial.println(" Gas");
  Serial.println("===========================================");

  // Display the data on the LCD using the displayOnLCD function
  displayOnLCD(String(T_inC) + (char)223 + "C"+" "+ String(H_inPer) + "%", String(Gas) + "G" +" "+ String(Co) + "Co");

  // Publish data to MQTT
  client.publish("master/quy_esp/writeattributevalue/MQ135/65VFyoeH9DRpTsLZxtdvkQ", String(Gas).c_str());
  client.publish("master/quy_esp/writeattributevalue/MQ7/65VFyoeH9DRpTsLZxtdvkQ", String(Co).c_str());
  client.publish("master/quy_esp/writeattributevalue/temperature/65VFyoeH9DRpTsLZxtdvkQ", String(T_inC).c_str());
  client.publish("master/quy_esp/writeattributevalue/relativeHumidity/65VFyoeH9DRpTsLZxtdvkQ", String(H_inPer).c_str());
}

