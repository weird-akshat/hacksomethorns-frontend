import 'package:frontend/time_tracking/entities/time_entry.dart';

TimeEntry mapToTimeEntry(Map<String, dynamic> entry) {
  return TimeEntry(
    description: entry['description'] ?? '',
    timeEntryId: entry['id'].toString(),
    userId: entry['user_id']?.toString() ?? '', // adjust if user_id key exists
    startTime: DateTime.parse(entry['start_time']),
    endTime: DateTime.parse(entry['end_time']),
    categoryId: entry['category_id'] ?? 0,
    categoryName: entry['category'] ?? '',
  );
}
