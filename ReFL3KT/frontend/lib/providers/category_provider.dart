import 'package:flutter/material.dart';
import 'package:frontend/api_methods/get_all_categories.dart';
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
}
