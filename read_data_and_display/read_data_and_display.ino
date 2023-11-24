#include <DHT.h>
#include <LiquidCrystal_I2C.h>
#include <ESP8266WiFi.h> //https://github.com/esp8266/Arduino
#include <DNSServer.h>
#include <ESP8266WebServer.h>
#include "WiFiManager.h" //https://github.com/tzapu/WiFiManager
#include  <ArduinoJson.h>
#include "secret.h"
#include <PubSubClient.h>
#define DHT_PIN D4 
 
#define MQ7_PIN_CONTROLL D7 
#define MQ135_PIN_CONTROLL D6

#define DHTTYPE DHT22
DHT dht(DHT_PIN, DHTTYPE);
// V$L$oft@2019
LiquidCrystal_I2C lcd(0x27,16,2); 

// timer instead of wait
long now = millis();
long lastMeasure = 0;
int t_delay = 5000;

 
//Objects
WiFiClient askClient; //Non-SSL Client, also remove the comments for askClient.setCACert(local_root_ca);

PubSubClient client(askClient);

 
void configModeCallback (WiFiManager *myWiFiManager)
{
  Serial.println("Entered config mode");
  Serial.println(WiFi.softAPIP());
  Serial.println(myWiFiManager->getConfigPortalSSID());
}


void setup() {
  // put your setup code here, to run once:
  Serial.begin(115200);

  //  wait for serial port to connect
  while (!Serial) 
    {
    }

  Serial.println ();
  Serial.println ("I2C scanner. Scanning ...");
  byte count = 0;
  
  Wire.begin();
  for (byte i = 8; i < 120; i++)
  {
    Wire.beginTransmission (i);
    if (Wire.endTransmission () == 0)
      {
      Serial.print ("Found address: ");
      Serial.print (i, DEC);
      Serial.print (" (0x");
      Serial.print (i, HEX);
      Serial.println (")");
      count++;
      delay (1);  // maybe unneeded?
      } // end of good response
  } 
  lcd.init();
  lcd.backlight();    
  
  Serial.println ("Done.");
  Serial.print ("Found ");
  Serial.print (count, DEC);
  Serial.println (" device(s).");
  

  lcd.clear();  
  lcd.setCursor(0,0); 
  lcd.print("Connecting to");
  lcd.setCursor(0,1); 
  lcd.print("wifi....");

  //Khai bao wifiManager
  WiFiManager wifiManager;
  //Setup callback de khoi dong AP voi SSID "ESP+chipID"
  wifiManager.setAPCallback(configModeCallback);
  if (!wifiManager.autoConnect())
  {
    lcd.clear();  
    lcd.setCursor(0,0); 
    lcd.print("Failed to connect");
    Serial.println("failed to connect and hit timeout");
    //Neu ket noi that bai thi reset
    ESP.reset();
    delay(1000);
  }
  
  // Thanh cong thi bao ra man hinh
  Serial.println("connected...");
 
  
  // askClient.setFingerprint(fingerprint);
  // askClient.setTrustAnchors(&cert);
  Serial.println("********** Attempting MQTT connection...");
  
  client.setServer(mqtt_server, mqtt_port);
  client.setCallback(callback);
  
  lcd.clear();  
  lcd.setCursor(0,0); 
  lcd.print("Attempting MQTT");
  lcd.setCursor(0,1); 
  lcd.print("connection....");
  
  dht.begin();
  pinMode(DHT_PIN, INPUT);
  pinMode(A0, INPUT);

  pinMode(MQ7_PIN_CONTROLL, OUTPUT);
  pinMode(MQ135_PIN_CONTROLL, OUTPUT);

  reconnect();
  publicData();
}

int analogReadMQ7() {
    digitalWrite(MQ7_PIN_CONTROLL, HIGH); // Turn MQ7 On
    digitalWrite(MQ135_PIN_CONTROLL, LOW); // Turn MQ135 Off
    return analogRead(A0);
}
 
int analogReadMQ135() {
    digitalWrite(MQ7_PIN_CONTROLL, LOW); //  Turn MQ7 Off
    digitalWrite(MQ135_PIN_CONTROLL, HIGH); // Turn MQ135 On
    return analogRead(A0);
}

void loop() {
    now = millis();
  // Publishes new temperature and humidity every 30 seconds
  if (now - lastMeasure > t_delay - 400) {
      reconnect();
      publicData();

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
void reconnect() {
  // Loop until we're reconnected
  while (!client.connected()) {
    Serial.println("********** Attempting MQTT connection...");
    // Attempt to connect
    Serial.print("ClientID to: ");
    Serial.println(ClientID);
    Serial.print("username to: ");
    Serial.println(username);
    Serial.print("mqttpass to: ");
    Serial.println(mqttpass);

    if (client.connect(ClientID, username, mqttpass, lastwill, 1, 1, lastwillmsg)) {
      Serial.println("-> MQTT client connected");
      client.subscribe(topic);
      Serial.print("Subscribed to: ");
      Serial.println(topic);
    } else {
      Serial.print("failed, rc=");
      Serial.print(client.state());
      Serial.println("-> try again in 5 seconds");
      // Wait 5 seconds before retrying
      delay(5000);
    }
  }
}

void publicData () {
   lastMeasure = now;
  

   // Read DHT22
    float T_inC, H_inPer, Gas, Co;
    T_inC=dht.readTemperature();
    H_inPer=dht.readHumidity();
    
    Co = analogReadMQ7(); // Read Analog value of first sensor
    delay(200);
    Gas = analogReadMQ135(); // Read Analog value of second sensor
    delay(200);
    
 
    Serial.print(T_inC); Serial.println(" C");
    Serial.print(H_inPer); Serial.println(" P");
    Serial.print(Co); Serial.println(" Co");
    Serial.print(Gas); Serial.println(" Gas");
    Serial.println("===========================================");

    lcd.clear();  
    lcd.setCursor(0,0);   //Set cursor to character 0 on line 0
    lcd.print(String(T_inC));
    lcd.print((char)223); // this is for celcius symbol
    lcd.print("C");
    lcd.setCursor(8,0);
    lcd.print(String(H_inPer));
    lcd.print("%");
    lcd.setCursor(0,1);   //Set cursor to character 0 on line 1
    lcd.print(String(Gas));
    lcd.print("G ");
    lcd.setCursor(8,1); 
    lcd.print(String(Co));
    lcd.print("Co");
    
    client.publish("master/quy_esp/writeattributevalue/MQ135/65VFyoeH9DRpTsLZxtdvkQ", String(Gas).c_str());
    client.publish("master/quy_esp/writeattributevalue/MQ7/65VFyoeH9DRpTsLZxtdvkQ", String(Co).c_str());

    client.publish("master/quy_esp/writeattributevalue/temperature/65VFyoeH9DRpTsLZxtdvkQ", String(T_inC).c_str());
    client.publish("master/quy_esp/writeattributevalue/relativeHumidity/65VFyoeH9DRpTsLZxtdvkQ", String(H_inPer).c_str());
 
}

 
