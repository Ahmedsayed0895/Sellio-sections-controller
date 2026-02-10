class CategorySection {
  final String? id;
  final String sectionTitle;
  final String categoryId;
  final int sortOrder;
  final bool isActive;
  final List<dynamic>? subCategories;

  const CategorySection({
    this.id,
    required this.sectionTitle,
    required this.categoryId,
    required this.sortOrder,
    required this.isActive,
    this.subCategories,
  });

  CategorySection copyWith({
    String? id,
    String? sectionTitle,
    String? categoryId,
    int? sortOrder,
    bool? isActive,
    List<dynamic>? subCategories,
  }) {
    return CategorySection(
      id: id ?? this.id,
      sectionTitle: sectionTitle ?? this.sectionTitle,
      categoryId: categoryId ?? this.categoryId,
      sortOrder: sortOrder ?? this.sortOrder,
      isActive: isActive ?? this.isActive,
      subCategories: subCategories ?? this.subCategories,
    );
  }
}
