import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:frontend/time_tracking/pages/time_tracking_page.dart';

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
      home: TimeTrackingPage(),
      theme: ThemeData.light(),
    );
  }
}
