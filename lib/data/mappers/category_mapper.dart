import '../../domain/entities/category.dart';
import '../models/category_model.dart';

/// Maps between [SubCategoryModel] (data layer) and [SubCategory] (domain layer).
class SubCategoryMapper {
  static SubCategory toEntity(SubCategoryModel model) {
    return SubCategory(
      id: model.id,
      title: model.title,
      imageUrl: model.imageUrl,
      categoryId: model.categoryId,
    );
  }
}

/// Maps between [CategoryModel] (data layer) and [Category] (domain layer).
class CategoryMapper {
  static Category toEntity(CategoryModel model) {
    return Category(
      id: model.id,
      title: model.title,
      subCategories: model.subCategories
          .map(SubCategoryMapper.toEntity)
          .toList(),
    );
  }
}
