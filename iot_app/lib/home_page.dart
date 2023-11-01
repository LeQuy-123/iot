// ignore_for_file: avoid_developer.log

import 'dart:io';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:iot_app/widget/clock.dart';
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
    final size = MediaQuery.of(context).size;

    return Scaffold(
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        title: Text(widget.title, style: const TextStyle(color: Colors.black26, fontWeight: FontWeight.w700)),
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
      body: Container(
        decoration: const BoxDecoration(
          image: DecorationImage(
            image: AssetImage("assets/bg.png"),
            fit: BoxFit.cover,
          ),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.start,
          children: [
            const SizedBox(height: 50),
            Center(
              child: Stack(
                alignment: Alignment.topCenter,
                children: [
                  Positioned(
                    bottom: 0,
                    child: Container(
                      width: size.width - 32,
                      height: 200,
                      decoration: ShapeDecoration(
                        gradient: const LinearGradient(
                          begin: Alignment(-0.42, -0.91),
                          end: Alignment(0.42, 0.91),
                          colors: [Color(0xFF67E1D2), Color(0xFF53A8FF)],
                        ),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(50),
                        ),
                      ),
                    ),
                  ),
                  Column(children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                      children: [
                        Image.asset('assets/sun.png', scale: 2.5),
                        const Padding(
                          padding:  EdgeInsets.only(top: 55),
                          child:  Text(
                            '27 \u2103',
                            style: TextStyle(
                              color: Colors.white70,
                              fontSize: 40,
                              fontFamily: 'Inter',
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                        )
                      ],
                    ),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                      children: [
                        const Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Ho Chi Minh, Viet Nam',
                              style: TextStyle(
                                color: Colors.white,
                                fontSize: 18,
                                fontFamily: 'Inter',
                                fontWeight: FontWeight.w700,
                              ),
                            ),
                            ClockWidget()
                          ],
                        ),
                        Image.asset('assets/wind.png', scale: 2.5),
                      ],
                    )
                  ]),
                ],
              ),
            )
          ],
        ),
      ),
    );
  }
}
