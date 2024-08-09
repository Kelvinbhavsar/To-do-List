import 'package:flutter/material.dart';

class UserProvider with ChangeNotifier {
  // ignore: prefer_final_fields
  List<Map<String, String>> _users = [
    {"name": "User-1", "email": "user1@example.com"},
    {"name": "User-2", "email": "user2@example.com"},
    {"name": "User-3", "email": "user3@example.com"},
  ];

  List<Map<String, String>> get users => _users;

  void addUser(String name, String email) {
    _users.add({"name": name, "email": email});
    notifyListeners();
  }

  void deleteUser(int index) {
    _users.removeAt(index);
    notifyListeners();
  }
}
