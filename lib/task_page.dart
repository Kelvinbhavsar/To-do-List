import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'user_provider.dart';

class TaskPage extends StatefulWidget {
  const TaskPage({Key? key}) : super(key: key);

  @override
  _TaskPageState createState() => _TaskPageState();
}

class _TaskPageState extends State<TaskPage> {
  List<Map<String, String>> tasks = [];
  List<Map<String, String>> completedTasks = [];

  void _navigateToAddTaskPage() async {
    final result = await Navigator.of(context).push<Map<String, dynamic>>(
      MaterialPageRoute(builder: (context) => const AddTaskPage()),
    );

    if (result != null && result['tasks'] != null) {
      setState(() {
        for (var task in result['tasks']) {
          tasks.add({
            "task": task,
            "user": result['user']!,
            "time": result['time']!,
          });
        }
      });
    }
  }

  void _confirmDeleteTask(int index) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Confirm Delete'),
          content: const Text('Are you sure you want to delete this task?'),
          actions: <Widget>[
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: const Text('Cancel'),
            ),
            TextButton(
              onPressed: () {
                setState(() {
                  tasks.removeAt(index);
                });
                Navigator.of(context).pop();
              },
              child: const Text('Delete'),
            ),
          ],
        );
      },
    );
  }

  void _completeTask(int index) {
    setState(() {
      completedTasks.add(tasks.removeAt(index));
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: ListView(
        children: [
          ListView.builder(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            itemCount: tasks.length,
            itemBuilder: (context, index) {
              return Padding(
                padding: const EdgeInsets.symmetric(vertical: 8.0, horizontal: 16.0),
                child: Row(
                  children: [
                    Expanded(
                      child: Card(
                        child: ListTile(
                          title: Text(tasks[index]['task']!),
                          subtitle: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text('Assigned to: ${tasks[index]['user']}'),
                              Text(
                                'Added on: ${tasks[index]['time']}',
                                style: const TextStyle(color: Colors.grey),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                    IconButton(
                      icon: const Icon(Icons.check_circle_outline),
                      onPressed: () {
                        _completeTask(index);
                      },
                    ),
                    IconButton(
                      icon: const Icon(Icons.delete),
                      onPressed: () {
                        _confirmDeleteTask(index);
                      },
                    ),
                  ],
                ),
              );
            },
          ),
          if (completedTasks.isNotEmpty)
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Divider(),
                const Padding(
                  padding: EdgeInsets.all(16.0),
                  child: Text(
                    'Completed Tasks',
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                  ),
                ),
                ListView.builder(
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  itemCount: completedTasks.length,
                  itemBuilder: (context, index) {
                    return Padding(
                      padding: const EdgeInsets.symmetric(vertical: 8.0, horizontal: 16.0),
                      child: Row(
                        children: [
                          Expanded(
                            child: Card(
                              child: ListTile(
                                title: Text(
                                  completedTasks[index]['task']!,
                                  style: const TextStyle(
                                    decoration: TextDecoration.lineThrough,
                                  ),
                                ),
                                subtitle: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text('Assigned to: ${completedTasks[index]['user']}'),
                                    Text(
                                      'Completed on: ${completedTasks[index]['time']}',
                                      style: const TextStyle(color: Colors.grey),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          ),
                          IconButton(
                            icon: const Icon(Icons.delete),
                            onPressed: () {
                              setState(() {
                                completedTasks.removeAt(index);
                              });
                            },
                          ),
                        ],
                      ),
                    );
                  },
                ),
              ],
            ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: _navigateToAddTaskPage,
        child: const Icon(Icons.add),
      ),
    );
  }
}

// Add Task Page
class AddTaskPage extends StatefulWidget {
  const AddTaskPage({Key? key}) : super(key: key);

  @override
  _AddTaskPageState createState() => _AddTaskPageState();
}

class _AddTaskPageState extends State<AddTaskPage> {
  List<TextEditingController> controllers = [TextEditingController()];
  String? selectedUser;
  List<String> tasks = [];
  String? taskTime;

  @override
  void initState() {
    super.initState();
    taskTime = DateTime.now().toString(); // Set the initial time
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Add New Task'),
        actions: [
          TextButton(
            onPressed: () {
              if (selectedUser != null && tasks.isNotEmpty) {
                Navigator.of(context)
                    .pop({"tasks": tasks, "user": selectedUser, "time": taskTime});
              }
            },
            child: const Text('Save', style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: <Widget>[
            Consumer<UserProvider>(
              builder: (context, userProvider, child) {
                return DropdownButton<String>(
                  isExpanded: true,
                  value: selectedUser,
                  hint: const Text('Select User'),
                  items: userProvider.users.map((user) {
                    return DropdownMenuItem<String>(
                      value: user['name'],
                      child: Text(user['name']!),
                    );
                  }).toList(),
                  onChanged: (value) {
                    setState(() {
                      selectedUser = value;
                    });
                  },
                );
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
                              controllers.removeAt(index + 1); // Keep the last empty controller
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
              onPressed: () {
                if (selectedUser != null && tasks.isNotEmpty) {
                  Navigator.of(context)
                      .pop({"tasks": tasks, "user": selectedUser, "time": taskTime});
                }
              },
              style: ElevatedButton.styleFrom(
                padding: const EdgeInsets.symmetric(
                    vertical: 16.0, horizontal: 64.0),
                backgroundColor: const Color.fromRGBO(93, 203, 125, 100),
              ),
              child: const Text(
                'Assign',
                style: TextStyle(color: Colors.white),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
