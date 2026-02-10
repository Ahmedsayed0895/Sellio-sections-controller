import '../entities/section.dart';

abstract class ISectionRepository {
  Future<List<CategorySection>> getSections();
  Future<CategorySection> createSection(CategorySection section);
  Future<void> updateSection(String id, Map<String, dynamic> updates);
  Future<void> deleteSection(String id);
}
