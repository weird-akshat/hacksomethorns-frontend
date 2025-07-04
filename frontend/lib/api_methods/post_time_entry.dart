import 'dart:convert';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:frontend/time_tracking/entities/time_entry.dart';
import 'package:frontend/to_object_methods/map_to_time_entry.dart';
import 'package:http/http.dart' as http;

Future<TimeEntry?> postTimeEntry(TimeEntry entry) async {
  final String apiUrl = dotenv.env['API_URL']!;

  final Map<String, dynamic> requestBody = {
    "description": entry.description,
    "start_time": entry.startTime.toUtc().toIso8601String(),
    "end_time": entry.endTime?.toUtc().toIso8601String(),
    "category_id": entry.categoryId,
  };

  try {
    final response = await http.post(
      Uri.parse("${apiUrl}api/users/1/time-entries/"),
      headers: {"Content-Type": "application/json"},
      body: jsonEncode(requestBody),
    );

    if (response.statusCode == 201 || response.statusCode == 200) {
      final Map<String, dynamic> responseData = jsonDecode(response.body);
      return mapToTimeEntry(responseData);
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
