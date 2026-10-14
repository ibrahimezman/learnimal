import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'firebase_options.dart';
import 'screens/login_page.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);

  // You may set the permission requests to "provisional" which allows the user to choose what type
  // of notifications they would like to receive once the user receives a notification.
  final notificationSettings = await FirebaseMessaging.instance
      .requestPermission(provisional: true);

  // For apple platforms, make sure the APNS token is available before making any FCM plugin API calls
  final apnsToken = await FirebaseMessaging.instance.getToken();
  if (apnsToken != null) {
    // APNS token is available, make FCM plugin API requests...
    FirebaseMessaging.onMessage.listen((RemoteMessage message) {
      print(message.notification?.title);

      print(message.notification?.body);
    });
    print(apnsToken);
  }

  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});
    @override
    Widget build(BuildContext context) {
      return MaterialApp(
        debugShowCheckedModeBanner: false,
        title: 'Learnimal',
        home: const LoginPage(),
      );
    }
}