import 'package:flutter/material.dart';
import 'package:frontend/goal_tracking/entities/tree_node.dart';
import 'package:frontend/goal_tracking/widgets/graphview.dart';

class TreeScreen extends StatefulWidget {
  const TreeScreen({super.key});

  @override
  State<TreeScreen> createState() => _TreeScreenState();
}

class _TreeScreenState extends State<TreeScreen> {
  TreeNode node1 = TreeNode(name: "Goal");
  TreeNode node2 = TreeNode(name: "Goal");
  TreeNode node3 = TreeNode(name: "Goal");
  TreeNode node4 = TreeNode(name: "Goal");
  TreeNode node5 = TreeNode(name: "Goal");
  TreeNode node6 = TreeNode(name: "Goal");
  TreeNode node7 = TreeNode(name: "Goal");
  TreeNode node8 = TreeNode(name: "Goal");
  TreeNode node9 = TreeNode(name: "Goal");
  TreeNode node10 = TreeNode(name: "Goal");
  TreeNode node11 = TreeNode(name: "Goal");
  TreeNode node12 = TreeNode(name: "Goal");
  TreeNode node13 = TreeNode(name: "Goal");

  @override
  void initState() {
    super.initState();

    // Level 1 (root)
    node1.addChildren([node2, node3]);

    // Level 2
    node2.addChildren([node4, node5]);
    node3.addChildren([node6]);

    node3.addChildren([node11, node12, node12]);

    // Level 3
    node4.addChildren([node7]);
    node5.addChildren([node8]);
    node6.addChildren([node9, node10]);

    // Level 4: leaf nodes
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: GraphView(root: node1),
      // backgroundColor: Colors.black,
    );
  }
}
