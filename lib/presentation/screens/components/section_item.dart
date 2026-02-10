import 'package:flutter/material.dart';
import '../../../domain/entities/category.dart';
import '../../../domain/entities/section.dart';
import '../../theme/app_colors.dart';

class CategorySectionItem extends StatefulWidget {
  final CategorySection section;
  final Category? linkedCategory;
  final ValueChanged<bool> onToggleActive;
  final VoidCallback onDelete;
  final VoidCallback onTap;

  const CategorySectionItem({
    super.key,
    required this.section,
    this.linkedCategory,
    required this.onToggleActive,
    required this.onDelete,
    required this.onTap,
  });

  @override
  State<CategorySectionItem> createState() => _CategorySectionItemState();
}

class _CategorySectionItemState extends State<CategorySectionItem>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _scaleAnimation;
  late Animation<double> _fadeAnimation;
  bool _isDeleting = false;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 400),
    );

    _scaleAnimation = CurvedAnimation(
      parent: _controller,
      curve: Curves.fastOutSlowIn,
    );

    _fadeAnimation = CurvedAnimation(parent: _controller, curve: Curves.easeIn);

    _controller.forward();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  Future<void> _animateDelete() async {
    setState(() {
      _isDeleting = true;
    });
    await _controller.reverse();
    widget.onDelete();
  }

  @override
  Widget build(BuildContext context) {
    if (_isDeleting && _controller.isDismissed) {
      return const SizedBox.shrink();
    }

    return ScaleTransition(
      scale: _scaleAnimation,
      child: FadeTransition(
        opacity: _fadeAnimation,
        child: Container(
          margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          decoration: BoxDecoration(
            color: AppColors.surface,
            borderRadius: BorderRadius.circular(16),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.05),
                blurRadius: 10,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: Material(
            color: Colors.transparent,
            child: InkWell(
              onTap: widget.onTap,
              borderRadius: BorderRadius.circular(16),
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Header: Sort Order + Title + Actions
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // Sort Order Badge
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 10,
                            vertical: 6,
                          ),
                          decoration: BoxDecoration(
                            color: AppColors.primary.withValues(alpha: 0.1),
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Text(
                            "#${widget.section.sortOrder}",
                            style: const TextStyle(
                              color: AppColors.primary,
                              fontWeight: FontWeight.bold,
                              fontSize: 14,
                            ),
                          ),
                        ),
                        const SizedBox(width: 12),
                        // Title & ID
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                widget.section.sectionTitle,
                                style: const TextStyle(
                                  fontWeight: FontWeight.bold,
                                  fontSize: 16,
                                  color: AppColors.onSurface,
                                ),
                              ),
                              const SizedBox(height: 4),
                              Text(
                                "ID: ${widget.section.id}",
                                style: TextStyle(
                                  fontSize: 10,
                                  color: AppColors.hint,
                                  fontFamily: 'monospace',
                                ),
                              ),
                            ],
                          ),
                        ),
                        // Active Switch & Menu
                        Row(
                          children: [
                            Transform.scale(
                              scale: 0.8,
                              child: Switch(
                                value: widget.section.isActive,
                                onChanged: widget.onToggleActive,
                                activeColor: AppColors.primary,
                                inactiveThumbColor: AppColors.hint,
                                inactiveTrackColor: Colors.grey.shade200,
                              ),
                            ),
                            const SizedBox(width: 4),
                            IconButton(
                              icon: const Icon(
                                Icons.delete_outline_rounded,
                                color: AppColors.error,
                              ),
                              onPressed: _animateDelete,
                              tooltip: 'Delete Section',
                            ),
                          ],
                        ),
                      ],
                    ),

                    const Divider(
                      height: 24,
                      thickness: 1,
                      color: Color(0xFFEEEEEE),
                    ),

                    // Body: Category Details
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Icon(
                          Icons.category_outlined,
                          size: 18,
                          color: AppColors.primary,
                        ),
                        const SizedBox(width: 8),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                "LINKED CATEGORY",
                                style: TextStyle(
                                  fontSize: 10,
                                  fontWeight: FontWeight.w900,
                                  letterSpacing: 0.5,
                                  color: AppColors.hint,
                                ),
                              ),
                              const SizedBox(height: 4),
                              if (widget.linkedCategory != null) ...[
                                Text(
                                  widget.linkedCategory!.title,
                                  style: const TextStyle(
                                    fontSize: 14,
                                    fontWeight: FontWeight.w600,
                                    color: AppColors.onSurface,
                                  ),
                                ),
                                const SizedBox(height: 8),
                                if (widget
                                    .linkedCategory!
                                    .subCategories
                                    .isNotEmpty)
                                  Wrap(
                                    spacing: 6,
                                    runSpacing: 4,
                                    children: widget
                                        .linkedCategory!
                                        .subCategories
                                        .map((sub) {
                                          final hasImage =
                                              sub.imageUrl != null &&
                                              sub.imageUrl!.isNotEmpty;
                                          return Container(
                                            padding: const EdgeInsets.all(4),
                                            decoration: BoxDecoration(
                                              color: Colors.grey.shade100,
                                              borderRadius:
                                                  BorderRadius.circular(20),
                                              border: Border.all(
                                                color: Colors.grey.shade300,
                                              ),
                                            ),
                                            child: Row(
                                              mainAxisSize: MainAxisSize.min,
                                              children: [
                                                CircleAvatar(
                                                  radius: 10,
                                                  backgroundImage: hasImage
                                                      ? NetworkImage(
                                                          sub.imageUrl!,
                                                        )
                                                      : null,
                                                  onBackgroundImageError:
                                                      hasImage
                                                      ? (_, __) {}
                                                      : null,
                                                  child: !hasImage
                                                      ? const Icon(
                                                          Icons
                                                              .image_not_supported,
                                                          size: 10,
                                                        )
                                                      : null,
                                                ),
                                                const SizedBox(width: 6),
                                                Text(
                                                  sub.title,
                                                  style: TextStyle(
                                                    fontSize: 11,
                                                    color: Colors.grey.shade700,
                                                    fontWeight: FontWeight.w500,
                                                  ),
                                                ),
                                                const SizedBox(width: 4),
                                              ],
                                            ),
                                          );
                                        })
                                        .toList(),
                                  )
                                else
                                  Text(
                                    "No Subcategories",
                                    style: TextStyle(
                                      fontSize: 12,
                                      color: AppColors.hint,
                                      fontStyle: FontStyle.italic,
                                    ),
                                  ),
                              ] else
                                Text(
                                  "Unknown Category (${widget.section.categoryId})",
                                  style: const TextStyle(
                                    fontSize: 14,
                                    color: AppColors.error,
                                    decoration: TextDecoration.lineThrough,
                                  ),
                                ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
