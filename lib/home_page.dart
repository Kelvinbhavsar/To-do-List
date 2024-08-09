import 'dart:js_interop_unsafe';

import 'package:flutter/material.dart';
import 'user_page.dart';
import 'task_page.dart';

class HomePage extends StatefulWidget {
  const HomePage({Key? key}) : super(key: key);

  @override
  _HomePageState createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> with SingleTickerProviderStateMixin {
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        toolbarHeight: 44,
        elevation: 0,
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(8), // Set the desired height here
          child: TabBar(
            labelColor: Colors.black,
            unselectedLabelColor: Colors.grey,
            indicatorColor: Colors.black,
            controller: _tabController,
            tabs: const <Widget>[
              Tab(text: 'Members'),
              Tab(text: 'Task'),
            ],
          ),
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        children: const <Widget>[
          UserPage(),
          TaskPage(),
        ],
      ),
    );
  }
}
