import 'package:http/http.dart' as http;
import 'package:flutter_dotenv/flutter_dotenv.dart';

Future<void> deleteUserGoal(
    {required String userId, required int goalId}) async {
  final baseUrl = dotenv.env['API_URL'];
  final url = Uri.parse('${baseUrl}api/users/$userId/goals/$goalId/');

  print(url);
  final response = await http.delete(url);

  if (response.statusCode != 204) {
    throw Exception('Failed to delete goal: ${response.body}');
  }
}
