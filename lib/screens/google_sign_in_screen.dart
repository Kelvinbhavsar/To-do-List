import 'dart:developer';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
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
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("SignIn Page"),
      ),
      body: Center(
        child: ElevatedButton(
          onPressed: () async {
            try {
              await signInWithGoogle().then(
                (value) async {
                  if (emailPattern.hasMatch(gmailEmail!)) {
                    SharedPrefService.setGmail(gmail: gmailEmail);
                    SharedPrefService.setUser(username: gmailName);
                    if (isNewUser!) {
                      await userCollection
                          .doc(gmailEmail)
                          .set({'name': gmailName, 'email': gmailEmail}).then(
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
                    ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
                        content: Text("Please enter amtics id!!!")));
                  }
                },
              );
            } catch (e) {
              log("error ::::: ${e}");
            }
          },
          child: const Text('Google SignIn'),
        ),
      ),
    );
  }
}
