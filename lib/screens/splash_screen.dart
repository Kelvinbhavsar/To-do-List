import 'dart:async';
import 'dart:developer';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:sizer/sizer.dart';
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
// String userImageUrl = '';

class _SplashScreenState extends State<SplashScreen>
    with TickerProviderStateMixin {
  double _textOpacity = 0.0;
  double _fontSize = 2;
  double _containerSize = 100.w;
  double _containerOpacity = 0.0;

  late Animation<double> animation1;
  late AnimationController _controller;

  Future getUsername() async {
    String? getgmail = await SharedPrefService.getGmail();
    String? data = await SharedPrefService.getUsername();
    setState(() {
      userGmail = getgmail ?? '';

      userName = data ?? '';
    });
  }

  @override
  void initState() {
    _controller =
        AnimationController(vsync: this, duration: Duration(seconds: 3));

    animation1 = Tween<double>(begin: 10, end: 30).animate(CurvedAnimation(
        parent: _controller, curve: Curves.fastLinearToSlowEaseIn))
      ..addListener(() {
        setState(() {
          _textOpacity = 1.0;
        });
      });
    _controller.forward();

    Timer(Duration(seconds: 1), () {
      setState(() {
        _fontSize = 1.06;
      });
    });

    Timer(Duration(seconds: 1), () {
      setState(() {
        _containerSize = 70.w;
        _containerOpacity = 1;
      });
    });

    getUsername().whenComplete(
      () => Timer(Duration(seconds: 3), () {
        if (userName != '') {
          // Get.off(HomeScreen());
          Navigator.pushReplacement(
              context,
              MaterialPageRoute(
                builder: (context) => HomeScreen(),
              ));
        } else {
          Navigator.pushReplacement(
              context,
              MaterialPageRoute(
                builder: (context) => GoogleSignInScreen(),
              ));
        }
        _controller.dispose();
      }),
    );

    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: AnimatedOpacity(
          duration: Duration(milliseconds: 2000),
          curve: Curves.fastLinearToSlowEaseIn,
          opacity: _containerOpacity,
          child: AnimatedContainer(
            duration: Duration(milliseconds: 5000),
            curve: Curves.fastLinearToSlowEaseIn,
            height: _containerSize,
            width: _containerSize,
            alignment: Alignment.center,
            decoration: BoxDecoration(
              color: Colors.grey.withOpacity(.5),
              borderRadius: BorderRadius.circular(30),
            ),
            child: Image.asset('assets/images/logo.png'),
          ),
        ),
      ),
    );
  }
}
