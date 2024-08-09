import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'user_provider.dart';
import 'sign_in_screen.dart'; // Import the sign_in_screen.dart file
import 'home_page.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (context) => UserProvider(),
      child: MaterialApp(
        debugShowCheckedModeBanner: false,
        title: 'User and Task Manager',
        theme: ThemeData(
          primarySwatch: Colors.blue,
        ),
        home: const SignInScreen(), // Set SignInScreen as the home
      ),
    );
  }
}
