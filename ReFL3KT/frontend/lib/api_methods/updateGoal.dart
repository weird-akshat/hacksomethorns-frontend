import 'package:frontend/goal_tracking/entities/tree_node.dart';
import 'package:http/http.dart' as http;
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'dart:convert';

Future<TreeNode> updateGoalFromNode({
  required String userId,
  required int goalId,
  required TreeNode node,
}) async {
  final baseUrl = dotenv.env['API_URL'];
  final url = Uri.parse('${baseUrl}api/users/{$userId}/goals/{$goalId}/');

  final response = await http.put(
    url,
    headers: {'Content-Type': 'application/json'},
    body: jsonEncode(node.toJson(userId)),
  );

  if (response.statusCode == 200) {
    final data = jsonDecode(response.body);
    return TreeNode(
      id: node.id,
      name: data['name'],
    )
      ..description = data['description']
      ..parentId = data['parent']
      ..status = data['status']
      ..priority = data['priority']
      ..deadline = data['deadline']
      ..isGroupGoal = data['is_group_goal'];
  } else {
    throw Exception('Failed to update goal: ${response.body}');
  }
}
