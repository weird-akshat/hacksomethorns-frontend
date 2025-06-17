import 'package:flutter/material.dart';
import 'package:frontend/providers/theme_provider.dart';
import 'package:frontend/time_tracking/time_tracking_logging/configuration.dart';
import 'package:frontend/time_tracking/entities/time_entry.dart';
import 'package:frontend/time_tracking/time_tracking_logging/pages/time_entry_sheet.dart';
import 'package:provider/provider.dart';

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
  @override
  Widget build(BuildContext context) {
    TextStyle style = TextStyle(
        fontWeight: timeEntryWidgetFontweight,
        color: Provider.of<ThemeProvider>(context).isDarkMode
            ? timeEntryWidgetTextColorDark
            : timeEntryWidgetTextColorLight,
        overflow: TextOverflow.ellipsis);

    return Padding(
      padding: const EdgeInsets.all(timeEntryWidgetPadding),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          GestureDetector(
            onTap: () {
              showModalBottomSheet(
                context: context,
                isScrollControlled: true,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.vertical(top: Radius.circular(25)),
                ),
                builder: (context) => FractionallySizedBox(
                  heightFactor: 0.6,
                  child: TimeEntrySheet(timeEntry: widget.timeEntry),
                ),
              );
            },
            child: Container(
                decoration: BoxDecoration(
                    borderRadius: timeEntryWidgetBorderRadius,
                    border: Border(
                      top: BorderSide(
                          color: Provider.of<ThemeProvider>(context).isDarkMode
                              ? timeEntryWidgetBorderColorDark
                              : timeEntryWidgetBorderColorLight),
                      bottom: BorderSide(
                          color: Provider.of<ThemeProvider>(context).isDarkMode
                              ? timeEntryWidgetBorderColorDark
                              : timeEntryWidgetBorderColorLight),
                      left: BorderSide(
                          color: Provider.of<ThemeProvider>(context).isDarkMode
                              ? timeEntryWidgetBorderColorDark
                              : timeEntryWidgetBorderColorLight),
                      right: BorderSide(
                          color: Provider.of<ThemeProvider>(context).isDarkMode
                              ? timeEntryWidgetBorderColorDark
                              : timeEntryWidgetBorderColorLight),
                    ),
                    color: Provider.of<ThemeProvider>(context).isDarkMode
                        ? timeEntryWidgetColorDark
                        : timeEntryWidgetColorLight),
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
                            color:
                                Provider.of<ThemeProvider>(context).isDarkMode
                                    ? timeEntryWidgetTextColorDark
                                    : timeEntryWidgetTextColorLight,
                            size: MediaQuery.of(context).size.height *
                                timeEntryWidgetIconSize,
                          ),
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
