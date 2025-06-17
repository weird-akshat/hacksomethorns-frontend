import 'package:flutter/material.dart';
import 'package:frontend/time_tracking/entities/category.dart';

class CategoryWidget extends StatelessWidget {
  final Category category;
  const CategoryWidget({
    required this.category,
    super.key,
    // required this.list,
  });

  // final List<Category> list;

  @override
  Widget build(BuildContext context) {
    return Container(
      color: category.color,
      height: MediaQuery.of(context).size.height * .10,
      width: MediaQuery.of(context).size.width * .9,
      child: Text(category.name),
    );
  }
}
