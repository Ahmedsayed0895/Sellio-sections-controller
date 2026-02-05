import 'package:flutter/material.dart';
import '../models/section.dart';
import '../controllers/admin_panel_controller.dart';
import '../theme/app_colors.dart';
import 'components/section_dialogs.dart';
import 'components/section_item.dart';

class AdminPanel extends StatefulWidget {
  const AdminPanel({super.key});

  @override
  State<AdminPanel> createState() => _AdminPanelState();
}

class _AdminPanelState extends State<AdminPanel> {
  late final AdminPanelController _controller;

  @override
  void initState() {
    super.initState();
    _controller = AdminPanelController();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  Future<void> _createSection(String title, String catId, int sortOrder) async {
    final error = await _controller.createSection(title, catId, sortOrder);
    if (error == null) {
      _showSnack("Section created!", isError: false);
    } else {
      _showSnack("Failed to create: $error", isError: true);
    }
  }

  Future<void> _updateSection(String id, Map<String, dynamic> updates) async {
    final error = await _controller.updateSection(id, updates);
    _controller.loadData();
    if (error != null) {
      _showSnack("Failed to update: $error", isError: true);
    }
  }

  Future<void> _deleteSection(String id) async {
    final error = await _controller.deleteSection(id);
    if (error == null) {
      _showSnack("Section deleted", isError: false);
    } else {
      _showSnack("Failed to delete: $error", isError: true);
    }
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

  void _showAddDialog() {
    showDialog(
      context: context,
      builder: (_) => SectionDialog(
        categories: _controller.categories,
        initialSortOrder: _controller.sections.length + 1,
        onSave: (title, catId, sortOrder) {
          _createSection(title, catId, sortOrder);
        },
      ),
    );
  }

  void _showEditDialog(CategorySection section) {
    showDialog(
      context: context,
      builder: (_) => SectionDialog(
        categories: _controller.categories,
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
    return AnimatedBuilder(
      animation: _controller,
      builder: (context, child) {
        return Scaffold(
          appBar: AppBar(
            title: const Text("HOME SECTIONS"),
            actions: [
              IconButton(
                icon: const Icon(Icons.refresh),
                onPressed: _controller.loadData,
              ),
            ],
          ),
          body: _controller.isLoading
              ? Center(
                  child: CircularProgressIndicator(color: AppColors.primary),
                )
              : _controller.errorMessage != null
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
                        "Error loading data:\n${_controller.errorMessage}",
                        textAlign: TextAlign.center,
                      ),
                      const SizedBox(height: 16),
                      ElevatedButton(
                        onPressed: _controller.loadData,
                        child: const Text("Retry"),
                      ),
                    ],
                  ),
                )
              : _controller.sections.isEmpty
              ? Center(
                  child: Text(
                    "No sections yet.\nTap + to add one.",
                    textAlign: TextAlign.center,
                    style: TextStyle(color: AppColors.subtitle),
                  ),
                )
              : ListView.builder(
                  padding: const EdgeInsets.only(bottom: 80, top: 16),
                  itemCount: _controller.sections.length,
                  itemBuilder: (ctx, index) {
                    final section = _controller.sections[index];
                    final linkedCategory = _controller.categories
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
                      onTap: () => _showEditDialog(section),
                    );
                  },
                ),
          floatingActionButton: FloatingActionButton.extended(
            onPressed: _showAddDialog,
            icon: const Icon(Icons.add),
            label: const Text("Add Section"),
          ),
        );
      },
    );
  }
}
