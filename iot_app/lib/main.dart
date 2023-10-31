// ignore_for_file: avoid_developer.log

import 'dart:io';

import 'package:flutter/material.dart';
import 'package:iot_app/firebase_messaging.dart';
import 'package:iot_app/firebase_options.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:mqtt_client/mqtt_client.dart';
import 'package:mqtt_client/mqtt_server_client.dart';
import 'dart:developer' as developer;
final client = MqttServerClient('192.168.1.13', '');

Future main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);
  // ignore: unused_local_variable
  String? token = await FirebaseMessagingService().configure();
  await FirebaseMessagingService().subscribeToTopic('iot');

  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Demo',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
        useMaterial3: true,
      ),
      home: const MyHomePage(title: 'Iot App'),
    );
  }
}

class MyHomePage extends StatefulWidget {
  const MyHomePage({super.key, required this.title});
  final String title;

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  int _counter = 0;
  @override
  void initState() {
    initMQTT();
    super.initState();
  }

  Future<void> initMQTT() async {
    const pubTopic =
        "master/client1/attribute/+/#";
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
      exit(-1);
    }
    client.subscribe(pubTopic, MqttQos.exactlyOnce);
    client.updates!.listen((List<MqttReceivedMessage<MqttMessage?>>? c) {
      final recMess = c![0].payload as MqttPublishMessage;
      final pt =
          MqttPublishPayload.bytesToStringAsString(recMess.payload.message);

      /// The above may seem a little convoluted for users only interested in the
      /// payload, some users however may be interested in the received publish message,
      /// lets not constrain ourselves yet until the package has been in the wild
      /// for a while.
      /// The payload is a byte buffer, this will be specific to the topic
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

  void _incrementCounter() {
    setState(() {
      _counter++;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
        title: Text(widget.title),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            const Text(
              'You have pushed the button this many times:',
            ),
            Text(
              '$_counter',
              style: Theme.of(context).textTheme.headlineMedium,
            ),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: _incrementCounter,
        tooltip: 'Increment',
        child: const Icon(Icons.add),
      ),
    );
  }
}

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
    exit(-1);
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
