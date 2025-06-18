// import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:frontend/providers/category_provider.dart';
import 'package:frontend/time_tracking/Methods/pick_date_time.dart';
import 'package:frontend/time_tracking/entities/category.dart';
import 'package:frontend/time_tracking/time_tracking_analysis/widgets/category_widget.dart';
import 'package:frontend/time_tracking/time_tracking_analysis/widgets/date_time_picker_button.dart';
import 'package:provider/provider.dart';

class CategoryAnalytics extends StatefulWidget {
  const CategoryAnalytics({super.key});

  @override
  State<CategoryAnalytics> createState() => _CategoryAnalyticsState();
}

class _CategoryAnalyticsState extends State<CategoryAnalytics> {
  late final newStartTime;
  late final newEndTime;
  List<Category> list = [
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

    final categoryProvider =
        Provider.of<CategoryProvider>(context, listen: false);
    if (categoryProvider.isEmpty()) {
      categoryProvider.loadCategories('1'); // pass actual user ID here
    }
    setState(() {
      list = categoryProvider.list;
      print(list);
    });
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
                child: DateTimePickerButton(
                  text: "Start Time",
                )),
            Padding(
                padding: const EdgeInsets.all(8.0),
                child: DateTimePickerButton(text: "End Time")),
            Expanded(
                child: ListView.builder(
                    itemCount:
                        Provider.of<CategoryProvider>(context).list.length,
                    itemBuilder: (context, index) => CategoryWidget(
                        category: Provider.of<CategoryProvider>(context)
                            .list[index])))
          ],
        ),
      ),
    );
  }
}
