import 'package:flutter/material.dart';
import 'package:flutter_staggered_animations/flutter_staggered_animations.dart';
import 'package:frontend/providers/category_provider.dart';
import 'package:frontend/providers/theme_provider.dart';
import 'package:frontend/providers/user_provider.dart';
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
      categoryProvider.loadCategories(
          Provider.of<UserProvider>(context, listen: false).userId!);
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
      child: Consumer<ThemeProvider>(
        builder: (context, themeProvider, child) {
          return InkWell(
            onTap: () => _pickDate(isStart: isStart),
            borderRadius: BorderRadius.circular(12),
            splashColor: themeProvider.primaryAccent.withOpacity(0.1),
            highlightColor: themeProvider.primaryAccent.withOpacity(0.05),
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 200),
              padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 20),
              decoration: BoxDecoration(
                color: themeProvider.cardColor,
                border: Border.all(
                  color: themeProvider.borderColor,
                  width: 1.5,
                ),
                borderRadius: BorderRadius.circular(12),
                boxShadow: [
                  BoxShadow(
                    color: themeProvider.isDarkMode
                        ? Colors.black.withOpacity(0.3)
                        : Colors.grey.withOpacity(0.1),
                    blurRadius: 8,
                    offset: const Offset(0, 2),
                  ),
                ],
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: themeProvider.primaryAccent.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Icon(
                      Icons.calendar_today_rounded,
                      color: themeProvider.primaryAccent,
                      size: 20,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        label,
                        style: TextStyle(
                          fontSize: 12,
                          color: themeProvider.textColor.withOpacity(0.7),
                          fontWeight: FontWeight.w500,
                          letterSpacing: 0.5,
                        ),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        DateFormat.yMMMd().format(value),
                        style: TextStyle(
                          fontSize: 16,
                          color: themeProvider.textColor,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(width: 8),
                  Icon(
                    Icons.keyboard_arrow_down_rounded,
                    color: themeProvider.textColor.withOpacity(0.5),
                    size: 18,
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final categories = Provider.of<CategoryProvider>(context).list;
    return Scaffold(
      body: Center(
        child: Column(
          children: [
            _dateSelector("Start Date", newStartTime, true),
            _dateSelector("End Date", newEndTime, false),
            Expanded(
              child: AnimationLimiter(
                child: ListView.builder(
                  itemCount: categories.length,
                  itemBuilder: (context, index) =>
                      AnimationConfiguration.staggeredList(
                    position: index,
                    child: GestureDetector(
                      onTap: () {
                        Navigator.of(context).push(MaterialPageRoute(
                          builder: (context) => CategoryDetailedAnalytics(
                            category: categories[index],
                            endTime: newEndTime,
                            startTime: newStartTime,
                          ),
                        ));
                      },
                      child: SlideAnimation(
                        child: FadeInAnimation(
                            child: CategoryWidget(category: categories[index])),
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
