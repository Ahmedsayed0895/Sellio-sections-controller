class Category {
  final String id;
  final String title;
  final List<SubCategory> subCategories;

  const Category({
    required this.id,
    required this.title,
    required this.subCategories,
  });
}

class SubCategory {
  final String id;
  final String title;
  final String imageUrl;
  final String categoryId;

  const SubCategory({
    required this.id,
    required this.title,
    required this.imageUrl,
    required this.categoryId,
  });
}
