import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:flutter_dotenv/flutter_dotenv.dart';

Future<Map<String, dynamic>> fetchGoalAnalytics(
    String userId, int goalId) async {
  final String apiUrl = dotenv.env['API_URL']!;

  final uri = Uri.parse('${apiUrl}api/users/$userId/goals/$goalId/analytics/');
  print(uri);
  print('yoo');
  final response = await http.get(uri);
  print(response.body);

  if (response.statusCode == 200) {
    print(response);
    return jsonDecode(response.body);
  } else {
    print('object');
    throw Exception('Failed to fetch goal analytics: ${response.body}');
  }
}
