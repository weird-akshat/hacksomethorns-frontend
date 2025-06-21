import 'dart:convert';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:frontend/goal_tracking/entities/tree_node.dart';
import 'package:http/http.dart' as http;

Future<void> postGoalFromTreeNode(TreeNode node, int userId) async {
  final String apiUrl = dotenv.env['API_URL']!;
  final uri = Uri.parse('$apiUrl/users/$userId//goals/');

  final response = await http.post(
    uri,
    headers: {'Content-Type': 'application/json'},
    body: jsonEncode(node.toJson(userId)),
  );

  if (response.statusCode != 201) {
    throw Exception('Failed to create goal: ${response.body}');
  }
}
