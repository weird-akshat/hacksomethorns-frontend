import 'dart:convert';

import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:frontend/goal_tracking/entities/task.dart';
import 'package:http/http.dart' as http;

Future<Task> createTask(String userId, int goalId, Task task) async {
  final String apiUrl = dotenv.env['API_URL']!;
  final uri = Uri.parse('$apiUrl/users/$userId/goals/$goalId/tasks/');

  final response = await http.post(
    uri,
    headers: {'Content-Type': 'application/json'},
    body: jsonEncode({
      'title': task.name,
      'description': '',
      'goal': goalId,
      'category': task.category,
      'is_recurring': task.isRecurring,
      'due_date': DateTime.now().toIso8601String(),
      'estimated_time': (task.timeSpent * 60).toInt(),
    }),
  );

  if (response.statusCode == 201 || response.statusCode == 200) {
    final Map<String, dynamic> data = jsonDecode(response.body);
    return Task.fromJson(data);
  } else {
    throw Exception('Failed to create task: ${response.body}');
  }
}
