import 'package:flutter/material.dart';
import 'package:user_todo/auths/firebase_auths.dart';
import 'package:user_todo/auths/google_sign_in.dart';
import 'package:user_todo/auths/shared_pref.dart';
import 'package:user_todo/screens/google_sign_in_screen.dart';
import 'package:user_todo/screens/splash_screen.dart';

class ProfileScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(),
      body: Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: <Widget>[
            CircleAvatar(
              radius: 50,
              backgroundImage:
                  NetworkImage(kFirebase.currentUser!.photoURL ?? ''),
              backgroundColor: Colors.grey.shade200,
            ),
            SizedBox(height: 20),
            Text(
              kFirebase.currentUser!.displayName.toString(),
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
              ),
            ),
            SizedBox(height: 10),
            Text(
              kFirebase.currentUser!.email.toString(),
              style: TextStyle(
                fontSize: 16,
                color: Colors.grey.shade600,
              ),
            ),
            SizedBox(height: 30),
            ElevatedButton(
              onPressed: () async {
                await signOutGoogle();
                SharedPrefService.logOut();
                // Navigate to the SignInPage when logout button is clicked
                Navigator.pushReplacement(
                  context,
                  MaterialPageRoute(builder: (context) => GoogleSignInScreen()),
                );
              },
              child: Text('Logout'),
            ),
          ],
        ),
      ),
    );
  }
}
