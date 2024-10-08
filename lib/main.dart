import 'dart:io';

import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:user_todo/screens/google_sign_in_screen.dart';
import 'package:user_todo/screens/splash_screen.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  Platform.isAndroid
      ? await Firebase.initializeApp(
          options: FirebaseOptions(
              apiKey: 'AIzaSyDn4BG357OxFle4LbC_4ZOfs03szSTqCtk',
              appId: '1:1075629369168:android:e3489d7fcae49711b52e55',
              messagingSenderId: '1075629369168',
              projectId: 'flutter-application-2-df821'),
        )
      : await Firebase.initializeApp();
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      // home: GoogleSignInScreen(),
      home: SplashScreen(),
    );
  }
}
