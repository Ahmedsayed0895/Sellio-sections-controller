import 'package:json_annotation/json_annotation.dart';

part 'section_model.g.dart';

@JsonSerializable()
class SectionModel {
  final String? id;
  final String sectionTitle;
  final String categoryId;
  final int sortOrder;
  final bool isActive;
  final List<dynamic>? subCategories;

  const SectionModel({
    this.id,
    required this.sectionTitle,
    required this.categoryId,
    required this.sortOrder,
    required this.isActive,
    this.subCategories,
  });

  factory SectionModel.fromJson(Map<String, dynamic> json) =>
      _$SectionModelFromJson(json);

  Map<String, dynamic> toJson() => _$SectionModelToJson(this);
}
