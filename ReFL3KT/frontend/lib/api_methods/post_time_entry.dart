import 'dart:convert';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:frontend/time_tracking/entities/time_entry.dart';
import 'package:http/http.dart' as http;

Future<TimeEntry?> postTimeEntry(TimeEntry entry) async {
  final String apiUrl = dotenv.env['API_URL']!;
  final int userId = 1;

  final Map<String, dynamic> requestBody = {
    "description": entry.description,
    "start_time": entry.startTime.toUtc().toIso8601String(),
    "end_time": entry.endTime?.toUtc().toIso8601String(),
    "category_id": entry.categoryId,
  };
  print(requestBody);

  print('API Request Body: ${jsonEncode(requestBody)}');

  try {
    final response = await http.post(
      Uri.parse("${apiUrl}api/users/$userId/time-entries/"),
      headers: {"Content-Type": "application/json"},
      body: jsonEncode(requestBody),
    );

    print('API Response Status: ${response.statusCode}');
    print('API Response Body: ${response.body}');

    if (response.statusCode == 201 || response.statusCode == 200) {
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
        userId: userId.toString(),
      );
    } else {
      print("Failed to post time entry: ${response.statusCode}");
      print("Response body: ${response.body}");
      return null;
    }
  } catch (e) {
    print("Error posting time entry: $e");
    return null;
  }
}
