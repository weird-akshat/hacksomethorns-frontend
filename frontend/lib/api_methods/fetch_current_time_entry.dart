import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:frontend/time_tracking/entities/time_entry.dart';

Future<TimeEntry?> fetchCurrentTimeEntry(String userId) async {
  final String apiUrl = dotenv.env['API_URL']!;
  final uri =
      Uri.parse("${apiUrl}api/users/$userId/time-entries/current_time_entry/");

  try {
    final response = await http.get(uri);

    if (response.statusCode == 200 && response.body.isNotEmpty) {
      final Map<String, dynamic> jsonData = jsonDecode(response.body);

      return TimeEntry(
        timeEntryId: jsonData['_timeEntryId'],
        description: jsonData['_description'],
        startTime: DateTime.parse(jsonData['_startTime']),
        endTime: jsonData['_endTime'] != null
            ? DateTime.parse(jsonData['_endTime'])
            : null,
        categoryId: jsonData['_categoryId'],
        categoryName: jsonData['_categoryName'],
        userId: userId,
      );
    } else if (response.statusCode == 404) {
      return null; // No active time entry
    } else {
      print("Failed to fetch current time entry: ${response.statusCode}");
      return null;
    }
  } catch (e) {
    print("Error fetching current time entry: $e");
    return null;
  }
}
