import 'package:flutter/material.dart';
import 'package:frontend/api_methods/delete_time_entry.dart';
import 'package:frontend/providers/theme_provider.dart';
import 'package:frontend/providers/user_provider.dart';
import 'package:frontend/time_tracking/time_tracking_logging/configuration.dart';
import 'package:frontend/time_tracking/entities/time_entry.dart';
import 'package:frontend/time_tracking/time_tracking_logging/pages/time_entry_sheet.dart';
import 'package:frontend/time_tracking/time_tracking_logging/pages/update_time_entry_sheet.dart';
import 'package:provider/provider.dart';
// Import your delete API function
// import 'package:frontend/api_methods/delete_time_entry.dart';

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
    );

    return Padding(
      padding: const EdgeInsets.all(timeEntryWidgetPadding),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Dismissible(
            key: Key(widget.timeEntry.timeEntryId.toString()),
            direction: DismissDirection.endToStart,
            background: Container(
              alignment: Alignment.centerRight,
              padding: const EdgeInsets.only(right: 20),
              decoration: BoxDecoration(
                color: Colors.red,
                borderRadius: timeEntryWidgetBorderRadius,
              ),
              child: const Icon(
                Icons.delete,
                color: Colors.white,
                size: 30,
              ),
            ),
            confirmDismiss: (direction) async {
              return await showDialog<bool>(
                context: context,
                builder: (context) => AlertDialog(
                  title: const Text('Delete Time Entry'),
                  content: const Text(
                      'Are you sure you want to delete this time entry?'),
                  actions: [
                    TextButton(
                      onPressed: () => Navigator.of(context).pop(false),
                      child: const Text('Cancel'),
                    ),
                    TextButton(
                      onPressed: () => Navigator.of(context).pop(true),
                      style: TextButton.styleFrom(foregroundColor: Colors.red),
                      child: const Text('Delete'),
                    ),
                  ],
                ),
              );
            },
            onDismissed: (direction) async {
              // Set endTime to the specified value
              widget.timeEntry.endTime = DateTime(1970, 1, 1, 5, 30);

              // Call the delete API
              bool deleteSuccess = await deleteTimeEntry(
                  widget.timeEntry, Provider.of<UserProvider>(context).userId!);

              if (deleteSuccess) {
                // Show success message
                if (mounted) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text('Time entry deleted successfully'),
                      backgroundColor: Colors.green,
                    ),
                  );
                }

                // You might want to notify parent widget or provider about the deletion
                // Example: Provider.of<TimelogProvider>(context, listen: false).removeTimeEntry(widget.timeEntry);
              } else {
                // Show error message
                if (mounted) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text('Failed to delete time entry'),
                      backgroundColor: Colors.red,
                    ),
                  );
                }

                // You might want to refresh the list to restore the item
                // or handle the error case appropriately
              }
            },
            child: GestureDetector(
              onTap: () {
                showModalBottomSheet(
                  context: context,
                  isScrollControlled: true,
                  shape: const RoundedRectangleBorder(
                    borderRadius:
                        BorderRadius.vertical(top: Radius.circular(25)),
                  ),
                  builder: (context) => FractionallySizedBox(
                    heightFactor: 0.6,
                    child: UpdateTimeEntrySheet(timeEntry: widget.timeEntry),
                  ),
                );
              },
              child: Container(
                  decoration: BoxDecoration(
                      borderRadius: timeEntryWidgetBorderRadius,
                      border: Border(
                        top: BorderSide(
                            color:
                                Provider.of<ThemeProvider>(context).isDarkMode
                                    ? timeEntryWidgetBorderColorDark
                                    : timeEntryWidgetBorderColorLight),
                        bottom: BorderSide(
                            color:
                                Provider.of<ThemeProvider>(context).isDarkMode
                                    ? timeEntryWidgetBorderColorDark
                                    : timeEntryWidgetBorderColorLight),
                        left: BorderSide(
                            color:
                                Provider.of<ThemeProvider>(context).isDarkMode
                                    ? timeEntryWidgetBorderColorDark
                                    : timeEntryWidgetBorderColorLight),
                        right: BorderSide(
                            color:
                                Provider.of<ThemeProvider>(context).isDarkMode
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
                                // overflow:
                                // TextOverflow.ellipsis, // or .clip or .fade
                                maxLines: 2,
                                style: style.copyWith(
                                  fontSize: MediaQuery.of(context).size.height *
                                      timeEntryWidgetDescriptionFontSize,
                                )),
                            (Text(
                                widget.timeEntry.duration
                                    .toString()
                                    .split('.')
                                    .first,
                                style: style.copyWith(
                                    fontSize:
                                        MediaQuery.of(context).size.height *
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
            ),
          )
        ],
      ),
    );
  }
}
