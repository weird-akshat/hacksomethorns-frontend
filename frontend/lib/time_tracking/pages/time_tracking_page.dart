import 'package:flutter/material.dart';
import 'package:frontend/time_tracking/entities/time_entry.dart';
import 'package:frontend/time_tracking/widgets/time_entry_widget.dart';

class TimeTrackingPage extends StatefulWidget {
  const TimeTrackingPage({super.key});

  @override
  State<TimeTrackingPage> createState() => _TimeTrackingPageState();
}

class _TimeTrackingPageState extends State<TimeTrackingPage> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      // bottomSheet: Text('data'),
      appBar: AppBar(
        title: Text(
          'Timer',
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
      ),
      body: SafeArea(
        child: TimeEntryWidget(
          timeEntry: TimeEntry(
              description: 'description',
              timeEntryId: 'timeEntryId',
              userId: 'userId',
              startTime: DateTime.now(),
              endTime: DateTime.now(),
              categoryId: 5,
              categoryName: 'Project'),
          context: context,
        ),
      ),
    );
  }
}
