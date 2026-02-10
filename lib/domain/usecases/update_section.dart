import 'package:injectable/injectable.dart';
import '../repositories/section_repository.dart';

@lazySingleton
class UpdateSection {
  final ISectionRepository repository;

  UpdateSection(this.repository);

  Future<void> call(String id, Map<String, dynamic> updates) {
    return repository.updateSection(id, updates);
  }
}
