// ignore_for_file: avoid_developer.log

import 'dart:convert';
import 'dart:io';

// import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:iot_app/model/location.dart';
// import 'package:iot_app/widget/clock.dart';
// ignore: unused_import
import 'package:mqtt_client/mqtt_client.dart';
import 'package:mqtt_client/mqtt_server_client.dart';
import 'dart:developer' as developer;

final client = MqttServerClient('192.168.1.13', '');

/// The subscribed callback
void onSubscribed(String topic) {
  developer.log('EXAMPLE::Subscription confirmed for topic $topic');
}

/// The unsolicited disconnect callback
void onDisconnected() {
  developer
      .log('EXAMPLE::OnDisconnected client callback - Client disconnection');
  if (client.connectionStatus!.disconnectionOrigin ==
      MqttDisconnectionOrigin.solicited) {
    developer
        .log('EXAMPLE::OnDisconnected callback is solicited, this is correct');
  } else {
    developer.log(
        'EXAMPLE::OnDisconnected callback is unsolicited or none, this is incorrect - exiting');
  }
}

/// The successful connect callback
void onConnected() {
  developer.log(
      'EXAMPLE::OnConnected client callback - Client connection was successful');
}

void onAutoReconnect() {
  developer.log(
      'EXAMPLE::onAutoReconnect client callback - Client auto reconnection sequence will start');
}

class MqttPage extends StatefulWidget {
  const MqttPage({super.key, required this.title});
  final String title;

  @override
  State<MqttPage> createState() => _MqttPageState();
}

class _MqttPageState extends State<MqttPage> {
  bool isOn = false;
  List<Location> locations = []; // List of Location objects
  Location? selectedLocation;
  @override
  void initState() {
    initMQTT();
    super.initState();
  }

  Future<void> initMQTT() async {
    const pubTopic = "master/client1/attribute/+/#";
    final connMess = MqttConnectMessage()
        .withClientIdentifier('client1')
        .withWillTopic(
            'willtopic') // If you set this you must set a will message
        .withWillMessage('My Will message')
        .startClean() // Non persistent session for testing
        .withWillQos(MqttQos.atLeastOnce);
    client.logging(on: false);
    client.autoReconnect = true;
    client.onAutoReconnect = onAutoReconnect;
    client.setProtocolV311();
    client.keepAlivePeriod = 20;
    client.connectTimeoutPeriod = 20000; // milliseconds
    client.onDisconnected = onDisconnected;
    client.onConnected = onConnected;
    client.onSubscribed = onSubscribed;
    client.connectionMessage = connMess;
    try {
      await client.connect('master:quy', 'JdH6fLtpmYCj62XAHbUfdxeaAgl9tjyX');
    } on NoConnectionException catch (e) {
      // Raised by the client when connection fails.
      developer.log('EXAMPLE::client exception - $e');
      client.disconnect();
    } on SocketException catch (e) {
      // Raised by the socket layer
      developer.log('EXAMPLE::socket exception - $e');
      client.disconnect();
    }
    if (client.connectionStatus!.state == MqttConnectionState.connected) {
      developer.log('EXAMPLE::Mosquitto client connected');
    } else {
      /// Use status here rather than state if you also want the broker return code.
      developer.log(
          'EXAMPLE::ERROR Mosquitto client connection failed - disconnecting, status is ${client.connectionStatus}');
      client.disconnect();
      // exit(-1);
    }
    client.subscribe(pubTopic, MqttQos.exactlyOnce);
    client.updates!.listen((List<MqttReceivedMessage<MqttMessage?>>? c) {
      final recMess = c![0].payload as MqttPublishMessage;
      final pt =
          MqttPublishPayload.bytesToStringAsString(recMess.payload.message);
      developer.log(
          'EXAMPLE::Change notification:: topic is <${c[0].topic}>, payload is <-- $pt -->');
      developer.log('');
    });
    client.published!.listen((MqttPublishMessage message) {
      developer.log(
          'EXAMPLE::Published notification:: topic is ${message.variableHeader!.topicName}, with Qos ${message.header!.qos}');
    });
  }

 

  @override
  void dispose() {
    client.disconnect();
    super.dispose();
  }

  // Function to search for locations based on the input
  void searchLocations(String query) {
    // Perform the search logic here and update the 'locations' list
    setState(() {
      locations = locations.where((location) {
        final name = location.name.toLowerCase();
        final lowerQuery = query.toLowerCase();
        return name.contains(lowerQuery);
      }).toList();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        title: Text(widget.title,
            style: const TextStyle(
                color: Colors.black26, fontWeight: FontWeight.w700)),
        actions: [
          if (locations.isNotEmpty)
            DropdownButton<Location>(
              value: selectedLocation,
              onChanged: (Location? newValue) {
                setState(() {
                  selectedLocation = newValue;
                });
              },
              items: locations
                  .map<DropdownMenuItem<Location>>((Location location) {
                return DropdownMenuItem<Location>(
                  value: location,
                  child: Text(location.name),
                );
              }).toList(),
            ),
        ],
      ),
      body: SingleChildScrollView(
        child: Container(
          decoration: const BoxDecoration(
            image: DecorationImage(
              image: AssetImage("assets/bg.png"),
              fit: BoxFit.fill,
            ),
          ),
          child: const Column(
            mainAxisAlignment: MainAxisAlignment.start,
            children: [
              SizedBox(height: 66),
            ],
          ),
        ),
      ),
    );
  }
}
