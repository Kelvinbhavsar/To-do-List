import 'dart:developer';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:sizer/sizer.dart';
import 'package:user_todo/auths/firebase_auths.dart';
import 'package:user_todo/auths/google_sign_in.dart';
import 'package:user_todo/auths/shared_pref.dart';
import 'package:user_todo/screens/home_screen.dart';

class GoogleSignInScreen extends StatefulWidget {
  const GoogleSignInScreen({super.key});

  @override
  State<GoogleSignInScreen> createState() => _GoogleSignInScreenState();
}

class _GoogleSignInScreenState extends State<GoogleSignInScreen> {
  ImageProvider googleLogo = AssetImage("assets/images/google_logo.png");
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("SignIn Page"),
      ),
      body: SizedBox(
        height: 100.h,
        width: 100.w,
        child: Column(
          // mainAxisSize: MainAxisSize.max,
          crossAxisAlignment: CrossAxisAlignment.center,
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Image.asset(
              'assets/images/logo.png',
              height: 20.h,
            ),
            SizedBox(height: 4.h),
            ElevatedButton(
              onPressed: () async {
                try {
                  await signInWithGoogle().then(
                    (value) async {
                      // todo VERY IMP @utu validation is reamining
                      if (/*gmailEmail!.endsWith("@utu.ac.in")*/ true) {
                        SharedPrefService.setGmail(gmail: gmailEmail);
                        SharedPrefService.setUser(username: gmailName);
                        if (isNewUser!) {
                          await userCollection.doc(gmailEmail).set(
                              {'name': gmailName, 'email': gmailEmail}).then(
                            (value) => Navigator.pushReplacement(
                              context,
                              MaterialPageRoute(
                                builder: (context) => HomeScreen(),
                              ),
                            ),
                          );
                        } else {
                          Navigator.pushReplacement(
                            context,
                            MaterialPageRoute(
                              builder: (context) => HomeScreen(),
                            ),
                          );
                        }
                      } else {
                        await signOutGoogle();
                        ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(
                                content: Text("Please enter amtics id!!!")));
                      }
                    },
                  );
                } catch (e) {
                  log("error ::::: ${e}");
                }
              },
              child: Row(
                mainAxisSize: MainAxisSize.min,
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Image(
                    image: googleLogo,
                    height: 3.h,
                    width: 3.h,
                  ),
                  SizedBox(width: 10),
                  Text("Login with AMTICS id")
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
