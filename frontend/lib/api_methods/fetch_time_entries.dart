import 'dart:convert';

import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:frontend/time_tracking/entities/time_entry.dart';
import 'package:frontend/to_object_methods/map_to_datetime_time_entry_list.dart';
import 'package:http/http.dart' as http;

Future<Map<DateTime, List<TimeEntry>>> fetchTimeEntries() async {
  final String apiUrl = dotenv.env['API_URL']!;

  try {
    // print("$apiUrl/api/time-entries");
    final response = await http.get(Uri.parse("${apiUrl}api/time-entries/"));

    if (response.statusCode == 200) {
      final data = {
        "2025-06-16": [
          {
            "id": 1,
            "description": "Work planning",
            "start_time": "2025-06-16T08:00:00Z",
            "end_time": "2025-06-16T09:00:00Z",
            "category": "Work",
            "is_active": false,
            "duration": "1:00:00",
            "created_at": "2025-06-16T09:01:00Z",
            "updated_at": "2025-06-16T09:01:00Z"
          },
          {
            "id": 2,
            "description": "Quick journaling",
            "start_time": "2025-06-16T21:00:00Z",
            "end_time": "2025-06-16T21:10:00Z",
            "category": "Reflection",
            "is_active": false,
            "duration": "0:10:00",
            "created_at": "2025-06-16T21:10:30Z",
            "updated_at": "2025-06-16T21:10:30Z"
          }
        ],
        "2025-06-17": [
          {
            "id": 3,
            "description": "Gym session",
            "start_time": "2025-06-17T06:30:00Z",
            "end_time": "2025-06-17T07:15:00Z",
            "category": "Health",
            "is_active": false,
            "duration": "0:45:00",
            "created_at": "2025-06-17T07:16:00Z",
            "updated_at": "2025-06-17T07:16:00Z"
          },
          {
            "id": 4,
            "description": "Reading",
            "start_time": "2025-06-17T22:00:00Z",
            "end_time": "2025-06-17T22:30:00Z",
            "category": "Learning",
            "is_active": false,
            "duration": "0:30:00",
            "created_at": "2025-06-17T22:31:00Z",
            "updated_at": "2025-06-17T22:31:00Z"
          }
        ],
        "2025-06-18": [
          {
            "id": 5,
            "description": "Meeting with team",
            "start_time": "2025-06-18T10:00:00Z",
            "end_time": "2025-06-18T11:00:00Z",
            "category": "Work",
            "is_active": false,
            "duration": "1:00:00",
            "created_at": "2025-06-18T11:01:00Z",
            "updated_at": "2025-06-18T11:01:00Z"
          },
          {
            "id": 6,
            "description": "Idea brainstorm",
            "start_time": "2025-06-18T23:00:00Z",
            "end_time": "2025-06-18T23:15:00Z",
            "category": "Creative",
            "is_active": false,
            "duration": "0:15:00",
            "created_at": "2025-06-18T23:16:00Z",
            "updated_at": "2025-06-18T23:16:00Z"
          }
        ],
        "2025-06-19": [
          {
            "id": 7,
            "description": "Walk outside",
            "start_time": "2025-06-19T17:30:00Z",
            "end_time": "2025-06-19T18:00:00Z",
            "category": "Health",
            "is_active": false,
            "duration": "0:30:00",
            "created_at": "2025-06-19T18:01:00Z",
            "updated_at": "2025-06-19T18:01:00Z"
          }
        ],
        "2025-06-20": [
          {
            "id": 8,
            "description": "YouTube break",
            "start_time": "2025-06-20T14:00:00Z",
            "end_time": "2025-06-20T14:10:00Z",
            "category": "Fun",
            "is_active": false,
            "duration": "0:10:00",
            "created_at": "2025-06-20T14:10:30Z",
            "updated_at": "2025-06-20T14:10:30Z"
          },
          {
            "id": 9,
            "description": "Project coding",
            "start_time": "2025-06-20T19:00:00Z",
            "end_time": "2025-06-20T21:00:00Z",
            "category": "Work",
            "is_active": false,
            "duration": "2:00:00",
            "created_at": "2025-06-20T21:01:00Z",
            "updated_at": "2025-06-20T21:01:00Z"
          }
        ],
        "2025-06-21": [
          {
            "id": 10,
            "description": "Friend call",
            "start_time": "2025-06-21T15:00:00Z",
            "end_time": "2025-06-21T15:45:00Z",
            "category": "Social",
            "is_active": false,
            "duration": "0:45:00",
            "created_at": "2025-06-21T15:46:00Z",
            "updated_at": "2025-06-21T15:46:00Z"
          }
        ],
        "2025-06-22": [
          {
            "id": 11,
            "description": "Planning week",
            "start_time": "2025-06-22T19:00:00Z",
            "end_time": "2025-06-22T19:30:00Z",
            "category": "Reflection",
            "is_active": false,
            "duration": "0:30:00",
            "created_at": "2025-06-22T19:31:00Z",
            "updated_at": "2025-06-22T19:31:00Z"
          },
          {
            "id": 12,
            "description": "Clean room",
            "start_time": "2025-06-22T11:00:00Z",
            "end_time": "2025-06-22T11:30:00Z",
            "category": "Home",
            "is_active": false,
            "duration": "0:30:00",
            "created_at": "2025-06-22T11:31:00Z",
            "updated_at": "2025-06-22T11:31:00Z"
          }
        ]
      };

      // (mapToDateTimeTimeEntryList(data));
      // print('Data: $data');
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
