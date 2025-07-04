import 'dart:convert';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:frontend/goal_tracking/entities/tree_node.dart';
import 'package:http/http.dart' as http;

Future<TreeNode> postGoalFromTreeNode(TreeNode node, String userId) async {
  final String apiUrl = dotenv.env['API_URL']!;

  print(node.deadline);
  final uri = Uri.parse('${apiUrl}api/users/$userId/goals/');
  print(uri);
  print(node.toJson(userId));
  final response = await http.post(
    uri,
    headers: {'Content-Type': 'application/json'},
    body: jsonEncode(node.toJson(userId)),
  );

  if (response.statusCode != 201) {
    throw Exception('Failed to create goal: ${response.body}');
  }

  final responseData = jsonDecode(response.body);
  return TreeNode.fromJson(responseData);
}
