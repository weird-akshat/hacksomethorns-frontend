import 'package:flutter/material.dart';
import 'package:frontend/api_methods/fetch_time_entries.dart';
import 'package:frontend/providers/current_time_entry_provider.dart';
import 'package:frontend/providers/theme_provider.dart';
import 'package:frontend/providers/timelog_provider.dart';
import 'package:frontend/time_tracking/time_tracking_logging/configuration.dart';
import 'package:frontend/time_tracking/entities/time_entry.dart';
// import 'package:frontend/time_tracking/pages/configuration.dart';
import 'package:frontend/time_tracking/time_tracking_logging/pages/time_entry_sheet.dart';
import 'package:frontend/time_tracking/time_tracking_logging/widgets/current_time_tracking_widget.dart';
import 'package:frontend/time_tracking/time_tracking_logging/widgets/day_timeline_widget.dart';
import 'package:frontend/time_tracking/time_tracking_logging/widgets/time_entry_widget.dart';
import 'package:frontend/time_tracking/time_tracking_logging/widgets/timeline_widget.dart';
import 'package:provider/provider.dart';

class TimeTrackingPage extends StatefulWidget {
  const TimeTrackingPage({super.key});

  @override
  State<TimeTrackingPage> createState() => _TimeTrackingPageState();
}

class _TimeTrackingPageState extends State<TimeTrackingPage> {
  @override
  void initState() {
    super.initState();

    final timelogProvider =
        Provider.of<TimelogProvider>(context, listen: false);
    if (timelogProvider.isEmpty()) {
      timelogProvider.loadTimeEntries();
    }
  }

  @override
  Widget build(BuildContext context) {
    var themeProvider = Provider.of<ThemeProvider>(context);
    return Scaffold(
      // backgroundColor: scaffoldColor,
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
                color: themeProvider.isDarkMode
                    ? timeEntryWidgetTextColorDark
                    : timeEntryWidgetTextColorLight,
              ),
            ),
          ),
          IconButton(
            icon: Icon(
                themeProvider.isDarkMode ? Icons.dark_mode : Icons.light_mode),
            onPressed: () {
              themeProvider
                  .toggleTheme(); // no value passed, it toggles internally
            },
          )
        ],
        // backgroundColor: scaffoldColor,
        title: Text(
          'Timer',
          style: TextStyle(
              fontWeight: FontWeight.bold,
              color: themeProvider.isDarkMode
                  ? timeEntryWidgetTextColorDark
                  : timeEntryWidgetTextColorLight),
        ),
      ),
      body: SafeArea(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Expanded(
                child: Consumer<TimelogProvider>(
                    builder: (context, timelogProvider, child) =>
                        TimelineWidget(
                            Provider.of<TimelogProvider>(context).map))),
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
              child: CurrentTimeTrackingWidget(
                themeProvider: themeProvider,
                userId: "1",
              ),
            )
          ],
        ),
      ),
    );
  }
}
