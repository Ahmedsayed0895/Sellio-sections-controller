import 'package:injectable/injectable.dart';
import '../../domain/entities/section.dart';
import '../../domain/repositories/section_repository.dart';
import '../datasources/remote_datasource.dart';
import '../models/section_model.dart';

@LazySingleton(as: ISectionRepository)
class SectionRepositoryImpl implements ISectionRepository {
  final IRemoteDataSource dataSource;

  SectionRepositoryImpl(this.dataSource);

  @override
  Future<List<CategorySection>> getSections() async {
    return await dataSource.fetchSections();
  }

  @override
  Future<CategorySection> createSection(CategorySection section) async {
    final model = SectionModel.fromEntity(section);
    return await dataSource.createSection(model);
  }

  @override
  Future<void> updateSection(String id, Map<String, dynamic> updates) async {
    return await dataSource.updateSection(id, updates);
  }

  @override
  Future<void> deleteSection(String id) async {
    return await dataSource.deleteSection(id);
  }
}
