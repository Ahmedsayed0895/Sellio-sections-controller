// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'section_model.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

SectionModel _$SectionModelFromJson(Map<String, dynamic> json) => SectionModel(
  id: json['id'] as String?,
  sectionTitle: json['sectionTitle'] as String,
  categoryId: json['categoryId'] as String,
  sortOrder: (json['sortOrder'] as num).toInt(),
  isActive: json['isActive'] as bool,
  subCategories: json['subCategories'] as List<dynamic>?,
);

Map<String, dynamic> _$SectionModelToJson(SectionModel instance) =>
    <String, dynamic>{
      'id': instance.id,
      'sectionTitle': instance.sectionTitle,
      'categoryId': instance.categoryId,
      'sortOrder': instance.sortOrder,
      'isActive': instance.isActive,
      'subCategories': instance.subCategories,
    };
