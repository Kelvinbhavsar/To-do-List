import 'dart:async';

import 'package:flutter/material.dart';
import 'package:user_todo/auths/shared_pref.dart';
import 'package:user_todo/screens/google_sign_in_screen.dart';
import 'package:user_todo/screens/home_screen.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

String userName = '';
String userGmail = '';

class _SplashScreenState extends State<SplashScreen> {
  Future getUsername() async {
    String? data = await SharedPrefService.getUsername();
    setState(() {
      userName = data ?? '';
    });
  }

  @override
  void initState() {
    getUsername().whenComplete(
      () => Timer(Duration(seconds: 3), () {
        // log('user - $user \nisotp - ${otpVerification}');
        // if (user != '' && otpVerification == 'done') {

        // if(user == ''){
        //   Navigator.pushReplacement(context, MaterialPageRoute(builder: (context) => GoogleSignInScreen(),));
        // }else{
        //   Navigator()
        // }

        if (userName != '') {
          // Get.off(HomeScreen());
          Navigator.pushReplacement(
              context,
              MaterialPageRoute(
                builder: (context) => HomeScreen(),
              ));
        } else {
          // Get.off(HomeScreen());
          // Get.off(GoogleSignInScreen());
          Navigator.pushReplacement(
              context,
              MaterialPageRoute(
                builder: (context) => GoogleSignInScreen(),
              ));
        }
      }),
    );

    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: Text("its a Splash Screen"),
      ),
    );
  }
}
