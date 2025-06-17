// day_timeline_widget.dart
import 'package:flutter/material.dart';
import 'package:frontend/time_tracking/entities/time_entry.dart';
import 'package:frontend/time_tracking/widgets/time_entry_widget.dart';
import 'package:frontend/time_tracking/pages/configuration.dart';

class DayTimelineWidget extends StatelessWidget {
  const DayTimelineWidget({super.key, required this.date, required this.list});
  final DateTime date;
  final List<TimeEntry> list;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: dayTimelineWidgetCrossAxisAlignment,
      children: [
        Padding(
          padding: const EdgeInsets.all(dayTimelineWidgetPadding),
          child: Text(
            "${date.day}/${date.month}/${date.year}",
            style: TextStyle(
              fontSize: MediaQuery.of(context).size.height *
                  dayTimelineWidgetDateFontSize,
              fontWeight: dayTimelineWidgetDateFontWeight,
              color: dayTimelineWidgetDateColor,
            ),
          ),
        ),
        ListView.builder(
            shrinkWrap: true,
            physics: NeverScrollableScrollPhysics(),
            itemCount: list.length,
            itemBuilder: (context, index) {
              return TimeEntryWidget(
                timeEntry: list[index],
              );
            })
      ],
    );
  }
}
