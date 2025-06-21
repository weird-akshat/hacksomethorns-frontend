import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:flutter_dotenv/flutter_dotenv.dart';

Future<Map<String, dynamic>?> getUserTimeAnalytics({
  required String userId,
  required DateTime start,
  required DateTime end,
}) async {
  print('object');
  final String apiUrl = dotenv.env['API_URL']!;
  final uri = Uri.parse(
    "${apiUrl}api/users/$userId/time-entries/analytics/"
    "?_startTime=${start.toIso8601String()}&_endTime=${end.toIso8601String()}",
  );

  try {
    final response = await http.get(uri);

    if (response.statusCode == 200) {
      print(response);
      return jsonDecode(response.body);
    } else {
      print("Failed to fetch analytics: ${response.statusCode}");
      print("Response body: ${response.body}");
      return null;
    }
  } catch (e) {
    print("Error fetching analytics: $e");
    return null;
  }
}
