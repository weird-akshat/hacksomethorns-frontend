import 'package:flutter/material.dart';
import 'package:frontend/time_tracking/Methods/pick_date_time.dart';
import 'package:frontend/time_tracking/entities/time_entry.dart';

class ShowcaseTimeEntrySheet extends StatefulWidget {
  const ShowcaseTimeEntrySheet({super.key, required this.timeEntry});
  final TimeEntry timeEntry;
  @override
  State<ShowcaseTimeEntrySheet> createState() => _TimeEntrySheetState();
}
//add duraiton and category option

class _TimeEntrySheetState extends State<ShowcaseTimeEntrySheet> {
  Widget buildGrabHandle() {
    return Center(
      child: Container(
        margin: const EdgeInsets.only(top: 8),
        width: 40,
        height: 5,
        decoration: BoxDecoration(
          color: Colors.grey[600],
          borderRadius: BorderRadius.circular(10),
        ),
      ),
    );
  }

  late DateTime newStartTime;
  late DateTime newEndTime;
  late String desc;

  @override
  void initState() {
    super.initState();
    newStartTime = widget.timeEntry.startTime;
    newEndTime = widget.timeEntry.endTime!;
    desc = widget.timeEntry.description;
  }

  @override
  Widget build(BuildContext context) {
    // String newDescription;
    return Container(
      color: Colors.black,
      width: double.infinity,
      child: Padding(
        padding: const EdgeInsets.all(8.0),
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: buildGrabHandle(),
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                IconButton(
                    style: ButtonStyle(
                        iconColor: WidgetStatePropertyAll(Colors.white),
                        shape: WidgetStatePropertyAll(RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(10))),
                        backgroundColor: WidgetStatePropertyAll(
                          const Color(0xff1a1a1a),
                        )),
                    icon: Icon(Icons.close),
                    onPressed: () {
                      Navigator.pop(context);
                    }),
                Text(
                  'Time Entry',
                  style: TextStyle(
                      color: Colors.white,
                      fontSize: 20,
                      fontWeight: FontWeight.bold),
                ),
                TextButton(
                  onPressed: () {},
                  style: ButtonStyle(
                      iconColor: WidgetStatePropertyAll(Colors.white),
                      shape: WidgetStatePropertyAll(RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10))),
                      backgroundColor: WidgetStatePropertyAll(
                        const Color(0xff1a1a1a),
                      )),
                  child: Text(
                    'Save',
                    style: TextStyle(
                        color: Colors.white,
                        fontSize: 15,
                        fontWeight: FontWeight.bold),
                  ),
                )
              ],
            ),
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: TextField(
                cursorColor: Colors.white,
                decoration: InputDecoration(
                  filled: true,
                  fillColor: Color(0xff1a1a1a),
                  hintText: "Description ",
                  enabledBorder: OutlineInputBorder(
                    borderSide: BorderSide(
                      color: Color(0xff1a1a1a),
                    ),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderSide: BorderSide(
                      color: Color(0xff1a1a1a),
                    ),
                    borderRadius: BorderRadius.circular(10),
                  ),
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: TextButton(
                style: ButtonStyle(
                    iconColor: WidgetStatePropertyAll(Colors.white),
                    shape: WidgetStatePropertyAll(RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10))),
                    backgroundColor: WidgetStatePropertyAll(
                      const Color(0xff1a1a1a),
                    )),
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
                            color: Colors.grey,
                            child: Icon(Icons.play_arrow)),
                        Padding(
                          padding: const EdgeInsets.fromLTRB(8.0, 0, 0, 0),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Text(
                                'Start Time',
                                style: TextStyle(color: Colors.grey),
                              ),
                              Text(
                                newStartTime.toString().substring(0, 16),
                                style: TextStyle(color: Colors.grey),
                              )
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                onPressed: () {
                  // print(widget.timeEntry.startTime);
                },
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: TextButton(
                style: ButtonStyle(
                    iconColor: WidgetStatePropertyAll(Colors.white),
                    shape: WidgetStatePropertyAll(RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10))),
                    backgroundColor: WidgetStatePropertyAll(
                      const Color(0xff1a1a1a),
                    )),
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
                            color: Colors.grey,
                            child: Icon(Icons.pause)),
                        Padding(
                          padding: const EdgeInsets.fromLTRB(8.0, 0, 0, 0),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Text(
                                'End Time',
                                style: TextStyle(color: Colors.grey),
                              ),
                              Text(
                                newEndTime.toString().substring(0, 16),
                                style: TextStyle(color: Colors.grey),
                              )
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                onPressed: () {
                  // print(widget.timeEntry.endTime);
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  DateTime? selectedDateTime;
}
