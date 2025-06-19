import 'package:flutter/material.dart';
import 'package:frontend/goal_tracking/entities/tree_node.dart';
import 'package:frontend/goal_tracking/widgets/graphview.dart';

class TreeScreen extends StatefulWidget {
  const TreeScreen({super.key});

  @override
  State<TreeScreen> createState() => _TreeScreenState();
}

class _TreeScreenState extends State<TreeScreen> {
  TreeNode node1 = TreeNode();
  TreeNode node2 = TreeNode();
  TreeNode node3 = TreeNode();
  TreeNode node4 = TreeNode();
  TreeNode node5 = TreeNode();
  TreeNode node6 = TreeNode();
  TreeNode node7 = TreeNode();
  TreeNode node8 = TreeNode();
  TreeNode node9 = TreeNode();
  TreeNode node10 = TreeNode();
  TreeNode node11 = TreeNode();
  TreeNode node12 = TreeNode();
  TreeNode node13 = TreeNode();

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
