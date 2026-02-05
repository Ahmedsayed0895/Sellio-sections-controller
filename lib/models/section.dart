class CategorySection {
  final String? id;
  final String sectionTitle;
  final String categoryId;
  int sortOrder;
  bool isActive;
  final List<dynamic>? subCategories;

  CategorySection({
    this.id,
    required this.sectionTitle,
    required this.categoryId,
    required this.sortOrder,
    required this.isActive,
    this.subCategories,
  });

  factory CategorySection.fromJson(Map<String, dynamic> json) {
    return CategorySection(
      id: json['id'],
      sectionTitle: json['sectionTitle'] ?? '',
      categoryId: json['categoryId'] ?? '',
      sortOrder: json['sortOrder'] ?? 0,
      isActive: json['isActive'] ?? false,
      subCategories: json['subCategories'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      if (id != null) 'id': id,
      'sectionTitle': sectionTitle,
      'categoryId': categoryId,
      'sortOrder': sortOrder,
      'isActive': isActive,
    };
  }

  CategorySection copyWith({
    String? sectionTitle,
    String? categoryId,
    int? sortOrder,
    bool? isActive,
  }) {
    return CategorySection(
      id: id,
      sectionTitle: sectionTitle ?? this.sectionTitle,
      categoryId: categoryId ?? this.categoryId,
      sortOrder: sortOrder ?? this.sortOrder,
      isActive: isActive ?? this.isActive,
      subCategories: subCategories,
    );
  }
}
