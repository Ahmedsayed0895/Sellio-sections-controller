import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../domain/entities/section.dart';
import '../cubits/admin_panel_cubit.dart';
import '../cubits/admin_panel_state.dart';
import '../theme/app_colors.dart';
import 'components/section_dialogs.dart';
import 'components/section_item.dart';
import 'components/section_shimmer.dart';

class AdminPanel extends StatefulWidget {
  const AdminPanel({super.key});

  @override
  State<AdminPanel> createState() => _AdminPanelState();
}

class _AdminPanelState extends State<AdminPanel> {
  void _createSection(String title, String catId, int sortOrder) {
    context.read<AdminPanelCubit>().addSection(title, catId, sortOrder);
  }

  void _updateSection(String id, Map<String, dynamic> updates) {
    context.read<AdminPanelCubit>().editSection(id, updates);
  }

  void _deleteSection(String id) {
    context.read<AdminPanelCubit>().removeSection(id);
  }

  void _showSnack(String msg, {bool isError = false}) {
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(msg),
        backgroundColor: isError ? AppColors.error : AppColors.success,
        behavior: SnackBarBehavior.floating,
      ),
    );
  }

  void _showAddDialog(BuildContext context, AdminPanelState state) {
    showDialog(
      context: context,
      builder: (_) => SectionDialog(
        categories: state.categories,
        initialSortOrder: state.sections.length + 1,
        onSave: (title, catId, sortOrder) {
          _createSection(title, catId, sortOrder);
        },
      ),
    );
  }

  void _showEditDialog(
    BuildContext context,
    AdminPanelState state,
    CategorySection section,
  ) {
    showDialog(
      context: context,
      builder: (_) => SectionDialog(
        categories: state.categories,
        section: section,
        onSave: (title, catId, sortOrder) {
          final updates = <String, dynamic>{};
          if (title != section.sectionTitle) {
            updates['sectionTitle'] = title;
          }
          if (catId != section.categoryId) {
            updates['categoryId'] = catId;
          }
          if (sortOrder != section.sortOrder) {
            updates['sortOrder'] = sortOrder;
          }

          if (updates.isNotEmpty) {
            _updateSection(section.id!, updates);
          }
        },
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return BlocConsumer<AdminPanelCubit, AdminPanelState>(
      listener: (context, state) {
        if (state.errorMessage != null) {
          _showSnack(state.errorMessage!, isError: true);
        }
      },
      builder: (context, state) {
        return Scaffold(
          appBar: AppBar(
            title: const Text("HOME SECTIONS"),
            actions: [
              IconButton(
                icon: const Icon(Icons.refresh),
                onPressed: () => context.read<AdminPanelCubit>().loadData(),
              ),
            ],
          ),
          body: state.status == AdminPanelStatus.loading
              ? const SectionShimmerList()
              : state.status == AdminPanelStatus.failure
              ? Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(
                        Icons.error_outline,
                        size: 48,
                        color: AppColors.error.withValues(alpha: 0.7),
                      ),
                      const SizedBox(height: 16),
                      Text(
                        "Error loading data:\n${state.errorMessage}",
                        textAlign: TextAlign.center,
                      ),
                      const SizedBox(height: 16),
                      ElevatedButton(
                        onPressed: () =>
                            context.read<AdminPanelCubit>().loadData(),
                        child: const Text("Retry"),
                      ),
                    ],
                  ),
                )
              : state.sections.isEmpty
              ? Center(
                  child: Text(
                    "No sections yet.\nTap + to add one.",
                    textAlign: TextAlign.center,
                    style: TextStyle(color: AppColors.subtitle),
                  ),
                )
              : ListView.builder(
                  padding: const EdgeInsets.only(bottom: 80, top: 16),
                  itemCount: state.sections.length,
                  itemBuilder: (ctx, index) {
                    final section = state.sections[index];
                    final linkedCategory = state.categories
                        .where((c) => c.id == section.categoryId)
                        .firstOrNull;

                    return CategorySectionItem(
                      key: ValueKey(section.id),
                      section: section,
                      linkedCategory: linkedCategory,
                      onToggleActive: (val) {
                        _updateSection(section.id!, {'isActive': val});
                      },
                      onDelete: () => _deleteSection(section.id!),
                      onTap: () => _showEditDialog(context, state, section),
                    );
                  },
                ),
          floatingActionButton: FloatingActionButton.extended(
            onPressed: () => _showAddDialog(context, state),
            icon: const Icon(Icons.add),
            label: const Text("Add Section"),
          ),
        );
      },
    );
  }
}
