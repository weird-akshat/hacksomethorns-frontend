// goal_root_page.dart

import 'package:flutter/material.dart';
import 'package:flutter_staggered_animations/flutter_staggered_animations.dart';
import 'package:lottie/lottie.dart';
import 'package:frontend/api_methods/fetch_goal_tree.dart';
import 'package:frontend/api_methods/delete_user_goal.dart';
import 'package:frontend/api_methods/post_goal_from_treenode.dart';
import 'package:frontend/goal_tracking/configuration.dart';
import 'package:frontend/goal_tracking/entities/tree_node.dart';
import 'package:frontend/goal_tracking/pages/tree_screen.dart';
import 'package:frontend/providers/theme_provider.dart';
import 'package:frontend/providers/user_provider.dart';
import 'package:provider/provider.dart';

class GoalRootPage extends StatefulWidget {
  const GoalRootPage(this.openDrawer, {super.key});
  // final GlobalKey<ScaffoldState> scaffoldKey;
  final VoidCallback openDrawer;
  @override
  State<GoalRootPage> createState() => _GoalRootPageState();
}

class _GoalRootPageState extends State<GoalRootPage>
    with TickerProviderStateMixin {
  late AnimationController _fabAnimationController;
  late AnimationController _listAnimationController;
  late Animation<double> _fabScaleAnimation;
  late Animation<double> _fabRotationAnimation;

  void _showCreateRootGoalDialog(BuildContext context, String userId,
      {VoidCallback? onGoalAdded}) {
    final nameController = TextEditingController();
    String priority = 'medium';
    String status = 'active';
    DateTime? deadline;
    bool isGroupGoal = false;

    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext context) {
        bool isLoading = false;

        return Consumer<ThemeProvider>(
          builder: (context, themeProvider, child) {
            return StatefulBuilder(
              builder: (context, setState) {
                return TweenAnimationBuilder<double>(
                  tween: Tween(begin: 0.0, end: 1.0),
                  duration: const Duration(milliseconds: 300),
                  curve: Curves.elasticOut,
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
                                Icons.flag,
                                color: themeProvider.primaryAccent,
                                size: 24,
                              ),
                            ),
                            const SizedBox(width: 12),
                            Text(
                              'Create Root Goal',
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
                                icon: Icons.label_outline,
                                themeProvider: themeProvider,
                                enabled: !isLoading,
                              ),
                              const SizedBox(height: 16),
                              _buildAnimatedDropdown(
                                value: priority,
                                label: 'Priority',
                                icon: Icons.priority_high,
                                items: ['high', 'urgent', 'medium', 'low'],
                                themeProvider: themeProvider,
                                enabled: !isLoading,
                                onChanged: (val) =>
                                    setState(() => priority = val!),
                              ),
                              const SizedBox(height: 16),
                              _buildAnimatedDropdown(
                                value: status,
                                label: 'Status',
                                icon: Icons.track_changes,
                                items: ['active', 'completed'],
                                themeProvider: themeProvider,
                                enabled: !isLoading,
                                onChanged: (val) =>
                                    setState(() => status = val!),
                              ),
                              const SizedBox(height: 16),
                              _buildDatePicker(
                                deadline: deadline,
                                themeProvider: themeProvider,
                                enabled: !isLoading,
                                onDateSelected: (date) =>
                                    setState(() => deadline = date),
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
                                        'Creating your goal...',
                                        style: TextStyle(
                                          color: themeProvider.textColor
                                              .withOpacity(0.8),
                                          fontWeight: FontWeight.w500,
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
                            onPressed: isLoading
                                ? null
                                : () async {
                                    if (nameController.text.trim().isNotEmpty) {
                                      setState(() => isLoading = true);
                                      final rootGoal = TreeNode(
                                        priority: priority,
                                        id: 0,
                                        name: nameController.text.trim(),
                                      )
                                        ..description = ''
                                        ..priority = priority
                                        ..status = status
                                        ..deadline = deadline
                                        ..isGroupGoal = isGroupGoal
                                        ..parentId = null;

                                      try {
                                        final TreeNode returnedGoal =
                                            await postGoalFromTreeNode(
                                          rootGoal,
                                          Provider.of<UserProvider>(context,
                                                  listen: false)
                                              .userId!,
                                        );
                                        if (onGoalAdded != null) {
                                          onGoalAdded();
                                        }
                                        Navigator.pop(context);
                                        if (context.mounted) {
                                          _showSuccessSnackBar(
                                              context, 'Root goal created!');
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
                                    }
                                  },
                            style: ElevatedButton.styleFrom(
                              backgroundColor: themeProvider.primaryAccent,
                              foregroundColor: Colors.white,
                              padding: const EdgeInsets.symmetric(
                                  horizontal: 24, vertical: 12),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(12),
                              ),
                              elevation: 2,
                            ),
                            child: isLoading
                                ? const SizedBox(
                                    width: 18,
                                    height: 18,
                                    child: CircularProgressIndicator(
                                      strokeWidth: 2,
                                      color: Colors.white,
                                    ),
                                  )
                                : const Text('Create Goal',
                                    style:
                                        TextStyle(fontWeight: FontWeight.bold)),
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
            opacity: value,
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
            opacity: animValue,
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

  Widget _buildDatePicker({
    required DateTime? deadline,
    required ThemeProvider themeProvider,
    required bool enabled,
    required ValueChanged<DateTime?> onDateSelected,
  }) {
    return TweenAnimationBuilder<double>(
      tween: Tween(begin: 0.0, end: 1.0),
      duration: const Duration(milliseconds: 700),
      curve: Curves.easeOutBack,
      builder: (context, value, child) {
        return Transform.translate(
          offset: Offset(0, 20 * (1 - value)),
          child: Opacity(
            opacity: value,
            child: Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(12),
                border: Border.all(
                  color: themeProvider.borderColor.withOpacity(0.3),
                ),
              ),
              child: Row(
                children: [
                  Icon(Icons.calendar_today,
                      color: themeProvider.primaryAccent),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Deadline',
                          style: TextStyle(
                            color: themeProvider.textColor.withOpacity(0.7),
                            fontSize: 12,
                          ),
                        ),
                        Text(
                          deadline != null
                              ? '${deadline!.day}/${deadline!.month}/${deadline!.year}'
                              : 'Not set',
                          style: TextStyle(
                            color: themeProvider.textColor,
                            fontSize: 16,
                          ),
                        ),
                      ],
                    ),
                  ),
                  IconButton(
                    icon: Icon(Icons.edit_calendar,
                        color: themeProvider.secondaryAccent),
                    onPressed: enabled
                        ? () async {
                            final picked = await showDatePicker(
                              context: context,
                              initialDate: deadline ?? DateTime.now(),
                              firstDate: DateTime(2000),
                              lastDate: DateTime(2100),
                              builder: (context, child) {
                                return Theme(
                                  data: Theme.of(context).copyWith(
                                    colorScheme:
                                        ColorScheme.fromSwatch().copyWith(
                                      primary: themeProvider.primaryAccent,
                                    ),
                                  ),
                                  child: child!,
                                );
                              },
                            );
                            if (picked != null) {
                              onDateSelected(picked);
                            }
                          }
                        : null,
                  ),
                ],
              ),
            ),
          ),
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
    _fabAnimationController = AnimationController(
      duration: const Duration(milliseconds: 300),
      vsync: this,
    );
    _listAnimationController = AnimationController(
      duration: const Duration(milliseconds: 800),
      vsync: this,
    );

    _fabScaleAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
          parent: _fabAnimationController, curve: Curves.elasticOut),
    );
    _fabRotationAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _fabAnimationController, curve: Curves.easeInOut),
    );

    _fabAnimationController.forward(); // Add this line here
    // _fetchGoals();
    _fetchGoals();
  }

  @override
  void dispose() {
    _fabAnimationController.dispose();
    _listAnimationController.dispose();
    _goalController.dispose();
    super.dispose();
  }

  Future<void> _fetchGoals() async {
    setState(() {
      _isLoading = true;
      _error = null;
    });
    try {
      final fetchedList = await fetchGoalTree(
          Provider.of<UserProvider>(context, listen: false).userId!);
      setState(() {
        list = fetchedList;
        _isLoading = false;
      });
      _fabAnimationController.forward();
      _listAnimationController.forward();
    } catch (e) {
      setState(() {
        _error = e.toString();
        _isLoading = false;
      });
    }
  }

  Future<void> _addGoal(String name, String priority) async {
    setState(() => _isLoading = true);
    try {
      final newGoal = TreeNode(
        priority: priority,
        id: 0,
        name: name,
      );
      final created = await postGoalFromTreeNode(
          newGoal, Provider.of<UserProvider>(context, listen: false).userId!);
      setState(() {
        list.add(created);
        _isLoading = false;
      });
      _showSuccessSnackBar(context, 'Goal "$name" added!');
    } catch (e) {
      setState(() => _isLoading = false);
      _showErrorSnackBar(context, 'Failed to add goal: $e');
    }
  }

  Future<void> _deleteGoal(TreeNode node) async {
    setState(() => _isLoading = true);
    try {
      await deleteUserGoal(
          userId: Provider.of<UserProvider>(context, listen: false).userId!,
          goalId: node.id!);
      setState(() {
        list.removeWhere((g) => g.id == node.id);
        _isLoading = false;
      });
      _showSuccessSnackBar(context, 'Goal "${node.name}" deleted!');
    } catch (e) {
      setState(() => _isLoading = false);
      _showErrorSnackBar(context, 'Failed to delete goal: $e');
    }
  }

  Future<void> _updateGoalStatus(TreeNode node, bool isCompleted) async {
    setState(() => _isLoading = true);
    try {
      node.status = isCompleted ? 'completed' : 'active';

      await postGoalFromTreeNode(
        node,
        Provider.of<UserProvider>(context, listen: false).userId!,
      );

      setState(() {
        final index = list.indexWhere((g) => g.id == node.id);
        if (index != -1) {
          list[index] = node;
        }
        _isLoading = false;
      });

      _showSuccessSnackBar(
        context,
        isCompleted
            ? 'Goal "${node.name}" completed! 🎉'
            : 'Goal "${node.name}" reactivated!',
      );
    } catch (e) {
      setState(() => _isLoading = false);
      _showErrorSnackBar(context, 'Failed to update goal: $e');
    }
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

  @override
  Widget build(BuildContext context) {
    final themeProvider = Provider.of<ThemeProvider>(context);

    return Scaffold(
      backgroundColor: themeProvider.scaffoldColor,
      appBar: AppBar(
        backgroundColor: themeProvider.cardColor,
        elevation: 0,
        centerTitle: true,
        leading: Builder(
          builder: (context) => IconButton(
            icon: Icon(Icons.menu, color: themeProvider.primaryAccent),
            onPressed: widget.openDrawer,
            tooltip: 'Open Menu',
          ),
        ),
        title: TweenAnimationBuilder<double>(
          tween: Tween(begin: 0.0, end: 1.0),
          duration: const Duration(milliseconds: 800),
          curve: Curves.easeOutBack,
          builder: (context, value, child) {
            return Transform.translate(
              offset: Offset(0, 30 * (1 - value)),
              child: Opacity(
                opacity: value.clamp(0.0, 1.0), // Add .clamp(0.0, 1.0)

                // opacity: value,
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Container(
                      padding: const EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        color: themeProvider.primaryAccent.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Icon(
                        Icons.flag,
                        color: themeProvider.primaryAccent,
                        size: 24,
                      ),
                    ),
                    const SizedBox(width: 12),
                    Text(
                      'Main Goals',
                      style: TextStyle(
                        color: themeProvider.textColor,
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                        letterSpacing: 0.5,
                      ),
                    ),
                  ],
                ),
              ),
            );
          },
        ),
        actions: [
          AnimatedBuilder(
            animation: _fabScaleAnimation,
            builder: (context, child) {
              return Transform.scale(
                scale: _fabScaleAnimation.value,
                child: IconButton(
                  icon: Icon(Icons.refresh,
                      color: themeProvider.primaryAccent, size: 28),
                  onPressed: _fetchGoals,
                  tooltip: "Refresh Goals",
                ),
              );
            },
          ),
          AnimatedBuilder(
            animation: _fabScaleAnimation,
            builder: (context, child) {
              return Transform.scale(
                scale: _fabScaleAnimation.value,
                child: IconButton(
                  icon: Icon(Icons.add_circle,
                      color: themeProvider.secondaryAccent, size: 28),
                  onPressed: () {
                    _showCreateRootGoalDialog(
                        context,
                        Provider.of<UserProvider>(context, listen: false)
                            .userId!,
                        onGoalAdded: _fetchGoals);
                  },
                ),
              );
            },
          ),
        ],
      ),
      body: _isLoading
          ? Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  SizedBox(
                    width: 60,
                    height: 60,
                    child: CircularProgressIndicator(
                      strokeWidth: 4,
                      valueColor: AlwaysStoppedAnimation<Color>(
                          themeProvider.primaryAccent),
                    ),
                  ),
                  const SizedBox(height: 20),
                  Text(
                    'Loading your goals...',
                    style: TextStyle(
                      color: themeProvider.textColor.withOpacity(0.7),
                      fontSize: 16,
                    ),
                  ),
                ],
              ),
            )
          : _error != null
              ? Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(
                        Icons.error_outline,
                        color: Colors.red,
                        size: 64,
                      ),
                      const SizedBox(height: 16),
                      Text(
                        'Error: $_error',
                        style: TextStyle(color: Colors.red, fontSize: 16),
                        textAlign: TextAlign.center,
                      ),
                    ],
                  ),
                )
              : list.isEmpty
                  ? Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(
                            Icons.flag_outlined,
                            color: themeProvider.textColor.withOpacity(0.5),
                            size: 80,
                          ),
                          const SizedBox(height: 20),
                          Text(
                            'No goals yet',
                            style: TextStyle(
                              color: themeProvider.textColor,
                              fontSize: 24,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          const SizedBox(height: 8),
                          Text(
                            'Tap the + button to create your first goal',
                            style: TextStyle(
                              color: themeProvider.textColor.withOpacity(0.7),
                              fontSize: 16,
                            ),
                          ),
                        ],
                      ),
                    )
                  : Padding(
                      padding: const EdgeInsets.all(20.0),
                      child: AnimationLimiter(
                        child: ListView.separated(
                          itemCount: list.length,
                          separatorBuilder: (context, index) =>
                              const SizedBox(height: 16),
                          itemBuilder: (context, index) {
                            final goal = list[index];
                            return AnimationConfiguration.staggeredList(
                              position: index,
                              duration: const Duration(milliseconds: 600),
                              child: SlideAnimation(
                                verticalOffset: 50.0,
                                child: FadeInAnimation(
                                  child: GestureDetector(
                                    onTap: () {
                                      Navigator.of(context).push(
                                        PageRouteBuilder(
                                          pageBuilder: (context, animation,
                                                  secondaryAnimation) =>
                                              TreeScreen(node: list[index]),
                                          transitionsBuilder: (context,
                                              animation,
                                              secondaryAnimation,
                                              child) {
                                            const begin = Offset(1.0, 0.0);
                                            const end = Offset.zero;
                                            const curve = Curves.ease;

                                            var tween =
                                                Tween(begin: begin, end: end)
                                                    .chain(
                                              CurveTween(curve: curve),
                                            );

                                            return SlideTransition(
                                              position: animation.drive(tween),
                                              child: child,
                                            );
                                          },
                                        ),
                                      );
                                    },
                                    child: RootGoalWidget(
                                      treeNode: goal,
                                      offset: Offset(
                                        MediaQuery.of(context).size.width / 2,
                                        MediaQuery.of(context).size.height *
                                            (index + 1) /
                                            (list.length + 1),
                                      ),
                                      onGoalDeleted: () => _deleteGoal(goal),
                                      onGoalStatusChanged: (isCompleted) =>
                                          _updateGoalStatus(goal, isCompleted),
                                    ),
                                  ),
                                ),
                              ),
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
  final Function(bool)? onGoalStatusChanged; // NEW: Callback for status change

  const RootGoalWidget({
    super.key,
    required this.offset,
    required this.treeNode,
    this.onGoalDeleted,
    this.onGoalStatusChanged, // NEW: Add to constructor
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
    return Consumer<ThemeProvider>(
      builder: (context, themeProvider, child) {
        final isCompleted = widget.treeNode.status ==
            'completed'; // NEW: Check completion status

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
              color: isCompleted // NEW: Change color based on completion
                  ? (themeProvider.isDarkMode
                      ? Colors.green.shade800
                      : Colors.green.shade100)
                  : (themeProvider.isDarkMode
                      ? Colors.grey.shade900
                      : Colors.white),
              borderRadius: BorderRadius.circular(8),
              border: Border.all(
                color: isCompleted
                    ? Colors.green
                    : (themeProvider.isDarkMode
                        ? Colors.white24
                        : Colors.black12),
                width: 1,
              ),
              boxShadow: [
                BoxShadow(
                  color: (themeProvider.isDarkMode ? Colors.black : Colors.grey)
                      .withOpacity(0.1),
                  blurRadius: 4,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
            child: Padding(
              padding: const EdgeInsets.all(8),
              child: Column(
                children: [
                  // NEW: Add checkbox at the top
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Expanded(
                        child: Text(
                          widget.treeNode.name ?? "Goal Name",
                          style: TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.w500,
                            color: themeProvider.isDarkMode
                                ? Colors.white
                                : Colors.black,
                            decoration: isCompleted
                                ? TextDecoration.lineThrough
                                : null, // NEW: Strike through when completed
                          ),
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                          textAlign: TextAlign.center,
                        ),
                      ),
                      GestureDetector(
                        onTap: () {
                          if (widget.onGoalStatusChanged != null) {
                            widget.onGoalStatusChanged!(!isCompleted);
                          }
                        },
                        child: Container(
                          width: 20,
                          height: 20,
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            border: Border.all(
                              color: isCompleted ? Colors.green : Colors.grey,
                              width: 2,
                            ),
                            color:
                                isCompleted ? Colors.green : Colors.transparent,
                          ),
                          child: isCompleted
                              ? const Icon(
                                  Icons.check,
                                  size: 14,
                                  color: Colors.white,
                                )
                              : null,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }
}
