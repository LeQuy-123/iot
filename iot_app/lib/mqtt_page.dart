import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:iot_app/model/asset.dart';
import 'package:iot_app/model/weather.dart';
import 'package:iot_app/provider/log_provider.dart';
import 'package:iot_app/provider/token_provider.dart';
import 'package:iot_app/widget/asset_list_select.dart';
import 'package:iot_app/widget/chart.dart';
import 'package:iot_app/widget/custom_date_picker.dart';
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
  String temperature = "0.0";
  String humidity = "0.0";
  WeatherInfoToday? weatherData;

  DateTime? selectedDateTime;
  String? selectedDateTimeType = '';

  String selectedAssetId = '';

  List<Asset> listAsset = [];


  bool isConnected = false;
  @override
  void initState() {
    super.initState();
  }

 

  void connectToMqttServer(String ipAddress) async {
    getAssestsList(ipAddress);
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
        if(jsonMessage["attributeState"]["ref"]["id"] == "65VFyoeH9DRpTsLZxtdvkQ") {
          if (jsonMessage["attributeState"]["ref"]["name"] == "temperature") {
          setState(() {
            temperature = jsonMessage["attributeState"]["value"].toString();
          });
        }
        if (jsonMessage["attributeState"]["ref"]["name"] == "relativeHumidity") {
          setState(() {
            humidity = jsonMessage["attributeState"]["value"].toString();
          });
        }
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

  void getAssestsList(String ipAddress) async {
    String? token = await TokenProvider.getToken(ipAddress);

    var headers = {
      'Content-Type': 'application/json', // Change content type to JSON
      'Authorization': token ?? '',
    };

    var body = {
      "recursive": true,
      "select": {"basic": true},
      "realm": {"name": "master"},
      "parents": [
        {"id": "7DKNXpBRGRX0El2mY7F6N8"}
      ],
      "limit": 20
    };

    var request = http.Request(
        'POST', Uri.parse('https://$ipAddress/api/master/asset/query'));

    // Encode the body data to JSON
    request.body = jsonEncode(body);

    request.headers.addAll(headers);

    // Send the request
    var response = await http.Client().send(request);

    // Handle the response as needed
    try {
      if (response.statusCode == 200) {
        // Successful response
        var responseBody = await response.stream.bytesToString();
        List<dynamic> jsonList = json.decode(responseBody);
        List<Asset> assets =
            jsonList.map((json) => Asset.fromJson(json)).toList();
        List<Asset> uniqueAssets = removeDuplicatesById(assets);
        setState(() {
          listAsset = uniqueAssets;
        });
        Log.print("Response: $responseBody");
      } else {
        // Handle errors
        Log.print("Error: ${response.statusCode}");
        Log.print("Response: ${await response.stream.bytesToString()}");
      }
    } catch (e) {
      Log.print("Error: $e");
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        title: const Text('MQTT Page'),
        actions: [
          if (isConnected)
            TextButton(
              onPressed: disconnectFromMqttServer,
              child: const Text('Disconnect'),
            ),
        ],
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
                  keyboardType: TextInputType.number,
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
              SingleChildScrollView(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.start,
                  children: [
                    Column(
                      children: [
                        const SizedBox(height: 16),
                        Container(
                          padding: const EdgeInsets.all(16.0),
                          decoration: BoxDecoration(
                            gradient: LinearGradient(
                              begin: Alignment.topLeft,
                              end: Alignment.bottomRight,
                              colors: [
                                double.parse(temperature) > 30.0
                                    ? Colors.red
                                    : Colors.blue,
                                Colors.teal
                              ], // Gradient colors
                            ),
                            borderRadius: BorderRadius.circular(12.0),
                            boxShadow: [
                              BoxShadow(
                                color: Colors.grey.withOpacity(0.5),
                                spreadRadius: 5,
                                blurRadius: 7,
                                offset: const Offset(0, 3),
                              ),
                            ],
                          ),
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.start,
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'Temperature: ${temperature.toString()} \u2103',
                                style: const TextStyle(
                                  color: Colors.white, // Text color
                                  fontSize: 14.0,
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                              Text(
                                'Humidity: ${humidity.toString()} %',
                                style: const TextStyle(
                                  color: Colors.white, // Text color
                                  fontSize: 14.0,
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                            ],
                          ),
                        ),
                        Column(
                          children: [
                            Padding(
                              padding: const EdgeInsets.all(16.0),
                              child: Row(
                                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                                children: [
                                  AssetListSelectWidget(
                                      assets: listAsset,
                                      onSelectAssets: (String id) {
                                        setState(() {
                                          selectedAssetId = id;
                                        });
                                      }),
                                  CustomDateTimePicker(onSelectTimeRange: (x, type) {
                                    setState(() {
                                      selectedDateTime = x;
                                      selectedDateTimeType = type;
                                    });
                                  }),
                                ],
                              ),
                            ),
                            LineChartSample10(
                                selectedDateTime: selectedDateTime,
                                selectedAssetId: selectedAssetId,
                                temperature: temperature,
                                selectedDateTimeType: selectedDateTimeType,
                                ipAddress: ipAddressController.text)
                           
                          ],
                        ),
                      ],
                    ),
                  ],
                ),
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
List<Asset> removeDuplicatesById(List<Asset> inputList) {
  Set<String> uniqueIds = {};
  List<Asset> resultList = [];

  for (var asset in inputList) {
    if (uniqueIds.add(asset.id)) {
      // If the id is added to the set, it means it's unique, so add the asset to the result list.
      resultList.add(asset);
    }
  }

  return resultList;
}
