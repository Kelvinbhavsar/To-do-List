import 'dart:developer';

import 'package:flutter/material.dart';
import 'package:flutter_application_2/screens/new_task_screen.dart';
import 'package:flutter_application_2/screens/task_screen.dart';
import 'package:flutter_application_2/screens/user_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  List _screens = [
    UserScreen(),
    TaskScreen(),
    // NewTaskScreen(),
  ];
  var _index = 0;
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: _screens[_index],
      bottomNavigationBar: BottomNavigationBar(
        backgroundColor: Color.fromRGBO(93, 203, 125, 100),
        elevation: 0,
        items: const <BottomNavigationBarItem>[
          BottomNavigationBarItem(
            icon: Icon(Icons.person),
            label: 'User',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.task),
            label: 'Task',
          ),
        ],
        currentIndex: _index,
        selectedItemColor: Colors.white,
        onTap: (value) {
          setState(() {
            _index = value;
          });
        },
      ),
    );
  }
}
