import 'package:flutter/material.dart';
import '../../../domain/entities/category.dart';
import '../../../domain/entities/section.dart';
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
                    const SizedBox(height: 16),
                    Row(
                      children: [
                        Icon(
                          Icons.grid_view_rounded,
                          size: 16,
                          color: AppColors.primary,
                        ),
                        const SizedBox(width: 6),
                        const Text(
                          "SUBCATEGORIES",
                          style: TextStyle(
                            fontSize: 11,
                            color: AppColors.hint,
                            fontWeight: FontWeight.w800,
                            letterSpacing: 0.8,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    Builder(
                      builder: (context) {
                        final selectedCategory = widget.categories
                            .cast<Category>()
                            .firstWhere(
                              (c) => c.id == _selectedCategoryId,
                              orElse: () => widget.categories.first,
                            );
                        if (selectedCategory.subCategories.isEmpty) {
                          return Container(
                            width: double.infinity,
                            padding: const EdgeInsets.symmetric(vertical: 20),
                            decoration: BoxDecoration(
                              color: Colors.grey.shade50,
                              borderRadius: BorderRadius.circular(12),
                              border: Border.all(color: Colors.grey.shade200),
                            ),
                            child: Column(
                              children: [
                                Icon(
                                  Icons.category_outlined,
                                  size: 28,
                                  color: AppColors.hint,
                                ),
                                const SizedBox(height: 6),
                                Text(
                                  "No subcategories",
                                  style: TextStyle(
                                    color: AppColors.hint,
                                    fontSize: 12,
                                    fontStyle: FontStyle.italic,
                                  ),
                                ),
                              ],
                            ),
                          );
                        }
                        return Wrap(
                          spacing: 8,
                          runSpacing: 8,
                          children: selectedCategory.subCategories.map((sub) {
                            final hasImage =
                                sub.imageUrl != null &&
                                sub.imageUrl!.isNotEmpty;
                            return SizedBox(
                              width: 80,
                              height: 95,
                              child: Container(
                                decoration: BoxDecoration(
                                  color: Colors.white,
                                  borderRadius: BorderRadius.circular(12),
                                  border: Border.all(
                                    color: AppColors.primary.withValues(
                                      alpha: 0.15,
                                    ),
                                  ),
                                  boxShadow: [
                                    BoxShadow(
                                      color: Colors.black.withValues(
                                        alpha: 0.04,
                                      ),
                                      blurRadius: 6,
                                      offset: const Offset(0, 2),
                                    ),
                                  ],
                                ),
                                child: Column(
                                  children: [
                                    // Image area
                                    Expanded(
                                      child: Container(
                                        width: double.infinity,
                                        decoration: BoxDecoration(
                                          color: AppColors.primary.withValues(
                                            alpha: 0.06,
                                          ),
                                          borderRadius:
                                              const BorderRadius.vertical(
                                                top: Radius.circular(11),
                                              ),
                                        ),
                                        child: hasImage
                                            ? ClipRRect(
                                                borderRadius:
                                                    const BorderRadius.vertical(
                                                      top: Radius.circular(11),
                                                    ),
                                                child: Image.network(
                                                  sub.imageUrl!,
                                                  fit: BoxFit.cover,
                                                  errorBuilder: (_, __, ___) =>
                                                      const Center(
                                                        child: Icon(
                                                          Icons
                                                              .broken_image_rounded,
                                                          color: AppColors.hint,
                                                          size: 22,
                                                        ),
                                                      ),
                                                ),
                                              )
                                            : const Center(
                                                child: Icon(
                                                  Icons.image_outlined,
                                                  color: AppColors.hint,
                                                  size: 24,
                                                ),
                                              ),
                                      ),
                                    ),
                                    // Title area
                                    Padding(
                                      padding: const EdgeInsets.symmetric(
                                        horizontal: 4,
                                        vertical: 6,
                                      ),
                                      child: Text(
                                        sub.title,
                                        textAlign: TextAlign.center,
                                        maxLines: 2,
                                        overflow: TextOverflow.ellipsis,
                                        style: const TextStyle(
                                          fontSize: 10,
                                          fontWeight: FontWeight.w600,
                                          color: AppColors.onSurface,
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                              ),
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
