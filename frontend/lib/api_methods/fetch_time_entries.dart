import 'dart:convert';

import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:http/http.dart' as http;

Future<void> fetchTimeEntries() async {
  final String apiUrl = dotenv.env['API_URL']!;

  try {
    print("$apiUrl/api/time-entries");
    final response = await http.get(Uri.parse("${apiUrl}api/time-entries/"));

    if (response.statusCode == 200) {
      final data = json.decode(response.body);
      print('Data: $data');
    } else {
      print('Failed to load data. Status code: ${response.statusCode}');
    }
  } catch (e) {
    print('Error: $e');
  }
}
