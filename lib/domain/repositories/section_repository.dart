import '../entities/section.dart';

abstract class ISectionRepository {
  Future<List<CategorySection>> getSections();
  Future<List<CategorySection>> createSection(CategorySection section);
  Future<void> updateSection(String id, Map<String, dynamic> updates);
  Future<void> deleteSection(String id);
}
