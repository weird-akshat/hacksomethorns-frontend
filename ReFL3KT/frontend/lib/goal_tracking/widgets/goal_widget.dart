import 'package:flutter/material.dart';
import 'package:frontend/api_methods/delete_user_goal.dart';
import 'package:frontend/api_methods/post_goal_from_treenode.dart';
import 'package:frontend/api_methods/updateGoal.dart';
import 'package:frontend/goal_tracking/pages/goal_report_screen.dart';
import 'package:frontend/goal_tracking/pages/goal_root_page.dart';
import 'package:frontend/providers/theme_provider.dart';
import 'package:frontend/providers/user_provider.dart';
import 'package:provider/provider.dart';
import 'package:frontend/goal_tracking/configuration.dart';
import 'package:frontend/goal_tracking/entities/tree_node.dart';

import 'package:http/http.dart' as http;

class GoalWidget extends StatefulWidget {
  final TreeNode treeNode;
  final Offset offset;
  final VoidCallback? onChildAdded;
  final VoidCallback? onGoalDeleted;
  final VoidCallback? onGoalUpdated;
  final VoidCallback? onParentChanged;
  final List<TreeNode>? availableParents;
  final String userId;

  const GoalWidget({
    super.key,
    required this.offset,
    required this.treeNode,
    this.onChildAdded,
    this.onGoalDeleted,
    this.onGoalUpdated,
    this.onParentChanged,
    this.availableParents,
    required this.userId,
  });

  @override
  State<GoalWidget> createState() => _GoalState();
}

class _GoalState extends State<GoalWidget> {
  late double left, top;
  bool isDragging = false;
  // bool isDeleting = false; // For delete button

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
            final isDark = themeProvider.isDarkMode;
            return AlertDialog(
              backgroundColor: isDark ? Colors.grey.shade900 : Colors.white,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(20),
              ),
              titlePadding: EdgeInsets.fromLTRB(24, 20, 24, 10),
              contentPadding: EdgeInsets.fromLTRB(24, 10, 24, 24),
              title: Text(
                'Goal Options',
                style: TextStyle(
                  color: isDark ? Colors.white : Colors.black,
                  fontWeight: FontWeight.w600,
                  fontSize: 20,
                ),
              ),
              content: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'What would you like to do with:',
                    style: TextStyle(
                      color: isDark ? Colors.white70 : Colors.black87,
                      fontSize: 14.5,
                    ),
                  ),
                  SizedBox(height: 4),
                  Text(
                    '"${widget.treeNode.name}"',
                    style: TextStyle(
                      color: isDark ? Colors.white : Colors.black,
                      fontWeight: FontWeight.bold,
                      fontSize: 16,
                    ),
                  ),
                  SizedBox(height: 24),
                  ElevatedButton.icon(
                    onPressed: () {
                      Navigator.pop(context);
                      _showCreateChildGoalDialog(context);
                    },
                    icon: Icon(Icons.add, size: 20),
                    label: Text('Add New Goal'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.blue,
                      foregroundColor: Colors.white,
                      minimumSize: Size(double.infinity, 50),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                  ),
                  SizedBox(height: 12),
                  ElevatedButton.icon(
                    onPressed: () {
                      Navigator.pop(context);
                      _showUpdateGoalDialog();
                    },
                    icon: Icon(Icons.edit, size: 20),
                    label: Text('Update Goal'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.green,
                      foregroundColor: Colors.white,
                      minimumSize: Size(double.infinity, 50),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                  ),
                  SizedBox(height: 12),
                  ElevatedButton.icon(
                    onPressed: () {
                      Navigator.pop(context);
                      _showDeleteConfirmationDialog();
                    },
                    icon: Icon(Icons.delete, size: 20),
                    label: Text('Delete Goal'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.red,
                      foregroundColor: Colors.white,
                      minimumSize: Size(double.infinity, 50),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                  ),
                ],
              ),
              actions: [
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 8),
                  child: OutlinedButton(
                    onPressed: () => Navigator.pop(context),
                    style: OutlinedButton.styleFrom(
                      side: BorderSide(
                        color: isDark ? Colors.white38 : Colors.black26,
                      ),
                      foregroundColor: isDark ? Colors.white70 : Colors.black54,
                      minimumSize: Size(double.infinity, 44),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10),
                      ),
                    ),
                    child: Text('Cancel'),
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
            bool isDeleting = false;
            return StatefulBuilder(
              builder: (context, setState) {
                // bool isDeleting = false; // Local loading state for delete
                return AlertDialog(
                  backgroundColor: themeProvider.isDarkMode
                      ? Colors.grey.shade900
                      : Colors.white,
                  title: Text(
                    'Delete Goal',
                    style: TextStyle(
                      color: themeProvider.isDarkMode
                          ? Colors.white
                          : Colors.black,
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
                      if (isDeleting)
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
                              'Deleting goal...',
                              style: TextStyle(
                                color: themeProvider.isDarkMode
                                    ? Colors.white70
                                    : Colors.black54,
                              ),
                            ),
                          ],
                        ),
                    ],
                  ),
                  actions: [
                    TextButton(
                      onPressed:
                          isDeleting ? null : () => Navigator.pop(context),
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
                      onPressed: isDeleting
                          ? null
                          : () async {
                              setState(() => isDeleting = true);
                              try {
                                await _deleteGoal();
                                Navigator.pop(context);
                              } catch (e) {
                                // Error is already handled in _deleteGoal
                              } finally {
                                if (mounted) {
                                  setState(() => isDeleting = false);
                                }
                              }
                            },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.red,
                        foregroundColor: Colors.white,
                      ),
                      child: isDeleting
                          ? SizedBox(
                              width: 18,
                              height: 18,
                              child: CircularProgressIndicator(
                                strokeWidth: 2,
                                color: Colors.white,
                              ),
                            )
                          : Text('Delete'),
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

  Future<void> _deleteGoal() async {
    try {
      await deleteUserGoal(
        userId: Provider.of<UserProvider>(context, listen: false).userId!,
        goalId: widget.treeNode.id!,
      );

      if (widget.treeNode.parent != null) {
        widget.treeNode.parent!.removeChild(widget.treeNode);
      }

      if (widget.onGoalDeleted != null) {
        widget.onGoalDeleted!();
      }

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content:
                Text('Goal "${widget.treeNode.name}" deleted successfully!'),
            backgroundColor: Colors.red,
            duration: Duration(seconds: 2),
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Failed to delete goal: $e'),
            backgroundColor: Colors.red,
            duration: Duration(seconds: 2),
          ),
        );
      }
      rethrow; // Re-throw to handle in the calling function
    }
  }

  Widget _buildAnimatedTextField({
    required TextEditingController controller,
    required String label,
    required IconData icon,
    required ThemeProvider themeProvider,
    required bool enabled,
  }) {
    return TweenAnimationBuilder<double>(
      tween: Tween(begin: 0.0, end: 1.0),
      duration: const Duration(milliseconds: 500),
      curve: Curves.easeOutBack,
      builder: (context, value, child) {
        return Transform.translate(
          offset: Offset(0, 20 * (1 - value)),
          child: Opacity(
            opacity: value.clamp(0.0, 1.0),
            child: Container(
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(12),
                border: Border.all(
                  color: themeProvider.borderColor.withOpacity(0.3),
                ),
              ),
              child: TextField(
                controller: controller,
                enabled: enabled,
                style: TextStyle(color: themeProvider.textColor),
                decoration: InputDecoration(
                  labelText: label,
                  labelStyle: TextStyle(
                      color: themeProvider.textColor.withOpacity(0.7)),
                  prefixIcon: Icon(icon, color: themeProvider.primaryAccent),
                  border: InputBorder.none,
                  contentPadding: const EdgeInsets.all(16),
                ),
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _buildDatePicker({
    required DateTime? deadline,
    required ThemeProvider themeProvider,
    required bool enabled,
    required void Function(DateTime date) onDateSelected,
  }) {
    return GestureDetector(
      onTap: enabled
          ? () async {
              final DateTime? pickedDate = await showDatePicker(
                context: context,
                initialDate: deadline ?? DateTime.now(),
                firstDate: DateTime(2000),
                lastDate: DateTime(2100),
                builder: (BuildContext context, Widget? child) {
                  return Theme(
                    data: ThemeData.dark().copyWith(
                      colorScheme: ColorScheme.dark(
                        primary: themeProvider.primaryAccent,
                        surface: themeProvider.cardColor,
                        onSurface: themeProvider.textColor,
                      ),
                      dialogBackgroundColor: themeProvider.cardColor,
                      textButtonTheme: TextButtonThemeData(
                        style: TextButton.styleFrom(
                          foregroundColor: themeProvider.primaryAccent,
                        ),
                      ),
                    ),
                    child: child!,
                  );
                },
              );
              if (pickedDate != null) {
                onDateSelected(pickedDate);
              }
            }
          : null,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 16),
        decoration: BoxDecoration(
          color: themeProvider.cardColor.withOpacity(0.8),
          borderRadius: BorderRadius.circular(12),
          border:
              Border.all(color: themeProvider.primaryAccent.withOpacity(0.5)),
        ),
        child: Row(
          children: [
            Icon(Icons.date_range, color: themeProvider.primaryAccent),
            const SizedBox(width: 12),
            Expanded(
              child: Text(
                deadline != null
                    ? '${deadline.year}-${deadline.month.toString().padLeft(2, '0')}-${deadline.day.toString().padLeft(2, '0')}'
                    : 'Select Deadline',
                style: TextStyle(
                  color: deadline != null
                      ? themeProvider.textColor
                      : themeProvider.textColor.withOpacity(0.6),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _showCreateChildGoalDialog(BuildContext context) {
    final nameController = TextEditingController();
    String priority = 'medium';
    DateTime? deadline;
    bool isGroupGoal = false;
    bool isLoading = false;

    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) {
        return Consumer<ThemeProvider>(
          builder: (context, themeProvider, child) {
            return StatefulBuilder(
              builder: (context, setState) {
                return TweenAnimationBuilder<double>(
                  tween: Tween(begin: 0.95, end: 1.0),
                  duration: const Duration(milliseconds: 300),
                  curve: Curves.easeOutBack,
                  builder: (context, value, child) {
                    return Transform.scale(
                      scale: value,
                      child: AlertDialog(
                        backgroundColor: themeProvider.cardColor,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(20),
                        ),
                        elevation: 20,
                        title: Row(
                          children: [
                            Container(
                              padding: const EdgeInsets.all(8),
                              decoration: BoxDecoration(
                                color: themeProvider.primaryAccent
                                    .withOpacity(0.1),
                                borderRadius: BorderRadius.circular(12),
                              ),
                              child: Icon(
                                Icons.subdirectory_arrow_right_rounded,
                                color: themeProvider.primaryAccent,
                              ),
                            ),
                            const SizedBox(width: 12),
                            Text(
                              'Create Child Goal',
                              style: TextStyle(
                                color: themeProvider.textColor,
                                fontWeight: FontWeight.bold,
                                fontSize: 20,
                              ),
                            ),
                          ],
                        ),
                        content: SingleChildScrollView(
                          child: Column(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              _buildAnimatedTextField(
                                controller: nameController,
                                label: 'Goal Name',
                                icon: Icons.label_important_outlined,
                                themeProvider: themeProvider,
                                enabled: !isLoading,
                              ),
                              const SizedBox(height: 16),
                              _buildAnimatedDropdown(
                                value: priority,
                                label: 'Priority',
                                icon: Icons.priority_high,
                                items: ['high', 'medium', 'low'],
                                themeProvider: themeProvider,
                                enabled: !isLoading,
                                onChanged: (val) =>
                                    setState(() => priority = val!),
                              ),
                              const SizedBox(height: 16),
                              _buildDatePicker(
                                deadline: deadline,
                                themeProvider: themeProvider,
                                enabled: !isLoading,
                                onDateSelected: (picked) =>
                                    setState(() => deadline = picked),
                              ),
                              if (isLoading) ...[
                                const SizedBox(height: 20),
                                Container(
                                  padding: const EdgeInsets.all(16),
                                  decoration: BoxDecoration(
                                    color: themeProvider.subtleAccent
                                        .withOpacity(0.1),
                                    borderRadius: BorderRadius.circular(12),
                                  ),
                                  child: Row(
                                    children: [
                                      SizedBox(
                                        width: 20,
                                        height: 20,
                                        child: CircularProgressIndicator(
                                          strokeWidth: 2,
                                          valueColor:
                                              AlwaysStoppedAnimation<Color>(
                                            themeProvider.primaryAccent,
                                          ),
                                        ),
                                      ),
                                      const SizedBox(width: 12),
                                      Text(
                                        'Creating child goal...',
                                        style: TextStyle(
                                          color: themeProvider.textColor
                                              .withOpacity(0.8),
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ],
                            ],
                          ),
                        ),
                        actions: [
                          TextButton(
                            onPressed:
                                isLoading ? null : () => Navigator.pop(context),
                            style: TextButton.styleFrom(
                              foregroundColor:
                                  themeProvider.textColor.withOpacity(0.7),
                              padding: const EdgeInsets.symmetric(
                                  horizontal: 20, vertical: 12),
                            ),
                            child: const Text('Cancel'),
                          ),
                          ElevatedButton(
                            onPressed: isLoading ||
                                    nameController.text.trim().isEmpty ||
                                    deadline == null
                                ? null
                                : () async {
                                    setState(() => isLoading = true);
                                    final childNode = TreeNode(
                                      priority: priority,
                                      id: 0,
                                      name: nameController.text.trim(),
                                    )
                                      ..description = ''
                                      ..parent = widget.treeNode
                                      ..parentId = widget.treeNode.id
                                      ..status = 'active'
                                      ..deadline = deadline
                                      ..isGroupGoal = isGroupGoal;

                                    try {
                                      final userId = Provider.of<UserProvider>(
                                              context,
                                              listen: false)
                                          .userId!;
                                      final returnedGoal =
                                          await postGoalFromTreeNode(
                                              childNode, userId);

                                      widget.treeNode.addChild(childNode);

                                      if (widget.onChildAdded != null) {
                                        widget.onChildAdded!();
                                      }

                                      childNode
                                        ..id = returnedGoal.id
                                        ..name = returnedGoal.name
                                        ..deadline = returnedGoal.deadline
                                        ..isGroupGoal = returnedGoal.isGroupGoal
                                        ..description = returnedGoal.description
                                        ..parentId = returnedGoal.parentId
                                        ..priority = returnedGoal.priority
                                        ..status = returnedGoal.status;

                                      Navigator.pop(context);
                                      if (context.mounted) {
                                        _showSuccessSnackBar(
                                            context, 'Child goal created!');
                                      }
                                    } catch (e) {
                                      if (context.mounted) {
                                        _showErrorSnackBar(context,
                                            'Failed to create goal: $e');
                                      }
                                    } finally {
                                      if (context.mounted) {
                                        setState(() => isLoading = false);
                                      }
                                    }
                                  },
                            style: ElevatedButton.styleFrom(
                              backgroundColor: themeProvider.primaryAccent,
                              foregroundColor: Colors.black,
                              padding: const EdgeInsets.symmetric(
                                  horizontal: 24, vertical: 12),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(12),
                              ),
                              elevation: 2,
                            ),
                            child: isLoading
                                ? const SizedBox(
                                    width: 20,
                                    height: 20,
                                    child: CircularProgressIndicator(
                                      strokeWidth: 2,
                                      color: Colors.white,
                                    ),
                                  )
                                : const Text('Create'),
                          ),
                        ],
                      ),
                    );
                  },
                );
              },
            );
          },
        );
      },
    );
  }

  void _showSuccessSnackBar(BuildContext context, String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Row(
          children: [
            const Icon(Icons.check_circle, color: Colors.white),
            const SizedBox(width: 8),
            Expanded(child: Text(message)),
          ],
        ),
        backgroundColor: Colors.green,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
        margin: const EdgeInsets.all(16),
      ),
    );
  }

  void _showErrorSnackBar(BuildContext context, String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Row(
          children: [
            const Icon(Icons.error, color: Colors.white),
            const SizedBox(width: 8),
            Expanded(child: Text(message)),
          ],
        ),
        backgroundColor: Colors.red,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
        margin: const EdgeInsets.all(16),
      ),
    );
  }

  void showChangeParentDialog() {
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

  Widget _buildAnimatedDropdown<T>({
    required T value,
    required String label,
    required IconData icon,
    required List<T> items,
    required ThemeProvider themeProvider,
    required bool enabled,
    required ValueChanged<T?>? onChanged,
  }) {
    return TweenAnimationBuilder<double>(
      tween: Tween(begin: 0.0, end: 1.0),
      duration: const Duration(milliseconds: 600),
      curve: Curves.easeOutBack,
      builder: (context, animValue, child) {
        return Transform.translate(
          offset: Offset(0, 20 * (1 - animValue)),
          child: Opacity(
            opacity: animValue.clamp(0, 1),
            child: Container(
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(12),
                border: Border.all(
                  color: themeProvider.borderColor.withOpacity(0.3),
                ),
              ),
              child: DropdownButtonFormField<T>(
                value: value,
                style: TextStyle(color: themeProvider.textColor),
                decoration: InputDecoration(
                  labelText: label,
                  labelStyle: TextStyle(
                      color: themeProvider.textColor.withOpacity(0.7)),
                  prefixIcon: Icon(icon, color: themeProvider.primaryAccent),
                  border: InputBorder.none,
                  contentPadding: const EdgeInsets.all(16),
                ),
                dropdownColor: themeProvider.cardColor,
                items: items
                    .map((e) => DropdownMenuItem(
                          value: e,
                          child: Text(
                            e.toString(),
                            style: TextStyle(color: themeProvider.textColor),
                          ),
                        ))
                    .toList(),
                onChanged: enabled ? onChanged : null,
              ),
            ),
          ),
        );
      },
    );
  }

  void _showUpdateGoalDialog() {
    final nameController = TextEditingController(text: widget.treeNode.name);
    final descriptionController =
        TextEditingController(text: widget.treeNode.description ?? '');
    String priority = widget.treeNode.priority;
    DateTime? deadline =
        widget.treeNode.deadline != null ? (widget.treeNode.deadline!) : null;
    bool isGroupGoal = widget.treeNode.isGroupGoal;
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
                                'Updating goal...',
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
                                widget.treeNode.name =
                                    nameController.text.trim();
                                widget.treeNode.description = '';
                                widget.treeNode.priority = priority;
                                widget.treeNode.deadline = deadline;
                                widget.treeNode.isGroupGoal = isGroupGoal;

                                try {
                                  await updateGoalFromNode(
                                    priority: priority,
                                    userId: Provider.of<UserProvider>(context,
                                            listen: false)
                                        .userId!,
                                    goalId: widget.treeNode.id!,
                                    node: widget.treeNode,
                                  );
                                  setState(() {});
                                  if (widget.onGoalUpdated != null) {
                                    widget.onGoalUpdated!();
                                  }
                                  Navigator.pop(context);
                                  if (mounted) {
                                    ScaffoldMessenger.of(context).showSnackBar(
                                      SnackBar(
                                        content: Text('Goal updated!'),
                                        backgroundColor: Colors.green,
                                      ),
                                    );
                                  }
                                } catch (e) {
                                  if (mounted) {
                                    ScaffoldMessenger.of(context).showSnackBar(
                                      SnackBar(
                                        content:
                                            Text('Failed to update goal: $e'),
                                        backgroundColor: Colors.red,
                                      ),
                                    );
                                  }
                                } finally {
                                  if (mounted) {
                                    setState(() => isLoading = false);
                                  }
                                }
                              }
                            },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.green,
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
                          : Text('Update'),
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
                  builder: (builder) => GoalReportScreen(
                        goal: widget.treeNode,
                      )));
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
                        'Deadline: ${widget.treeNode.deadline!.toIso8601String().split('T')[0]}',
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
