import 'package:flutter/material.dart';
import 'package:frontend/goal_tracking/configuration.dart';
import 'package:frontend/goal_tracking/entities/tree_node.dart';
// import 'package:getwidget/components/list_tile/gf_list_tile.dart';

//Goal class will have a treeNode,
class GoalWidget extends StatefulWidget {
  final TreeNode treeNode;
  final Offset offset;
  const GoalWidget({super.key, required this.offset, required this.treeNode});

  @override
  State<GoalWidget> createState() => _GoalState();
}

class _GoalState extends State<GoalWidget> {
  late double left, top;
  @override
  void initState() {
    super.initState();
    left = widget.offset.dx;
    top = widget.offset.dy;
  }

  @override
  Widget build(BuildContext context) {
    return Positioned(
        left: left,
        top: top,
        child: GestureDetector(
          onPanUpdate: (details) {
            setState(() {
              left += details.delta.dx;
              top += details.delta.dy;
            });
          },
          onPanEnd: (details) {
            setState(() {
              left = widget.offset.dx;
              top = widget.offset.dy;
            });
          },
          child: Card(
              color: Colors.white,
              child: Container(
                width: GOAL_WIDGET_WIDTH,
                height: GOAL_WIDGET_HEIGHT,
                child: Column(
                  children: [Text("Goal Name")],
                ),
              )),
        ));
  }
}
