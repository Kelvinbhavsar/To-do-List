import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'dart:developer';

import 'package:flutter/widgets.dart';

class TaskScreen extends StatefulWidget {
  const TaskScreen({super.key});

  @override
  State<TaskScreen> createState() => _TaskScreenState();
}

class _TaskScreenState extends State<TaskScreen> {
  List<Map<String, dynamic>> data = [];
  List<String> months = [
    'Jan',
    "Feb",
    'Mar',
    "Apr",
    "May",
    "Jun",
    "Jul",
    "Aug",
    "Sep",
    "Oct",
    "Nov",
    "Dec"
  ];

  @override
  void initState() {
    super.initState();
    fetchData().then((fetchedData) {
      setState(() {
        data = fetchedData;
      });
    });
  }

  // Method to fetch data from Firestore
  Future<List<Map<String, dynamic>>> fetchData() async {
    try {
      final QuerySnapshot snapshot =
          await FirebaseFirestore.instance.collection('users').get();
      final List<QueryDocumentSnapshot> documents = snapshot.docs;
      return documents
          .map((doc) => doc.data() as Map<String, dynamic>)
          .toList();
    } catch (e) {
      log("Error fetching data: $e");
      return [];
    }
  }

  void _navigateToAddTaskPage() async {
    final result = await Navigator.of(context).push<Map<String, dynamic>>(
      MaterialPageRoute(builder: (context) => AddTaskPage(data: data)),
    );

    if (result != null) {
      // handle returned tasks and user if needed
    }
  }

  Card customCard({ts, data, index, isSubmitted}) {
    return Card(
      margin: const EdgeInsets.symmetric(vertical: 8.0, horizontal: 16.0),
      child: ListTile(
        title: Text(
          data[index]['taskname'],
          style: TextStyle(
            decoration:
                isSubmitted ? TextDecoration.lineThrough : TextDecoration.none,
          ),
        ),
        subtitle: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              " ${ts.toDate().day} , ${months[ts.toDate().month - 1]} ${ts.toDate().year.toString().substring(2, 4)}",
              style: TextStyle(color: Colors.grey),
            ),
            Text(
              'To: ${data[index]['name']}',
              style: const TextStyle(color: Colors.grey),
            ),
          ],
        ),
        trailing: IconButton(
          icon: const Icon(
            Icons.delete,
            color: Colors.black45,
          ),
          onPressed: () {
            _confirmDeleteTask(data[index]['taskname'].replaceAll(' ', '_'));
          },
        ),
      ),
    );
  }

  void _confirmDeleteTask(String taskId) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Confirm Deletion'),
          content: Text(
              'Are you sure you want to delete the task with ID ${taskId.replaceAll('_', " ")}?'),
          actions: <Widget>[
            TextButton(
              child: const Text('Cancel'),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
            ElevatedButton(
              child: const Text(
                'Delete',
              ),
              onPressed: () async {
                try {
                  await FirebaseFirestore.instance
                      .collection('tasks')
                      .doc(taskId)
                      .delete();
                  setState(() {});
                } catch (e) {
                  log("Error deleting task: $e");
                }
                Navigator.of(context).pop();
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
        onPressed: _navigateToAddTaskPage,
        child: const Icon(Icons.add),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          child: Column(
            children: [
              // Pending Tasks StreamBuilder
              StreamBuilder(
                stream: FirebaseFirestore.instance
                    .collection("tasks")
                    .where('submittime', isEqualTo: '-')
                    .orderBy('createtime', descending: true)
                    .snapshots(),
                builder: (context, snapshot) {
                  if (snapshot.hasData) {
                    var data = snapshot.data!.docs;
                    return data.isEmpty
                        ? const Text("No Pending Tasks")
                        : Column(
                            children: [
                              const Align(
                                alignment: Alignment(-0.8, 0),
                                child: Text(
                                  "Pending Tasks",
                                  style: TextStyle(fontSize: 20),
                                ),
                              ),
                              ListView.builder(
                                shrinkWrap: true,
                                physics: const NeverScrollableScrollPhysics(),
                                itemCount: data.length,
                                itemBuilder: (context, index) {
                                  Timestamp ts = data[index]['createtime'];
                                  // return Card(
                                  //   margin: const EdgeInsets.symmetric(
                                  //       vertical: 8.0, horizontal: 16.0),
                                  //   child: ListTile(
                                  //     title: Text(
                                  //       data[index]['taskname'],
                                  //       style: const TextStyle(),
                                  //     ),
                                  //     subtitle: Align(
                                  //       alignment: Alignment.bottomRight,
                                  //       child: Text(
                                  //         'Assigned to: ${data[index]['name']}',
                                  //         style: const TextStyle(
                                  //             color: Colors.grey),
                                  //       ),
                                  //     ),
                                  //     trailing: IconButton(
                                  //       icon: const Icon(
                                  //         Icons.delete,
                                  //         color: Colors.black54,
                                  //       ),
                                  //       onPressed: () {
                                  //         _confirmDeleteTask(data[index]
                                  //                 ['taskname']
                                  //             .replaceAll(' ', '_'));
                                  //       },
                                  //     ),
                                  //   ),
                                  // );
                                  return customCard(
                                      ts: ts,
                                      data: data,
                                      index: index,
                                      isSubmitted: false);
                                },
                              ),
                            ],
                          );
                  } else {
                    return const Center(child: CircularProgressIndicator());
                  }
                },
              ),
              const Divider(),

              /// Submitted Tasks StreamBuilder
              StreamBuilder(
                stream: FirebaseFirestore.instance
                    .collection('tasks')
                    .where('submittime', isNotEqualTo: '-')
                    .orderBy('createtime', descending: true)
                    .snapshots(),
                builder: (context, snapshot) {
                  if (!snapshot.hasData) {
                    return const CircularProgressIndicator();
                  }
                  var data = snapshot.data!.docs;
                  return data.isEmpty
                      ? const Text("No Tasks Submitted Yet")
                      : Column(
                          children: [
                            const Align(
                              alignment: Alignment(-0.8, 0),
                              child: Text(
                                "Submitted Tasks",
                                style: TextStyle(fontSize: 20),
                              ),
                            ),
                            ListView.builder(
                              shrinkWrap: true,
                              physics: const NeverScrollableScrollPhysics(),
                              itemCount: data.length,
                              itemBuilder: (context, index) {
                                Timestamp ts = data[index]['createtime'];
                                return customCard(
                                    ts: ts,
                                    data: data,
                                    index: index,
                                    isSubmitted: true);
                                // return Card(
                                //   margin: const EdgeInsets.symmetric(
                                //       vertical: 8.0, horizontal: 16.0),
                                //   child: ListTile(
                                //     title: Text(
                                //       data[index]['taskname'],
                                //       style: const TextStyle(
                                //         decoration: TextDecoration.lineThrough,
                                //       ),
                                //     ),
                                //     subtitle: Align(
                                //       alignment: Alignment.bottomRight,
                                //       child: Text(
                                //         'Assigned to: ${data[index]['name']}',
                                //         style:
                                //             const TextStyle(color: Colors.grey),
                                //       ),
                                //     ),
                                //     trailing: IconButton(
                                //       icon: const Icon(Icons.delete),
                                //       onPressed: () {
                                //         _confirmDeleteTask(data[index]
                                //                 ['taskname']
                                //             .replaceAll(' ', '_'));
                                //       },
                                //     ),
                                //   ),
                                // );
                              },
                            ),
                          ],
                        );
                },
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class AddTaskPage extends StatefulWidget {
  final List<Map<String, dynamic>> data;

  const AddTaskPage({required this.data, Key? key}) : super(key: key);

  @override
  _AddTaskPageState createState() => _AddTaskPageState();
}

class _AddTaskPageState extends State<AddTaskPage> {
  List<TextEditingController> controllers = [TextEditingController()];
  String? _selectedUser;
  List<String> tasks = [];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Add New Task'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: <Widget>[
            DropdownButton<String>(
              isExpanded: true,
              value: _selectedUser,
              hint: const Text('Select User'),
              items: widget.data.map((e) {
                return DropdownMenuItem<String>(
                  value: "${e['email']}1/1/1${e['name']}",
                  child: Text(e['name']!),
                );
              }).toList(),
              onChanged: (value) {
                setState(() {
                  _selectedUser = value;
                });
              },
            ),
            const SizedBox(height: 16.0),
            Expanded(
              child: ListView.builder(
                itemCount: tasks.length + 1,
                itemBuilder: (context, index) {
                  if (index == tasks.length) {
                    return Row(
                      children: [
                        Expanded(
                          child: TextField(
                            controller: controllers.last,
                            decoration: const InputDecoration(
                              labelText: 'Enter task to assign',
                            ),
                          ),
                        ),
                        IconButton(
                          icon: const Icon(Icons.add),
                          onPressed: () {
                            if (controllers.last.text.isNotEmpty) {
                              setState(() {
                                tasks.add(controllers.last.text);
                                controllers.add(TextEditingController());
                              });
                            }
                          },
                        ),
                      ],
                    );
                  } else {
                    return Card(
                      margin: const EdgeInsets.symmetric(vertical: 8.0),
                      child: ListTile(
                        title: Text(tasks[index]),
                        trailing: IconButton(
                          icon: const Icon(Icons.delete),
                          onPressed: () {
                            setState(() {
                              tasks.removeAt(index);
                              controllers.removeAt(index);
                            });
                          },
                        ),
                      ),
                    );
                  }
                },
              ),
            ),
            ElevatedButton(
              onPressed: () async {
                // Save the tasks and user to Firestore
                if (_selectedUser != null && tasks.isNotEmpty) {
                  for (var task in tasks) {
                    var _email = _selectedUser!.split('1/1/1')[0];
                    var _name = _selectedUser!.split('1/1/1')[1];
                    await FirebaseFirestore.instance
                        .collection("tasks")
                        .doc(task.trim().replaceAll(' ', '_'))
                        .set({
                      'name': _name,
                      'taskname': task,
                      'createtime': Timestamp.now(),
                      'submittime': '-',
                      'email': _email,
                    });
                  }
                  Navigator.pop(context, {
                    'tasks': tasks,
                    'user': _selectedUser,
                  });
                }
              },
              child: const Text('Submit'),
            ),
          ],
        ),
      ),
    );
  }
}
