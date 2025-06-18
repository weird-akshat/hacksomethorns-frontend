import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:flutter_dotenv/flutter_dotenv.dart';

import 'package:frontend/time_tracking/entities/category.dart';

Future<bool> postCategory(Category category) async {
  final String apiUrl = dotenv.env['API_URL']!;
  final uri = Uri.parse("${apiUrl}api/users/${category.userId}/categories/");

  final Map<String, dynamic> requestBody = {
    "name": category.name,
    "color":
        category.color.value.toRadixString(16).padLeft(8, '0').toUpperCase(),
  };

  try {
    final response = await http.post(
      uri,
      headers: {"Content-Type": "application/json"},
      body: jsonEncode(requestBody),
    );

    if (response.statusCode == 201 || response.statusCode == 200) {
      print("Category created successfully");
      return true;
    } else {
      print("Failed to create category: ${response.statusCode}");
      print("Response body: ${response.body}");
      return false;
    }
  } catch (e) {
    print("Error creating category: $e");
    return false;
  }
}
