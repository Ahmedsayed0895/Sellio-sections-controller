import 'package:injectable/injectable.dart';
import '../../domain/entities/section.dart';
import '../../domain/repositories/section_repository.dart';
import '../datasources/remote_datasource.dart';
import '../mappers/section_mapper.dart';

@LazySingleton(as: ISectionRepository)
class SectionRepositoryImpl implements ISectionRepository {
  final IRemoteDataSource dataSource;

  SectionRepositoryImpl(this.dataSource);

  @override
  Future<List<CategorySection>> getSections() async {
    final models = await dataSource.fetchSections();
    return models.map(SectionMapper.toEntity).toList();
  }

  @override
  Future<List<CategorySection>> createSection(CategorySection section) async {
    final model = SectionMapper.toModel(section);
    final createdModels = await dataSource.createSection(model);
    return createdModels.map(SectionMapper.toEntity).toList();
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
