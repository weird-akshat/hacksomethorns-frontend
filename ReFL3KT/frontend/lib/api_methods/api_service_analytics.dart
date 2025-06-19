import 'dart:convert';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:http/http.dart' as http;

class ApiServiceAnalytics {
  static String baseUrl = dotenv.env['API_URL']!;
  // Returns: Map of category to duration string
  static Future<Map<String, String>> getCategoryTimeSpentMap(
    String userID,
  ) async {
    final url = Uri.parse(
      '${baseUrl}api/users/$userID/time-entries/analytics/?_startTime=2000-01-01&_endTime=2025-12-31',
    );
    print(url);
    final response = await http.get(
      url,
      headers: {'Content-Type': 'application/json'},
    );

    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      final categoryTotals = data['category_totals'] as Map<String, dynamic>;

      final Map<String, String> result = categoryTotals.map(
        (key, value) => MapEntry(key, value.toString()),
      );

      print("Time Spent per Category:");
      result.forEach((key, value) => print('$key: $value'));

      return result;
    } else {
      print('Failed to fetch category durations: ${response.statusCode}');
      return {};
    }
  }

  // Converts a duration string like "2 days, 4:24:00.696634" to total seconds
  static int parseDurationToSeconds(String durationStr) {
    try {
      final dayMatch = RegExp(r'(\d+)\s+days?').firstMatch(durationStr);
      final timePart = durationStr.contains(',')
          ? durationStr.split(',')[1].trim()
          : durationStr;

      final parts = timePart.split(':');
      int hours = int.parse(parts[0]);
      int minutes = int.parse(parts[1]);
      double secondsWithMillis = double.parse(parts[2]);
      int seconds = secondsWithMillis.floor();

      int totalSeconds = hours * 3600 + minutes * 60 + seconds;
      if (dayMatch != null) {
        int days = int.parse(dayMatch.group(1)!);
        totalSeconds += days * 86400;
      }

      return totalSeconds;
    } catch (e) {
      print('Error parsing duration: $durationStr - $e');
      return 0;
    }
  }

  // Returns: Map of category to percentage of total duration
  static Future<Map<String, double>> getCategoryPercentageMap(
    String userID,
  ) async {
    final categoryDurations = await getCategoryTimeSpentMap(userID);

    int totalSeconds = 0;
    Map<String, int> durationInSecondsMap = {};

    categoryDurations.forEach((category, durationStr) {
      int seconds = parseDurationToSeconds(durationStr);
      durationInSecondsMap[category] = seconds;
      totalSeconds += seconds;
    });

    if (totalSeconds == 0) return {};

    Map<String, double> percentageMap = {};
    durationInSecondsMap.forEach((category, seconds) {
      double percentage = (seconds / totalSeconds) * 100;
      percentageMap[category] = double.parse(percentage.toStringAsFixed(2));
    });

    print("Percentage per Category:");
    percentageMap.forEach((key, value) => print('$key: $value%'));

    return percentageMap;
  }
}
