import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:flutter_dotenv/flutter_dotenv.dart';

Future<Map<String, dynamic>> fetchGoalAnalytics(int userId, int goalId) async {
  final String apiUrl = dotenv.env['API_URL']!;
  final uri = Uri.parse('$apiUrl/users/$userId/goals/$goalId/analytics/');

  final response = await http.get(uri);

  if (response.statusCode == 200) {
    return jsonDecode(response.body);
  } else {
    throw Exception('Failed to fetch goal analytics: ${response.body}');
  }
}
