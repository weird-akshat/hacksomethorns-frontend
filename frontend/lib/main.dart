import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:frontend/time_tracking/time_tracking_logging/pages/time_tracking_page.dart';
import 'package:frontend/time_tracking/time_tracking_analysis/pages/category_analytics.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();

  SystemChrome.setPreferredOrientations([
    DeviceOrientation.portraitUp,
    DeviceOrientation.portraitDown,
  ]).then((_) {
    runApp(const MyApp());
  });
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: CategoryAnalytics(),
      theme: ThemeData.light(),
    );
  }
}
