import 'dart:developer';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:user_todo/auths/firebase_auths.dart';
import 'package:user_todo/auths/shared_pref.dart';

GoogleSignIn googleSignIn = GoogleSignIn();

String? gmailName;
String? gmailEmail;
bool? isNewUser;
String? imageUrl;

// todo : change regex when launch
// final RegExp emailPattern = RegExp(r'^\d{2}amtics\d{3}@gmail\.com$');

/// amtics id
// final RegExp emailPattern = RegExp(r'^\d{2}amtics\d{3}@gmail\.com$');

Future<String> otpVerificationStatus() async {
  String otpVerificationDone = 'nope';
  if (kFirebase.currentUser != null) {
    log('kfirebase is not null');
    final otp1 = await FirebaseFirestore.instance
        .collection('otpVerification')
        .doc(kFirebase.currentUser!.uid.toString())
        .get()
        .then((value) {
      if (value.exists) {
        otpVerificationDone = value.data()!['otpVerification'];
      }
    });
  }
  return otpVerificationDone;
}

Future signInWithGoogle() async {
  final GoogleSignInAccount? googleSignInAccount = await googleSignIn.signIn();
  final GoogleSignInAuthentication googleSignInAuthentication =
      await googleSignInAccount!.authentication;

  final AuthCredential authCredential = GoogleAuthProvider.credential(
      accessToken: googleSignInAuthentication.accessToken,
      idToken: googleSignInAuthentication.idToken);

  UserCredential authresult =
      await FirebaseAuth.instance.signInWithCredential(authCredential);
  User? user = authresult.user;

  gmailName = user!.displayName;
  gmailEmail = user.email;
  isNewUser = authresult.additionalUserInfo!.isNewUser;
  imageUrl = user.photoURL;

  final User? currentUser = FirebaseAuth.instance.currentUser;
  assert(user.uid == currentUser!.uid);
  print('signInWithGoogle succeeded: $user');
  return '$user';
}

Future<void> signOutGoogle() async {
  await googleSignIn.signOut();
  gmailName = '';
  gmailEmail = '';
  SharedPrefService.logOut();
  print("User Signed Out");
}
