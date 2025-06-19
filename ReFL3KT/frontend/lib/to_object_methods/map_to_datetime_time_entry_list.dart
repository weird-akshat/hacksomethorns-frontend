import 'package:frontend/time_tracking/entities/time_entry.dart';
import 'package:frontend/to_object_methods/map_to_time_entry.dart';

Map<DateTime, List<TimeEntry>> mapToDateTimeTimeEntryList(
    Map<String, dynamic> rawData) {
  final Map<DateTime, List<TimeEntry>> result = {};

  rawData.forEach((dateStr, entryList) {
    final date = DateTime.parse(dateStr).toLocal();

    final timeEntries = (entryList as List<dynamic>)
        .map((entry) => mapToTimeEntry(entry))
        .toList();
    result[date] = timeEntries;
  });

  return result;
}
