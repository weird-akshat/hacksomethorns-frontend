import 'dart:convert';
import 'package:http/http.dart' as http;

class AiSchedulerAPi {
  final baseUrl = 'https://refl3kt.onrender.com';

  Future<void> postUserAvailability(String startTime, String endTime) async {
    final url = Uri.parse('$baseUrl/api/availability/');

    final response = await http.post(
      url,
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({"start_time": startTime, "end_time": endTime}),
    );

    if (response.statusCode == 200 || response.statusCode == 201) {
      print('Schedule availability completed successfully');
    } else {
      print('Error: ${response.statusCode}');
      print('Response body: ${response.body}');
      throw Exception('Failed to post user availability');
    }
  }

  Future<void> scheduleTasks(String userID) async {
    final url = Uri.parse('$baseUrl/api/scheduling/schedule/$userID/');

    final response = await http.post(
      url,
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({}),
    );

    if (response.statusCode == 200 || response.statusCode == 201) {
      print('Task scheduling done successfully');
    } else {
      print('Error: ${response.statusCode}');
      print('Response body: ${response.body}');
      throw Exception('Failed to schedule tasks');
    }
  }

  Future<List<Map<String, dynamic>>> getAllScheduledTasks(String userID) async {
    List<Map<String, dynamic>> tasks = [];

    final url = Uri.parse('$baseUrl/api/scheduled-tasks/user/$userID/');

    try {
      final response = await http.get(
        url,
        headers: {'Content-Type': 'application/json'},
      );

      print('getAllScheduledTasks - Status: ${response.statusCode}');
      print('getAllScheduledTasks - Response: ${response.body}');

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);

        if (data is List) {
          for (var item in data) {
            if (item is Map<String, dynamic>) {
              final taskTitle = item['task_title'];
              final estimatedTime = item['estimated_time'];
              final taskId = item['task_id'] ?? item['id'];

              if (taskTitle != null && estimatedTime != null) {
                tasks.add({
                  'task_id': taskId,
                  'task_title': taskTitle,
                  'estimated_time': estimatedTime,
                });
              }
            }
          }
        } else if (data is Map<String, dynamic>) {
          // Handle single object response
          final taskTitle = data['task_title'];
          final estimatedTime = data['estimated_time'];
          final taskId = data['task_id'] ?? data['id'];

          if (taskTitle != null && estimatedTime != null) {
            tasks.add({
              'task_id': taskId,
              'task_title': taskTitle,
              'estimated_time': estimatedTime,
            });
          }
        } else {
          print("Unexpected data format: ${data.runtimeType}");
        }
      } else {
        print("Failed to load tasks. Status: ${response.statusCode}");
        print("Response body: ${response.body}");
      }
    } catch (e) {
      print("Error fetching tasks: $e");
    }
    return tasks;
  }

  Future<Map<String, dynamic>> scheduleDetails(String userID) async {
    Map<String, dynamic> result = {};
    final url = Uri.parse('$baseUrl/api/sessions/user/$userID/');

    try {
      final response = await http.get(
        url,
        headers: {'Content-Type': 'application/json'},
      );

      print('scheduleDetails - Status: ${response.statusCode}');
      print('scheduleDetails - Response: ${response.body}');

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);

        // Handle both single object and array responses
        Map<String, dynamic> sessionData;
        if (data is List && data.isNotEmpty) {
          sessionData = data[0];
        } else if (data is Map<String, dynamic>) {
          sessionData = data;
        } else {
          print('Unexpected data format: ${data.runtimeType}');
          return {'total_tasks': 0, 'total_time': 0};
        }

        // Try multiple possible field names for tasks
        final numTask = sessionData["total_tasks_scheduled"] ??
            sessionData["total_tasks"] ??
            sessionData["tasks_count"] ??
            sessionData["task_count"] ??
            0;

        // Try multiple possible field names for time
        final time = sessionData['total_time_scheduled'] ??
            sessionData['total_time'] ??
            sessionData['time_scheduled'] ??
            sessionData['estimated_time'] ??
            0;

        // Convert time to appropriate format if it's a string
        dynamic processedTime = time;
        if (time is String) {
          try {
            processedTime = double.parse(time);
          } catch (e) {
            print('Could not parse time string: $time');
            processedTime = 0;
          }
        }

        result = {'total_tasks': numTask, 'total_time': processedTime};

        print('Processed result: $result');
      } else {
        print('Failed to load summarised information ${response.statusCode}');
        print('Response body: ${response.body}');
        result = {'total_tasks': 0, 'total_time': 0};
      }
    } catch (e) {
      print('Error fetching schedule details: $e');
      result = {'total_tasks': 0, 'total_time': 0};
    }
    return result;
  }

  Future<void> completeTask(String userID, String taskID) async {
    final url = Uri.parse('$baseUrl/api/scheduling/task-action/$taskID/');

    try {
      final response = await http.post(
        url,
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          "task_id": taskID,
          "status": "complete",
          "action": "complete",
        }),
      );

      print('completeTask - Status: ${response.statusCode}');
      print('completeTask - Response: ${response.body}');

      if (response.statusCode == 200 || response.statusCode == 204) {
        print('Task completion successful');
      } else {
        print('Error completing task ${response.statusCode}');
        print('Response body: ${response.body}');
        throw Exception('Failed to complete task: ${response.statusCode}');
      }
    } catch (e) {
      print('Exception in completeTask: $e');
      throw Exception('Failed to complete task: $e');
    }
  }

  Future<List<Map<String, dynamic>>> getTopFiveTasks(String userID) async {
    List<Map<String, dynamic>> tasks = [];

    final url = Uri.parse(
      '$baseUrl/api/scheduling/high-priority/$userID/?limit=5',
    );

    try {
      final response = await http.get(
        url,
        headers: {'Content-Type': 'application/json'},
      );

      print('getTopFiveTasks - Status: ${response.statusCode}');
      print('getTopFiveTasks - Response: ${response.body}');

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);

        if (data is List) {
          for (var item in data) {
            if (item is Map<String, dynamic>) {
              final taskTitle = item['task_title'];
              final estimatedTime = item['estimated_time'];
              final taskId = item['task_id'] ?? item['id'];

              if (taskTitle != null && estimatedTime != null) {
                tasks.add({
                  'task_id': taskId,
                  'task_title': taskTitle,
                  'estimated_time': estimatedTime,
                });
              }
            }
          }
        } else if (data is Map<String, dynamic>) {
          // Handle single object response
          final taskTitle = data['task_title'];
          final estimatedTime = data['estimated_time'];
          final taskId = data['task_id'] ?? data['id'];

          if (taskTitle != null && estimatedTime != null) {
            tasks.add({
              'task_id': taskId,
              'task_title': taskTitle,
              'estimated_time': estimatedTime,
            });
          }
        } else {
          print("Unexpected data format: ${data.runtimeType}");
        }
      } else {
        print("Failed to load priority tasks. Status: ${response.statusCode}");
        print("Response body: ${response.body}");
      }
    } catch (e) {
      print("Error fetching priority tasks: $e");
    }
    return tasks;
  }

  Future<Map<String, dynamic>> getUserAvailability(String userID) async {
    Map<String, dynamic> data = {};

    final url = Uri.parse('$baseUrl/api/availability/user/$userID/');

    try {
      final response = await http.get(
        url,
        headers: {'Content-Type': 'application/json'},
      );

      print('getUserAvailability - Status: ${response.statusCode}');
      print('getUserAvailability - Response: ${response.body}');

      if (response.statusCode == 200) {
        final responseData = jsonDecode(response.body);

        // Handle both single object and array responses
        Map<String, dynamic> availabilityData;
        if (responseData is List && responseData.isNotEmpty) {
          availabilityData = responseData[0];
        } else if (responseData is Map<String, dynamic>) {
          availabilityData = responseData;
        } else {
          print('Unexpected data format: ${responseData.runtimeType}');
          return {};
        }

        final startTime = availabilityData['start_time'];
        final endTime = availabilityData['end_time'];

        if (startTime != null && endTime != null) {
          data['start_time'] = startTime;
          data['end_time'] = endTime;
        }
      } else {
        print('Failed to load availability data ${response.statusCode}');
        print('Response body: ${response.body}');
      }
    } catch (e) {
      print('Error fetching availability: $e');
    }
    return data;
  }

  Future<void> updateAvailability(
    String userID,
    String startTime,
    String endTime,
  ) async {
    final url = Uri.parse('$baseUrl/api/availability/user/$userID/');

    try {
      final response = await http.put(
        url,
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({"start_time": startTime, "end_time": endTime}),
      );

      print('updateAvailability - Status: ${response.statusCode}');
      print('updateAvailability - Response: ${response.body}');

      if (response.statusCode == 200 || response.statusCode == 204) {
        print('Update successful ${response.body}');
      } else {
        print('Request failed ${response.statusCode}');
        print('Response body: ${response.body}');
        throw Exception(
          'Failed to update availability: ${response.statusCode}',
        );
      }
    } catch (e) {
      print('Exception in updateAvailability: $e');
      throw Exception('Failed to update availability: $e');
    }
  }

  Future<void> addAvailability(
    String userID,
    String startTime,
    String endTime,
  ) async {
    final url = Uri.parse('$baseUrl/api/availability/user/$userID/');

    try {
      final response = await http.post(
        url,
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({"start_time": startTime, "end_time": endTime}),
      );

      print('addAvailability - Status: ${response.statusCode}');
      print('addAvailability - Response: ${response.body}');

      if (response.statusCode == 200 || response.statusCode == 201) {
        print('Addition successful ${response.body}');
      } else {
        print('Request failed ${response.statusCode}');
        print('Response body: ${response.body}');
        throw Exception('Failed to add availability: ${response.statusCode}');
      }
    } catch (e) {
      print('Exception in addAvailability: $e');
      throw Exception('Failed to add availability: $e');
    }
  }

  Future<void> taskRescheduler(String userID) async {
    final url = Uri.parse('$baseUrl/api/scheduling/reschedule/$userID/');

    try {
      final response = await http.get(
        url,
        headers: {'Content-Type': 'application/json'},
      );

      print('taskRescheduler - Status: ${response.statusCode}');
      print('taskRescheduler - Response: ${response.body}');

      if (response.statusCode == 200 || response.statusCode == 201) {
        print('Rescheduling done successfully ${response.statusCode}');
      } else {
        print('Error rescheduling ${response.statusCode}');
        print('Response body: ${response.body}');
        throw Exception('Failed to reschedule tasks: ${response.statusCode}');
      }
    } catch (e) {
      print('Exception in taskRescheduler: $e');
      throw Exception('Failed to reschedule tasks: $e');
    }
  }

  Future<void> skipTask(String userID, String taskID) async {
    final url = Uri.parse('$baseUrl/api/scheduling/task-action/$taskID/');

    try {
      final response = await http.post(
        url,
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          "task_id": taskID,
          "status": "skipped",
          "action": "skipped",
        }),
      );

      print('skipTask - Status: ${response.statusCode}');
      print('skipTask - Response: ${response.body}');

      if (response.statusCode == 200 || response.statusCode == 204) {
        print('Task skip successful');
      } else {
        print('Error skipping task ${response.statusCode}');
        print('Response body: ${response.body}');
        throw Exception('Failed to skip task: ${response.statusCode}');
      }
    } catch (e) {
      print('Exception in skipTask: $e');
      throw Exception('Failed to skip task: $e');
    }
  }
}
