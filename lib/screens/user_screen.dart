import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter_application_2/auths/firebase_auths.dart';

class UserScreen extends StatefulWidget {
  const UserScreen({super.key});

  @override
  State<UserScreen> createState() => _UserScreenState();
}

class _UserScreenState extends State<UserScreen> {
  final TextEditingController _username = TextEditingController();
  final TextEditingController _userEmail = TextEditingController();
  void _addUser() {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Add New User'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: <Widget>[
              TextField(
                decoration: const InputDecoration(labelText: 'Name'),
                onChanged: (value) {
                  _username.text = value;
                },
              ),
              SizedBox(height: 10),
              TextField(
                decoration: const InputDecoration(labelText: 'Email'),
                onChanged: (value) {
                  _userEmail.text = value;
                },
              ),
            ],
          ),
          actions: <Widget>[
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.blue,
              ),
              child: const Text('Add', style: TextStyle(color: Colors.white)),
              onPressed: () async {
                await userCollection
                    .doc(_userEmail.text)
                    .set({"name": _username.text, "email": _userEmail.text}).whenComplete(() => Navigator.pop(context));
              },
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      floatingActionButton: FloatingActionButton(
        onPressed: _addUser,
        child: const Icon(
          Icons.add,
          color: Colors.white,
        ),
      ),
      body: StreamBuilder(
        stream: FirebaseFirestore.instance.collection("users").snapshots(),
        builder: (context, snapshot) {
          if (snapshot.hasData) {
            var data = snapshot.data!.docs;
            return ListView.builder(
              itemCount: snapshot.data!.docs.length,
              itemBuilder: (context, index) {
                return Card(
                  margin:
                  const EdgeInsets.symmetric(vertical: 8.0, horizontal: 16.0),
                  child: ListTile(
                    title: Text('User: ${data[index]['name']}'),
                    subtitle: Text('Email: ${data[index]['email']}'),
                    trailing: IconButton(
                      icon: const Icon(Icons.delete),
                      color: Colors.red,
                      onPressed: ()async{
                         FirebaseFirestore.instance.collection('users').doc(data[index]['email'].toString()).delete();
                      },
                    ),
                  ),
                );
              },
            );
          } else {
            return Center(child: CircularProgressIndicator());
          }
        },
      ),
    );
  }
}
