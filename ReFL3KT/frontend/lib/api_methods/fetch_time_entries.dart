import 'dart:convert';

import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:frontend/time_tracking/entities/time_entry.dart';
import 'package:frontend/to_object_methods/map_to_datetime_time_entry_list.dart';
import 'package:http/http.dart' as http;

Future<Map<DateTime, List<TimeEntry>>> fetchTimeEntries(String userId) async {
  final String apiUrl = dotenv.env['API_URL']!;
  // final String userId;
  print("${apiUrl}api/users/$userId/time-entries/recent_entries");

  try {
    // print("$apiUrl/api/time-entries");
    final response = await http.get(
        Uri.parse("${apiUrl}api/users/$userId/time-entries/recent_entries"));

    print("${apiUrl}api/users/$userId/time-entries/recent_entries");

    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);

      // (mapToDateTimeTimeEntryList(data));
      print('Data: $data');
      return mapToDateTimeTimeEntryList(data);
    } else {
      // print('Failed to load data. Status code: ${response.statusCode}');
      // throw Exception('Failed to load data. Status code: ${response.statusCode}');
      return {};
    }
  } catch (e) {
    print('Error: $e');
    return {};
  }
}
