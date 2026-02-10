import 'package:injectable/injectable.dart';
import '../entities/category.dart';
import '../repositories/category_repository.dart';

@lazySingleton
class GetCategories {
  final ICategoryRepository repository;

  GetCategories(this.repository);

  Future<List<Category>> call() {
    return repository.getCategories();
  }
}
