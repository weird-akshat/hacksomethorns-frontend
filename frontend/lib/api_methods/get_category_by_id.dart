import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:flutter/material.dart';
import 'package:frontend/time_tracking/entities/category.dart';

Future<Category?> getCategoryById({
  required String userId,
  required int categoryId,
}) async {
  final String apiUrl = dotenv.env['API_URL']!;
  final uri = Uri.parse("${apiUrl}api/users/$userId/categories/$categoryId/");

  try {
    final response = await http.get(uri);

    if (response.statusCode == 200) {
      final Map<String, dynamic> json = jsonDecode(response.body);
      return Category(
        json['user_id'],
        json['category_id'],
        json['name'],
        Color(int.parse(json['color'], radix: 16)).withOpacity(1.0),
      );
    } else {
      print("Failed to fetch category: ${response.statusCode}");
      print("Response body: ${response.body}");
      return null;
    }
  } catch (e) {
    print("Error fetching category: $e");
    return null;
  }
}
