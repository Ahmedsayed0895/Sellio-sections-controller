import '../entities/category.dart';

abstract class ICategoryRepository {
  Future<List<Category>> getCategories();
}
