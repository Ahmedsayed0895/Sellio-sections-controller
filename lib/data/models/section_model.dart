import 'package:json_annotation/json_annotation.dart';
import '../../domain/entities/section.dart';

part 'section_model.g.dart';

@JsonSerializable()
class SectionModel extends CategorySection {
  const SectionModel({
    super.id,
    required super.sectionTitle,
    required super.categoryId,
    required super.sortOrder,
    required super.isActive,
    super.subCategories,
  });

  factory SectionModel.fromJson(Map<String, dynamic> json) =>
      _$SectionModelFromJson(json);

  Map<String, dynamic> toJson() => _$SectionModelToJson(this);

  factory SectionModel.fromEntity(CategorySection entity) {
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
