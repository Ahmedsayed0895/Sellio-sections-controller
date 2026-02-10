import 'package:injectable/injectable.dart';
import 'package:flutter/foundation.dart' hide Category;
import '../../domain/entities/category.dart';
import '../../domain/entities/section.dart';
import '../../domain/usecases/create_section.dart';
import '../../domain/usecases/delete_section.dart';
import '../../domain/usecases/get_categories.dart';
import '../../domain/usecases/get_sections.dart';
import '../../domain/usecases/update_section.dart';

@injectable
class AdminPanelViewModel extends ChangeNotifier {
  final GetSections _getSections;
  final CreateSection _createSection;
  final UpdateSection _updateSection;
  final DeleteSection _deleteSection;
  final GetCategories _getCategories;

  List<CategorySection> _sections = [];
  List<Category> _categories = [];
  bool _isLoading = true;
  String? _errorMessage;

  List<CategorySection> get sections => _sections;
  List<Category> get categories => _categories;
  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;

  AdminPanelViewModel({
    required GetSections getSections,
    required CreateSection createSection,
    required UpdateSection updateSection,
    required DeleteSection deleteSection,
    required GetCategories getCategories,
  }) : _getSections = getSections,
       _createSection = createSection,
       _updateSection = updateSection,
       _deleteSection = deleteSection,
       _getCategories = getCategories {
    loadData();
  }

  Future<void> loadData() async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      final localInactive = _sections.where((s) => !s.isActive).toList();

      final results = await Future.wait([_getSections(), _getCategories()]);

      final fetchedActiveSections = results[0] as List<CategorySection>;
      final categories = results[1] as List<Category>;

      final mergedSections = <CategorySection>[...localInactive];

      for (final fetched in fetchedActiveSections) {
        final index = mergedSections.indexWhere((s) => s.id == fetched.id);
        if (index != -1) {
          mergedSections[index] = fetched;
        } else {
          mergedSections.add(fetched);
        }
      }

      mergedSections.sort((a, b) => a.sortOrder.compareTo(b.sortOrder));

      _sections = mergedSections;
      _categories = categories;
      _isLoading = false;
    } catch (e) {
      _errorMessage = e.toString();
      _isLoading = false;
    }
    notifyListeners();
  }

  Future<String?> addSection(String title, String catId, int sortOrder) async {
    final newSection = CategorySection(
      sectionTitle: title,
      categoryId: catId,
      sortOrder: sortOrder,
      isActive: true,
    );

    try {
      final created = await _createSection(newSection);
      _sections.add(created);
      _sections.sort((a, b) => a.sortOrder.compareTo(b.sortOrder));
      notifyListeners();
      return null;
    } catch (e) {
      return e.toString();
    }
  }

  Future<String?> editSection(String id, Map<String, dynamic> updates) async {
    final index = _sections.indexWhere((s) => s.id == id);
    if (index == -1) return "Section not found";

    final originalSection = _sections[index];
    final updatedSection = originalSection.copyWith(
      sectionTitle: updates['sectionTitle'],
      categoryId: updates['categoryId'],
      sortOrder: updates['sortOrder'],
      isActive: updates['isActive'],
    );

    _sections[index] = updatedSection;
    if (updates.containsKey('sortOrder')) {
      _sections.sort((a, b) => a.sortOrder.compareTo(b.sortOrder));
    }
    notifyListeners();

    try {
      await _updateSection(id, updates);
      return null;
    } catch (e) {
      _sections[index] = originalSection;
      _sections.sort((a, b) => a.sortOrder.compareTo(b.sortOrder));
      notifyListeners();
      return e.toString();
    }
  }

  Future<String?> removeSection(String id) async {
    final backup = List<CategorySection>.from(_sections);
    _sections.removeWhere((s) => s.id == id);
    notifyListeners();

    try {
      await _deleteSection(id);
      return null;
    } catch (e) {
      _sections = backup;
      notifyListeners();
      return e.toString();
    }
  }
}
