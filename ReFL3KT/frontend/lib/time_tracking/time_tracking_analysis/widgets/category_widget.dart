import 'package:flutter/material.dart';
import 'package:frontend/time_tracking/entities/category.dart';
import 'package:frontend/time_tracking/time_tracking_analysis/pages/category_detailed_analytics.dart';

class CategoryWidget extends StatelessWidget {
  final Category category;
  const CategoryWidget({
    required this.category,
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.symmetric(vertical: 10, horizontal: 8),
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: Theme.of(context).cardColor,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black12,
            blurRadius: 12,
            offset: const Offset(0, 6),
          ),
        ],
        border: Border.all(
          color: Colors.grey.withOpacity(0.2),
          width: 1.2,
        ),
      ),
      height: MediaQuery.of(context).size.height * .10,
      width: MediaQuery.of(context).size.width * .9,
      alignment: Alignment.centerLeft,
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          // Colored dot
          Container(
            width: 16,
            height: 16,
            margin: const EdgeInsets.only(right: 16),
            decoration: BoxDecoration(
              color: category.color,
              shape: BoxShape.circle,
            ),
          ),
          // Category name (colored text)
          Text(
            category.name,
            style: TextStyle(
              fontSize: 22,
              fontWeight: FontWeight.bold,
              color: category.color, // Use category color for text
              letterSpacing: 1.2,
              shadows: [
                Shadow(
                  color: Colors.black.withOpacity(0.08),
                  offset: const Offset(1, 2),
                  blurRadius: 2,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
