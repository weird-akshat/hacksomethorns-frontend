import 'package:flutter/material.dart';
import 'package:frontend/time_tracking/time_tracking_analysis/pages/category_analytics.dart';
import 'package:frontend/time_tracking/time_tracking_logging/pages/time_tracking_page.dart';
import 'package:frontend/time_tracking/time_tracking_logging/pages/new_time_entry_sheet.dart';
import 'package:frontend/providers/theme_provider.dart';
import 'package:frontend/time_tracking/time_tracking_logging/configuration.dart';
import 'package:provider/provider.dart';

class Home extends StatefulWidget {
  const Home({super.key});

  @override
  State<Home> createState() => _HomeState();
}

class _HomeState extends State<Home> {
  Widget currentWidgetPage = const TimeTrackingPage();

  @override
  Widget build(BuildContext context) {
    final themeProvider = Provider.of<ThemeProvider>(context);

    return Scaffold(
      appBar: AppBar(
        actions: currentWidgetPage is CategoryAnalytics
            ? [
                IconButton(
                  icon: Icon(
                    themeProvider.isDarkMode
                        ? Icons.dark_mode
                        : Icons.light_mode,
                  ),
                  onPressed: () {
                    themeProvider.toggleTheme();
                  },
                )
              ]
            : [
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
                  icon: Icon(
                    themeProvider.isDarkMode
                        ? Icons.dark_mode
                        : Icons.light_mode,
                  ),
                  onPressed: () {
                    themeProvider.toggleTheme();
                  },
                )
              ],
        title: Text(
          currentWidgetPage is CategoryAnalytics ? 'Analytics' : 'Timer',
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
          ],
        ),
      ),
      body: currentWidgetPage,
    );
  }
}
