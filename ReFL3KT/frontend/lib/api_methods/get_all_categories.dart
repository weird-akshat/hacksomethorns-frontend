import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:flutter/material.dart';
import 'package:frontend/time_tracking/entities/category.dart';

Future<List<Category>> getAllCategories(String userId) async {
  final String apiUrl = dotenv.env['API_URL']!;
  String? nextUrl = "${apiUrl}api/users/$userId/categories/";
  List<Category> allCategories = [];
  print(nextUrl);

  try {
    while (nextUrl != null) {
      final uri = Uri.parse(nextUrl);
      final response = await http.get(uri);

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        final List<dynamic> jsonList = data['results'];

        final List<Category> pageCategories = jsonList.map((json) {
          return Category(
            userId.toString(),
            json['_categoryId'] ?? 0,
            json['_name'] ?? '',
            parseColor(json['_color']),
          );
        }).toList();

        allCategories.addAll(pageCategories);
        nextUrl = data['next'];
      } else {
        print("Failed to fetch categories: ${response.statusCode}");
        break;
      }
    }
  } catch (e) {
    print("Error fetching categories: $e");
  }

  return allCategories;
}

Color parseColor(String? value) {
  if (value == null) return const Color(0xFFCCCCCC); // default

  try {
    return Color(int.parse("0xff$value"));
  } catch (_) {
    return const Color(0xFFCCCCCC); // fallback if parsing fails
  }
}

// Usage
