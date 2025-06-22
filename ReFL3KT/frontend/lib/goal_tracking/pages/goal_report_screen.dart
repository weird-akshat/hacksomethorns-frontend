import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:frontend/api_methods/createTask.dart';
import 'package:frontend/api_methods/delete_task.dart';
import 'package:frontend/api_methods/fetch_tasks_for_goal.dart';
import 'package:frontend/api_methods/get_goal_analytics.dart';
import 'package:frontend/api_methods/update_task.dart';
import 'package:frontend/goal_tracking/entities/task.dart';
import 'package:frontend/goal_tracking/entities/tree_node.dart';
import 'package:frontend/providers/theme_provider.dart';
import 'package:frontend/providers/user_provider.dart';
import 'package:frontend/time_tracking/entities/category.dart';
import 'package:frontend/time_tracking/time_tracking_analysis/widgets/category_picker.dart';
import 'package:provider/provider.dart';
import 'package:syncfusion_flutter_charts/charts.dart';

class ChartData {
  ChartData(this.task, this.duration);
  final String task;
  final double duration;
}

class GoalReportScreen extends StatefulWidget {
  final TreeNode goal;
  const GoalReportScreen({super.key, required this.goal});

  @override
  State<GoalReportScreen> createState() => _GoalReportScreenState();
}

class _GoalReportScreenState extends State<GoalReportScreen> {
  late TooltipBehavior _tooltipBehavior;
  bool isLoading = true;
  bool isError = false;
  List<Task> tasks = [];
  Map<String, dynamic>? analytics;

  @override
  void initState() {
    super.initState();
    _tooltipBehavior = TooltipBehavior(enable: true);
    _loadData();
  }

  Future<void> _loadData() async {
    if (!mounted) return;
    setState(() {
      isLoading = true;
      isError = false;
    });
    try {
      final fetchedTasks = await fetchTasksForGoal(
          Provider.of<UserProvider>(context, listen: false).userId!,
          widget.goal.id);
      final fetchedAnalytics = await fetchGoalAnalytics(
          Provider.of<UserProvider>(context, listen: false).userId!,
          widget.goal.id);
      setState(() {
        tasks = fetchedTasks;
        analytics = fetchedAnalytics;
        isLoading = false;
      });
    } catch (e) {
      print('Error loading data: $e');
      setState(() {
        isLoading = false;
        isError = true;
      });
    }
  }

  Future<void> _addTask(Task task) async {
    print("_addTask called with task: ${task.name}");
    setState(() => isLoading = true);
    try {
      print("Calling createTask API...");
      final userId = Provider.of<UserProvider>(context, listen: false).userId!;
      print("User ID: $userId, Goal ID: ${widget.goal.id}");

      await createTask(userId, widget.goal.id, task);
      print("createTask API call successful");
      await _loadData();
    } catch (e) {
      print("Error in _addTask: $e");
      setState(() => isLoading = false);
      // Show error to user
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Failed to add task: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  Future<void> _updateTask(Task task) async {
    setState(() => isLoading = true);
    try {
      await updateTask(
          userId: Provider.of<UserProvider>(context, listen: false).userId!,
          goalId: widget.goal.id,
          task: task);
      await _loadData();
    } catch (e) {
      print("Error updating task: $e");
      setState(() => isLoading = false);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Failed to update task: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  Future<void> _deleteTask(Task task) async {
    setState(() => isLoading = true);
    try {
      await deleteTask(
          userId: Provider.of<UserProvider>(context, listen: false).userId!,
          goalId: widget.goal.id,
          taskId: task.id);
      await _loadData();
    } catch (e) {
      print("Error deleting task: $e");
      setState(() => isLoading = false);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Failed to delete task: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  void _toggleTaskCompletion(Task task) async {
    // Don't toggle recurring tasks
    if (task.isRecurring) return;

    setState(() => isLoading = true);
    try {
      final newStatus =
          task.status == 'completed' ? 'not_started' : 'completed';
      final updatedTask = task.copyWith(status: newStatus);

      await updateTask(
        userId: Provider.of<UserProvider>(context, listen: false).userId!,
        goalId: widget.goal.id,
        task: updatedTask,
      );
      await _loadData();
    } catch (e) {
      print("Error toggling task: $e");
      setState(() => isLoading = false);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Failed to update task: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  void _showAddTaskDialog() {
    print("_showAddTaskDialog called");
    _showTaskDialog();
  }

  void _showEditTaskDialog(Task task) {
    _showTaskDialog(task: task);
  }

  void _showTaskDialog({Task? task}) {
    print("_showTaskDialog called, editing: ${task != null}");
    final nameController = TextEditingController(text: task?.name ?? '');
    bool isRecurring = task?.isRecurring ?? false;
    Category? selectedCategory;

    // Initialize with existing category if editing
    if (task != null) {
      // You might need to fetch the category details here if needed
      // selectedCategory = ...;
    }

    showDialog(
      context: context,
      builder: (BuildContext context) {
        return Consumer<ThemeProvider>(
          builder: (context, themeProvider, child) {
            return StatefulBuilder(
              builder: (context, setDialogState) {
                return AlertDialog(
                  backgroundColor: themeProvider.cardColor,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16),
                    side:
                        BorderSide(color: themeProvider.borderColor, width: 1),
                  ),
                  title: Text(
                    task == null ? 'Add New Task' : 'Edit Task',
                    style: TextStyle(
                      color: themeProvider.textColor,
                      fontWeight: FontWeight.bold,
                      fontSize: 20,
                    ),
                  ),
                  content: SingleChildScrollView(
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        _buildTextField(
                          controller: nameController,
                          label: 'Task Name',
                          themeProvider: themeProvider,
                        ),
                        SizedBox(height: 16),
                        CategoryPicker(
                          initialCategoryName: selectedCategory?.name,
                          onCategorySelected: (cat) {
                            print("Category selected: ${cat?.name}");
                            setDialogState(() {
                              selectedCategory = cat;
                            });
                          },
                        ),
                        SizedBox(height: 16),
                        Row(
                          children: [
                            Text(
                              'Is Recurring:',
                              style: TextStyle(
                                color: themeProvider.textColor,
                                fontSize: 16,
                              ),
                            ),
                            Spacer(),
                            Switch(
                              value: isRecurring,
                              onChanged: (value) {
                                setDialogState(() {
                                  isRecurring = value;
                                });
                              },
                              activeColor: themeProvider.primaryAccent,
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                  actions: [
                    TextButton(
                      onPressed: () {
                        print("Dialog cancelled");
                        Navigator.of(context).pop();
                      },
                      child: Text(
                        'Cancel',
                        style: TextStyle(color: themeProvider.subtleAccent),
                      ),
                    ),
                    ElevatedButton(
                      onPressed: () {
                        print("Add/Update button pressed");
                        print("Task name: '${nameController.text}'");
                        print("Selected category: ${selectedCategory?.name}");
                        print("Is recurring: $isRecurring");

                        if (nameController.text.trim().isEmpty) {
                          print("Task name is empty");
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(
                              content: Text('Please enter a task name'),
                              backgroundColor: Colors.orange,
                            ),
                          );
                          return;
                        }

                        if (selectedCategory == null) {
                          print("No category selected");
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(
                              content: Text('Please select a category'),
                              backgroundColor: Colors.orange,
                            ),
                          );
                          return;
                        }

                        final newTask = Task(
                          id: task?.id ??
                              DateTime.now().millisecondsSinceEpoch.toString(),
                          name: nameController.text.trim(),
                          category: selectedCategory!.categoryId,
                          isRecurring: isRecurring,
                          status: task?.status ?? 'not_started',
                          timeSpent: task?.timeSpent ?? 0.0,
                        );

                        print("Created task object: ${newTask.name}");

                        Navigator.of(context).pop();

                        if (task == null) {
                          print("Calling _addTask");
                          _addTask(newTask);
                        } else {
                          print("Calling _updateTask");
                          _updateTask(newTask);
                        }
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: themeProvider.primaryAccent,
                        foregroundColor: Colors.white,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                      ),
                      child: Text(task == null ? 'Add' : 'Update'),
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

  Widget _buildTextField({
    required TextEditingController controller,
    required String label,
    required ThemeProvider themeProvider,
  }) {
    return TextField(
      controller: controller,
      style: TextStyle(color: themeProvider.textColor),
      decoration: InputDecoration(
        labelText: label,
        labelStyle: TextStyle(color: themeProvider.subtleAccent),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: BorderSide(color: themeProvider.borderColor),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: BorderSide(color: themeProvider.primaryAccent, width: 2),
        ),
        filled: true,
        fillColor: themeProvider.scaffoldColor,
      ),
    );
  }

  void _showTaskOptionsDialog(Task task) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return Consumer<ThemeProvider>(
          builder: (context, themeProvider, child) {
            return AlertDialog(
              backgroundColor: themeProvider.cardColor,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(16),
                side: BorderSide(color: themeProvider.borderColor, width: 1),
              ),
              title: Text(
                'Task Options',
                style: TextStyle(
                  color: themeProvider.textColor,
                  fontWeight: FontWeight.bold,
                ),
              ),
              content: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  ListTile(
                    leading:
                        Icon(Icons.edit, color: themeProvider.primaryAccent),
                    title: Text(
                      'Update',
                      style: TextStyle(color: themeProvider.textColor),
                    ),
                    onTap: () {
                      Navigator.of(context).pop();
                      _showEditTaskDialog(task);
                    },
                  ),
                  ListTile(
                    leading: Icon(Icons.delete, color: Colors.red),
                    title: Text(
                      'Delete',
                      style: TextStyle(color: themeProvider.textColor),
                    ),
                    onTap: () {
                      Navigator.of(context).pop();
                      _deleteTask(task);
                    },
                  ),
                ],
              ),
            );
          },
        );
      },
    );
  }

  List<ChartData> get chartData {
    final children = analytics?['immediate_children'];
    if (children == null) return [];
    return children.entries.map<ChartData>((entry) {
      return ChartData(entry.key, (entry.value as num).toDouble());
    }).toList();
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<ThemeProvider>(
      builder: (context, themeProvider, child) {
        if (isLoading) {
          return Scaffold(
            backgroundColor: themeProvider.scaffoldColor,
            appBar: AppBar(
              title: Text(
                'Goal Report: ${widget.goal.name}',
                style: TextStyle(
                  color: themeProvider.textColor,
                  fontWeight: FontWeight.bold,
                ),
              ),
              backgroundColor: themeProvider.cardColor,
              elevation: 0,
              iconTheme: IconThemeData(color: themeProvider.textColor),
            ),
            body: Center(child: CircularProgressIndicator()),
          );
        }

        if (isError) {
          return Scaffold(
            backgroundColor: themeProvider.scaffoldColor,
            appBar: AppBar(
              title: Text(
                'Goal Report: ${widget.goal.name}',
                style: TextStyle(
                  color: themeProvider.textColor,
                  fontWeight: FontWeight.bold,
                ),
              ),
              backgroundColor: themeProvider.cardColor,
              elevation: 0,
              iconTheme: IconThemeData(color: themeProvider.textColor),
            ),
            body: Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    'Failed to load data',
                    style: TextStyle(color: themeProvider.textColor),
                  ),
                  SizedBox(height: 16),
                  ElevatedButton(
                    onPressed: _loadData,
                    child: Text('Retry'),
                  ),
                ],
              ),
            ),
          );
        }

        return Scaffold(
          backgroundColor: themeProvider.scaffoldColor,
          appBar: AppBar(
            title: Text(
              'Goal Report: ${widget.goal.name}',
              style: TextStyle(
                color: themeProvider.textColor,
                fontWeight: FontWeight.bold,
              ),
            ),
            backgroundColor: themeProvider.cardColor,
            elevation: 0,
            iconTheme: IconThemeData(color: themeProvider.textColor),
          ),
          body: SingleChildScrollView(
            padding: EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Task List Section
                _buildTaskListSection(themeProvider),
                SizedBox(height: 24),
                // Charts Section
                _buildChartsSection(themeProvider),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildTaskListSection(ThemeProvider themeProvider) {
    return Container(
      decoration: BoxDecoration(
        color: themeProvider.cardColor,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: themeProvider.borderColor),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: EdgeInsets.all(16),
            child: Row(
              children: [
                Text(
                  'Tasks',
                  style: TextStyle(
                    color: themeProvider.textColor,
                    fontSize: 22,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                Spacer(),
                FloatingActionButton.small(
                  onPressed: () {
                    print("Add task button pressed");
                    _showAddTaskDialog();
                  },
                  backgroundColor: themeProvider.primaryAccent,
                  child: Icon(Icons.add, color: Colors.white),
                ),
              ],
            ),
          ),
          Container(
            height: 300,
            child: tasks.isEmpty
                ? Center(
                    child: Text(
                      'No tasks yet. Add one to get started!',
                      style: TextStyle(
                        color: themeProvider.subtleAccent,
                        fontSize: 16,
                      ),
                    ),
                  )
                : ListView.builder(
                    padding: EdgeInsets.symmetric(horizontal: 16),
                    itemCount: tasks.length,
                    itemBuilder: (context, index) {
                      final task = tasks[index];
                      return _buildTaskCard(task, themeProvider);
                    },
                  ),
          ),
          SizedBox(height: 16),
        ],
      ),
    );
  }

  Widget _buildLubePointsCard(ThemeProvider themeProvider) {
    if (analytics == null) return SizedBox();

    final totalTimeSpent = analytics!['total_time_spent'] as num? ?? 0;
    // Using 8.7 as multiplier to make it non-obvious
    final lubePoints = (totalTimeSpent * 8.7).round();

    return Container(
      margin: EdgeInsets.only(bottom: 24),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            themeProvider.primaryAccent.withOpacity(0.8),
            themeProvider.secondaryAccent.withOpacity(0.8),
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: themeProvider.primaryAccent.withOpacity(0.3),
            blurRadius: 10,
            offset: Offset(0, 4),
          ),
        ],
      ),
      child: Padding(
        padding: EdgeInsets.all(20),
        child: Row(
          children: [
            Container(
              padding: EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.white.withOpacity(0.2),
                borderRadius: BorderRadius.circular(16),
              ),
              child: Icon(
                Icons.star_rounded,
                color: Colors.white,
                size: 28,
              ),
            ),
            SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Lube Points',
                    style: TextStyle(
                      color: Colors.white.withOpacity(0.9),
                      fontSize: 14,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  SizedBox(height: 4),
                  Text(
                    '$lubePoints',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 32,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  Text(
                    'Keep grinding! 🔥',
                    style: TextStyle(
                      color: Colors.white.withOpacity(0.8),
                      fontSize: 12,
                    ),
                  ),
                ],
              ),
            ),
            Container(
              padding: EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: Colors.white.withOpacity(0.2),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Icon(
                Icons.trending_up,
                color: Colors.white,
                size: 24,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTaskCard(Task task, ThemeProvider themeProvider) {
    final isCompletedNonRecurring =
        !task.isRecurring && task.status == 'completed';

    return Container(
      margin: EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: isCompletedNonRecurring
            ? themeProvider.scaffoldColor.withOpacity(0.6)
            : themeProvider.scaffoldColor,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
            color: isCompletedNonRecurring
                ? themeProvider.borderColor.withOpacity(0.5)
                : themeProvider.borderColor),
      ),
      child: ListTile(
        onTap: () => _showTaskOptionsDialog(task),
        leading: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Checkbox for non-recurring tasks
            if (!task.isRecurring)
              GestureDetector(
                onTap: () => _toggleTaskCompletion(task),
                child: Container(
                  width: 24,
                  height: 24,
                  decoration: BoxDecoration(
                    color: task.status == 'completed'
                        ? Colors.green
                        : Colors.transparent,
                    border: Border.all(
                      color: task.status == 'completed'
                          ? Colors.green
                          : themeProvider.borderColor,
                      width: 2,
                    ),
                    borderRadius: BorderRadius.circular(4),
                  ),
                  child: task.status == 'completed'
                      ? Icon(
                          Icons.check,
                          color: Colors.white,
                          size: 16,
                        )
                      : null,
                ),
              ),
            if (!task.isRecurring) SizedBox(width: 8),
            // Status indicator circle
            Container(
              width: 12,
              height: 12,
              decoration: BoxDecoration(
                color: task.isRecurring
                    ? themeProvider.primaryAccent
                    : (task.status == 'completed'
                        ? Colors.green
                        : themeProvider.secondaryAccent),
                shape: BoxShape.circle,
              ),
            ),
          ],
        ),
        title: Text(
          task.name,
          style: TextStyle(
            color: isCompletedNonRecurring
                ? themeProvider.textColor.withOpacity(0.6)
                : themeProvider.textColor,
            fontWeight: FontWeight.w600,
            decoration: isCompletedNonRecurring
                ? TextDecoration.lineThrough
                : TextDecoration.none,
          ),
        ),
        trailing: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            if (task.isRecurring)
              Container(
                padding: EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: themeProvider.primaryAccent.withOpacity(0.2),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Text(
                  'Recurring',
                  style: TextStyle(
                    color: themeProvider.primaryAccent,
                    fontSize: 12,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ),
            if (isCompletedNonRecurring)
              Container(
                padding: EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: Colors.green.withOpacity(0.2),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Text(
                  'Completed',
                  style: TextStyle(
                    color: Colors.green,
                    fontSize: 12,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ),
            SizedBox(width: 8),
            Icon(
              Icons.more_vert,
              color: themeProvider.subtleAccent,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildChartsSection(ThemeProvider themeProvider) {
    if (analytics == null) {
      return SizedBox();
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Time Analytics',
          style: TextStyle(
            color: themeProvider.textColor,
            fontSize: 22,
            fontWeight: FontWeight.bold,
          ),
        ),
        SizedBox(height: 16),

        _buildLubePointsCard(themeProvider),

        // Pie Chart
        Container(
          decoration: BoxDecoration(
            color: themeProvider.cardColor,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: themeProvider.borderColor),
          ),
          padding: EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Time Distribution',
                style: TextStyle(
                  color: themeProvider.textColor,
                  fontSize: 18,
                  fontWeight: FontWeight.w600,
                ),
              ),
              SizedBox(height: 16),
              Container(
                height: 400,
                child: SfCircularChart(
                  tooltipBehavior: _tooltipBehavior,
                  legend: Legend(
                    isVisible: true,
                    textStyle: TextStyle(
                      color: themeProvider.textColor,
                      fontSize: 12,
                    ),
                    position: LegendPosition.bottom,
                    overflowMode: LegendItemOverflowMode.wrap,
                    itemPadding: 8,
                    height: '30%',
                  ),
                  series: <CircularSeries<ChartData, String>>[
                    DoughnutSeries<ChartData, String>(
                      dataSource: chartData,
                      xValueMapper: (ChartData data, _) => data.task,
                      yValueMapper: (ChartData data, _) => data.duration,
                      name: 'Time Spent',
                      dataLabelSettings: DataLabelSettings(
                        isVisible: true,
                        textStyle: TextStyle(
                          color: themeProvider.textColor,
                          fontSize: 10,
                        ),
                        labelPosition: ChartDataLabelPosition.outside,
                        connectorLineSettings: ConnectorLineSettings(
                          type: ConnectorType.curve,
                          color: themeProvider.borderColor,
                        ),
                      ),
                      pointColorMapper: (ChartData data, int index) {
                        final colors = [
                          themeProvider.primaryAccent,
                          themeProvider.secondaryAccent,
                          themeProvider.subtleAccent,
                          Colors.orange,
                          Colors.purple,
                          Colors.teal,
                          Colors.indigo,
                        ];
                        return colors[index % colors.length];
                      },
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),

        SizedBox(height: 24),

        // Bar Chart
        Container(
          decoration: BoxDecoration(
            color: themeProvider.cardColor,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: themeProvider.borderColor),
          ),
          padding: EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Task Performance',
                style: TextStyle(
                  color: themeProvider.textColor,
                  fontSize: 18,
                  fontWeight: FontWeight.w600,
                ),
              ),
              SizedBox(height: 16),
              Container(
                height: 350,
                child: SfCartesianChart(
                  primaryXAxis: CategoryAxis(
                    labelStyle: TextStyle(
                      color: themeProvider.textColor,
                      fontSize: 10,
                    ),
                    axisLine: AxisLine(color: themeProvider.borderColor),
                    majorTickLines:
                        MajorTickLines(color: themeProvider.borderColor),
                    labelRotation: -45,
                    labelIntersectAction: AxisLabelIntersectAction.rotate45,
                  ),
                  primaryYAxis: NumericAxis(
                    minimum: 0,
                    title: AxisTitle(
                      text: 'Hours',
                      textStyle: TextStyle(color: themeProvider.textColor),
                    ),
                    labelStyle: TextStyle(color: themeProvider.textColor),
                    axisLine: AxisLine(color: themeProvider.borderColor),
                    majorTickLines:
                        MajorTickLines(color: themeProvider.borderColor),
                    majorGridLines: MajorGridLines(
                        color: themeProvider.borderColor.withOpacity(0.3)),
                  ),
                  tooltipBehavior: TooltipBehavior(
                    enable: true,
                    format: 'point.x: point.yh',
                    textStyle: TextStyle(color: Colors.white),
                    color: themeProvider.primaryAccent,
                  ),
                  series: <CartesianSeries<ChartData, String>>[
                    ColumnSeries<ChartData, String>(
                      dataSource: chartData,
                      xValueMapper: (ChartData data, _) => data.task,
                      yValueMapper: (ChartData data, _) => data.duration,
                      name: 'Hours Spent',
                      color: themeProvider.primaryAccent,
                      borderRadius:
                          BorderRadius.vertical(top: Radius.circular(4)),
                      dataLabelSettings: DataLabelSettings(
                        isVisible: true,
                        textStyle: TextStyle(
                          color: themeProvider.textColor,
                          fontSize: 10,
                        ),
                        labelAlignment: ChartDataLabelAlignment.top,
                      ),
                      spacing: 0.2,
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),

        SizedBox(height: 24)
      ],
    );
  }
}
