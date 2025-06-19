import 'package:flutter/material.dart';
import 'package:frontend/api_methods/fetch_time_entries.dart';
import 'package:frontend/providers/category_provider.dart';
import 'package:frontend/providers/current_time_entry_provider.dart';
import 'package:frontend/providers/theme_provider.dart';
import 'package:frontend/providers/timelog_provider.dart';
import 'package:frontend/time_tracking/time_tracking_logging/configuration.dart';
import 'package:frontend/time_tracking/entities/time_entry.dart';
import 'package:frontend/time_tracking/time_tracking_logging/pages/new_time_entry_sheet.dart';
import 'package:frontend/time_tracking/time_tracking_logging/pages/time_entry_sheet.dart';
import 'package:frontend/time_tracking/time_tracking_logging/pages/update_time_entry_sheet.dart';
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
    final categoryProvider =
        Provider.of<CategoryProvider>(context, listen: false);
    if (categoryProvider.isEmpty()) {
      categoryProvider.loadCategories('1'); // use actual user ID
    }

    final timelogProvider =
        Provider.of<TimelogProvider>(context, listen: false);
    if (timelogProvider.isEmpty()) {
      timelogProvider.loadTimeEntries();
    }

    final currentEntryProvider =
        Provider.of<CurrentTimeEntryProvider>(context, listen: false);
    currentEntryProvider.loadCurrentEntry("1"); // use actual user ID
  }

  @override
  Widget build(BuildContext context) {
    final themeProvider = Provider.of<ThemeProvider>(context);
    final currentEntryProvider = Provider.of<CurrentTimeEntryProvider>(context);

    return Scaffold(
      body: SafeArea(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Expanded(
              child: Consumer<TimelogProvider>(
                builder: (context, timelogProvider, child) =>
                    TimelineWidget(timelogProvider.map),
              ),
            ),
            GestureDetector(
              onTap: () {
                final isTracking = currentEntryProvider.isTracking;
                final currentEntry = currentEntryProvider.currentEntry;
                isTracking && currentEntry != null
                    ? SizedBox()
                    : showModalBottomSheet(
                        context: context,
                        isScrollControlled: true,
                        shape: const RoundedRectangleBorder(
                          borderRadius:
                              BorderRadius.vertical(top: Radius.circular(25)),
                        ),
                        builder: (context) => FractionallySizedBox(
                          heightFactor: 0.6,
                          child: isTracking && currentEntry != null
                              ? SizedBox()
                              : const NewTimeEntrySheet(),
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
