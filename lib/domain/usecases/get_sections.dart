import 'package:injectable/injectable.dart';
import '../entities/section.dart';
import '../repositories/section_repository.dart';

@lazySingleton
class GetSections {
  final ISectionRepository repository;

  GetSections(this.repository);

  Future<List<CategorySection>> call() {
    return repository.getSections();
  }
}
