import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:flutter_dotenv/flutter_dotenv.dart';

Future<void> deleteTask({
  required int userId,
  required int goalId,
  required String taskId,
}) async {
  final String apiUrl = dotenv.env['API_URL']!;
  final uri = Uri.parse('$apiUrl/users/$userId/goals/$goalId/tasks/$taskId/');

  final response = await http.delete(uri);

  if (response.statusCode != 204) {
    throw Exception('Failed to delete task: ${response.body}');
  }
}
