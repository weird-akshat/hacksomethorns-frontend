import 'package:flutter/material.dart';
import 'ai_scheduler_api.dart';

class TaskSchedulerHome extends StatefulWidget {
  const TaskSchedulerHome({super.key, required this.userId});
  final String userId;

  @override
  _TaskSchedulerHomeState createState() => _TaskSchedulerHomeState();
}

class _TaskSchedulerHomeState extends State<TaskSchedulerHome> {
  final AiSchedulerAPi api = AiSchedulerAPi();
  late String userID;

  List<Map<String, dynamic>> tasks = [];
  Map<String, dynamic> availability = {};
  Map<String, dynamic> scheduleDetails = {};
  bool isLoading = false;

  @override
  void initState() {
    super.initState();
    userID = widget.userId;
    _loadInitialData();
  }

  Future<void> _loadInitialData() async {
    setState(() => isLoading = true);

    try {
      final loadedTasks = await api.getAllScheduledTasks(userID);
      final userAvailability = await api.getUserAvailability(userID);
      final details = await api.scheduleDetails(userID);

      setState(() {
        tasks = loadedTasks;
        availability = userAvailability;
        scheduleDetails = details;
        isLoading = false;
      });
    } catch (e) {
      print('Error loading data: $e');
      setState(() => isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        title: Text('Task Scheduler', style: TextStyle(color: Colors.white)),
        backgroundColor: Colors.grey[900],
        elevation: 0,
        actions: [
          IconButton(
            icon: Icon(Icons.refresh, color: Colors.white),
            onPressed: _loadInitialData,
            tooltip: 'Refresh',
          ),
        ],
      ),
      body: isLoading
          ? Center(child: CircularProgressIndicator(color: Colors.blue))
          : RefreshIndicator(
              backgroundColor: Colors.grey[800],
              color: Colors.blue,
              onRefresh: _loadInitialData,
              child: SingleChildScrollView(
                physics: AlwaysScrollableScrollPhysics(),
                padding: EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _buildAvailabilityCard(),
                    SizedBox(height: 16),
                    _buildScheduleStatsCard(),
                    SizedBox(height: 16),
                    _buildTasksSection(),
                    SizedBox(height: 16),
                    _buildActionButtons(),
                  ],
                ),
              ),
            ),
    );
  }

  Widget _buildAvailabilityCard() {
    return Card(
      color: Colors.grey[900],
      elevation: 4,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(Icons.schedule, color: Colors.blue),
                SizedBox(width: 8),
                Text(
                  'Current Availability',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
              ],
            ),
            SizedBox(height: 12),
            if (availability.isNotEmpty) ...[
              Text(
                'Start Time: ${availability['start_time'] ?? 'Not set'}',
                style: TextStyle(color: Colors.white70),
              ),
              Text(
                'End Time: ${availability['end_time'] ?? 'Not set'}',
                style: TextStyle(color: Colors.white70),
              ),
              if (availability['day_of_week'] != null)
                Text(
                  'Day: ${_getDayName(availability['day_of_week'])}',
                  style: TextStyle(color: Colors.white70),
                ),
            ] else
              Text(
                'No availability set',
                style: TextStyle(color: Colors.grey[400]),
              ),
            SizedBox(height: 12),
            ElevatedButton(
              onPressed: () => _showAvailabilityDialog(),
              child: Text('Update Availability'),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.blue[600],
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildScheduleStatsCard() {
    int totalTasks = 0;
    String totalTime = '0m';

    if (scheduleDetails.isNotEmpty) {
      // Handle total tasks
      var tasksValue = scheduleDetails['total_tasks'];
      if (tasksValue != null) {
        if (tasksValue is int) {
          totalTasks = tasksValue;
        } else if (tasksValue is String) {
          totalTasks = int.tryParse(tasksValue) ?? 0;
        }
      }

      // Handle total time
      var timeValue = scheduleDetails['total_time'];
      if (timeValue != null) {
        if (timeValue is double) {
          totalTime = '${timeValue.toStringAsFixed(1)}m';
        } else if (timeValue is int) {
          totalTime = '${timeValue}m';
        } else if (timeValue is String) {
          double? parsedTime = double.tryParse(timeValue);
          if (parsedTime != null) {
            totalTime = '${parsedTime.toStringAsFixed(1)}h';
          } else {
            totalTime = timeValue.contains('h') ? timeValue : '${timeValue}h';
          }
        }
      }
    }

    return Card(
      color: Colors.grey[900],
      elevation: 4,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(Icons.analytics, color: Colors.green[400]),
                SizedBox(width: 8),
                Text(
                  'Schedule Overview',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
              ],
            ),
            SizedBox(height: 12),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                _buildStatItem(
                  'Total Tasks',
                  totalTasks.toString(),
                  Icons.task_alt,
                ),
                _buildStatItem('Total Time', totalTime, Icons.timer),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStatItem(String label, String value, IconData icon) {
    return Column(
      children: [
        Icon(icon, color: Colors.blue[400], size: 24),
        SizedBox(height: 4),
        Text(
          value,
          style: TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.bold,
            color: Colors.white,
          ),
        ),
        Text(label, style: TextStyle(fontSize: 12, color: Colors.grey[400])),
      ],
    );
  }

  Widget _buildTasksSection() {
    return Card(
      color: Colors.grey[900],
      elevation: 4,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Row(
                  children: [
                    Icon(Icons.list_alt, color: Colors.orange[400]),
                    SizedBox(width: 8),
                    Text(
                      'Scheduled Tasks',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                    ),
                  ],
                ),
                // TextButton(
                //   onPressed: _loadTopPriorityTasks,
                //   child: Text(
                //     'High Priority',
                //     style: TextStyle(color: Colors.blue[400]),
                //   ),
                // ),
              ],
            ),
            SizedBox(height: 12),
            Container(
              height: 400,
              child: tasks.isEmpty
                  ? Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(
                            Icons.task_alt,
                            size: 64,
                            color: Colors.grey[600],
                          ),
                          SizedBox(height: 16),
                          Text(
                            'No tasks scheduled',
                            style: TextStyle(
                              fontSize: 16,
                              color: Colors.grey[400],
                            ),
                          ),
                          SizedBox(height: 8),
                          TextButton(
                            onPressed: _scheduleNewTasks,
                            child: Text(
                              'Schedule Some Tasks',
                              style: TextStyle(color: Colors.blue[400]),
                            ),
                          ),
                        ],
                      ),
                    )
                  : ListView.separated(
                      itemCount: tasks.length,
                      separatorBuilder: (context, index) =>
                          Divider(color: Colors.grey[700]),
                      itemBuilder: (context, index) {
                        final task = tasks[index];
                        return _buildTaskItem(task, index);
                      },
                    ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTaskItem(Map<String, dynamic> task, int index) {
    return Container(
      padding: EdgeInsets.symmetric(vertical: 8, horizontal: 4),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            task['task_title'] ?? task['title'] ?? 'Untitled Task',
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w500,
              color: Colors.white,
            ),
          ),
          SizedBox(height: 4),
          Row(
            children: [
              Icon(Icons.timer, size: 16, color: Colors.grey[400]),
              SizedBox(width: 4),
              Text(
                '${task['estimated_time'] ?? task['duration'] ?? 'Unknown'} minutes',
                style: TextStyle(color: Colors.grey[400], fontSize: 14),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildActionButtons() {
    return Card(
      color: Colors.grey[900],
      elevation: 4,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Text(
              'Quick Actions',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: Colors.white,
              ),
            ),
            SizedBox(height: 16),
            Row(
              children: [
                Expanded(
                  child: ElevatedButton.icon(
                    onPressed: _scheduleNewTasks,
                    icon: Icon(Icons.add_task),
                    label: Text('Schedule Tasks'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.green[600],
                      foregroundColor: Colors.white,
                      padding: EdgeInsets.symmetric(vertical: 12),
                    ),
                  ),
                ),
                SizedBox(width: 12),
                Expanded(
                  child: ElevatedButton.icon(
                    onPressed: _rescheduleeTasks,
                    icon: Icon(Icons.refresh),
                    label: Text('Reschedule'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.orange[600],
                      foregroundColor: Colors.white,
                      padding: EdgeInsets.symmetric(vertical: 12),
                    ),
                  ),
                ),
              ],
            ),
            SizedBox(height: 12),
            ElevatedButton.icon(
              onPressed: _showSessionHistory,
              icon: Icon(Icons.history),
              label: Text('View Past Sessions'),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.purple[600],
                foregroundColor: Colors.white,
                padding: EdgeInsets.symmetric(vertical: 12),
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _showAvailabilityDialog() {
    TimeOfDay startTime = TimeOfDay.now();
    TimeOfDay endTime = TimeOfDay.now().replacing(
      hour: (TimeOfDay.now().hour + 2) % 24,
    );

    // Days of the week with their corresponding integer values
    List<Map<String, dynamic>> daysOfWeek = [
      {'name': 'Sunday', 'value': 0},
      {'name': 'Monday', 'value': 1},
      {'name': 'Tuesday', 'value': 2},
      {'name': 'Wednesday', 'value': 3},
      {'name': 'Thursday', 'value': 4},
      {'name': 'Friday', 'value': 5},
      {'name': 'Saturday', 'value': 6},
    ];

    // Get current day (0=Sunday, 1=Monday, etc.)
    int currentDayIndex = DateTime.now().weekday % 7; // Convert to 0-6 range
    Map<String, dynamic> selectedDay = daysOfWeek[currentDayIndex];

    showDialog(
      context: context,
      builder: (BuildContext context) {
        return StatefulBuilder(
          builder: (context, setState) {
            return AlertDialog(
              backgroundColor: Colors.grey[900],
              title: Text(
                'Set Availability',
                style: TextStyle(color: Colors.white),
              ),
              content: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  // Day selection
                  Container(
                    padding: EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                    decoration: BoxDecoration(
                      border: Border.all(color: Colors.grey[600]!),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: DropdownButtonHideUnderline(
                      child: DropdownButton<Map<String, dynamic>>(
                        value: selectedDay,
                        isExpanded: true,
                        dropdownColor: Colors.grey[800],
                        style: TextStyle(color: Colors.white),
                        icon: Icon(
                          Icons.arrow_drop_down,
                          color: Colors.blue[400],
                        ),
                        items: daysOfWeek.map((Map<String, dynamic> day) {
                          return DropdownMenuItem<Map<String, dynamic>>(
                            value: day,
                            child: Row(
                              children: [
                                Icon(
                                  Icons.calendar_today,
                                  color: Colors.blue[400],
                                  size: 16,
                                ),
                                SizedBox(width: 8),
                                Text(day['name']),
                                SizedBox(width: 8),
                                Text(
                                  '(${day['value']})',
                                  style: TextStyle(
                                    color: Colors.grey[400],
                                    fontSize: 12,
                                  ),
                                ),
                              ],
                            ),
                          );
                        }).toList(),
                        onChanged: (Map<String, dynamic>? newValue) {
                          if (newValue != null) {
                            setState(() {
                              selectedDay = newValue;
                            });
                          }
                        },
                      ),
                    ),
                  ),
                  SizedBox(height: 16),
                  ListTile(
                    leading: Icon(Icons.access_time, color: Colors.blue[400]),
                    title: Text(
                      'Start Time',
                      style: TextStyle(color: Colors.white),
                    ),
                    subtitle: Text(
                      startTime.format(context),
                      style: TextStyle(color: Colors.grey[400]),
                    ),
                    onTap: () async {
                      final time = await showTimePicker(
                        context: context,
                        initialTime: startTime,
                        builder: (context, child) {
                          return Theme(
                            data: Theme.of(context).copyWith(
                              colorScheme: ColorScheme.dark(
                                primary: Colors.blue,
                                surface: Colors.grey[800]!,
                              ),
                            ),
                            child: child!,
                          );
                        },
                      );
                      if (time != null) {
                        setState(() => startTime = time);
                      }
                    },
                  ),
                  ListTile(
                    leading: Icon(
                      Icons.access_time_filled,
                      color: Colors.blue[400],
                    ),
                    title: Text(
                      'End Time',
                      style: TextStyle(color: Colors.white),
                    ),
                    subtitle: Text(
                      endTime.format(context),
                      style: TextStyle(color: Colors.grey[400]),
                    ),
                    onTap: () async {
                      final time = await showTimePicker(
                        context: context,
                        initialTime: endTime,
                        builder: (context, child) {
                          return Theme(
                            data: Theme.of(context).copyWith(
                              colorScheme: ColorScheme.dark(
                                primary: Colors.blue,
                                surface: Colors.grey[800]!,
                              ),
                            ),
                            child: child!,
                          );
                        },
                      );
                      if (time != null) {
                        setState(() => endTime = time);
                      }
                    },
                  ),
                ],
              ),
              actions: [
                TextButton(
                  onPressed: () => Navigator.of(context).pop(),
                  child: Text(
                    'Cancel',
                    style: TextStyle(color: Colors.grey[400]),
                  ),
                ),
                ElevatedButton(
                  onPressed: () async {
                    await _updateAvailability(
                      startTime,
                      endTime,
                      selectedDay['value'],
                    );
                    Navigator.of(context).pop();
                  },
                  child: Text('Save'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.blue[600],
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

  Future<void> _updateAvailability(
    TimeOfDay startTime,
    TimeOfDay endTime,
    int dayOfWeek,
  ) async {
    try {
      final startTimeStr =
          '${startTime.hour.toString().padLeft(2, '0')}:${startTime.minute.toString().padLeft(2, '0')}';
      final endTimeStr =
          '${endTime.hour.toString().padLeft(2, '0')}:${endTime.minute.toString().padLeft(2, '0')}';

      // Get day name for display purposes
      List<String> dayNames = [
        'Sunday',
        'Monday',
        'Tuesday',
        'Wednesday',
        'Thursday',
        'Friday',
        'Saturday',
      ];
      String dayName = dayNames[dayOfWeek];

      print(
        'Updating availability: $dayName ($dayOfWeek) $startTimeStr - $endTimeStr',
      );
      print('User ID: $userID');

      // Always try to add availability with all required fields
      await api.addAvailability(userID, startTimeStr, endTimeStr, dayOfWeek);

      await _loadInitialData();
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Availability updated successfully for $dayName!'),
          backgroundColor: Colors.green[700],
        ),
      );
    } catch (e) {
      print('Error updating availability: $e');

      String errorMessage = 'Error updating availability';
      if (e.toString().contains('400')) {
        errorMessage = 'Invalid data provided. Please check your input.';
      } else if (e.toString().contains('404')) {
        errorMessage = 'Availability endpoint not found.';
      } else if (e.toString().contains('403')) {
        errorMessage = 'Access denied. Check your permissions.';
      } else if (e.toString().contains('500')) {
        errorMessage = 'Server error. Please try again later.';
      }

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(errorMessage),
          backgroundColor: Colors.red[700],
          duration: Duration(seconds: 4),
        ),
      );
    }
  }

  Future<void> _loadTopPriorityTasks() async {
    setState(() => isLoading = true);
    try {
      final priorityTasks = await api.getTopFiveTasks(userID);
      setState(() {
        tasks = priorityTasks;
        isLoading = false;
      });
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Loaded ${priorityTasks.length} high priority tasks'),
          backgroundColor: Colors.blue[700],
        ),
      );
    } catch (e) {
      print('Error loading priority tasks: $e');
      setState(() => isLoading = false);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Error loading priority tasks: $e'),
          backgroundColor: Colors.red[700],
        ),
      );
    }
  }

  Future<void> _scheduleNewTasks() async {
    setState(() => isLoading = true);
    try {
      await api.scheduleTasks(userID);
      await _loadInitialData(); // This will set isLoading to false
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Tasks scheduled successfully!'),
          backgroundColor: Colors.green[700],
        ),
      );
    } catch (e) {
      print('Error scheduling tasks: $e');
      setState(() => isLoading = false);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Error scheduling tasks: $e'),
          backgroundColor: Colors.red[700],
        ),
      );
    }
  }

  Future<void> _rescheduleeTasks() async {
    setState(() => isLoading = true);
    try {
      await api.taskRescheduler(userID);
      await _loadInitialData(); // This will set isLoading to false
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Tasks rescheduled successfully!'),
          backgroundColor: Colors.green[700],
        ),
      );
    } catch (e) {
      print('Error rescheduling tasks: $e');
      setState(() => isLoading = false);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Error rescheduling tasks: $e'),
          backgroundColor: Colors.red[700],
        ),
      );
    }
  }

  void _showSessionHistory() {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          backgroundColor: Colors.grey[900],
          title: Row(
            children: [
              Icon(Icons.history, color: Colors.purple[400]),
              SizedBox(width: 8),
              Text('Past Sessions', style: TextStyle(color: Colors.white)),
            ],
          ),
          content: Container(
            width: double.maxFinite,
            height: 300,
            child: Column(
              children: [
                if (scheduleDetails.isNotEmpty) ...[
                  ListTile(
                    leading: Icon(Icons.task_alt, color: Colors.blue[400]),
                    title: Text(
                      'Total Tasks Scheduled',
                      style: TextStyle(color: Colors.white),
                    ),
                    trailing: Text(
                      scheduleDetails['total_tasks']?.toString() ?? '0',
                      style: TextStyle(color: Colors.white),
                    ),
                  ),
                  ListTile(
                    leading: Icon(Icons.timer, color: Colors.blue[400]),
                    title: Text(
                      'Total Time Scheduled',
                      style: TextStyle(color: Colors.white),
                    ),
                    trailing: Text(
                      _formatTime(scheduleDetails['total_time']),
                      style: TextStyle(color: Colors.white),
                    ),
                  ),
                  Divider(color: Colors.grey[700]),
                  Expanded(
                    child: SingleChildScrollView(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Debug Info:',
                            style: TextStyle(
                              color: Colors.grey[400],
                              fontSize: 12,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          SizedBox(height: 8),
                          Container(
                            padding: EdgeInsets.all(8),
                            decoration: BoxDecoration(
                              color: Colors.grey[800],
                              borderRadius: BorderRadius.circular(4),
                            ),
                            child: Text(
                              scheduleDetails.toString(),
                              style: TextStyle(
                                color: Colors.grey[300],
                                fontSize: 10,
                                fontFamily: 'monospace',
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ] else
                  Center(
                    child: Text(
                      'No session data available',
                      style: TextStyle(color: Colors.grey[400]),
                    ),
                  ),
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: Text('Close', style: TextStyle(color: Colors.blue[400])),
            ),
          ],
        );
      },
    );
  }

  String _formatTime(dynamic timeValue) {
    if (timeValue == null) return '0 hours';

    if (timeValue is double) {
      return '${timeValue.toStringAsFixed(1)} hours';
    } else if (timeValue is int) {
      return '$timeValue hours';
    } else if (timeValue is String) {
      double? parsedTime = double.tryParse(timeValue);
      if (parsedTime != null) {
        return '${parsedTime.toStringAsFixed(1)} hours';
      } else {
        return timeValue.contains('hour') ? timeValue : '$timeValue hours';
      }
    }

    return timeValue.toString();
  }

  String _getDayName(dynamic dayValue) {
    List<String> dayNames = [
      'Sunday',
      'Monday',
      'Tuesday',
      'Wednesday',
      'Thursday',
      'Friday',
      'Saturday',
    ];

    if (dayValue is int && dayValue >= 0 && dayValue <= 6) {
      return dayNames[dayValue];
    } else if (dayValue is String) {
      int? dayInt = int.tryParse(dayValue);
      if (dayInt != null && dayInt >= 0 && dayInt <= 6) {
        return dayNames[dayInt];
      }
      return dayValue; // Return as-is if it's already a string name
    }

    return 'Unknown';
  }
}
