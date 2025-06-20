import 'package:flutter/material.dart';
import 'package:frontend/providers/theme_provider.dart';
import 'package:provider/provider.dart';
import 'package:frontend/goal_tracking/configuration.dart';
import 'package:frontend/goal_tracking/entities/tree_node.dart';

class GoalWidget extends StatefulWidget {
  final TreeNode treeNode;
  final Offset offset;
  final VoidCallback? onChildAdded;
  final VoidCallback? onGoalDeleted;

  const GoalWidget({
    super.key,
    required this.offset,
    required this.treeNode,
    this.onChildAdded,
    this.onGoalDeleted,
  });

  @override
  State<GoalWidget> createState() => _GoalState();
}

class _GoalState extends State<GoalWidget> {
  late double left, top;
  bool isDragging = false;

  @override
  void initState() {
    super.initState();
    left = widget.offset.dx;
    top = widget.offset.dy;
  }

  @override
  void didUpdateWidget(GoalWidget oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.offset != widget.offset && !isDragging) {
      setState(() {
        left = widget.offset.dx;
        top = widget.offset.dy;
      });
    }
  }

  void _showGoalOptionsDialog() {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return Consumer<ThemeProvider>(
          builder: (context, themeProvider, child) {
            return AlertDialog(
              backgroundColor: themeProvider.isDarkMode
                  ? Colors.grey.shade900
                  : Colors.white,
              title: Text(
                'Goal Options',
                style: TextStyle(
                  color: themeProvider.isDarkMode ? Colors.white : Colors.black,
                  fontWeight: FontWeight.bold,
                ),
              ),
              content: Text(
                'What would you like to do with "${widget.treeNode.name}"?',
                style: TextStyle(
                  color: themeProvider.isDarkMode
                      ? Colors.white70
                      : Colors.black87,
                ),
              ),
              actions: [
                TextButton(
                  onPressed: () => Navigator.pop(context),
                  child: Text(
                    'Cancel',
                    style: TextStyle(
                      color: themeProvider.isDarkMode
                          ? Colors.white70
                          : Colors.black54,
                    ),
                  ),
                ),
                ElevatedButton.icon(
                  onPressed: () {
                    Navigator.pop(context);
                    _showCreateChildDialog();
                  },
                  icon: Icon(Icons.add),
                  label: Text('Add New Goal'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.blue,
                    foregroundColor: Colors.white,
                  ),
                ),
                ElevatedButton.icon(
                  onPressed: () {
                    Navigator.pop(context);
                    _showDeleteConfirmationDialog();
                  },
                  icon: Icon(Icons.delete),
                  label: Text('Delete Goal'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.red,
                    foregroundColor: Colors.white,
                  ),
                ),
              ],
            );
          },
        );
      },
    );
  }

  void _showDeleteConfirmationDialog() {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return Consumer<ThemeProvider>(
          builder: (context, themeProvider, child) {
            return AlertDialog(
              backgroundColor: themeProvider.isDarkMode
                  ? Colors.grey.shade900
                  : Colors.white,
              title: Text(
                'Delete Goal',
                style: TextStyle(
                  color: themeProvider.isDarkMode ? Colors.white : Colors.black,
                  fontWeight: FontWeight.bold,
                ),
              ),
              content: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Are you sure you want to delete "${widget.treeNode.name}"?',
                    style: TextStyle(
                      color: themeProvider.isDarkMode
                          ? Colors.white70
                          : Colors.black87,
                    ),
                  ),
                  SizedBox(height: 8),
                ],
              ),
              actions: [
                TextButton(
                  onPressed: () => Navigator.pop(context),
                  child: Text(
                    'Cancel',
                    style: TextStyle(
                      color: themeProvider.isDarkMode
                          ? Colors.white70
                          : Colors.black54,
                    ),
                  ),
                ),
                ElevatedButton(
                  onPressed: () {
                    Navigator.pop(context);
                    _deleteGoal();
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.red,
                    foregroundColor: Colors.white,
                  ),
                  child: Text('Delete'),
                ),
              ],
            );
          },
        );
      },
    );
  }

  void _deleteGoal() {
    print(widget.treeNode.parent);
    if (widget.treeNode.parent != null) {
      widget.treeNode.parent!.removeChild(widget.treeNode);
    }
    print(widget.treeNode.parent);

    if (widget.onGoalDeleted != null) {
      widget.onGoalDeleted!();
    }

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Goal "${widget.treeNode.name}" deleted successfully!'),
        backgroundColor: Colors.red,
        duration: Duration(seconds: 2),
      ),
    );
  }

  void _showCreateChildDialog() {
    final nameController = TextEditingController();
    final descriptionController = TextEditingController();
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return Consumer<ThemeProvider>(
          builder: (context, themeProvider, child) {
            return AlertDialog(
              backgroundColor: themeProvider.isDarkMode
                  ? Colors.grey.shade900
                  : Colors.white,
              title: Text(
                'Create Child Goal',
                style: TextStyle(
                  color: themeProvider.isDarkMode ? Colors.white : Colors.black,
                  fontWeight: FontWeight.bold,
                ),
              ),
              content: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  TextField(
                    controller: nameController,
                    style: TextStyle(
                      color: themeProvider.isDarkMode
                          ? Colors.white
                          : Colors.black,
                    ),
                    decoration: InputDecoration(
                      labelText: 'Goal Name',
                      labelStyle: TextStyle(
                        color: themeProvider.isDarkMode
                            ? Colors.white70
                            : Colors.black54,
                      ),
                      border: OutlineInputBorder(),
                    ),
                  ),
                  SizedBox(height: 16),
                ],
              ),
              actions: [
                TextButton(
                  onPressed: () => Navigator.pop(context),
                  child: Text(
                    'Cancel',
                    style: TextStyle(
                      color: themeProvider.isDarkMode
                          ? Colors.white70
                          : Colors.black54,
                    ),
                  ),
                ),
                ElevatedButton(
                  onPressed: () {
                    if (nameController.text.trim().isNotEmpty) {
                      _createChildGoal(
                        nameController.text.trim(),
                        descriptionController.text.trim(),
                      );
                      Navigator.pop(context);
                    }
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.blue,
                    foregroundColor: Colors.white,
                  ),
                  child: Text('Create'),
                ),
              ],
            );
          },
        );
      },
    );
  }

  void _createChildGoal(String name, String description) {
    final childNode = TreeNode(name: name);
    widget.treeNode.addChild(childNode);

    if (widget.onChildAdded != null) {
      widget.onChildAdded!();
    }

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Child goal "$name" created successfully!'),
        backgroundColor: Colors.green,
        duration: Duration(seconds: 2),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Positioned(
      left: left,
      top: top,
      child: Consumer<ThemeProvider>(
        builder: (context, themeProvider, child) {
          return GestureDetector(
            onPanStart: (_) => isDragging = true,
            onPanUpdate: (details) {
              setState(() {
                left += details.delta.dx;
                top += details.delta.dy;
              });
            },
            onPanEnd: (_) {
              setState(() {
                isDragging = false;
                left = widget.offset.dx;
                top = widget.offset.dy;
              });
            },
            onLongPress: _showGoalOptionsDialog,
            child: Container(
              width: GOAL_WIDGET_WIDTH,
              height: GOAL_WIDGET_HEIGHT,
              decoration: BoxDecoration(
                color: themeProvider.isDarkMode
                    ? Colors.grey.shade900
                    : Colors.white,
                borderRadius: BorderRadius.circular(8),
                border: Border.all(
                  color: themeProvider.isDarkMode
                      ? Colors.white24
                      : Colors.black12,
                  width: 1,
                ),
                boxShadow: [
                  BoxShadow(
                    color:
                        (themeProvider.isDarkMode ? Colors.black : Colors.grey)
                            .withOpacity(0.1),
                    blurRadius: 4,
                    offset: Offset(0, 2),
                  ),
                ],
              ),
              child: Padding(
                padding: EdgeInsets.all(8),
                child: Center(
                  child: Text(
                    widget.treeNode.name ?? "Goal Name",
                    style: TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.w500,
                      color: themeProvider.isDarkMode
                          ? Colors.white
                          : Colors.black,
                    ),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    textAlign: TextAlign.center,
                  ),
                ),
              ),
            ),
          );
        },
      ),
    );
  }
}
