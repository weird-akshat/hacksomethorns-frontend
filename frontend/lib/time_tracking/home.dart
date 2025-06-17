import 'package:flutter/material.dart';
import 'package:frontend/time_tracking/time_tracking_analysis/pages/category_analytics.dart';
import 'package:frontend/time_tracking/time_tracking_logging/pages/time_tracking_page.dart';

class Home extends StatefulWidget {
  const Home({super.key});

  @override
  State<Home> createState() => _HomeState();
}

class _HomeState extends State<Home> {
  Widget currentWidgetPage = TimeTrackingPage();
  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    // Widget currentWidgetPage= TimeTrackingPage() ;

    TimeTrackingPage();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      drawer: Drawer(
        child: ListView(
          children: [
            DrawerHeader(
              padding: EdgeInsets.all(0),
              child: Icon(Icons.menu),
            ),
            ListTile(
              title: Text('Time Tracking Page'),
              onTap: () {
                Navigator.of(context).pop();
                setState(() {
                  // if (currentWidgetPage)
                  currentWidgetPage = TimeTrackingPage();
                });
              },
            ),
            ListTile(
              title: Text('Category Wise Analytics'),
              onTap: () {
                Navigator.of(context).pop();
                setState(() {
                  currentWidgetPage = CategoryAnalytics();
                });
              },
            ),
            ListTile(
              title: Text('Analytics'),
              onTap: () {
                Navigator.of(context).pop();
                setState(() {
                  // currentWidgetPage = CategoryAnalytics();
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
