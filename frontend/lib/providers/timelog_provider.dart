import 'package:flutter/material.dart';
import 'package:frontend/api_methods/fetch_time_entries.dart';
import 'package:frontend/time_tracking/entities/time_entry.dart';

class TimelogProvider with ChangeNotifier {
  Map<DateTime, List<TimeEntry>> map = {};

  bool isEmpty() {
    return map.isEmpty;
  }

  Future<void> loadTimeEntries() async {
    map = await fetchTimeEntries();
    for (final entry in map.entries) {
      entry.value.sort((a, b) => b.startTime.compareTo(a.startTime));
    }
    notifyListeners();
  }
}
