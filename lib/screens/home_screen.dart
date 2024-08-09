import 'dart:developer';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:user_todo/auths/google_sign_in.dart';
import 'package:user_todo/auths/shared_pref.dart';
import 'package:user_todo/screens/google_sign_in_screen.dart';
import 'package:user_todo/screens/splash_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

String? userName = '';
String? userGmail = '';

class _HomeScreenState extends State<HomeScreen> {
  Future getData() async {
    String? _userame = await SharedPrefService.getUsername();
    String? _useremail = await SharedPrefService.getGmail();
    setState(() {
      userName = _userame ?? '';
      userGmail = _useremail ?? '';
    });
  }

  @override
  void initState() {
    getData().then(
      (value) {
        log("$userName");
        setState(() {});
      },
    );
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      drawer: Drawer(
        child: SafeArea(
            child: Column(
          children: [
            ListTile(
              title: Text("Welcome! \n$userName"),
              leading: CircleAvatar(
                backgroundColor: Colors.green,
                maxRadius: 20,
                minRadius: 20,
                child: imageUrl == null
                    ? Text(userName![0])
                    : Image.network(
                        imageUrl!,
                      ),
              ),
            ),
            ListTile(
              title: Text("Sign Out"),
              trailing: Icon(Icons.logout),
              onTap: () async {
                await signOutGoogle().then(
                  (value) {
                    Navigator.pushReplacement(
                        context,
                        MaterialPageRoute(
                          builder: (context) => GoogleSignInScreen(),
                        ));
                    return ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(content: Text("Google Signed Out!!!")));
                  },
                );
              },
            ),
          ],
        )),
      ),
      appBar: AppBar(
        title: Text("Home Screen"),
      ),
      body: StreamBuilder(
        stream: FirebaseFirestore.instance
            .collection('tasks')
            .where('email', isEqualTo: userGmail)
            .snapshots(),
        builder: (context, snapshot) {
          if (snapshot.hasData) {
            var data = snapshot.data!.docs;
            return ListView.builder(
              itemCount: data.length,
              itemBuilder: (context, index) {
                return ListTile(title: Text("${data[index]['taskname']}"));
              },
            );
          }
          return Container();
        },
      ),
    );
  }
}
