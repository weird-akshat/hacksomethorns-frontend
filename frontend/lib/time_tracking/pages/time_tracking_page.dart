import 'package:flutter/material.dart';
import 'package:frontend/time_tracking/entities/time_entry.dart';
import 'package:frontend/time_tracking/widgets/day_timeline_widget.dart';
import 'package:frontend/time_tracking/widgets/time_entry_widget.dart';
import 'package:frontend/time_tracking/widgets/timeline_widget.dart';

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
        child: TimelineWidget(),
      ),
    );
  }
}
