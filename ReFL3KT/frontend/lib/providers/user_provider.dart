import 'package:flutter/material.dart';

class UserProvider extends ChangeNotifier {
  String? userId;
  String? username;
  String? token;

  void setUser(
      {required String userId,
      required String username,
      required String token}) {
    this.userId = userId;
    this.username = username;
    this.token = token;
    notifyListeners();
  }

  void clearUser() {
    userId = null;
    username = null;
    token = null;
    notifyListeners();
  }

  bool get isLoggedIn => userId != null && token != null;
}
