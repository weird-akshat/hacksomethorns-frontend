import 'package:flutter/material.dart';
import 'package:frontend/providers/category_provider.dart';
import 'package:frontend/time_tracking/entities/category.dart';
import 'package:frontend/time_tracking/time_tracking_analysis/pages/category_detailed_analytics.dart';
import 'package:frontend/time_tracking/time_tracking_analysis/widgets/category_widget.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';

class CategoryAnalytics extends StatefulWidget {
  const CategoryAnalytics({super.key});

  @override
  State<CategoryAnalytics> createState() => _CategoryAnalyticsState();
}

class _CategoryAnalyticsState extends State<CategoryAnalytics> {
  late DateTime newStartTime;
  late DateTime newEndTime;
  List<Category> list = [];

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
    list = categoryProvider.list;
  }

  Future<void> _pickDate({required bool isStart}) async {
    final picked = await showDatePicker(
      context: context,
      initialDate: isStart ? newStartTime : newEndTime,
      firstDate: DateTime(2000),
      lastDate: DateTime(2100),
    );
    if (picked != null) {
      setState(() {
        if (isStart) {
          newStartTime = picked;
        } else {
          newEndTime = picked;
        }
      });
    }
  }

  Widget _dateSelector(String label, DateTime value, bool isStart) {
    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: InkWell(
        onTap: () => _pickDate(isStart: isStart),
        borderRadius: BorderRadius.circular(8),
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
          decoration: BoxDecoration(
            border: Border.all(color: Colors.blue),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(Icons.calendar_today, color: Colors.blue),
              const SizedBox(width: 8),
              Text(
                '$label: ${DateFormat.yMMMd().format(value)}',
                style: TextStyle(fontSize: 16),
              ),
            ],
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final categories = Provider.of<CategoryProvider>(context).list;
    return Scaffold(
      appBar: AppBar(
        title: const Text('Category Analytics'),
        centerTitle: true,
      ),
      body: Center(
        child: Column(
          children: [
            _dateSelector("Start Date", newStartTime, true),
            _dateSelector("End Date", newEndTime, false),
            Expanded(
              child: ListView.builder(
                itemCount: categories.length,
                itemBuilder: (context, index) => GestureDetector(
                  onTap: () {
                    Navigator.of(context).push(MaterialPageRoute(
                      builder: (context) => CategoryDetailedAnalytics(
                        category: categories[index],
                        endTime: newEndTime,
                        startTime: newStartTime,
                      ),
                    ));
                  },
                  child: CategoryWidget(category: categories[index]),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
