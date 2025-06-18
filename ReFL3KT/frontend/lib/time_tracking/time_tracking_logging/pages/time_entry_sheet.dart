import 'package:flutter/material.dart';
import 'package:frontend/api_methods/fetch_time_entries.dart';
import 'package:frontend/api_methods/post_time_entry.dart';
import 'package:frontend/providers/theme_provider.dart';
import 'package:frontend/time_tracking/Methods/pick_date_time.dart';
import 'package:frontend/time_tracking/entities/time_entry.dart';
import 'package:frontend/time_tracking/time_tracking_analysis/widgets/category_picker.dart';
import 'package:frontend/time_tracking/time_tracking_logging/configuration.dart';
import 'package:provider/provider.dart';

class TimeEntrySheet extends StatefulWidget {
  const TimeEntrySheet({super.key, required this.timeEntry});
  final TimeEntry timeEntry;
  @override
  State<TimeEntrySheet> createState() => _TimeEntrySheetState();
}

class _TimeEntrySheetState extends State<TimeEntrySheet> {
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

  late DateTime newStartTime;
  late DateTime newEndTime;
  late String desc;
  late TextEditingController descriptionController;

  @override
  void initState() {
    super.initState();
    newStartTime = widget.timeEntry.startTime;
    newEndTime = widget.timeEntry.endTime!;
    desc = widget.timeEntry.description;
    descriptionController = TextEditingController(text: desc);
  }

  @override
  void dispose() {
    descriptionController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final themeProvider = Provider.of<ThemeProvider>(context);
    final isDarkMode = themeProvider.isDarkMode;

    // Define colors based on theme using exact names from config
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
                  'Time Entry',
                  style: TextStyle(
                      color: textColor,
                      fontSize: 20,
                      fontWeight: FontWeight.bold),
                ),
                TextButton(
                  onPressed: () async {
                    final newEntry = TimeEntry(
                      description: descriptionController.text,
                      timeEntryId: widget.timeEntry.timeEntryId,
                      userId: widget.timeEntry.userId,
                      startTime: newStartTime,
                      endTime: newEndTime,
                      categoryId: widget.timeEntry.categoryId,
                      categoryName: widget.timeEntry.categoryName,
                    );

                    // final success = await postTimeEntry(newEntry);
                    final success = true;

                    if (success) {
                      print("Posted successfully, now fetching entries...");
                      Navigator.pop(context);
                      // await fetchTimeEntries();
                    } else {
                      print("Failed to post entry.");
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

            // Description Field
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
                onChanged: (value) {
                  desc = value;
                },
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: CategoryPicker(
                onCategorySelected: (cat) {},
              ),
            ),

            // Start Time Button
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
                                      Text(
                                        'Start Time',
                                        style: TextStyle(
                                            color: hintColor, fontSize: 14),
                                      ),
                                      SizedBox(height: 4),
                                      Text(
                                        newStartTime
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
                        onPressed: () async {
                          newStartTime =
                              await pickDateTime(newStartTime, context);
                          setState(() {});
                        },
                      ),
                    ),
                    // End Time Button
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
                                      Text(
                                        'End Time',
                                        style: TextStyle(
                                            color: hintColor, fontSize: 14),
                                      ),
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
                        onPressed: () async {
                          newEndTime = await pickDateTime(newEndTime, context);
                          setState(() {});
                        },
                      ),
                    ),

                    // Duration Display
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

            // Category Picker
          ],
        ),
      ),
    );
  }
}
