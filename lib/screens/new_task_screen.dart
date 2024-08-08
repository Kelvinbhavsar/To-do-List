import 'dart:developer';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter_application_2/auths/firebase_auths.dart';

class NewTaskScreen extends StatefulWidget {
  const NewTaskScreen({super.key});

  @override
  State<NewTaskScreen> createState() => _NewTaskScreenState();
}

class _NewTaskScreenState extends State<NewTaskScreen> {
  final TextEditingController _taskController = TextEditingController();
  String? _selectedUser;
  late final data;
  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Scaffold(
        body: FutureBuilder(
          future: userCollection.get(),
          builder: (context, snapshot) {
            return snapshot.hasData
                ? Column(
                    children: [
                      DropdownButton(
                        value: _selectedUser,
                        items: snapshot.data!.docs.map(
                          (user) {
                            return DropdownMenuItem<String>(
                              value: user['name'],
                              child: Text(user['name']!),
                            );
                          },
                        ).toList(),
                        onChanged: (value) {
                          setState(() {
                            _selectedUser = value;
                            log("$_selectedUser ---- $value ");
                          });
                        },
                      ),
                    ],
                  )
                : Text("no data found");
          },
        ),
      ),
    );
  }
}
