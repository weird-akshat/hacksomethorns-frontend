import 'package:flutter/material.dart';
import 'package:frontend/time_tracking/entities/time_entry.dart';
import 'package:frontend/time_tracking/widgets/time_entry_widget.dart';

class DayTimelineWidget extends StatelessWidget {
  const DayTimelineWidget({super.key, required this.date, required this.list});
  final DateTime date;
  final List<TimeEntry> list;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.all(8.0),
          child: Text("${date.day}/${date.month}/${date.year}"),
        ),
        ListView.builder(
            shrinkWrap: true,
            physics: NeverScrollableScrollPhysics(),
            itemCount: list.length,
            itemBuilder: (context, index) {
              // print(list);
              return TimeEntryWidget(
                timeEntry: list[index],
                // context: context,
              );
            })
      ],
    );
  }
}
