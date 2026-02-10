import 'package:injectable/injectable.dart';
import '../repositories/section_repository.dart';

@lazySingleton
class DeleteSection {
  final ISectionRepository repository;

  DeleteSection(this.repository);

  Future<void> call(String id) {
    return repository.deleteSection(id);
  }
}
