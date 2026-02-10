import 'package:injectable/injectable.dart';
import '../../domain/entities/category.dart';
import '../../domain/repositories/category_repository.dart';
import '../datasources/remote_datasource.dart';
import '../mappers/category_mapper.dart';

@LazySingleton(as: ICategoryRepository)
class CategoryRepositoryImpl implements ICategoryRepository {
  final IRemoteDataSource dataSource;

  CategoryRepositoryImpl(this.dataSource);

  @override
  Future<List<Category>> getCategories() async {
    final models = await dataSource.fetchCategories();
    return models.map(CategoryMapper.toEntity).toList();
  }
}
