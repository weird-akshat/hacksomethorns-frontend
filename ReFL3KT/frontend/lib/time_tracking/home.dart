import 'package:flutter/material.dart';
// import 'package:frontend/ai_scheduler.dart';
import 'package:frontend/goal_tracking/pages/goal_root_page.dart';
import 'package:frontend/providers/user_provider.dart';
import 'package:frontend/task_scheduler.dart';
import 'package:frontend/time_tracking/time_tracking_analysis/pages/analytics_screen.dart';
import 'package:frontend/time_tracking/time_tracking_analysis/pages/category_analytics.dart';
import 'package:frontend/time_tracking/time_tracking_logging/pages/time_tracking_page.dart';
import 'package:frontend/time_tracking/time_tracking_logging/pages/new_time_entry_sheet.dart';
import 'package:frontend/providers/theme_provider.dart';
import 'package:frontend/time_tracking/time_tracking_logging/configuration.dart';
import 'package:frontend/providers/category_provider.dart';
import 'package:frontend/providers/timelog_provider.dart';
import 'package:frontend/providers/current_time_entry_provider.dart';
import 'package:frontend/user_auth/api_service_auth.dart';
import 'package:frontend/user_auth/login_screen.dart';
import 'package:provider/provider.dart';
// Add these imports

class Home extends StatefulWidget {
  const Home({super.key});

  @override
  State<Home> createState() => _HomeState();
}

class _HomeState extends State<Home> {
  final GlobalKey<ScaffoldState> scaffoldKey = GlobalKey<ScaffoldState>();
  Widget currentWidgetPage = TimeTrackingPage();
  bool isLoading = true;
  // bool isLoading = true;
  bool _hasLoaded = false;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (!_hasLoaded) {
      _hasLoaded = true;
      _loadData();
    }
  }

  @override
  void initState() {
    super.initState();
    // _loadData();
  }

  Future<void> _loadData() async {
    setState(() => isLoading = true);
    final categoryProvider =
        Provider.of<CategoryProvider>(context, listen: false);
    if (categoryProvider.isEmpty()) {
      await categoryProvider
          .loadCategories(Provider.of<UserProvider>(context).userId!);
    }

    final timelogProvider =
        Provider.of<TimelogProvider>(context, listen: false);
    if (timelogProvider.isEmpty()) {
      await timelogProvider.loadTimeEntries(
          Provider.of<UserProvider>(context, listen: false).userId!);
    }

    final currentEntryProvider =
        Provider.of<CurrentTimeEntryProvider>(context, listen: false);
    await currentEntryProvider.loadCurrentEntry(
        Provider.of<UserProvider>(context, listen: false).userId!);

    setState(() => isLoading = false);
  }

  // Logout function
  Future<void> _logout() async {
    // Clear user provider
    Provider.of<UserProvider>(context, listen: false).clearUser();

    // Call API service logout
    await AuthApiService().signOut();

    // Navigate to login screen and clear history
    Navigator.of(context).pushAndRemoveUntil(
      MaterialPageRoute(builder: (context) => const LoginScreen()),
      (Route<dynamic> route) => false,
    );
  }

  void _openHomeDrawer() {
    scaffoldKey.currentState!.openDrawer();
  }

  @override
  Widget build(BuildContext context) {
    final themeProvider = Provider.of<ThemeProvider>(context);
    print("userd id");
    print(Provider.of<UserProvider>(context).userId);

    return Scaffold(
      key: scaffoldKey,
      appBar: currentWidgetPage.runtimeType == GoalRootPage
          ? null
          : AppBar(
              actions: [
                if (!(currentWidgetPage is CategoryAnalytics ||
                    currentWidgetPage is AnalyticsScreen ||
                    currentWidgetPage is GoalRootPage ||
                    currentWidgetPage is TaskSchedulerHome))
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
                    themeProvider.isDarkMode
                        ? Icons.dark_mode
                        : Icons.light_mode,
                  ),
                  onPressed: themeProvider.toggleTheme,
                ),
              ],
              title: Text(
                currentWidgetPage is CategoryAnalytics
                    ? 'Category Analytics'
                    : currentWidgetPage is AnalyticsScreen
                        ? 'Analytics'
                        : currentWidgetPage is TaskSchedulerHome
                            ? 'AI Task Scheduler'
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
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            DrawerHeader(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [Colors.blueAccent, Colors.lightBlueAccent],
                ),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.end,
                children: const [
                  Text(
                    'Menu',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  SizedBox(height: 8),
                  // Text(
                  //   'Navigate through sections',
                  //   style: TextStyle(
                  //     color: Colors.white70,
                  //     fontSize: 14,
                  //   ),
                  // ),
                ],
              ),
            ),
            Expanded(
              child: ListView(
                children: [
                  ListTile(
                    leading: const Icon(Icons.timer),
                    title: const Text('Time Tracking'),
                    onTap: () {
                      Navigator.of(context).pop();
                      setState(() {
                        currentWidgetPage = const TimeTrackingPage();
                      });
                    },
                  ),
                  ListTile(
                    leading: const Icon(Icons.pie_chart),
                    title: const Text('Category Analytics'),
                    onTap: () {
                      Navigator.of(context).pop();
                      setState(() {
                        currentWidgetPage = const CategoryAnalytics();
                      });
                    },
                  ),
                  ListTile(
                    leading: const Icon(Icons.bar_chart),
                    title: const Text('Analytics'),
                    onTap: () {
                      Navigator.of(context).pop();
                      setState(() {
                        currentWidgetPage = const AnalyticsScreen();
                      });
                    },
                  ),
                  ListTile(
                    leading: const Icon(Icons.flag),
                    title: const Text('Goal Overview'),
                    onTap: () {
                      Navigator.of(context).pop();
                      setState(() {
                        currentWidgetPage = GoalRootPage(_openHomeDrawer);
                      });
                    },
                  ),
                  ListTile(
                    leading: const Icon(Icons.calendar_today),
                    title: const Text('AI Task Scheduler'),
                    onTap: () {
                      Navigator.of(context).pop();
                      setState(() {
                        currentWidgetPage = TaskSchedulerHome(
                          userId:
                              Provider.of<UserProvider>(context, listen: false)
                                  .userId!,
                        );
                      });
                    },
                  ),
                  const Divider(),
                  ListTile(
                    leading: const Icon(Icons.logout, color: Colors.redAccent),
                    title: const Text('Logout'),
                    onTap: _logout,
                  ),
                ],
              ),
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
