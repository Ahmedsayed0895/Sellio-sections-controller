import 'package:flutter/material.dart';
import '../../models/section.dart';
import '../../models/category.dart';
import '../../theme/app_colors.dart';

class SectionDialog extends StatefulWidget {
  final List<Category> categories;
  final CategorySection? section;
  final int? initialSortOrder;
  final Function(String title, String categoryId, int sortOrder) onSave;

  const SectionDialog({
    super.key,
    required this.categories,
    required this.onSave,
    this.section,
    this.initialSortOrder,
  });

  @override
  State<SectionDialog> createState() => _SectionDialogState();
}

class _SectionDialogState extends State<SectionDialog> {
  late final TextEditingController _titleController;
  late final TextEditingController _orderController;
  String? _selectedCategoryId;

  bool get _isEdit => widget.section != null;

  @override
  void initState() {
    super.initState();
    _titleController = TextEditingController(
      text: _isEdit ? widget.section!.sectionTitle : '',
    );
    _orderController = TextEditingController(
      text: _isEdit
          ? widget.section!.sortOrder.toString()
          : (widget.initialSortOrder?.toString() ?? '1'),
    );

    if (_isEdit) {
      _selectedCategoryId = widget.section!.categoryId;
      if (!widget.categories.any((c) => c.id == _selectedCategoryId)) {
        _selectedCategoryId = widget.categories.isNotEmpty
            ? widget.categories.first.id
            : null;
      }
    } else {
      if (widget.categories.isNotEmpty) {
        _selectedCategoryId = widget.categories.first.id;
      }
    }
  }

  @override
  void dispose() {
    _titleController.dispose();
    _orderController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Text(_isEdit ? "Edit Section" : "New Section"),
      content: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: _titleController,
              decoration: const InputDecoration(
                labelText: "Section Title",
                hintText: "e.g. Men's Fashion",
                filled: true,
              ),
            ),
            const SizedBox(height: 12),
            TextField(
              controller: _orderController,
              keyboardType: TextInputType.number,
              decoration: const InputDecoration(
                labelText: "Sort Order",
                hintText: "e.g. 1",
                filled: true,
              ),
            ),
            const SizedBox(height: 12),
            if (widget.categories.isEmpty)
              const Text(
                "No categories loaded.",
                style: TextStyle(color: AppColors.error),
              ),
            if (widget.categories.isNotEmpty)
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  DropdownButtonFormField<String>(
                    value: _selectedCategoryId,
                    decoration: const InputDecoration(
                      labelText: "Category",
                      filled: true,
                    ),
                    isExpanded: true,
                    items: widget.categories.map<DropdownMenuItem<String>>((
                      cat,
                    ) {
                      return DropdownMenuItem(
                        value: cat.id,
                        child: Text(cat.title, overflow: TextOverflow.ellipsis),
                      );
                    }).toList(),
                    onChanged: (val) {
                      setState(() {
                        _selectedCategoryId = val;
                      });
                    },
                  ),
                  if (_selectedCategoryId != null) ...[
                    const SizedBox(height: 12),
                    const Text(
                      "Subcategories:",
                      style: TextStyle(
                        fontSize: 13,
                        color: AppColors.hint,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Builder(
                      builder: (context) {
                        final selectedCategory = widget.categories.firstWhere(
                          (c) => c.id == _selectedCategoryId,
                          orElse: () => widget.categories.first,
                        );
                        if (selectedCategory.subCategories.isEmpty) {
                          return const Text(
                            "No subcategories",
                            style: TextStyle(color: Colors.grey, fontSize: 12),
                          );
                        }
                        return Wrap(
                          spacing: 4.0,
                          runSpacing: -8.0,
                          children: selectedCategory.subCategories.map((sub) {
                            return Chip(
                              label: Text(
                                sub.title,
                                style: const TextStyle(fontSize: 11),
                              ),
                              padding: const EdgeInsets.symmetric(
                                horizontal: 4,
                              ),
                              visualDensity: VisualDensity.compact,
                            );
                          }).toList(),
                        );
                      },
                    ),
                  ],
                ],
              ),
          ],
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: const Text("Cancel"),
        ),
        ElevatedButton(
          onPressed: () {
            // Basic validation
            if (_titleController.text.isEmpty) return;
            if (_selectedCategoryId == null) return;

            final sortOrder =
                int.tryParse(_orderController.text) ??
                (widget.section?.sortOrder ?? widget.initialSortOrder ?? 1);

            widget.onSave(
              _titleController.text,
              _selectedCategoryId!,
              sortOrder,
            );
            Navigator.pop(context);
          },
          child: Text(_isEdit ? "Save" : "Create"),
        ),
      ],
    );
  }
}
