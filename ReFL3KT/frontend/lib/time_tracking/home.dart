import 'package:flutter/material.dart';
import 'package:frontend/goal_tracking/pages/goal_root_page.dart';
import 'package:frontend/time_tracking/time_tracking_analysis/pages/analytics_screen.dart';
import 'package:frontend/time_tracking/time_tracking_analysis/pages/category_analytics.dart';
import 'package:frontend/time_tracking/time_tracking_logging/pages/time_tracking_page.dart';
import 'package:frontend/time_tracking/time_tracking_logging/pages/new_time_entry_sheet.dart';
import 'package:frontend/providers/theme_provider.dart';
import 'package:frontend/time_tracking/time_tracking_logging/configuration.dart';
import 'package:frontend/providers/category_provider.dart';
import 'package:frontend/providers/timelog_provider.dart';
import 'package:frontend/providers/current_time_entry_provider.dart';
import 'package:provider/provider.dart';

class Home extends StatefulWidget {
  const Home({super.key});

  @override
  State<Home> createState() => _HomeState();
}

class _HomeState extends State<Home> {
  Widget currentWidgetPage = const TimeTrackingPage();
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  Future<void> _loadData() async {
    setState(() => isLoading = true);
    final categoryProvider =
        Provider.of<CategoryProvider>(context, listen: false);
    if (categoryProvider.isEmpty()) {
      await categoryProvider.loadCategories('1');
    }

    final timelogProvider =
        Provider.of<TimelogProvider>(context, listen: false);
    if (timelogProvider.isEmpty()) {
      await timelogProvider.loadTimeEntries();
    }

    final currentEntryProvider =
        Provider.of<CurrentTimeEntryProvider>(context, listen: false);
    await currentEntryProvider.loadCurrentEntry("1");

    setState(() => isLoading = false);
  }

  @override
  Widget build(BuildContext context) {
    final themeProvider = Provider.of<ThemeProvider>(context);

    return Scaffold(
      appBar: AppBar(
        actions: [
          if (!(currentWidgetPage is CategoryAnalytics ||
              currentWidgetPage is AnalyticsScreen))
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: GestureDetector(
                onTap: () {
                  showModalBottomSheet(
                    context: context,
                    isScrollControlled: true,
                    shape: const RoundedRectangleBorder(
                      borderRadius:
                          BorderRadius.vertical(top: Radius.circular(25)),
                    ),
                    builder: (context) => const FractionallySizedBox(
                      heightFactor: 0.6,
                      child: NewTimeEntrySheet(),
                    ),
                  );
                },
                child: Icon(
                  Icons.add,
                  color: themeProvider.isDarkMode
                      ? timeEntryWidgetTextColorDark
                      : timeEntryWidgetTextColorLight,
                ),
              ),
            ),
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: _loadData,
          ),
          IconButton(
            icon: Icon(
              themeProvider.isDarkMode ? Icons.dark_mode : Icons.light_mode,
            ),
            onPressed: themeProvider.toggleTheme,
          ),
        ],
        title: Text(
          currentWidgetPage is CategoryAnalytics
              ? 'Category Analytics'
              : currentWidgetPage is AnalyticsScreen
                  ? 'Analytics'
                  : 'Timer',
          style: TextStyle(
            fontWeight: FontWeight.bold,
            color: themeProvider.isDarkMode
                ? timeEntryWidgetTextColorDark
                : timeEntryWidgetTextColorLight,
          ),
        ),
      ),
      drawer: Drawer(
        child: ListView(
          children: [
            const Padding(
              padding: EdgeInsets.all(8.0),
              child: Text('Menu'),
            ),
            const Divider(),
            ListTile(
              title: const Text('Time Tracking Page'),
              onTap: () {
                Navigator.of(context).pop();
                setState(() {
                  currentWidgetPage = const TimeTrackingPage();
                });
              },
            ),
            ListTile(
              title: const Text('Category Wise Analytics'),
              onTap: () {
                Navigator.of(context).pop();
                setState(() {
                  currentWidgetPage = const CategoryAnalytics();
                });
              },
            ),
            ListTile(
              title: const Text('Analytics'),
              onTap: () {
                Navigator.of(context).pop();
                setState(() {
                  currentWidgetPage = const AnalyticsScreen();
                });
              },
            ),
            ListTile(
              title: const Text('Goal Root Page'),
              onTap: () {
                Navigator.of(context).pop();
                setState(() {
                  currentWidgetPage = const GoalRootPage();
                });
              },
            ),
          ],
        ),
      ),
      body: isLoading
          ? const Center(child: CircularProgressIndicator())
          : currentWidgetPage,
    );
  }
}
