import 'package:flutter/material.dart';
import 'package:frontend/time_tracking/entities/time_entry.dart';
import 'package:frontend/api_methods/fetch_current_time_entry.dart';

class CurrentTimeEntryProvider extends ChangeNotifier {
  TimeEntry? _currentEntry;

  TimeEntry? get currentEntry => _currentEntry;

  bool get isTracking => _currentEntry?.endTime == null;

  Future<void> loadCurrentEntry(String userId) async {
    _currentEntry = await fetchCurrentTimeEntry(userId);
    print(_currentEntry?.duration);
    notifyListeners();
  }

  void clearEntry() {
    _currentEntry = null;
    notifyListeners();
  }

  void setEntry(TimeEntry entry) {
    _currentEntry = entry;
    notifyListeners();
  }
}
