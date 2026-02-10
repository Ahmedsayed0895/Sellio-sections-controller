import 'package:injectable/injectable.dart';
import '../entities/section.dart';
import '../repositories/section_repository.dart';

@lazySingleton
class CreateSection {
  final ISectionRepository repository;

  CreateSection(this.repository);

  Future<CategorySection> call(CategorySection section) {
    return repository.createSection(section);
  }
}
