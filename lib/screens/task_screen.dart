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

  Card customCard(
      {required data, required index, required ts, required bool isSubmitted}) {
    return Card(
      color: Colors.white,
      // Ensure the card background is pure white
      margin: const EdgeInsets.symmetric(vertical: 10.0, horizontal: 18.0),
      elevation: 0,
      // Adjust elevation for shadow effect
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16.0), // Rounded edges
      ),
      child: Padding(
        padding: const EdgeInsets.all(16.0), // Add padding inside the card
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Task Title with Line Through if Submitted
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Expanded(
                  child: Text(
                    data[index]['taskname'],
                    style: TextStyle(
                      fontSize: 18.0,
                      fontWeight: FontWeight.bold,
                      decoration: isSubmitted
                          ? TextDecoration.lineThrough
                          : TextDecoration.none,
                    ),
                  ),
                ),
                isSubmitted
                    ? const Icon(
                        Icons.check_circle_rounded,
                        color: Colors.blue,
                      )
                    : IconButton(
                        icon: const Icon(Icons.radio_button_unchecked),
                        onPressed: () {
                          showDialog(
                            context: context,
                            builder: (context) => AlertDialog(
                              title:
                                  Text("Are you sure you want to submit it?"),
                              content:
                                  Text("Task : ${data[index]['taskname']}"),
                              actions: [
                                ElevatedButton(
                                    onPressed: () {
                                      Navigator.pop(context);
                                    },
                                    child: Text("Cancel")),
                                ElevatedButton(
                                    onPressed: () async {
                                      await taskCollection
                                          .doc(data[index]['taskname'])
                                          .update({
                                        'submittime': Timestamp.now()
                                      }).then(
                                        (value) => Navigator.pop(context),
                                      );
                                    },
                                    child: Text("Yes")),
                              ],
                            ),
                          );
                        },
                      ),
              ],
            ),

            // Horizontal Divider
            Divider(
              thickness: 1,
              color: Colors.grey[200],
            ),

            const SizedBox(height: 8.0),

            Text(
              "Assigned on ${months[ts.toDate().month - 1]} ${ts.toDate().day}, ${ts.toDate().year}",
              style: TextStyle(
                color: Colors.grey[700],
                fontSize: 16.0,
              ),
            ),
          ],
        ),
      ),
    );
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
                      : Column(
                          children: [
                            Align(
                              alignment: Alignment(-0.8, 0),
                              child: Text(
                                "Pending Tasks",
                                style: TextStyle(
                                  fontSize: 20.0,
                                  fontWeight: FontWeight.w600,
                                  color: Colors.black,
                                ),
                              ),
                            ),
                            ListView.builder(
                              itemCount: data.length,
                              shrinkWrap: true,
                              physics: NeverScrollableScrollPhysics(),
                              itemBuilder: (context, index) {
                                Timestamp ts = data[index]['createtime'];
                                /*return Card(
                                  color: Colors.white, // Same background color
                                  margin: const EdgeInsets.symmetric(
                                      vertical: 10.0, horizontal: 18.0),
                                  elevation: 0,
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(
                                        16.0), // Rounded edges like customCard
                                  ),
                                  child: ListTile(
                                    contentPadding: EdgeInsets.all(16.0),
                                    title: Expanded(
                                      child: Text(
                                        data[index]['taskname'],
                                        style: const TextStyle(
                                          fontSize: 18.0,
                                          fontWeight: FontWeight.bold,
                                        ),
                                      ),
                                    ),
                                    subtitle: Text(
                                      'assigned on : ${ts.toDate().day} , ${months[ts.toDate().month - 1]}',
                                      style: TextStyle(
                                        color: Colors.grey[700],
                                        fontSize: 16.0,
                                      ),
                                    ),
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
                                                            data[index]['taskname'])
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
                                );*/
                                return customCard(
                                    data: data,
                                    index: index,
                                    ts: ts,
                                    isSubmitted: false);
                              },
                            ),
                          ],
                        );
                }
                return Container();
              },
            ),
            Divider(),

            /// submit
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
                              style: TextStyle(
                                fontSize: 20.0,
                                fontWeight: FontWeight.w600,
                                color: Colors.black,
                              ),
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
                              return customCard(
                                  data: data2,
                                  index: index,
                                  ts: ts,
                                  isSubmitted: true);
                              /*return Card(
                                color: Colors.white, // Same background color
                                margin: const EdgeInsets.symmetric(
                                    vertical: 10.0, horizontal: 18.0),
                                elevation: 0,
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(
                                      16.0), // Rounded edges like customCard
                                ),
                                child: ListTile(
                                  title: Expanded(
                                    child: Text(
                                      data2[index]['taskname']!,
                                      style: const TextStyle(
                                        color: Colors.black45,
                                        decoration: TextDecoration.lineThrough,
                                      ),
                                    ),
                                  ),
                                  subtitle: Align(
                                    alignment: Alignment.bottomRight,
                                    child: Text(
                                        style: TextStyle(color: Colors.black87),
                                        'assigned on : ${ts.toDate().day} , ${months[ts.toDate().month - 1]} ${ts.toDate().year.toString().substring(2, 4)}'),
                                  ),

                                  /// delete button for submitted tasks
                                  */ /* trailing: IconButton(
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
                                  ),*/ /*
                                ),
                              );*/
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
