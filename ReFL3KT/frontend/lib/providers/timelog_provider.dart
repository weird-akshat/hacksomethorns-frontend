import 'package:flutter/material.dart';
import 'package:frontend/api_methods/fetch_time_entries.dart';
import 'package:frontend/time_tracking/entities/time_entry.dart';
import 'package:frontend/providers/timelog_provider.dart';

class TimelogProvider with ChangeNotifier {
  Map<DateTime, List<TimeEntry>> map = {};

  bool isEmpty() {
    return map.isEmpty;
  }

  void sort() {
    // Sort the inner lists
    for (final entry in map.entries) {
      entry.value.sort((a, b) => b.startTime.compareTo(a.startTime));
    }

    // Sort the map by keys in descending order
    final sortedEntries = map.entries.toList()
      ..sort((a, b) => b.key.compareTo(a.key));

    map = {
      for (final entry in sortedEntries) entry.key: entry.value,
    };
  }

  DateTime normalizeDate(DateTime date) {
    return DateTime(date.year, date.month, date.day);
  }

  Future<void> loadTimeEntries() async {
    map = await fetchTimeEntries();
    sort();
    notifyListeners();
  }

  void addTimeEntry(DateTime date, TimeEntry entry) {
    final normalizedDate = normalizeDate(date);
    print(entry.endTime);
    map.putIfAbsent(normalizedDate, () => []);
    map[normalizedDate]!.add(entry);
    map[normalizedDate]!.sort((a, b) => b.startTime.compareTo(a.startTime));
    notifyListeners();
  }
}
