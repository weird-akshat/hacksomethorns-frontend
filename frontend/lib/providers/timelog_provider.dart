import 'package:flutter/material.dart';

class TimelogProvider with ChangeNotifier {
  Map map = {};

  void loadTimeEntries() {
    notifyListeners();
  }
}
