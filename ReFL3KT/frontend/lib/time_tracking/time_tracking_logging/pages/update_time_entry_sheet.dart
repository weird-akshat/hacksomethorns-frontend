import 'package:flutter/material.dart';
import 'package:frontend/api_methods/fetch_time_entries.dart';
import 'package:frontend/api_methods/post_time_entry.dart';
import 'package:frontend/api_methods/update_time_entry.dart';
import 'package:frontend/providers/theme_provider.dart';
import 'package:frontend/providers/timelog_provider.dart';
import 'package:frontend/time_tracking/Methods/pick_date_time.dart';
import 'package:frontend/time_tracking/entities/time_entry.dart';
import 'package:frontend/time_tracking/time_tracking_analysis/widgets/category_picker.dart';
import 'package:frontend/time_tracking/time_tracking_logging/configuration.dart';
import 'package:provider/provider.dart';

class UpdateTimeEntrySheet extends StatefulWidget {
  UpdateTimeEntrySheet({super.key, required this.timeEntry});
  TimeEntry timeEntry;

  @override
  State<UpdateTimeEntrySheet> createState() => _TimeEntrySheetState();
}

class _TimeEntrySheetState extends State<UpdateTimeEntrySheet> {
  late DateTime newStartTime;
  late DateTime newEndTime;
  late String desc;
  late TextEditingController descriptionController;
  late int selectedCategoryId;
  late String selectedCategoryName;
  late DateTime originalDate; // Store original date for provider updates
  bool isLoading = false; // Add loading state

  @override
  void initState() {
    super.initState();
    newStartTime = widget.timeEntry.startTime;

    // Fix: Handle null endTime safely
    newEndTime = widget.timeEntry.endTime ?? DateTime.now();

    desc = widget.timeEntry.description;
    descriptionController = TextEditingController(text: desc);
    selectedCategoryId = widget.timeEntry.categoryId ?? -1;
    selectedCategoryName = widget.timeEntry.categoryName ?? 'Uncategorized';
    originalDate = DateTime(
      widget.timeEntry.startTime.year,
      widget.timeEntry.startTime.month,
      widget.timeEntry.startTime.day,
    );
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
                    onPressed: isLoading
                        ? null
                        : () {
                            Navigator.pop(context);
                          }),
                Text(
                  'Time Entry',
                  style: TextStyle(
                      color: textColor,
                      fontSize: 20,
                      fontWeight: FontWeight.bold),
                ),
                TextButton(
                  onPressed: isLoading
                      ? null
                      : () async {
                          setState(() {
                            isLoading = true;
                          });

                          final timelogProvider = Provider.of<TimelogProvider>(
                              context,
                              listen: false);

                          // Store original values for comparison
                          final originalStartTime = widget.timeEntry.startTime;
                          final originalEndTime = widget.timeEntry.endTime;
                          final originalDescription =
                              widget.timeEntry.description;
                          final originalCategoryId =
                              widget.timeEntry.categoryId;
                          final originalCategoryName =
                              widget.timeEntry.categoryName;

                          // Update the time entry object
                          widget.timeEntry.description =
                              descriptionController.text;
                          widget.timeEntry.startTime = newStartTime;
                          widget.timeEntry.endTime = newEndTime;
                          widget.timeEntry.categoryId = selectedCategoryId;
                          widget.timeEntry.categoryName = selectedCategoryName;

                          try {
                            // Make API call to persist changes
                            final success =
                                await updateTimeEntry(widget.timeEntry);

                            if (success) {
                              // Check if the date changed (entry moved to different day)
                              final newDate = DateTime(newStartTime.year,
                                  newStartTime.month, newStartTime.day);
                              final oldDate = DateTime(
                                  originalStartTime.year,
                                  originalStartTime.month,
                                  originalStartTime.day);

                              if (newDate != oldDate) {
                                // Entry moved to a different day - remove from old date and add to new date

                                // Remove from old date
                                if (timelogProvider.map.containsKey(oldDate)) {
                                  timelogProvider.map[oldDate]?.removeWhere(
                                      (entry) =>
                                          entry.timeEntryId ==
                                              widget.timeEntry
                                                  .timeEntryId || // Use ID if available
                                          (entry.startTime ==
                                                  originalStartTime &&
                                              entry.endTime ==
                                                  originalEndTime &&
                                              entry.description ==
                                                  originalDescription));

                                  // Remove the date key if no entries left
                                  if (timelogProvider.map[oldDate]?.isEmpty ==
                                      true) {
                                    timelogProvider.map.remove(oldDate);
                                  }
                                }

                                // Add to new date
                                timelogProvider.addTimeEntry(
                                    newDate, widget.timeEntry);
                              } else {
                                // Entry stayed on same day - just notify listeners to refresh UI
                                timelogProvider
                                    .sort(); // Re-sort in case time changed
                                timelogProvider.notifyListeners();
                              }

                              Navigator.pop(context);

                              // Show success message
                              ScaffoldMessenger.of(context).showSnackBar(
                                SnackBar(
                                  content:
                                      Text('Time entry updated successfully'),
                                  backgroundColor: Colors.green,
                                  duration: Duration(seconds: 2),
                                ),
                              );
                            } else {
                              throw Exception('Failed to update entry');
                            }
                          } catch (e) {
                            // Revert changes if API call failed
                            widget.timeEntry.description = originalDescription;
                            widget.timeEntry.startTime = originalStartTime;
                            widget.timeEntry.endTime = originalEndTime;
                            widget.timeEntry.categoryId = originalCategoryId;
                            widget.timeEntry.categoryName =
                                originalCategoryName;

                            // Show error message
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(
                                content: Text(
                                    'Failed to update time entry: ${e.toString()}'),
                                backgroundColor: Colors.red,
                                duration: Duration(seconds: 3),
                              ),
                            );

                            print("Failed to update entry: $e");
                          } finally {
                            if (mounted) {
                              setState(() {
                                isLoading = false;
                              });
                            }
                          }
                        },
                  style: ButtonStyle(
                    shape: WidgetStatePropertyAll(RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10))),
                    backgroundColor: WidgetStatePropertyAll(cardColor),
                  ),
                  child: isLoading
                      ? SizedBox(
                          width: 20,
                          height: 20,
                          child: CircularProgressIndicator(
                            strokeWidth: 2,
                            valueColor:
                                AlwaysStoppedAnimation<Color>(accentColor),
                          ),
                        )
                      : Text(
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
                enabled: !isLoading, // Disable input when loading
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
                  disabledBorder: OutlineInputBorder(
                    borderSide: BorderSide(color: borderColor.withOpacity(0.5)),
                    borderRadius: BorderRadius.circular(10),
                  ),
                ),
                onChanged: (value) {
                  desc = value;
                },
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
                    // Handle the case when no category is selected or category is cleared
                    selectedCategoryId = -1;
                    selectedCategoryName = 'Uncategorized';
                  }
                },
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
                                        newStartTime
                                            .toLocal()
                                            .toString()
                                            .substring(0, 16),
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
                        onPressed: isLoading
                            ? null
                            : () async {
                                newStartTime =
                                    await pickDateTime(newStartTime, context);
                                setState(() {});
                              },
                      ),
                    ),
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
                                  child: Icon(Icons.pause,
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
                                      Text('End Time',
                                          style: TextStyle(
                                              color: hintColor, fontSize: 14)),
                                      SizedBox(height: 4),
                                      Text(
                                        newEndTime.toString().substring(0, 16),
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
                        onPressed: isLoading
                            ? null
                            : () async {
                                newEndTime =
                                    await pickDateTime(newEndTime, context);
                                setState(() {});
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
                            'Duration: ${newEndTime.difference(newStartTime).inHours}h ${newEndTime.difference(newStartTime).inMinutes % 60}m',
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
