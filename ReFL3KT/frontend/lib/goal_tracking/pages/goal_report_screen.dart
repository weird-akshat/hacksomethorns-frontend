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
import 'package:frontend/time_tracking/entities/category.dart';
import 'package:frontend/time_tracking/time_tracking_analysis/widgets/category_picker.dart';
import 'package:syncfusion_flutter_charts/charts.dart';
import 'package:provider/provider.dart';

class ChartData {
  ChartData(this.task, this.duration);
  final String task;
  final double duration;
}

class GoalReportScreen extends StatefulWidget {
  final TreeNode goal;
  final String userId;
  const GoalReportScreen({super.key, required this.goal, required this.userId});

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
    setState(() {
      isLoading = true;
      isError = false;
    });
    try {
      final fetchedTasks =
          await fetchTasksForGoal(widget.userId, widget.goal.id);
      final fetchedAnalytics =
          await fetchGoalAnalytics(widget.userId, widget.goal.id);
      setState(() {
        tasks = fetchedTasks;
        analytics = fetchedAnalytics;
        isLoading = false;
      });
    } catch (e) {
      setState(() {
        isLoading = false;
        isError = true;
      });
    }
  }

  Future<void> _addTask(Task task) async {
    setState(() => isLoading = true);
    try {
      await createTask(widget.userId.toString(), widget.goal.id, task);
      await _loadData();
    } catch (_) {
      setState(() => isLoading = false);
    }
  }

  Future<void> _updateTask(Task task) async {
    setState(() => isLoading = true);
    try {
      await updateTask(
          userId: widget.userId, goalId: widget.goal.id, task: task);
      await _loadData();
    } catch (_) {
      setState(() => isLoading = false);
    }
  }

  Future<void> _deleteTask(Task task) async {
    setState(() => isLoading = true);
    try {
      await deleteTask(
          userId: widget.userId, goalId: widget.goal.id, taskId: task.id);
      await _loadData();
    } catch (_) {
      setState(() => isLoading = false);
    }
  }

  void _toggleTaskCompletion(Task task) {
    setState(() {
      final index = tasks.indexWhere((t) => t.id == task.id);
      if (index != -1) {
        tasks[index] = task.copyWith(isComplete: !task.isComplete);
      }
    });
  }

  void _showAddTaskDialog() {
    _showTaskDialog();
  }

  void _showEditTaskDialog(Task task) {
    _showTaskDialog(task: task);
  }

  void _showTaskDialog({Task? task}) {
    final nameController = TextEditingController(text: task?.name ?? '');
    bool isRecurring = task?.isRecurring ?? false;
    Category? selectedCategory;

    showDialog(
      context: context,
      builder: (BuildContext context) {
        return Consumer<ThemeProvider>(
          builder: (context, themeProvider, child) {
            return StatefulBuilder(
              builder: (context, setState) {
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
                            setState(() {
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
                                setState(() {
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
                      onPressed: () => Navigator.of(context).pop(),
                      child: Text(
                        'Cancel',
                        style: TextStyle(color: themeProvider.subtleAccent),
                      ),
                    ),
                    ElevatedButton(
                      onPressed: () {
                        if (nameController.text.isNotEmpty &&
                            selectedCategory != null) {
                          final newTask = Task(
                            id: task?.id ??
                                DateTime.now()
                                    .millisecondsSinceEpoch
                                    .toString(),
                            name: nameController.text,
                            category: selectedCategory!.categoryId,
                            isRecurring: isRecurring,
                            isComplete: task?.isComplete ?? false,
                            timeSpent: task?.timeSpent ?? 0.0,
                          );
                          if (task == null) {
                            _addTask(newTask);
                          } else {
                            _updateTask(newTask);
                          }
                          Navigator.of(context).pop();
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

  // FIX: Use immediate_children for chart data
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
          return Center(child: CircularProgressIndicator());
        }
        if (isError) {
          return Center(
              child: Text('Failed to load data',
                  style: TextStyle(color: themeProvider.textColor)));
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
                  onPressed: _showAddTaskDialog,
                  backgroundColor: themeProvider.primaryAccent,
                  child: Icon(Icons.add, color: Colors.white),
                ),
              ],
            ),
          ),
          Container(
            height: 300,
            child: ListView.builder(
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

  Widget _buildTaskCard(Task task, ThemeProvider themeProvider) {
    final isCompletedNonRecurring = !task.isRecurring && task.isComplete;

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
                  width: 20,
                  height: 20,
                  decoration: BoxDecoration(
                    color: task.isComplete
                        ? themeProvider.primaryAccent
                        : Colors.transparent,
                    border: Border.all(
                      color: task.isComplete
                          ? themeProvider.primaryAccent
                          : themeProvider.subtleAccent,
                      width: 2,
                    ),
                    borderRadius: BorderRadius.circular(4),
                  ),
                  child: task.isComplete
                      ? Icon(
                          Icons.check,
                          size: 14,
                          color: Colors.white,
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
                    : (task.isComplete
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
        // REMOVED: subtitle showing time spent
        // subtitle: Text(
        //   '${task.timeSpent.toStringAsFixed(1)}h${isCompletedNonRecurring ? ' • Completed' : ''}',
        //   style: TextStyle(
        //     color: isCompletedNonRecurring
        //         ? themeProvider.subtleAccent.withOpacity(0.6)
        //         : themeProvider.subtleAccent,
        //   ),
        // ),
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
      return SizedBox(); // Or a placeholder
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
