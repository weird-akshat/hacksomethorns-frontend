import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:flutter/material.dart';
import 'package:frontend/time_tracking/entities/category.dart';

Future<bool> deleteCategory({
  required String userId,
  required int categoryId,
}) async {
  final String apiUrl = dotenv.env['API_URL']!;
  final uri = Uri.parse("${apiUrl}api/users/$userId/categories/$categoryId/");

  try {
    final response = await http.delete(uri);

    if (response.statusCode == 204 || response.statusCode == 200) {
      print("Category deleted successfully");
      return true;
    } else {
      print("Failed to delete category: ${response.statusCode}");
      print("Response body: ${response.body}");
      return false;
    }
  } catch (e) {
    print("Error deleting category: $e");
    return false;
  }
}
