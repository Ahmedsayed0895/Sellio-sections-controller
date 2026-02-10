import 'package:equatable/equatable.dart';
import '../../domain/entities/category.dart';
import '../../domain/entities/section.dart';

enum AdminPanelStatus { initial, loading, success, failure }

class AdminPanelState extends Equatable {
  final AdminPanelStatus status;
  final List<CategorySection> sections;
  final List<Category> categories;
  final String? errorMessage;

  const AdminPanelState({
    this.status = AdminPanelStatus.initial,
    this.sections = const [],
    this.categories = const [],
    this.errorMessage,
  });

  AdminPanelState copyWith({
    AdminPanelStatus? status,
    List<CategorySection>? sections,
    List<Category>? categories,
    String? errorMessage,
  }) {
    return AdminPanelState(
      status: status ?? this.status,
      sections: sections ?? this.sections,
      categories: categories ?? this.categories,
      errorMessage: errorMessage,
    );
  }

  @override
  List<Object?> get props => [status, sections, categories, errorMessage];
}
