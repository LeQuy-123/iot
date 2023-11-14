// ignore_for_file: avoid_developer.log

import 'package:flutter/material.dart';
import 'package:iot_app/bottom_tab.dart';
import 'package:iot_app/firebase_messaging.dart';
import 'package:iot_app/firebase_options.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:iot_app/theme/dark_theme.dart';
import 'package:iot_app/theme/default_theme.dart';
import 'package:iot_app/theme/theme_provider.dart';
import 'package:provider/provider.dart';
import 'dart:io';

class MyHttpOverrides extends HttpOverrides {
  @override
  HttpClient createHttpClient(SecurityContext? context) {
    return super.createHttpClient(context)
      ..badCertificateCallback =
          (X509Certificate cert, String host, int port) => true;
  }
}
Future main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);
  // ignore: unused_local_variable
  String? token = await FirebaseMessagingService().configure();
  await FirebaseMessagingService().subscribeToTopic('iot');
  HttpOverrides.global = MyHttpOverrides();
  runApp(const MyApp());
}

class MyApp extends StatefulWidget {
  const MyApp({super.key});

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
   // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(
          create: (ctx) => ThemeProvider(),
        ),
      ],
      child: Consumer<ThemeProvider>(
        builder: (ctx, themeObject, _) => MaterialApp(
          title: 'Flutter Demo',
          home:  const NavigationBottomTab(),
          darkTheme: defalutTheme,
          theme:darkTheme ,
          themeMode: themeObject.mode,
        ),
      ),
    );
  }
}
