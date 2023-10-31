// Copyright 2019 The Chromium Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

import 'dart:async';
// import 'dart:convert';
import 'dart:developer' as developer;
import 'package:http/http.dart' as http;
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';

import 'firebase_options.dart';

/// Initialize the [FlutterLocalNotificationsPlugin] package.
FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin =
    FlutterLocalNotificationsPlugin();

@pragma('vm:entry-point')
Future<void> _firebaseMessagingBackgroundHandler(RemoteMessage message) async {
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);
  await setupFlutterNotifications();
  showFlutterNotification(message);
  // If you're going to use other Firebase services in the background, such as Firestore,
  // make sure you call `initializeApp` before using other Firebase services.
  developer.log('Handling a background message ${message.messageId}');
}

bool isFlutterLocalNotificationsInitialized = false;
AndroidNotificationChannel channel = const AndroidNotificationChannel(
  'high_importance_channel', // id
  'High Importance Notifications', // title
  description:
      'This channel is used for important notifications.', // description
  importance: Importance.high,
);
Future<void> setupFlutterNotifications() async {
  if (isFlutterLocalNotificationsInitialized) {
    return;
  }

  flutterLocalNotificationsPlugin = FlutterLocalNotificationsPlugin();

  /// Create an Android Notification Channel.
  ///
  /// We use this channel in the `AndroidManifest.xml` file to override the
  /// default FCM channel to enable heads up notifications.
  await flutterLocalNotificationsPlugin
      .resolvePlatformSpecificImplementation<
          AndroidFlutterLocalNotificationsPlugin>()
      ?.createNotificationChannel(channel);

  /// Update the iOS foreground notification presentation options to allow
  /// heads up notifications.
  await FirebaseMessaging.instance.setForegroundNotificationPresentationOptions(
    alert: true,
    badge: true,
    sound: true,
  );
  isFlutterLocalNotificationsInitialized = true;
}

void showFlutterNotification(RemoteMessage message) async {
  dynamic data = message.data;
  try {
    developer.log('data here is ${message.sentTime.toString()}');

    final http.Response response = await http.get(Uri.parse(data['Image']));
    BigTextStyleInformation? bigTextStyleInformation = data['Body'] != null
        ? BigTextStyleInformation(data['Body'],
            htmlFormatContent: true,
            htmlFormatTitle: true,
            htmlFormatBigText: true,
            htmlFormatContentTitle: true,
            htmlFormatSummaryText: true)
        : null;
    final ByteArrayAndroidBitmap largeIcon =
        ByteArrayAndroidBitmap(response.bodyBytes);
    if (!kIsWeb) {
      flutterLocalNotificationsPlugin.show(
          message.sentTime?.millisecond ?? 0,
          data['Title'],
          data['Body'],
          NotificationDetails(
            android: AndroidNotificationDetails(channel.id, channel.name,
                channelDescription: channel.description,
                icon: '@mipmap/ic_launcher',
                importance: Importance.max,
                largeIcon: largeIcon,
                styleInformation: bigTextStyleInformation),
          ),
          payload: data.toString());
    }
  } catch (e) {
    developer.log('error when dipslay noti $e');
  }
}

class FirebaseMessagingService {
  final FirebaseMessaging _fcm = FirebaseMessaging.instance;

  Future<String?> getToken() async {
    return await _fcm.getToken();
  }

  Future<void> subscribeToTopic(String topic) async {
    await _fcm.subscribeToTopic(topic);
  }

  Future<void> unsubscribeFromTopic(String topic) async {
    await _fcm.unsubscribeFromTopic(topic);
  }

  Future<void> setupInteractedMessage() async {
    // Get any messages which caused the application to open from
    // a terminated state.
    RemoteMessage? initialMessage =
        await FirebaseMessaging.instance.getInitialMessage();
    final data = initialMessage?.data;

    if (data != null && data['NotificationType'] != null) {
      handleNavigate(data['NotificationType'], data['refId'],
          data['content'] ?? data['Body']);
    }
  }

  Future<RemoteMessage?> checkForInitialMessage() async {
    RemoteMessage? message =
        await FirebaseMessaging.instance.getInitialMessage();
    return message;
  }

  void handlePress(RemoteMessage? message) {
    if (message != null) {}
  }

  void handleNavigate(key, id, content) {}

  void onDidReceiveLocalNotification(
      int id, String? title, String? body, String? payload) async {
    // display a dialog with the notification details, tap ok to go to another page
  }
  void onDidReceiveNotificationResponse(
      NotificationResponse notificationResponse) async {
    final String payload = notificationResponse.payload ?? '';
    if (notificationResponse.payload != null) {
      developer
          .log('notificationResponse ====> ${notificationResponse.payload}');
      try {
        // Remove the curly braces at the beginning and end of the string
        String input = payload.substring(1, payload.length - 1);

        // Split the string by commas
        List<String> keyValuePairs = input.split(', ');

        // Create a Map to store the key-value pairs
        Map<String, dynamic> resultMap = {};

        // Iterate through the key-value pairs and add them to the map
        for (String pair in keyValuePairs) {
          List<String> parts = pair.split(': ');
          String key = parts[0];
          String value = parts[1];

          // Remove leading and trailing whitespace and remove double quotes from values
          key = key.trim();
          value = value.trim().replaceAll("'", "");

          resultMap[key] = value;
        }
        handleNavigate(resultMap['NotificationType'], resultMap['refId'],
            resultMap['Body']);
      } catch (e) {
        developer.log('onDidReceiveNotificationResponse ====> $e');
      }
    }
  }

  Future<String?> configure() async {
    // Request permission for iOS devices
    await _fcm.requestPermission(
      alert: true,
      announcement: false,
      badge: true,
      carPlay: false,
      criticalAlert: false,
      provisional: false,
      sound: true,
    );
    setupFlutterNotifications();
    // Configure FCM message handling
    FirebaseMessaging.onMessage.listen(showFlutterNotification);
    FirebaseMessaging.onBackgroundMessage(_firebaseMessagingBackgroundHandler);
    FirebaseMessaging.instance
        .getInitialMessage()
        .then((RemoteMessage? message) {
      if (message != null) {
        final data = message.data;
        developer.log('data is commingg ====> $data');
        Future.delayed(const Duration(seconds: 1), () {
          handleNavigate(data['NotificationType'], data['refId'],
              data['content'] ?? data['Body']);
        });
      }
    });

    FirebaseMessaging.onMessageOpenedApp.listen((RemoteMessage message) {
      final data = message.data;
      developer.log('data is commingg ====> $data');
      Future.delayed(const Duration(seconds: 1), () {
        handleNavigate(data['NotificationType'], data['refId'],
            data['content'] ?? data['Body']);
      });
    });
    // initialise the plugin. app_icon needs to be a added as a drawable resource to the Android head project
    const AndroidInitializationSettings initializationSettingsAndroid =
        AndroidInitializationSettings('@mipmap/ic_launcher');

    final DarwinInitializationSettings initializationSettingsDarwin =
        DarwinInitializationSettings(
            onDidReceiveLocalNotification: onDidReceiveLocalNotification);

    final InitializationSettings initializationSettings =
        InitializationSettings(
      android: initializationSettingsAndroid,
      iOS: initializationSettingsDarwin,
    );
    await flutterLocalNotificationsPlugin.initialize(initializationSettings,
        onDidReceiveNotificationResponse: onDidReceiveNotificationResponse);
    try {
      final token = await getToken();
      developer.log("FCM token: $token");
      return token;
    } catch (e) {
      developer.log("FCM e: $e");

      return '';
    }
  }
}
