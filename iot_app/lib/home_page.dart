// ignore_for_file: avoid_developer.log

import 'dart:io';

// import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:iot_app/widget/chart.dart';
// import 'package:iot_app/widget/clock.dart';
// ignore: unused_import
import 'package:iot_app/widget/weather_forecast.dart';
import 'package:iot_app/widget/weather_info.dart';
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

class MyHomePage extends StatefulWidget {
  const MyHomePage({super.key, required this.title});
  final String title;

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  bool isOn = false;
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

  @override
  Widget build(BuildContext context) {

    return Scaffold(
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        title: Text(widget.title,
            style: const TextStyle(
                color: Colors.black26, fontWeight: FontWeight.w700)),
        // actions: [
        //   CupertinoSwitch(
        //       // overrides the default green color of the track
        //       activeColor: Colors.white38,
        //       // color of the round icon, which moves from right to left
        //       thumbColor: Colors.blueAccent,
        //       // when the switch is off
        //       trackColor: Colors.black38,
        //       // boolean variable value
        //       value: isOn,
        //       // changes the state of the switch
        //       onChanged: (value) {
        //         setState(() {
        //           isOn = value;
        //         });
        //         Provider.of<ThemeProvider>(context, listen: false).toggleMode();
        //       }),
        // ],
      ),
      body: SingleChildScrollView(
        child: Container(
          decoration: const BoxDecoration(
            image: DecorationImage(
              image: AssetImage("assets/bg.png"),
              fit: BoxFit.cover,
            ),
          ),
          child: const Column(
            mainAxisAlignment: MainAxisAlignment.start,
            children: [
              SizedBox(height: 66),

              WeatherInfo(),
              LineChartSample10(),
              // const WeatherForecast()
            ],
          ),
        ),
      ),
    );
  }
}
