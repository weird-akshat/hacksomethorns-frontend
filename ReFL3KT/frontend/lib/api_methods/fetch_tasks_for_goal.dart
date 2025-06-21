import 'dart:convert';
import 'package:frontend/goal_tracking/entities/task.dart';
import 'package:http/http.dart' as http;
import 'package:flutter_dotenv/flutter_dotenv.dart';

Future<List<Task>> fetchTasksForGoal(int userId, int goalId) async {
  final String apiUrl = dotenv.env['API_URL']!;
  final uri = Uri.parse('$apiUrl/users/$userId/goals/$goalId/tasks/');

  final response = await http.get(uri);

  if (response.statusCode == 200) {
    final data = jsonDecode(response.body);
    final List<dynamic> results = data['results'];
    return results.map((taskJson) => Task.fromJson(taskJson)).toList();
  } else {
    throw Exception('Failed to fetch tasks: ${response.body}');
  }
}
