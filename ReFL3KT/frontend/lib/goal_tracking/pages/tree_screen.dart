import 'package:flutter/material.dart';
import 'package:frontend/goal_tracking/entities/tree_node.dart';
import 'package:frontend/goal_tracking/widgets/graphview.dart';

class TreeScreen extends StatefulWidget {
  final TreeNode node;
  const TreeScreen({super.key, required this.node});

  @override
  State<TreeScreen> createState() => _TreeScreenState();
}

class _TreeScreenState extends State<TreeScreen> {
  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: GraphView(root: widget.node),
      // backgroundColor: Colors.black,
    );
  }
}
