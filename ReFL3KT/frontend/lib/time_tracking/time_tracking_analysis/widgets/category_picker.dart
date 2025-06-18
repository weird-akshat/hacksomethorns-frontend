import 'package:flutter/material.dart';
import 'package:frontend/providers/category_provider.dart';
import 'package:frontend/time_tracking/entities/category.dart';
import 'package:provider/provider.dart';

class CategoryPicker extends StatefulWidget {
  final void Function(Category?) onCategorySelected;
  final String? initialCategoryId;

  const CategoryPicker({
    super.key,
    required this.onCategorySelected,
    this.initialCategoryId,
  });

  @override
  _CategoryPickerState createState() => _CategoryPickerState();
}

class _CategoryPickerState extends State<CategoryPicker> {
  List<Category> list = [];
  Category? selectedCategory;

  @override
  void initState() {
    super.initState();
    final categoryProvider =
        Provider.of<CategoryProvider>(context, listen: false);

    if (categoryProvider.isEmpty()) {
      categoryProvider.loadCategories('1'); // Replace with actual userId
    }

    WidgetsBinding.instance.addPostFrameCallback((_) {
      setState(() {
        list = categoryProvider.list;
        if (list.isNotEmpty) {
          selectedCategory = list.first;
          widget.onCategorySelected(selectedCategory);
        }
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    return DropdownButton<Category>(
      value: selectedCategory,
      isExpanded: true,
      items: [
        ...list.map(
          (cat) => DropdownMenuItem<Category>(
            value: cat,
            child: Row(
              children: [
                Container(
                  width: 12,
                  height: 12,
                  margin: const EdgeInsets.only(right: 8),
                  decoration: BoxDecoration(
                    color: cat.color,
                    shape: BoxShape.circle,
                  ),
                ),
                Text(cat.name),
              ],
            ),
          ),
        ),
        DropdownMenuItem<Category>(
          value: null,
          child: Row(
            children: const [
              Icon(Icons.add, color: Colors.blue),
              SizedBox(width: 8),
              Text('Add Category', style: TextStyle(color: Colors.blue)),
            ],
          ),
        ),
      ],
      onChanged: (cat) {
        if (cat == null) {
          // Navigate to add category screen
          Navigator.pushNamed(context, '/add-category').then((_) {
            // Reload categories on return
            final categoryProvider =
                Provider.of<CategoryProvider>(context, listen: false);
            setState(() {
              list = categoryProvider.list;
              if (list.isNotEmpty) {
                selectedCategory = list.first;
                widget.onCategorySelected(selectedCategory);
              }
            });
          });
        } else {
          setState(() {
            selectedCategory = cat;
          });
          widget.onCategorySelected(cat);
        }
      },
    );
  }
}
