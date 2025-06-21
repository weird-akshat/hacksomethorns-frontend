import 'package:flutter/material.dart';
import 'package:frontend/api_methods/delete_user_goal.dart';
import 'package:frontend/api_methods/post_goal_from_treenode.dart';
import 'package:frontend/api_methods/updateGoal.dart';
import 'package:frontend/goal_tracking/pages/goal_report_screen.dart';
import 'package:frontend/goal_tracking/pages/goal_root_page.dart';
import 'package:frontend/providers/theme_provider.dart';
import 'package:provider/provider.dart';
import 'package:frontend/goal_tracking/configuration.dart';
import 'package:frontend/goal_tracking/entities/tree_node.dart';

import 'package:http/http.dart' as http;

class GoalWidget extends StatefulWidget {
  final TreeNode treeNode;
  // final TreeNode id;
  final Offset offset;
  final VoidCallback? onChildAdded;
  final VoidCallback? onGoalDeleted;
  final VoidCallback? onGoalUpdated;
  final VoidCallback? onParentChanged;
  final List<TreeNode>? availableParents;
  final int userId; // Added userId

  const GoalWidget({
    super.key,
    required this.offset,
    required this.treeNode,
    this.onChildAdded,
    this.onGoalDeleted,
    this.onGoalUpdated,
    this.onParentChanged,
    this.availableParents,
    // this.id,
    required this.userId, // Required for API calls
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
                ElevatedButton.icon(
                  onPressed: () {
                    Navigator.pop(context);
                    _showChangeParentDialog();
                  },
                  icon: Icon(Icons.swap_vert),
                  label: Text('Change Parent'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.orange,
                    foregroundColor: Colors.white,
                  ),
                ),
                ElevatedButton.icon(
                  onPressed: () {
                    Navigator.pop(context);
                    _showUpdateGoalDialog();
                  },
                  icon: Icon(Icons.edit),
                  label: Text('Update Goal'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.green,
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

  Future<void> _deleteGoal() async {
    try {
      await deleteUserGoal(
        userId: widget.userId,
        goalId: widget.treeNode.id!,
      );

      if (widget.treeNode.parent != null) {
        widget.treeNode.parent!.removeChild(widget.treeNode);
      }

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
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Failed to delete goal: $e'),
          backgroundColor: Colors.red,
          duration: Duration(seconds: 2),
        ),
      );
    }
  }

  void _showCreateChildDialog() {
    final nameController = TextEditingController();
    final descriptionController = TextEditingController();
    String priority = 'medium';
    String status = 'active';
    DateTime? deadline;
    bool isGroupGoal = false;

    showDialog(
      context: context,
      builder: (BuildContext context) {
        return Consumer<ThemeProvider>(
          builder: (context, themeProvider, child) {
            return StatefulBuilder(
              builder: (context, setState) {
                return AlertDialog(
                  backgroundColor: themeProvider.isDarkMode
                      ? Colors.grey.shade900
                      : Colors.white,
                  title: Text(
                    'Create Child Goal',
                    style: TextStyle(
                      color: themeProvider.isDarkMode
                          ? Colors.white
                          : Colors.black,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  content: SingleChildScrollView(
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        TextField(
                          controller: nameController,
                          decoration: InputDecoration(labelText: 'Goal Name'),
                        ),
                        SizedBox(height: 8),
                        TextField(
                          controller: descriptionController,
                          decoration: InputDecoration(labelText: 'Description'),
                        ),
                        SizedBox(height: 8),
                        DropdownButtonFormField<String>(
                          value: priority,
                          decoration: InputDecoration(labelText: 'Priority'),
                          items: ['high', 'urgent', 'medium', 'low']
                              .map((e) => DropdownMenuItem(
                                    value: e,
                                    child: Text(e),
                                  ))
                              .toList(),
                          onChanged: (val) => setState(() => priority = val!),
                        ),
                        SizedBox(height: 8),
                        DropdownButtonFormField<String>(
                          value: status,
                          decoration: InputDecoration(labelText: 'Status'),
                          items: ['active', 'completed']
                              .map((e) => DropdownMenuItem(
                                    value: e,
                                    child: Text(e),
                                  ))
                              .toList(),
                          onChanged: (val) => setState(() => status = val!),
                        ),
                        SizedBox(height: 8),
                        Row(
                          children: [
                            Text('Deadline:'),
                            SizedBox(width: 8),
                            Text(deadline != null
                                ? '${deadline!.year}-${deadline!.month}-${deadline!.day}'
                                : 'Not set'),
                            Spacer(),
                            IconButton(
                              icon: Icon(Icons.calendar_today),
                              onPressed: () async {
                                final picked = await showDatePicker(
                                  context: context,
                                  initialDate: DateTime.now(),
                                  firstDate: DateTime(2000),
                                  lastDate: DateTime(2100),
                                );
                                if (picked != null) {
                                  setState(() => deadline = picked);
                                }
                              },
                            ),
                          ],
                        ),
                        Row(
                          children: [
                            Checkbox(
                              value: isGroupGoal,
                              onChanged: (val) =>
                                  setState(() => isGroupGoal = val!),
                            ),
                            Text('Is Group Goal'),
                          ],
                        ),
                      ],
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
                    ElevatedButton(
                      onPressed: () async {
                        if (nameController.text.trim().isNotEmpty) {
                          final childNode = TreeNode(
                            id: 0,
                            name: nameController.text.trim(),
                          )
                            ..description = descriptionController.text
                            ..priority = priority
                            ..status = status
                            ..deadline = deadline?.toIso8601String()
                            ..isGroupGoal = isGroupGoal
                            ..parentId = widget.treeNode.id;

                          try {
                            await postGoalFromTreeNode(
                              childNode,
                              widget.userId,
                            );
                            widget.treeNode.addChild(childNode);
                            if (widget.onChildAdded != null) {
                              widget.onChildAdded!();
                            }
                            Navigator.pop(context);
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(
                                content: Text('Child goal created!'),
                                backgroundColor: Colors.green,
                              ),
                            );
                          } catch (e) {
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(
                                content: Text('Failed to create goal: $e'),
                                backgroundColor: Colors.red,
                              ),
                            );
                          }
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
      },
    );
  }

  void _showChangeParentDialog() {
    TreeNode? selectedParent = widget.treeNode.parent;
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
                'Change Parent',
                style: TextStyle(
                  color: themeProvider.isDarkMode ? Colors.white : Colors.black,
                  fontWeight: FontWeight.bold,
                ),
              ),
              content: DropdownButton<TreeNode>(
                value: selectedParent,
                isExpanded: true,
                items: (widget.availableParents ?? [])
                    .where((node) => node != widget.treeNode)
                    .map((node) {
                  return DropdownMenuItem<TreeNode>(
                    value: node,
                    child: Text(node.name ?? 'Unnamed'),
                  );
                }).toList(),
                onChanged: (TreeNode? newValue) {
                  setState(() {
                    selectedParent = newValue;
                  });
                },
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
                  onPressed: selectedParent != null &&
                          selectedParent != widget.treeNode.parent
                      ? () {
                          if (widget.treeNode.parent != null) {
                            widget.treeNode.parent!
                                .removeChild(widget.treeNode);
                          }
                          selectedParent!.addChild(widget.treeNode);
                          setState(() {});
                          Navigator.pop(context);

                          if (widget.onParentChanged != null) {
                            widget.onParentChanged!();
                          }

                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(
                              content: Text('Parent changed successfully!'),
                              backgroundColor: Colors.orange,
                              duration: Duration(seconds: 2),
                            ),
                          );
                        }
                      : null,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.orange,
                    foregroundColor: Colors.white,
                  ),
                  child: Text('Change'),
                ),
              ],
            );
          },
        );
      },
    );
  }

  void _showUpdateGoalDialog() {
    final nameController = TextEditingController(text: widget.treeNode.name);
    final descriptionController =
        TextEditingController(text: widget.treeNode.description ?? '');
    String priority = widget.treeNode.priority;
    String status = widget.treeNode.status;
    DateTime? deadline = widget.treeNode.deadline != null
        ? DateTime.tryParse(widget.treeNode.deadline!)
        : null;
    bool isGroupGoal = widget.treeNode.isGroupGoal;

    showDialog(
      context: context,
      builder: (BuildContext context) {
        return Consumer<ThemeProvider>(
          builder: (context, themeProvider, child) {
            return StatefulBuilder(
              builder: (context, setState) {
                return AlertDialog(
                  backgroundColor: themeProvider.isDarkMode
                      ? Colors.grey.shade900
                      : Colors.white,
                  title: Text(
                    'Update Goal',
                    style: TextStyle(
                      color: themeProvider.isDarkMode
                          ? Colors.white
                          : Colors.black,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  content: SingleChildScrollView(
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        TextField(
                          controller: nameController,
                          decoration: InputDecoration(labelText: 'Goal Name'),
                        ),
                        SizedBox(height: 8),
                        TextField(
                          controller: descriptionController,
                          decoration: InputDecoration(labelText: 'Description'),
                        ),
                        SizedBox(height: 8),
                        DropdownButtonFormField<String>(
                          value: priority,
                          decoration: InputDecoration(labelText: 'Priority'),
                          items: ['high', 'urgent', 'medium', 'low']
                              .map((e) => DropdownMenuItem(
                                    value: e,
                                    child: Text(e),
                                  ))
                              .toList(),
                          onChanged: (val) => setState(() => priority = val!),
                        ),
                        SizedBox(height: 8),
                        DropdownButtonFormField<String>(
                          value: status,
                          decoration: InputDecoration(labelText: 'Status'),
                          items: ['active', 'completed']
                              .map((e) => DropdownMenuItem(
                                    value: e,
                                    child: Text(e),
                                  ))
                              .toList(),
                          onChanged: (val) => setState(() => status = val!),
                        ),
                        SizedBox(height: 8),
                        Row(
                          children: [
                            Text('Deadline:'),
                            SizedBox(width: 8),
                            Text(deadline != null
                                ? '${deadline!.year}-${deadline!.month}-${deadline!.day}'
                                : 'Not set'),
                            Spacer(),
                            IconButton(
                              icon: Icon(Icons.calendar_today),
                              onPressed: () async {
                                final picked = await showDatePicker(
                                  context: context,
                                  initialDate: deadline ?? DateTime.now(),
                                  firstDate: DateTime(2000),
                                  lastDate: DateTime(2100),
                                );
                                if (picked != null) {
                                  setState(() => deadline = picked);
                                }
                              },
                            ),
                          ],
                        ),
                        Row(
                          children: [
                            Checkbox(
                              value: isGroupGoal,
                              onChanged: (val) =>
                                  setState(() => isGroupGoal = val!),
                            ),
                            Text('Is Group Goal'),
                          ],
                        ),
                      ],
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
                    ElevatedButton(
                      onPressed: () async {
                        if (nameController.text.trim().isNotEmpty) {
                          widget.treeNode.name = nameController.text.trim();
                          widget.treeNode.description =
                              descriptionController.text;
                          widget.treeNode.priority = priority;
                          widget.treeNode.status = status;
                          widget.treeNode.deadline =
                              deadline?.toIso8601String();
                          widget.treeNode.isGroupGoal = isGroupGoal;

                          try {
                            await updateGoalFromNode(
                              userId: widget.userId,
                              goalId: widget.treeNode.id!,
                              node: widget.treeNode,
                            );
                            if (widget.onGoalUpdated != null) {
                              widget.onGoalUpdated!();
                            }
                            Navigator.pop(context);
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(
                                content: Text('Goal updated!'),
                                backgroundColor: Colors.green,
                              ),
                            );
                          } catch (e) {
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(
                                content: Text('Failed to update goal: $e'),
                                backgroundColor: Colors.red,
                              ),
                            );
                          }
                        }
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.green,
                        foregroundColor: Colors.white,
                      ),
                      child: Text('Update'),
                    ),
                  ],
                );
              },
            );
          },
        );
      },
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
            onTap: () {
              Navigator.of(context).push(MaterialPageRoute(
                  builder: (builder) =>
                      GoalReportScreen(goal: widget.treeNode)));
            },
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
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
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
                    SizedBox(height: 4),
                    if (widget.treeNode.deadline != null)
                      Text(
                        'Deadline: ${widget.treeNode.deadline!.split('T')[0]}',
                        style: TextStyle(
                          fontSize: 9,
                          color: themeProvider.isDarkMode
                              ? Colors.white70
                              : Colors.black54,
                        ),
                      ),
                    SizedBox(height: 2),
                    Text(
                      'Priority: ${widget.treeNode.priority}',
                      style: TextStyle(
                        fontSize: 9,
                        color: themeProvider.isDarkMode
                            ? Colors.white70
                            : Colors.black54,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          );
        },
      ),
    );
  }
}
