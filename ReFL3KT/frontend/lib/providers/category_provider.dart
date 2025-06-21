import 'package:flutter/material.dart';
import 'package:frontend/api_methods/get_all_categories.dart';
import 'package:frontend/api_methods/post_category.dart'; // Add this import
import 'package:frontend/time_tracking/entities/category.dart';

class CategoryProvider with ChangeNotifier {
  List<Category> list = [];

  bool isEmpty() {
    return list.isEmpty;
  }

  Future<void> loadCategories(String userId) async {
    list = await getAllCategories(userId);
    notifyListeners();
  }

  Future<bool> addCategory(Category category, String userId) async {
    bool success = await postCategory(category);
    if (success) {
      // Reload categories to get the updated list from server
      await loadCategories(userId);
    }
    return success;
  }
}
