import 'dart:developer';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:user_todo/auths/firebase_auths.dart';
import 'package:user_todo/auths/shared_pref.dart';

class TaskScreen extends StatefulWidget {
  const TaskScreen({super.key});

  @override
  State<TaskScreen> createState() => _TaskScreenState();
}

String? userName = '';
String? userGmail = '';

class _TaskScreenState extends State<TaskScreen> {
  List<String> months = [
    "Jan",
    "Feb",
    'Mar',
    'Apr',
    "May",
    'Jun',
    'Jul',
    'Aug',
    'Sep',
    'Oct',
    'Nov',
    'Dec'
  ];

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
      body: SingleChildScrollView(
        child: Column(
          children: [
            StreamBuilder(
              stream: FirebaseFirestore.instance
                  .collection('tasks')
                  .where('email', isEqualTo: kFirebase.currentUser!.email)
                  .where('submittime', isEqualTo: '-')
                  .orderBy('createtime', descending: true)
                  .snapshots(),
              builder: (context, snapshot) {
                if (snapshot.hasData) {
                  var data = snapshot.data!.docs;
                  return data.length == 0
                      ? Center(
                          child: Text(
                          "No Task Available for You",
                          style: TextStyle(
                              fontSize: 20, fontWeight: FontWeight.w600),
                        ))
                      : ListView.builder(
                          itemCount: data.length,
                          shrinkWrap: true,
                          physics: NeverScrollableScrollPhysics(),
                          itemBuilder: (context, index) {
                            Timestamp ts = data[index]['createtime'];

                            /* return data[index]['submittime'] != '-'
                                ? SizedBox()
                                : Card*/
                            return Card(
                              margin: EdgeInsets.all(8.0),
                              child: ListTile(
                                contentPadding: EdgeInsets.all(16.0),
                                title: Text(data[index]['taskname']),
                                subtitle: Text(
                                    'assigned on : ${ts.toDate().day} , ${months[ts.toDate().month - 1]}'),
                                trailing: IconButton(
                                  icon:
                                      const Icon(Icons.radio_button_unchecked),
                                  onPressed: () {
                                    showDialog(
                                      context: context,
                                      builder: (context) => AlertDialog(
                                        title: Text(
                                            "Are you sure you want to submit it?"),
                                        content: Text(
                                            "Task : ${data[index]['taskname']}"),
                                        actions: [
                                          ElevatedButton(
                                              onPressed: () {
                                                Navigator.pop(context);
                                              },
                                              child: Text("Cancel")),
                                          ElevatedButton(
                                              onPressed: () async {
                                                await taskCollection
                                                    .doc(
                                                        convertSpaceToUnderScore(
                                                            data[index]
                                                                ['taskname']))
                                                    .update({
                                                  'submittime': Timestamp.now()
                                                }).then(
                                                  (value) =>
                                                      Navigator.pop(context),
                                                );
                                              },
                                              child: Text("Yes")),
                                        ],
                                      ),
                                    );
                                  },
                                ),
                              ),
                            );
                          },
                        );
                }
                return Container();
              },
            ),
            Divider(),
            StreamBuilder(
              stream: FirebaseFirestore.instance
                  .collection('tasks')
                  .where('email', isEqualTo: kFirebase.currentUser!.email)
                  .where('submittime', isNotEqualTo: '-')
                  .orderBy('createtime', descending: true)
                  .snapshots(),
              builder: (context, snapshot) {
                if (!snapshot.hasData) {
                  return CircularProgressIndicator();
                }
                var data2 = snapshot.data!.docs;
                return data2.length == 0
                    ? Text("No Task Submitted Yet")
                    : Column(
                        children: [
                          Align(
                            alignment: Alignment(-0.8, 0),
                            child: Text(
                              "Submitted Tasks",
                              style: TextStyle(fontSize: 20),
                            ),
                          ),
                          ListView.builder(
                            shrinkWrap:
                                true, // Use this to wrap content inside Column
                            physics:
                                NeverScrollableScrollPhysics(), // Disable scrolling for the ListView
                            itemCount: data2.length,
                            itemBuilder: (context, index) {
                              Timestamp ts = data2[index]['createtime'];
                              return Card(
                                margin: const EdgeInsets.symmetric(
                                    vertical: 8.0, horizontal: 16.0),
                                child: ListTile(
                                  title: Text(
                                    data2[index]['taskname']!,
                                    style: const TextStyle(
                                      decoration: TextDecoration.lineThrough,
                                    ),
                                  ),
                                  subtitle: Align(
                                    alignment: Alignment.bottomRight,
                                    child: Text(
                                        'assigned on : ${ts.toDate().day} , ${months[ts.toDate().month - 1]}'),
                                  ),

                                  /// delete button for submitted tasks
                                  /* trailing: IconButton(
                                    icon: const Icon(Icons.delete),
                                    onPressed: () {
                                      setState(() async {
                                        await FirebaseFirestore.instance
                                            .collection('tasks')
                                            .doc(data2[index]['taskname']
                                                .toString()
                                                .replaceAll(' ', '_'))
                                            .delete();
                                      });
                                    },
                                  ),*/
                                ),
                              );
                            },
                          ),
                        ],
                      );
              },
            ),
          ],
        ),
      ),
    );
  }
}

/* return Card(
          margin: EdgeInsets.all(8.0),
          child: ListTile(
            contentPadding: EdgeInsets.all(16.0),
            title: Text(tasks[index]),
            subtitle: Text('Details about ${tasks[index]}'),
            trailing: Icon(Icons.radio_button_unchecked),
          ),
        );*/
