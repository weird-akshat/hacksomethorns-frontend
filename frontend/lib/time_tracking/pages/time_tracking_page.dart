import 'package:flutter/material.dart';
import 'package:frontend/time_tracking/entities/time_entry.dart';
import 'package:frontend/time_tracking/pages/configuration.dart';
import 'package:frontend/time_tracking/pages/time_entry_sheet.dart';
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
      backgroundColor: scaffoldColor,
      // bottomSheet: Container(),
      appBar: AppBar(
        backgroundColor: scaffoldColor,
        title: Text(
          'Timer',
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
      ),
      body: SafeArea(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Expanded(child: TimelineWidget()),
            GestureDetector(
              onTap: () {
                showModalBottomSheet(
                  context: context,
                  isScrollControlled: true,
                  shape: RoundedRectangleBorder(
                    borderRadius:
                        BorderRadius.vertical(top: Radius.circular(25)),
                  ),
                  builder: (context) => FractionallySizedBox(
                    heightFactor: 0.6,
                    child: TimeEntrySheet(
                      timeEntry: TimeEntry(
                          description: 'description',
                          timeEntryId: 'timeEntryId',
                          userId: 'userId',
                          startTime: DateTime(2023),
                          endTime: DateTime(2023),
                          categoryId: 5,
                          categoryName: 'abc'),
                    ),
                  ),
                );
              },
              child: Container(
                color: Colors.transparent,
                height: MediaQuery.of(context).size.height * .125,
                width: double.infinity,
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Text('Duration'),
                          Text('Description'),
                          Text('Category'),
                        ],
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.all(16.0),
                      child: CircleAvatar(
                        radius: 30,
                        child: Icon(Icons.pause),
                      ),
                    )
                  ],
                ),
              ),
            )
          ],
        ),
      ),
    );
  }
}
