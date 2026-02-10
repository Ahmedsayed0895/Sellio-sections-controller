import '../models/category_model.dart';
import '../models/section_model.dart';

abstract class IRemoteDataSource {
  Future<List<SectionModel>> fetchSections();
  Future<List<SectionModel>> createSection(SectionModel section);
  Future<void> updateSection(String id, Map<String, dynamic> updates);
  Future<void> deleteSection(String id);
  Future<List<CategoryModel>> fetchCategories();
}
