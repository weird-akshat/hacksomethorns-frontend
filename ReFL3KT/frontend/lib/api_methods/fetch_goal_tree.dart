import 'dart:convert';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:frontend/goal_tracking/entities/tree_node.dart';
import 'package:http/http.dart' as http;

Future<List<TreeNode>> fetchGoalTree(String userId) async {
  print("a");
  final String apiUrl = dotenv.env['API_URL']!;
  final uri = Uri.parse("${apiUrl}api/users/$userId/goals");
  final response = await http.get(uri);

  if (response.statusCode == 200) {
    print("crazy");
    List<dynamic> jsonData = jsonDecode(response.body);
    return _buildTree(jsonData);
  } else {
    print("crazy error");
    throw Exception('Failed to load goals: ${response.statusCode}');
  }
}

List<TreeNode> _buildTree(List<dynamic> jsonList) {
  // Create node map for quick lookup
  final Map<int, TreeNode> nodeMap = {};

  // First pass: create all nodes
  for (var json in jsonList) {
    nodeMap[json['id']] = TreeNode(name: json['name']);
  }

  // Second pass: establish parent-child relationships
  for (var json in jsonList) {
    final currentNode = nodeMap[json['id']]!;

    // Handle children from subgoals
    if (json['subgoals'] != null && json['subgoals'] is List) {
      for (var childJson in json['subgoals']) {
        final childNode = nodeMap[childJson['id']]!;
        currentNode.addChild(childNode);
      }
    }
  }

  // Return root nodes (nodes with no parent)
  return jsonList
      .where((goal) => goal['parent'] == null)
      .map((root) => nodeMap[root['id']]!)
      .toList();
}
