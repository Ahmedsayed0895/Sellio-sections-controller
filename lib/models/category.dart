class Category {
  final String id;
  final String title;
  final List<SubCategory> subCategories;

  Category({
    required this.id,
    required this.title,
    required this.subCategories,
  });

  factory Category.fromJson(Map<String, dynamic> json) {
    return Category(
      id: json['id'],
      title: json['title'],
      subCategories:
          (json['subCategories'] as List<dynamic>?)
              ?.map((e) => SubCategory.fromJson(e))
              .toList() ??
          [],
    );
  }
}

class SubCategory {
  final String id;
  final String title;
  final String categoryId;

  SubCategory({
    required this.id,
    required this.title,
    required this.categoryId,
  });

  factory SubCategory.fromJson(Map<String, dynamic> json) {
    return SubCategory(
      id: json['id'],
      title: json['title'],
      categoryId: json['categoryId'],
    );
  }
}
