import 'package:flutter/material.dart';
import 'package:frontend/api_methods/post_time_entry.dart';
import 'package:frontend/providers/theme_provider.dart';
import 'package:frontend/providers/timelog_provider.dart';
import 'package:frontend/providers/current_time_entry_provider.dart';
import 'package:frontend/time_tracking/Methods/pick_date_time.dart';
import 'package:frontend/time_tracking/entities/time_entry.dart';
import 'package:frontend/time_tracking/time_tracking_analysis/widgets/category_picker.dart';
import 'package:frontend/time_tracking/time_tracking_logging/configuration.dart';
import 'package:provider/provider.dart';

class NewTimeEntrySheet extends StatefulWidget {
  const NewTimeEntrySheet({super.key});

  @override
  State<NewTimeEntrySheet> createState() => _NewTimeEntrySheetState();
}

class _NewTimeEntrySheetState extends State<NewTimeEntrySheet> {
  late DateTime startTime;
  DateTime? endTime;
  late TextEditingController descriptionController;
  int? selectedCategoryId;
  String selectedCategoryName = 'Uncategorized';
  bool isCurrentTimeEntry = false;

  @override
  void initState() {
    super.initState();
    final now = DateTime.now();
    startTime = DateTime(now.year, now.month, now.day, now.hour, now.minute);
    endTime = DateTime(now.year, now.month, now.day, now.hour + 1, now.minute);
    descriptionController = TextEditingController();
    selectedCategoryId = null; // Start with no category selected
  }

  @override
  void dispose() {
    descriptionController.dispose();
    super.dispose();
  }

  Widget buildGrabHandle(bool isDarkMode) {
    return Center(
      child: Container(
        margin: const EdgeInsets.only(top: 8),
        width: 40,
        height: 5,
        decoration: BoxDecoration(
          color: isDarkMode ? Color(0xff666666) : Color(0xffAAAAAA),
          borderRadius: BorderRadius.circular(10),
        ),
      ),
    );
  }

  String _formatDuration() {
    if (endTime == null) {
      return 'Currently tracking...';
    }
    final duration = endTime!.difference(startTime);
    final hours = duration.inHours;
    final minutes = duration.inMinutes % 60;
    return 'Duration: ${hours}h ${minutes}m';
  }

  @override
  Widget build(BuildContext context) {
    final themeProvider = Provider.of<ThemeProvider>(context);
    final isDarkMode = themeProvider.isDarkMode;

    final scaffoldColor = isDarkMode ? scaffoldColorDark : scaffoldColorLight;
    final cardColor =
        isDarkMode ? timeEntryWidgetColorDark : timeEntryWidgetColorLight;
    final textColor = isDarkMode
        ? timeEntryWidgetTextColorDark
        : timeEntryWidgetTextColorLight;
    final borderColor = isDarkMode ? borderColorDark : borderColorLight;
    final accentColor =
        isDarkMode ? primaryAccentColorDark : primaryAccentColorLight;
    final hintColor =
        isDarkMode ? secondaryAccentColorDark : secondaryAccentColorLight;

    return Container(
      color: scaffoldColor,
      width: double.infinity,
      child: Padding(
        padding: const EdgeInsets.all(8.0),
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: buildGrabHandle(isDarkMode),
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                IconButton(
                    style: ButtonStyle(
                      iconColor: WidgetStatePropertyAll(accentColor),
                      shape: WidgetStatePropertyAll(RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10))),
                      backgroundColor: WidgetStatePropertyAll(cardColor),
                    ),
                    icon: Icon(Icons.close),
                    onPressed: () {
                      Navigator.pop(context);
                    }),
                Text(
                  'New Time Entry',
                  style: TextStyle(
                      color: textColor,
                      fontSize: 20,
                      fontWeight: FontWeight.bold),
                ),
                TextButton(
                  onPressed: () async {
                    final timelogProvider =
                        Provider.of<TimelogProvider>(context, listen: false);
                    final currentTimeEntryProvider =
                        Provider.of<CurrentTimeEntryProvider>(context,
                            listen: false);

                    // Create new time entry from current widget state
                    final newTimeEntry = TimeEntry(
                      userId: "0",
                      timeEntryId: "0", // Will be set by the server
                      description: descriptionController.text.trim().isEmpty
                          ? 'Untitled'
                          : descriptionController.text.trim(),
                      startTime: startTime,
                      endTime: isCurrentTimeEntry ? null : endTime,
                      //issue here if it doesn't run
                      categoryId: selectedCategoryId ?? 0,
                      categoryName: selectedCategoryName,
                    );

                    try {
                      // Make API call to create new time entry
                      final createdEntry = await postTimeEntry(newTimeEntry);

                      if (createdEntry != null) {
                        // Work directly with the API response - don't copy back to widget

                        // Add to timelog provider for completed entries
                        if (createdEntry.endTime != null) {
                          final entryDate = DateTime(
                            createdEntry.startTime.year,
                            createdEntry.startTime.month,
                            createdEntry.startTime.day,
                          );
                          timelogProvider.addTimeEntry(entryDate, createdEntry);
                        }

                        // If it's a current time entry, update the current time entry provider
                        if (createdEntry.endTime == null) {
                          currentTimeEntryProvider.setEntry(createdEntry);
                        }

                        Navigator.pop(context);

                        // Show success message based on the API response
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                            content: Text(createdEntry.endTime == null
                                ? 'Time tracking started successfully'
                                : 'Time entry created successfully'),
                            backgroundColor: Colors.green,
                            duration: Duration(seconds: 2),
                          ),
                        );
                      } else {
                        throw Exception('Failed to create entry');
                      }
                    } catch (e) {
                      // Show error message
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content: Text(
                              'Failed to create time entry: ${e.toString()}'),
                          backgroundColor: Colors.red,
                          duration: Duration(seconds: 3),
                        ),
                      );

                      print("Failed to create entry: $e");
                    }
                  },
                  style: ButtonStyle(
                    shape: WidgetStatePropertyAll(RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10))),
                    backgroundColor: WidgetStatePropertyAll(cardColor),
                  ),
                  child: Text(
                    'Save',
                    style: TextStyle(
                        color: textColor,
                        fontSize: 15,
                        fontWeight: FontWeight.bold),
                  ),
                )
              ],
            ),
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: TextField(
                controller: descriptionController,
                cursorColor: accentColor,
                style: TextStyle(color: textColor),
                decoration: InputDecoration(
                  filled: true,
                  fillColor: cardColor,
                  hintText: "Description",
                  hintStyle: TextStyle(color: hintColor),
                  enabledBorder: OutlineInputBorder(
                    borderSide: BorderSide(color: borderColor),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderSide: BorderSide(color: accentColor),
                    borderRadius: BorderRadius.circular(10),
                  ),
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: CategoryPicker(
                initialCategoryName: selectedCategoryName,
                onCategorySelected: (cat) {
                  if (cat != null) {
                    selectedCategoryId = cat.categoryId;
                    selectedCategoryName = cat.name;
                  } else {
                    selectedCategoryId = null;
                    selectedCategoryName = 'Uncategorized';
                  }
                },
              ),
            ),
            // Toggle for current time entry
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: Container(
                width: double.infinity,
                constraints: BoxConstraints(maxWidth: 316),
                decoration: BoxDecoration(
                  color: cardColor,
                  borderRadius: BorderRadius.circular(10),
                  border: Border.all(color: borderColor),
                ),
                child: CheckboxListTile(
                  title: Text(
                    'Start as current time entry',
                    style: TextStyle(color: textColor, fontSize: 16),
                  ),
                  subtitle: Text(
                    'No end time - tracks current activity',
                    style: TextStyle(color: hintColor, fontSize: 12),
                  ),
                  value: isCurrentTimeEntry,
                  onChanged: (bool? value) {
                    setState(() {
                      isCurrentTimeEntry = value ?? false;
                      if (isCurrentTimeEntry) {
                        endTime = null;
                      } else {
                        // Set default end time to 1 hour from start
                        endTime = startTime.add(Duration(hours: 1));
                      }
                    });
                  },
                  activeColor: accentColor,
                  checkColor: Colors.white,
                  side: BorderSide(color: borderColor),
                ),
              ),
            ),
            Expanded(
              child: SingleChildScrollView(
                child: Column(
                  children: [
                    Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: TextButton(
                        style: ButtonStyle(
                          shape: WidgetStatePropertyAll(RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(10))),
                          backgroundColor: WidgetStatePropertyAll(cardColor),
                        ),
                        child: Padding(
                          padding: const EdgeInsets.all(8.0),
                          child: SizedBox(
                            width: 300,
                            height: 70,
                            child: Row(
                              crossAxisAlignment: CrossAxisAlignment.center,
                              children: [
                                Container(
                                  height: 30,
                                  width: 30,
                                  decoration: BoxDecoration(
                                    color: hintColor,
                                    borderRadius: BorderRadius.circular(6),
                                  ),
                                  child: Icon(Icons.play_arrow,
                                      color: accentColor, size: 18),
                                ),
                                Padding(
                                  padding:
                                      const EdgeInsets.fromLTRB(16.0, 0, 0, 0),
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: [
                                      Text('Start Time',
                                          style: TextStyle(
                                              color: hintColor, fontSize: 14)),
                                      SizedBox(height: 4),
                                      Text(
                                        startTime.toString().substring(0, 16),
                                        style: TextStyle(
                                            color: textColor,
                                            fontSize: 16,
                                            fontWeight: FontWeight.w600),
                                      )
                                    ],
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                        onPressed: () async {
                          final newStartTime =
                              await pickDateTime(startTime, context);
                          setState(() {
                            startTime = newStartTime;
                            // If not a current time entry and end time is before start time, adjust it
                            if (!isCurrentTimeEntry &&
                                endTime != null &&
                                endTime!.isBefore(startTime)) {
                              endTime = startTime.add(Duration(hours: 1));
                            }
                          });
                        },
                      ),
                    ),
                    if (!isCurrentTimeEntry)
                      Padding(
                        padding: const EdgeInsets.all(8.0),
                        child: TextButton(
                          style: ButtonStyle(
                            shape: WidgetStatePropertyAll(
                                RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(10))),
                            backgroundColor: WidgetStatePropertyAll(cardColor),
                          ),
                          child: Padding(
                            padding: const EdgeInsets.all(8.0),
                            child: SizedBox(
                              width: 300,
                              height: 70,
                              child: Row(
                                crossAxisAlignment: CrossAxisAlignment.center,
                                children: [
                                  Container(
                                    height: 30,
                                    width: 30,
                                    decoration: BoxDecoration(
                                      color: hintColor,
                                      borderRadius: BorderRadius.circular(6),
                                    ),
                                    child: Icon(Icons.pause,
                                        color: accentColor, size: 18),
                                  ),
                                  Padding(
                                    padding: const EdgeInsets.fromLTRB(
                                        16.0, 0, 0, 0),
                                    child: Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      mainAxisAlignment:
                                          MainAxisAlignment.center,
                                      children: [
                                        Text('End Time',
                                            style: TextStyle(
                                                color: hintColor,
                                                fontSize: 14)),
                                        SizedBox(height: 4),
                                        Text(
                                          endTime
                                                  ?.toString()
                                                  .substring(0, 16) ??
                                              'Not set',
                                          style: TextStyle(
                                              color: textColor,
                                              fontSize: 16,
                                              fontWeight: FontWeight.w600),
                                        )
                                      ],
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                          onPressed: () async {
                            if (endTime != null) {
                              final newEndTime =
                                  await pickDateTime(endTime!, context);
                              setState(() {
                                endTime = newEndTime;
                              });
                            }
                          },
                        ),
                      ),
                    Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: Container(
                        width: double.infinity,
                        constraints: BoxConstraints(maxWidth: 316),
                        height: 50,
                        decoration: BoxDecoration(
                          color: cardColor,
                          borderRadius: BorderRadius.circular(10),
                        ),
                        child: Center(
                          child: Text(
                            _formatDuration(),
                            style: TextStyle(
                              color: textColor,
                              fontSize: 16,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
