import 'dart:io';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:flutter_application_2/screens/home_screen.dart';
import 'package:flutter_application_2/screens/task_screen.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  Platform.isAndroid
      ? await Firebase.initializeApp(
    options: FirebaseOptions(
        apiKey: 'AIzaSyDn4BG357OxFle4LbC_4ZOfs03szSTqCtk',
        appId: '1:1075629369168:android:62fd22619ca4ea0fb52e55',
        messagingSenderId: '1075629369168',
        projectId: 'flutter-application-2-df821'),
  )
      : await Firebase.initializeApp();
  runApp(const MyApp());
}

class MyApp extends StatefulWidget {
  const MyApp({super.key});

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  TextEditingController add = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        inputDecorationTheme: InputDecorationTheme(
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(10),
          ),
        ),
      ),
      home: HomeScreen(),
      // home: TaskScreen(),
    );
  }
}
