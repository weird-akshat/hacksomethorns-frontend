// import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:frontend/time_tracking/Methods/pick_date_time.dart';
import 'package:frontend/time_tracking/entities/category.dart';
import 'package:frontend/time_tracking/time_tracking_analysis/widgets/category_widget.dart';

class CategoryAnalytics extends StatefulWidget {
  const CategoryAnalytics({super.key});

  @override
  State<CategoryAnalytics> createState() => _CategoryAnalyticsState();
}

class _CategoryAnalyticsState extends State<CategoryAnalytics> {
  late final newStartTime;
  late final newEndTime;
  final List<Category> list = [
    Category('user1', 1, 'Work', Colors.blue),
    Category('user1', 2, 'Study', Colors.green),
    Category('user1', 3, 'Exercise', Colors.red),
    Category('user1', 4, 'Leisure', Colors.orange),
    Category('user1', 5, 'Sleep', Colors.purple),
  ];

  @override
  void initState() {
    super.initState();
    newStartTime = DateTime.now();
    newEndTime = DateTime.now();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Category Analytics'),
        centerTitle: true,
      ),
      body: Center(
        child: Column(
          children: [
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
                onPressed: () async {
                  newStartTime = await pickDateTime(DateTime.now(), context);
                  print(newStartTime);
                  setState(() {});

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
                onPressed: () async {
                  newEndTime = await pickDateTime(DateTime.now(), context);
                  setState(() {});

                  // print(widget.timeEntry.endTime);
                },
              ),
            ),
            Expanded(
                child: ListView.builder(
                    itemCount: list.length,
                    itemBuilder: (context, index) =>
                        CategoryWidget(category: list[index])))
          ],
        ),
      ),
    );
  }
}
