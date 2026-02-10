import 'package:bloc/bloc.dart';
import 'package:injectable/injectable.dart';
import '../../domain/entities/section.dart';
import '../../domain/usecases/create_section.dart';
import '../../domain/usecases/delete_section.dart';
import '../../domain/usecases/get_categories.dart';
import '../../domain/usecases/get_sections.dart';
import '../../domain/usecases/update_section.dart';
import 'admin_panel_state.dart';
import '../../domain/entities/category.dart';

@injectable
class AdminPanelCubit extends Cubit<AdminPanelState> {
  final GetSections _getSections;
  final CreateSection _createSection;
  final UpdateSection _updateSection;
  final DeleteSection _deleteSection;
  final GetCategories _getCategories;

  AdminPanelCubit({
    required GetSections getSections,
    required CreateSection createSection,
    required UpdateSection updateSection,
    required DeleteSection deleteSection,
    required GetCategories getCategories,
  }) : _getSections = getSections,
       _createSection = createSection,
       _updateSection = updateSection,
       _deleteSection = deleteSection,
       _getCategories = getCategories,
       super(const AdminPanelState()) {
    loadData();
  }

  Future<void> loadData() async {
    emit(state.copyWith(status: AdminPanelStatus.loading));

    try {
      final localInactive = state.sections.where((s) => !s.isActive).toList();

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

      emit(
        state.copyWith(
          status: AdminPanelStatus.success,
          sections: mergedSections,
          categories: categories,
        ),
      );
    } catch (e) {
      emit(
        state.copyWith(
          status: AdminPanelStatus.failure,
          errorMessage: e.toString(),
        ),
      );
    }
  }

  Future<void> addSection(String title, String catId, int sortOrder) async {
    try {
      final newSection = CategorySection(
        sectionTitle: title,
        categoryId: catId,
        sortOrder: sortOrder,
        isActive: true,
      );

      final createdList = await _createSection(newSection);

      final localInactive = state.sections.where((s) => !s.isActive).toList();
      final mergedSections = <CategorySection>[...localInactive];

      for (final fetched in createdList) {
        final index = mergedSections.indexWhere((s) => s.id == fetched.id);
        if (index != -1) {
          mergedSections[index] = fetched;
        } else {
          mergedSections.add(fetched);
        }
      }

      mergedSections.sort((a, b) => a.sortOrder.compareTo(b.sortOrder));

      emit(state.copyWith(sections: mergedSections));
    } catch (e) {
      emit(
        state.copyWith(errorMessage: "Failed to add section: ${e.toString()}"),
      );
    }
  }

  Future<void> editSection(String id, Map<String, dynamic> updates) async {
    final originalSections = List<CategorySection>.from(state.sections);
    final index = originalSections.indexWhere((s) => s.id == id);
    if (index == -1) return;

    final originalSection = originalSections[index];
    final updatedSection = originalSection.copyWith(
      sectionTitle: updates['sectionTitle'],
      categoryId: updates['categoryId'],
      sortOrder: updates['sortOrder'],
      isActive: updates['isActive'],
    );

    final updatedList = List<CategorySection>.from(originalSections);
    updatedList[index] = updatedSection;

    if (updates.containsKey('sortOrder')) {
      updatedList.sort((a, b) => a.sortOrder.compareTo(b.sortOrder));
    }

    emit(state.copyWith(sections: updatedList));

    try {
      await _updateSection(id, updates);
      // Re-fetch to pick up server-side changes (e.g. sort order swaps)
      await loadData();
    } catch (e) {
      emit(
        state.copyWith(
          sections: originalSections,
          errorMessage: "Failed to update: ${e.toString()}",
        ),
      );
    }
  }

  Future<void> removeSection(String id) async {
    final originalSections = List<CategorySection>.from(state.sections);

    final updatedList = List<CategorySection>.from(originalSections)
      ..removeWhere((s) => s.id == id);

    emit(state.copyWith(sections: updatedList));

    try {
      await _deleteSection(id);
    } catch (e) {
      emit(
        state.copyWith(
          sections: originalSections,
          errorMessage: "Failed to delete: ${e.toString()}",
        ),
      );
    }
  }
}
