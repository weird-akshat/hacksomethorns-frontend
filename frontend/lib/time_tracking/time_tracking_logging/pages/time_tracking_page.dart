import 'package:flutter/material.dart';
import 'package:frontend/time_tracking/time_tracking_logging/configuration.dart';
import 'package:frontend/time_tracking/entities/time_entry.dart';
// import 'package:frontend/time_tracking/pages/configuration.dart';
import 'package:frontend/time_tracking/time_tracking_logging/pages/time_entry_sheet.dart';
import 'package:frontend/time_tracking/time_tracking_logging/widgets/day_timeline_widget.dart';
import 'package:frontend/time_tracking/time_tracking_logging/widgets/time_entry_widget.dart';
import 'package:frontend/time_tracking/time_tracking_logging/widgets/timeline_widget.dart';

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
        actions: [
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: GestureDetector(
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
              child: Icon(
                Icons.add,
                color: Colors.white,
              ),
            ),
          )
        ],
        backgroundColor: scaffoldColor,
        title: Text(
          'Timer',
          style: TextStyle(fontWeight: FontWeight.bold, color: Colors.white),
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
                          Text(
                            'Duration',
                            style: TextStyle(color: Colors.white),
                          ),
                          Text('Description',
                              style: TextStyle(color: Colors.white)),
                          Text('Category',
                              style: TextStyle(color: Colors.white)),
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
