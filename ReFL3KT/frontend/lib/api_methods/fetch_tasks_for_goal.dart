import 'dart:convert';
import 'package:frontend/goal_tracking/entities/task.dart';
import 'package:http/http.dart' as http;
import 'package:flutter_dotenv/flutter_dotenv.dart';

Future<List<Task>> fetchTasksForGoal(String userId, int goalId) async {
  final String apiUrl = dotenv.env['API_URL']!;
  final uri = Uri.parse('${apiUrl}api/users/$userId/goals/$goalId/tasks/');
  print(uri);
  // print('object')
  // print('')
  final response = await http.get(uri);
  print(response.body);
  if (response.statusCode == 200) {
    final data = jsonDecode(response.body);
    print(response);
    final List<dynamic> results = data['results'];
    return results.map((taskJson) => Task.fromJson(taskJson)).toList();
  } else {
    print(response.body);
    throw Exception('Failed to fetch tasks: ${response.body}');
  }
}
