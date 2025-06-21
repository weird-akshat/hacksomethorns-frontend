// goal_root_page.dart

import 'package:flutter/material.dart';
import 'package:frontend/api_methods/fetch_goal_tree.dart';
import 'package:frontend/api_methods/delete_user_goal.dart';
import 'package:frontend/api_methods/post_goal_from_treenode.dart';
import 'package:frontend/goal_tracking/configuration.dart';
import 'package:frontend/goal_tracking/entities/tree_node.dart';
import 'package:frontend/providers/theme_provider.dart';
import 'package:provider/provider.dart';

class GoalRootPage extends StatefulWidget {
  const GoalRootPage({super.key});

  @override
  State<GoalRootPage> createState() => _GoalRootPageState();
}

class _GoalRootPageState extends State<GoalRootPage> {
  void _showCreateRootGoalDialog(BuildContext context, String userId,
      {VoidCallback? onGoalAdded}) {
    final nameController = TextEditingController();
    String priority = 'medium';
    String status = 'active';
    DateTime? deadline;
    bool isGroupGoal = false;

    showDialog(
      context: context,
      builder: (BuildContext context) {
        bool isLoading = false;

        return Consumer<ThemeProvider>(
          builder: (context, themeProvider, child) {
            return StatefulBuilder(
              builder: (context, setState) {
                return AlertDialog(
                  backgroundColor: themeProvider.isDarkMode
                      ? Colors.grey.shade900
                      : Colors.white,
                  title: Text(
                    'Create Root Goal',
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
                          enabled: !isLoading,
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
                          onChanged: isLoading
                              ? null
                              : (val) => setState(() => priority = val!),
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
                          onChanged: isLoading
                              ? null
                              : (val) => setState(() => status = val!),
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
                              onPressed: isLoading
                                  ? null
                                  : () async {
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
                        if (isLoading) ...[
                          SizedBox(height: 16),
                          Row(
                            children: [
                              SizedBox(
                                width: 16,
                                height: 16,
                                child: CircularProgressIndicator(
                                  strokeWidth: 2,
                                  color: themeProvider.isDarkMode
                                      ? Colors.white70
                                      : Colors.black54,
                                ),
                              ),
                              SizedBox(width: 8),
                              Text(
                                'Creating goal...',
                                style: TextStyle(
                                  color: themeProvider.isDarkMode
                                      ? Colors.white70
                                      : Colors.black54,
                                ),
                              ),
                            ],
                          ),
                        ],
                      ],
                    ),
                  ),
                  actions: [
                    TextButton(
                      onPressed:
                          isLoading ? null : () => Navigator.pop(context),
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
                      onPressed: isLoading
                          ? null
                          : () async {
                              if (nameController.text.trim().isNotEmpty) {
                                setState(() => isLoading = true);
                                final rootGoal = TreeNode(
                                  id: 0,
                                  name: nameController.text.trim(),
                                )
                                  ..description = ''
                                  ..priority = priority
                                  ..status = status
                                  ..deadline = deadline
                                  ..isGroupGoal = isGroupGoal
                                  ..parentId = null; // No parent for root

                                try {
                                  final TreeNode returnedGoal =
                                      await postGoalFromTreeNode(
                                    rootGoal,
                                    "1",
                                  );
                                  if (onGoalAdded != null) {
                                    onGoalAdded();
                                  }
                                  Navigator.pop(context);
                                  if (context.mounted) {
                                    ScaffoldMessenger.of(context).showSnackBar(
                                      SnackBar(
                                        content: Text('Root goal created!'),
                                        backgroundColor: Colors.green,
                                      ),
                                    );
                                  }
                                } catch (e) {
                                  if (context.mounted) {
                                    ScaffoldMessenger.of(context).showSnackBar(
                                      SnackBar(
                                        content:
                                            Text('Failed to create goal: $e'),
                                        backgroundColor: Colors.red,
                                      ),
                                    );
                                  }
                                } finally {
                                  if (context.mounted) {
                                    setState(() => isLoading = false);
                                  }
                                }
                              }
                            },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.blue,
                        foregroundColor: Colors.white,
                      ),
                      child: isLoading
                          ? SizedBox(
                              width: 18,
                              height: 18,
                              child: CircularProgressIndicator(
                                strokeWidth: 2,
                                color: Colors.white,
                              ),
                            )
                          : Text('Create'),
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

  bool _isLoading = true;
  String? _error;
  List<TreeNode> list = [];
  final TextEditingController _goalController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _fetchGoals();
  }

  Future<void> _fetchGoals() async {
    setState(() {
      _isLoading = true;
      _error = null;
    });
    try {
      final fetchedList =
          await fetchGoalTree("1"); // Replace with actual user ID
      setState(() {
        list = fetchedList;
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _error = e.toString();
        _isLoading = false;
      });
    }
  }

  Future<void> _addGoal(String name) async {
    setState(() => _isLoading = true);
    try {
      final newGoal = TreeNode(
        id: 0,
        name: name,
      );
      final created = await postGoalFromTreeNode(
          newGoal, "1"); // Replace with actual user ID
      setState(() {
        list.add(created);
        _isLoading = false;
      });
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
            content: Text('Goal "$name" added!'),
            backgroundColor: Colors.green),
      );
    } catch (e) {
      setState(() => _isLoading = false);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
            content: Text('Failed to add goal: $e'),
            backgroundColor: Colors.red),
      );
    }
  }

  Future<void> _deleteGoal(TreeNode node) async {
    setState(() => _isLoading = true);
    try {
      await deleteUserGoal(
          userId: "1", goalId: node.id!); // Replace with actual user ID
      setState(() {
        list.removeWhere((g) => g.id == node.id);
        _isLoading = false;
      });
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
            content: Text('Goal "${node.name}" deleted!'),
            backgroundColor: Colors.red),
      );
    } catch (e) {
      setState(() => _isLoading = false);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
            content: Text('Failed to delete goal: $e'),
            backgroundColor: Colors.red),
      );
    }
  }

  void _showAddGoalDialog() {
    _goalController.clear();
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          backgroundColor: const Color(0xFF2D3748),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
            side: BorderSide(color: Colors.white.withOpacity(0.15), width: 1),
          ),
          title: const Text('Add New Goal',
              style: TextStyle(
                  color: Colors.white,
                  fontSize: 22,
                  fontWeight: FontWeight.bold)),
          content: TextField(
            controller: _goalController,
            autofocus: true,
            style: const TextStyle(color: Colors.white, fontSize: 16),
            decoration: InputDecoration(
              hintText: 'Enter your goal...',
              hintStyle:
                  TextStyle(color: Colors.white.withOpacity(0.6), fontSize: 16),
              enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide:
                    BorderSide(color: Colors.white.withOpacity(0.3), width: 1),
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: const BorderSide(color: Colors.white, width: 1.5),
              ),
              filled: true,
              fillColor: Colors.white.withOpacity(0.1),
              contentPadding:
                  const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: Text('Cancel',
                  style: TextStyle(color: Colors.white.withOpacity(0.7))),
            ),
            ElevatedButton(
              onPressed: () {
                final name = _goalController.text.trim();
                if (name.isNotEmpty) {
                  Navigator.of(context).pop();
                  _addGoal(name);
                }
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.grey[600],
                foregroundColor: Colors.black,
                elevation: 2,
                padding:
                    const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8)),
              ),
              child: const Text('Add Goal',
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
            ),
          ],
        );
      },
    );
  }

  @override
  void dispose() {
    _goalController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final themeProvider = Provider.of<ThemeProvider>(context, listen: false);
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        backgroundColor: Colors.grey[600],
        elevation: 2,
        centerTitle: true,
        title: const Text(
          'Main Goals',
          style: TextStyle(
            color: Colors.black,
            fontSize: 26,
            fontWeight: FontWeight.bold,
            letterSpacing: 0.5,
          ),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh, color: Colors.black, size: 28),
            onPressed: _fetchGoals,
            tooltip: "Reset Page",
          ),
          IconButton(
            icon: const Icon(Icons.add, color: Colors.black, size: 28),
            onPressed: () {
              _showCreateRootGoalDialog(context, "1");
            },
          ),
        ],
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : _error != null
              ? Center(
                  child: Text('Error: $_error',
                      style: const TextStyle(color: Colors.red)))
              : Padding(
                  padding: const EdgeInsets.all(20.0),
                  child: Center(
                    child: ListView.separated(
                      shrinkWrap: true,
                      itemCount: list.length,
                      separatorBuilder: (context, index) =>
                          const SizedBox(height: 20),
                      itemBuilder: (context, index) {
                        final goal = list[index];
                        return RootGoalWidget(
                          treeNode: goal,
                          offset: Offset(
                            MediaQuery.of(context).size.width / 2,
                            MediaQuery.of(context).size.height *
                                (index + 1) /
                                (list.length + 1),
                          ),
                          onGoalDeleted: () => _deleteGoal(goal),
                        );
                      },
                    ),
                  ),
                ),
    );
  }
}

class RootGoalWidget extends StatefulWidget {
  final TreeNode treeNode;
  final Offset offset;
  final VoidCallback? onGoalDeleted;

  const RootGoalWidget({
    super.key,
    required this.offset,
    required this.treeNode,
    this.onGoalDeleted,
  });

  @override
  State<RootGoalWidget> createState() => _RootGoalWidgetState();
}

class _RootGoalWidgetState extends State<RootGoalWidget> {
  late double left, top;
  bool isDragging = false;

  @override
  void initState() {
    super.initState();
    left = widget.offset.dx;
    top = widget.offset.dy;
  }

  @override
  void didUpdateWidget(RootGoalWidget oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.offset != widget.offset && !isDragging) {
      setState(() {
        left = widget.offset.dx;
        top = widget.offset.dy;
      });
    }
  }

  void _showDeleteDialog() {
    showDialog(
      context: context,
      builder: (context) {
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
              content: Text(
                'Are you sure you want to delete "${widget.treeNode.name}"?',
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
                ElevatedButton(
                  onPressed: () {
                    Navigator.pop(context);
                    if (widget.onGoalDeleted != null) widget.onGoalDeleted!();
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.red,
                    foregroundColor: Colors.white,
                  ),
                  child: const Text('Delete'),
                ),
              ],
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
            behavior: HitTestBehavior.translucent,
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
            onLongPress: _showDeleteDialog,
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
                    offset: const Offset(0, 2),
                  ),
                ],
              ),
              child: Padding(
                padding: const EdgeInsets.all(8),
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
