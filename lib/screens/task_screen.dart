import 'dart:developer';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter_application_2/auths/firebase_auths.dart';

class TaskScreen extends StatefulWidget {
  const TaskScreen({super.key});

  @override
  State<TaskScreen> createState() => _TaskScreenState();
}

class _TaskScreenState extends State<TaskScreen> {
  final TextEditingController _taskController = TextEditingController();

  List<TextEditingController> controllers = [TextEditingController()];

  List currentTasks = [];
  String? _selectedUser;
  String? _selectedEmail;
  late final userData;
  void _addTask() {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return StatefulBuilder(
          builder: (context, setState) {
            return AlertDialog(
              title: const Text('Add New Task'),
              content: SingleChildScrollView(
                child: Column(
                  children: <Widget>[
                    FutureBuilder(
                      future: userCollection.get(),
                      builder: (context, snapshot) {
                        return snapshot.hasData
                            ? DropdownButton<String>(
                                isExpanded: true,
                                value: _selectedEmail,
                                hint: const Text('Assign to User'),
                                items: snapshot.data!.docs.map(
                                  (user) {
                                    return DropdownMenuItem<String>(
                                      value: user['email'],
                                      child: Text(user['name']!),
                                    );
                                  },
                                ).toList(),
                                onChanged: (value) {
                                  setState(() {
                                    _selectedEmail = value;

                                    log("$_selectedEmail ---- $value ");
                                  });
                                },
                              )
                            : Text("");
                      },
                    ),
                    SizedBox(height: 10),
                    Column(
                      children: [
                        for (int i = 0; i < currentTasks.length; i++)
                          ListTile(
                            title: Text(currentTasks[i]),
                            trailing: IconButton(
                              icon: const Icon(Icons.delete),
                              onPressed: () {
                                setState(() {
                                  currentTasks.removeAt(i);
                                  controllers.removeAt(i);
                                });
                              },
                            ),
                          ),
                        for (int i = currentTasks.length;
                            i < controllers.length;
                            i++)
                          Row(
                            children: [
                              Expanded(
                                child: TextField(
                                  controller: controllers[i],
                                  decoration: const InputDecoration(
                                    labelText: 'Task',
                                  ),
                                ),
                              ),
                              IconButton(
                                icon: const Icon(Icons.check),
                                onPressed: () {
                                  if (controllers[i].text.isNotEmpty) {
                                    setState(() {
                                      currentTasks.add(controllers[i].text);
                                      controllers.add(TextEditingController());
                                    });
                                  }
                                },
                              ),
                            ],
                          ),
                      ],
                    ),
                  ],
                ),
              ),
              actions: <Widget>[
                TextButton(
                  child: const Text('Cancel'),
                  onPressed: () {
                    Navigator.of(context).pop();
                  },
                ),
                TextButton(
                  child: const Text('Save'),
                  onPressed: () {
                    if (_selectedEmail != null && currentTasks.isNotEmpty) {
                      setState(() {
                        log("$currentTasks");
                        taskCollection.doc(_selectedEmail).set({
                          "tasks" : currentTasks , "email" : _selectedEmail,

                        });
                        // for (var task in currentTasks) {
                        //   FirebaseFirestore.instance
                        //       .collection('tasks')
                        //       .add({"task": task, "user": _selectedUser});
                        // }
                      });
                      Navigator.of(context).pop();
                    }
                  },
                ),
              ],
            );
          },
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      floatingActionButton: FloatingActionButton(
        onPressed: () => _addTask(),
        child: const Icon(Icons.add),
      ),
      body: StreamBuilder(
        stream: taskCollection.snapshots(),
        builder: (context, snapshot) {
          if(snapshot.hasData){
          var data = snapshot.data!.docs;
            return ListView.builder(itemCount: data.length,itemBuilder: (context, index) {
              return Card(
                margin: const EdgeInsets.all(8.0),
                child: ExpansionTile(
                  title: Text("${data[index]['email']}"),
                  children: data[index]['tasks']!.map<Widget>((task) {
                    return ListTile(
                      title: Text(task),
                      trailing: IconButton(
                        icon: const Icon(Icons.delete),
                        onPressed: () {
                          setState(() {

                          });
                        },
                      ),
                    );
                  }).toList(),
                ),
              );

            },);
          }else{
            return CircularProgressIndicator();
          }
        },
      ),
    );
  }
}
