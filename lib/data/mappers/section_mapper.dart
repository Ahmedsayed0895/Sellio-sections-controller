import '../../domain/entities/section.dart';
import '../models/section_model.dart';

/// Maps between [SectionModel] (data layer) and [CategorySection] (domain layer).
class SectionMapper {
  /// Converts a data-layer [SectionModel] into a domain-layer [CategorySection].
  static CategorySection toEntity(SectionModel model) {
    return CategorySection(
      id: model.id,
      sectionTitle: model.sectionTitle,
      categoryId: model.categoryId,
      sortOrder: model.sortOrder,
      isActive: model.isActive,
      subCategories: model.subCategories,
    );
  }

  /// Converts a domain-layer [CategorySection] into a data-layer [SectionModel].
  static SectionModel toModel(CategorySection entity) {
    return SectionModel(
      id: entity.id,
      sectionTitle: entity.sectionTitle,
      categoryId: entity.categoryId,
      sortOrder: entity.sortOrder,
      isActive: entity.isActive,
      subCategories: entity.subCategories,
    );
  }
}
