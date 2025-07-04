import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:flutter/material.dart';
import 'package:frontend/time_tracking/entities/category.dart';

Future<bool> updateCategory(Category category) async {
  final String apiUrl = dotenv.env['API_URL']!;
  final uri = Uri.parse(
      "${apiUrl}api/users/${category.userId}/categories/${category.categoryId}/");

  final Map<String, dynamic> requestBody = {
    "name": category.name,
    "color":
        category.color.value.toRadixString(16).padLeft(8, '0').toUpperCase(),
  };

  try {
    final response = await http.put(
      uri,
      headers: {"Content-Type": "application/json"},
      body: jsonEncode(requestBody),
    );

    if (response.statusCode == 200) {
      print("Category updated successfully");
      return true;
    } else {
      print("Failed to update category: ${response.statusCode}");
      print("Response body: ${response.body}");
      return false;
    }
  } catch (e) {
    print("Error updating category: $e");
    return false;
  }
}
