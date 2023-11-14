import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:iot_app/model/weather.dart';
import 'package:iot_app/provider/log_provider.dart';
import 'package:mqtt_client/mqtt_client.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:mqtt_client/mqtt_server_client.dart';
import 'package:http/http.dart' as http;
class MqttPage extends StatefulWidget {
  const MqttPage({super.key});

  @override
  MqttPageState createState() => MqttPageState();
}

class MqttPageState extends State<MqttPage> {
  TextEditingController ipAddressController = TextEditingController();
  late MqttServerClient client;
  String receivedData = '';
  String temperature = "";
  String humidity = "";
  WeatherInfoToday? weatherData;
  List<WeatherInfoToday> forecastData = [];

  bool isConnected = false;
  @override
  void initState() {
    getToken();
    super.initState();
  }
  void getToken() async {
    var headers = {'Content-Type': 'application/x-www-form-urlencoded'};
    var request = http.Request( 'POST', Uri.parse('https://192.168.1.6/auth/realms/master/protocol/openid-connect/token'));
    request.bodyFields = {
      'grant_type': 'client_credentials',
      'client_id': 'quy',
      'client_secret': 'JdH6fLtpmYCj62XAHbUfdxeaAgl9tjyX'
    };
    request.headers.addAll(headers);

    http.StreamedResponse response = await request.send();
    Log.print("data--> ${response.statusCode}");
    if (response.statusCode == 200) {
      final data = await response.stream.bytesToString();
      Log.print("data--> $data");
    } else {
      Log.print( "response--> ${response.reasonPhrase}" );
    }
  }
  void connectToMqttServer(String ipAddress) async {
    client = MqttServerClient(ipAddress, 'iot_app');
    final MqttConnectMessage connMess = MqttConnectMessage()
        .withClientIdentifier('iot_app')
        .withWillTopic('willtopic')
        .withWillMessage('Will message')
        .startClean()
        .withWillQos(MqttQos.atLeastOnce)
        .withClientIdentifier('iot_app')
        .authenticateAs('master:quy', 'JdH6fLtpmYCj62XAHbUfdxeaAgl9tjyX');
    client.connectionMessage = connMess;
    client.keepAlivePeriod = 30;
    try {
      await client.connect();
      setState(() {
        isConnected = true;
      });
      client.subscribe('master/iot_app/attribute/+/#', MqttQos.atLeastOnce);
      client.updates?.listen((List<MqttReceivedMessage<MqttMessage>> c) {
        final MqttPublishMessage recMess = c[0].payload as MqttPublishMessage;
        final String message =
            MqttPublishPayload.bytesToStringAsString(recMess.payload.message);
        final jsonMessage = json.decode(message);

        if (jsonMessage["attributeState"]["ref"]["name"] == "temperature") {
          setState(() {
            temperature = jsonMessage["attributeState"]["value"].toString();
          });
        }
        if (jsonMessage["attributeState"]["ref"]["name"] == "humidity") {
          setState(() {
            humidity = jsonMessage["attributeState"]["value"].toString();
          });
        }
      });
    } catch (e) {
      Fluttertoast.showToast(
        msg: 'Failed to connect to the MQTT server',
        backgroundColor: Colors.red,
        textColor: Colors.white,
      );
      Log.print('Exception 123: $e');
    }
  }

  void disconnectFromMqttServer() {
    client.disconnect();
    setState(() {
      isConnected = false;
      receivedData = '';
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        title: const Text('MQTT Page'),
      ),
      body: Container(
        width: MediaQuery.of(context).size.width,
        decoration: const BoxDecoration(
          image: DecorationImage(
            image: AssetImage("assets/bg.png"),
            fit: BoxFit.fill,
          ),
        ),
        child: Column(
          children: <Widget>[
            SizedBox(height: AppBar().preferredSize.height + 10),
            if (!isConnected)
              Padding(
                padding: const EdgeInsets.all(16.0),
                child: TextField(
                  controller: ipAddressController,
                  decoration: const InputDecoration(
                    hintText: 'Enter IP Address (e.g., 0.0.0.0)',
                  ),
                ),
              ),
            if (!isConnected)
              ElevatedButton(
                onPressed: () {
                  if (ipAddressController.text != '') {
                    connectToMqttServer(ipAddressController.text);
                  }
                },
                child: const Text('Connect'),
              ),
            if (isConnected)
              Column(
                children: [
                  ElevatedButton(
                    onPressed: disconnectFromMqttServer,
                    child: const Text('Disconnect'),
                  ),
                  Column(
                    children: [
                      if(temperature != "") Text('Temprature: ${temperature.toString()} \u2103'),
                      if (humidity != "") Text('Humidity: ${humidity.toString()} %'),
                    ],
                  ),
                ],
              )
          ],
        ),
      ),
    );
  }

  @override
  void dispose() {
    if (isConnected) {
      client.disconnect();
    }
    super.dispose();
  }
}
