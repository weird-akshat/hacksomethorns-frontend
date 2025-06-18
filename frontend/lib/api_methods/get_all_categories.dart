import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:flutter/material.dart';
import 'package:frontend/time_tracking/entities/category.dart';

Future<List<Category>> getAllCategories(String userId) async {
  final String apiUrl = dotenv.env['API_URL']!;
  final uri = Uri.parse("${apiUrl}api/users/$userId/categories/");

  try {
    final response = await http.get(uri);

    if (response.statusCode == 200) {
      final List<dynamic> jsonList = jsonDecode(response.body);
      return jsonList.map((json) {
        return Category(
          json['user_id'],
          json['category_id'],
          json['name'],
          Color(int.parse(json['color'], radix: 16)).withOpacity(1.0),
        );
      }).toList();
    } else {
      print("Failed to fetch categories: ${response.statusCode}");
      return [];
    }
  } catch (e) {
    print("Error fetching categories: $e");
    return [];
  }
}
