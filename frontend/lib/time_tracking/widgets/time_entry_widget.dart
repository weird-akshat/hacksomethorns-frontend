import 'package:flutter/material.dart';
import 'package:frontend/time_tracking/entities/time_entry.dart';

class TimeEntryWidget extends StatefulWidget {
  final BuildContext context;
  final TimeEntry timeEntry;
  const TimeEntryWidget({
    required this.timeEntry,
    required this.context,
    super.key,
  });

  @override
  State<TimeEntryWidget> createState() => _TimeEntryWidgetState();
}

class _TimeEntryWidgetState extends State<TimeEntryWidget> {
  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) => Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Center(
            child: Container(
                decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(10),
                    color: Color(0xff1E1E1E)),
                width: constraints.maxWidth * .95,
                height: constraints.maxHeight * (0.1),
                child: Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.end,
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(widget.timeEntry.description),
                          (Text(widget.timeEntry.duration
                              .toString()
                              .split('.')
                              .first)),
                        ],
                      ),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(widget.timeEntry.categoryName),
                          Icon(Icons.play_arrow),
                        ],
                      )
                    ],
                  ),
                )),
          )
        ],
      ),
    );
  }
}
