import 'package:flutter/material.dart';
import 'package:frontend/time_tracking/entities/time_entry.dart';
import 'package:frontend/time_tracking/pages/configuration.dart';

class TimeEntryWidget extends StatefulWidget {
  final TimeEntry timeEntry;
  const TimeEntryWidget({
    required this.timeEntry,
    super.key,
  });

  @override
  State<TimeEntryWidget> createState() => _TimeEntryWidgetState();
}

class _TimeEntryWidgetState extends State<TimeEntryWidget> {
  TextStyle style = TextStyle(
      fontWeight: timeEntryWidgetFontweight,
      color: timeEntryWidgetTextColor,
      overflow: TextOverflow.ellipsis);
  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(timeEntryWidgetPadding),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Container(
              decoration: BoxDecoration(
                  borderRadius: timeEntryWidgetBorderRadius,
                  border: Border(
                    top: BorderSide(color: timeEntryWidgetBorderColor),
                    bottom: BorderSide(color: timeEntryWidgetBorderColor),
                    left: BorderSide(color: timeEntryWidgetBorderColor),
                    right: BorderSide(color: timeEntryWidgetBorderColor),
                  ),
                  color: timeEntryWidgetColor),
              width: MediaQuery.of(context).size.width *
                  timeEntryWidgetWidthMultiplier,
              height: MediaQuery.of(context).size.height *
                  timeEntryWidgetHeightMultiplier,
              child: Padding(
                padding: const EdgeInsets.all(timeEntryWidgetTextPadding),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(widget.timeEntry.description,
                            style: style.copyWith(
                                fontSize: MediaQuery.of(context).size.height *
                                    timeEntryWidgetDescriptionFontSize)),
                        (Text(
                            widget.timeEntry.duration
                                .toString()
                                .split('.')
                                .first,
                            style: style.copyWith(
                                fontSize: MediaQuery.of(context).size.height *
                                    timeEntryWidgetDurationFontSize))),
                      ],
                    ),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          widget.timeEntry.categoryName,
                          style: style.copyWith(
                              fontSize: MediaQuery.of(context).size.height *
                                  timeEntryWidgetCategoryFontSize),
                        ),
                        Icon(
                          Icons.play_arrow,
                          size: MediaQuery.of(context).size.height *
                              timeEntryWidgetIconSize,
                        ),
                      ],
                    )
                  ],
                ),
              ))
        ],
      ),
    );
  }
}
