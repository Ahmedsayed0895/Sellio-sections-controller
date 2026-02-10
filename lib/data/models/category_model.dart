import 'package:json_annotation/json_annotation.dart';
import '../../domain/entities/category.dart';

part 'category_model.g.dart';

@JsonSerializable()
class CategoryModel extends Category {
  @override
  @JsonKey(fromJson: _subsFromJson, toJson: _subsToJson)
  final List<SubCategory> subCategories;

  const CategoryModel({
    required super.id,
    required super.title,
    required this.subCategories,
  }) : super(subCategories: subCategories);

  factory CategoryModel.fromJson(Map<String, dynamic> json) =>
      _$CategoryModelFromJson(json);

  Map<String, dynamic> toJson() => _$CategoryModelToJson(this);

  static List<SubCategory> _subsFromJson(List<dynamic> json) {
    return json
        .map((e) => SubCategoryModel.fromJson(e as Map<String, dynamic>))
        .toList();
  }

  static List<Map<String, dynamic>> _subsToJson(List<SubCategory> subs) {
    return subs
        .map(
          (e) => (e is SubCategoryModel)
              ? e.toJson()
              : SubCategoryModel(
                  id: e.id,
                  title: e.title,
                  categoryId: e.categoryId,
                ).toJson(),
        )
        .toList();
  }
}

@JsonSerializable()
class SubCategoryModel extends SubCategory {
  const SubCategoryModel({
    required super.id,
    required super.title,
    required super.categoryId,
  });

  factory SubCategoryModel.fromJson(Map<String, dynamic> json) =>
      _$SubCategoryModelFromJson(json);

  Map<String, dynamic> toJson() => _$SubCategoryModelToJson(this);
}
