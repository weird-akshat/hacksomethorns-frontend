import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:frontend/goal_tracking/entities/task.dart';

Future<Task> updateTask({
  required String userId,
  required int goalId,
  required Task task,
}) async {
  final String apiUrl = dotenv.env['API_URL']!;
  final uri =
      Uri.parse('$apiUrl/users/${userId}goals/$goalId/tasks/${task.id}/');

  final body = jsonEncode({
    'title': task.name,
    'goal': goalId,
    'description':
        '', // You can update this if you include it in the Task model
    'category': task.category,
    'is_recurring': task.isRecurring,
    'due_date': DateTime.now()
        .toUtc()
        .toIso8601String(), // Ideally this should come from Task too
    'estimated_time':
        (task.timeSpent * 60).round(), // convert hours back to minutes
  });

  final response = await http.put(
    uri,
    headers: {'Content-Type': 'application/json'},
    body: body,
  );

  if (response.statusCode == 200) {
    return Task.fromJson(jsonDecode(response.body));
  } else {
    throw Exception('Failed to update task: ${response.body}');
  }
}
