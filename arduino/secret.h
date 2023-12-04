// Wifi 
const char* ssid = "xxxxxxxxxx"; // Wifi SSID
const char* password = "xxxxxxxxxx"; // Wifi Password

//MQTT Broker
const char* mqtt_server = "192.168.2.106";
unsigned int mqtt_port = 1883; //SSL 8883 NoneSSL 1883
const char* username = "master:quy"; // Service User Realm:Serviceuser
const char* mqttpass = "JdH6fLtpmYCj62XAHbUfdxeaAgl9tjyX"; // Service User Secret
const char* ClientID = "quy_esp";
const char* assestID = "65VFyoeH9DRpTsLZxtdvkQ";
//LastWill
const char* lastwill = "master/quy_esp/writeattributevalue/temperature/65VFyoeH9DRpTsLZxtdvkQ";
const char* lastwillmsg = "30";
//subscribing Topic
const char* topic = "master/quy_esp/attributevalue/temperature/65VFyoeH9DRpTsLZxtdvkQ"; //see Subscribing Topics in Documentation https://github.com/openremote/openremote/wiki/User-Guide%3A-Manager-APIs#mqtt-api-mqtt-broker
