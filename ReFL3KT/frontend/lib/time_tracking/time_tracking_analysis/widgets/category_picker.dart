import 'package:flutter/material.dart';
import 'package:frontend/providers/category_provider.dart';
import 'package:frontend/providers/user_provider.dart';
import 'package:frontend/time_tracking/entities/category.dart';
import 'package:provider/provider.dart';

class CategoryPicker extends StatefulWidget {
  final void Function(Category?) onCategorySelected;
  final String? initialCategoryName;

  const CategoryPicker({
    super.key,
    required this.onCategorySelected,
    this.initialCategoryName,
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
      categoryProvider.loadCategories(
        Provider.of<UserProvider>(context, listen: false).userId!,
      ); // Replace with actual userId
    }

    WidgetsBinding.instance.addPostFrameCallback((_) {
      setState(() {
        list = categoryProvider.list;

        if (list.isNotEmpty) {
          selectedCategory = widget.initialCategoryName != null
              ? list.firstWhere(
                  (cat) => cat.name == widget.initialCategoryName,
                  orElse: () => list.first,
                )
              : list.first;

          widget.onCategorySelected(selectedCategory);
        }
      });
    });
  }

  Future<void> _showAddCategoryDialog() async {
    final result = await showDialog<bool>(
      context: context,
      barrierDismissible: false, // Prevent dismissing during loading
      builder: (BuildContext context) {
        return const AddCategoryDialog(
          userId: '1', // Replace with actual userId
        );
      },
    );

    if (result == true) {
      // Category was successfully added, update the list
      final categoryProvider =
          Provider.of<CategoryProvider>(context, listen: false);
      setState(() {
        list = categoryProvider.list;
        if (list.isNotEmpty) {
          // Select the newly added category (should be the last one)
          selectedCategory = list.last;
          widget.onCategorySelected(selectedCategory);
        }
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<CategoryProvider>(
      builder: (context, provider, _) {
        list = provider.list;

        if (list.isNotEmpty && selectedCategory == null) {
          selectedCategory = widget.initialCategoryName != null
              ? list.firstWhere(
                  (cat) => cat.name == widget.initialCategoryName,
                  orElse: () => list.first,
                )
              : list.first;

          WidgetsBinding.instance.addPostFrameCallback((_) {
            widget.onCategorySelected(selectedCategory);
          });
        }

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
              _showAddCategoryDialog();
            } else {
              setState(() {
                selectedCategory = cat;
              });
              widget.onCategorySelected(cat);
            }
          },
        );
      },
    );
  }
}

class AddCategoryDialog extends StatefulWidget {
  final String userId;

  const AddCategoryDialog({
    super.key,
    required this.userId,
  });

  @override
  _AddCategoryDialogState createState() => _AddCategoryDialogState();
}

class _AddCategoryDialogState extends State<AddCategoryDialog> {
  final TextEditingController _nameController = TextEditingController();
  bool _isLoading = false;

  @override
  void dispose() {
    _nameController.dispose();
    super.dispose();
  }

  Future<void> _addCategory() async {
    if (_nameController.text.trim().isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please enter a category name'),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    setState(() {
      _isLoading = true;
    });

    final category = Category(
      '1', // userId
      0,
      _nameController.text.trim(),
      Colors.black, // Default or placeholder color
    );

    final categoryProvider =
        Provider.of<CategoryProvider>(context, listen: false);
    final success = await categoryProvider.addCategory(
        category, Provider.of<UserProvider>(context).userId!);

    setState(() {
      _isLoading = false;
    });

    if (success) {
      Navigator.of(context).pop(true);
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Failed to create category. Please try again.'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text('Add New Category'),
      content: _isLoading
          ? const SizedBox(
              height: 100,
              child: Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    CircularProgressIndicator(),
                    SizedBox(height: 16),
                    Text('Creating category...'),
                  ],
                ),
              ),
            )
          : SingleChildScrollView(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  TextField(
                    controller: _nameController,
                    decoration: const InputDecoration(
                      labelText: 'Category Name',
                      border: OutlineInputBorder(),
                    ),
                    textCapitalization: TextCapitalization.words,
                  ),
                ],
              ),
            ),
      actions: _isLoading
          ? []
          : [
              TextButton(
                onPressed: () => Navigator.of(context).pop(false),
                child: const Text('Cancel'),
              ),
              ElevatedButton(
                onPressed: _addCategory,
                child: const Text('Add Category'),
              ),
            ],
    );
  }
}
