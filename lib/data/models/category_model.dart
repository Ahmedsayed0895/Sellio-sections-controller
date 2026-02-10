import 'package:json_annotation/json_annotation.dart';

part 'category_model.g.dart';

@JsonSerializable()
class CategoryModel {
  final String id;
  final String title;

  @JsonKey(fromJson: _subsFromJson, toJson: _subsToJson)
  final List<SubCategoryModel> subCategories;

  const CategoryModel({
    required this.id,
    required this.title,
    required this.subCategories,
  });

  factory CategoryModel.fromJson(Map<String, dynamic> json) =>
      _$CategoryModelFromJson(json);

  Map<String, dynamic> toJson() => _$CategoryModelToJson(this);

  static List<SubCategoryModel> _subsFromJson(List<dynamic> json) {
    return json
        .map((e) => SubCategoryModel.fromJson(e as Map<String, dynamic>))
        .toList();
  }

  static List<Map<String, dynamic>> _subsToJson(List<SubCategoryModel> subs) {
    return subs.map((e) => e.toJson()).toList();
  }
}

@JsonSerializable()
class SubCategoryModel {
  final String id;
  final String title;
  final String? imageUrl;
  final String categoryId;

  const SubCategoryModel({
    required this.id,
    required this.title,
    this.imageUrl,
    required this.categoryId,
  });

  factory SubCategoryModel.fromJson(Map<String, dynamic> json) =>
      _$SubCategoryModelFromJson(json);

  Map<String, dynamic> toJson() => _$SubCategoryModelToJson(this);
}
