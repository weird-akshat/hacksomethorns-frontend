import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:frontend/goal_tracking/configuration.dart';
import 'package:frontend/goal_tracking/pages/goal_root_page.dart';
// import 'package:frontend/goal_tracking/pages/goal_root_page.dart';
import 'package:frontend/goal_tracking/pages/tree_screen.dart';
import 'package:frontend/providers/category_provider.dart';
import 'package:frontend/providers/current_time_entry_provider.dart';
import 'package:frontend/providers/theme_provider.dart';
import 'package:frontend/providers/timelog_provider.dart';
import 'package:frontend/providers/user_provider.dart';
import 'package:frontend/time_tracking/home.dart';
import 'package:frontend/time_tracking/time_tracking_analysis/pages/category_detailed_analytics.dart';
import 'package:frontend/time_tracking/time_tracking_logging/pages/time_tracking_page.dart';
import 'package:frontend/time_tracking/time_tracking_analysis/pages/category_analytics.dart';
import 'package:frontend/user_auth/login_screen.dart';
import 'package:provider/provider.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await dotenv.load(fileName: ".env");

  initConfig();

  SystemChrome.setPreferredOrientations([
    DeviceOrientation.portraitUp,
    DeviceOrientation.portraitDown,
  ]).then((_) {
    runApp(
      MultiProvider(
        providers: [
          ChangeNotifierProvider(create: (_) => ThemeProvider()),
          ChangeNotifierProvider(create: (_) => TimelogProvider()),
          ChangeNotifierProvider(create: (_) => CategoryProvider()),
          ChangeNotifierProvider(create: (_) => CurrentTimeEntryProvider()),
          ChangeNotifierProvider(
              create: (_) => UserProvider()), // <-- Add this line
        ],
        child: const MyApp(),
      ),
    );
  });
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return Consumer<ThemeProvider>(
      builder: (context, themeProvider, _) {
        return MaterialApp(
          debugShowCheckedModeBanner: false,
          home: LoginScreen(),
          theme: ThemeData(
            brightness: Brightness.light,
            primarySwatch: Colors.blue,
          ),
          darkTheme: ThemeData(
            brightness: Brightness.dark,
            primarySwatch: Colors.blue,
          ),
          themeMode: themeProvider.themeMode ?? ThemeMode.system,
        );
      },
    );
  }
}
