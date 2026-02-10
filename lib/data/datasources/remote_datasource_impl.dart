import 'package:dio/dio.dart';
import 'package:logger/logger.dart';
import 'package:injectable/injectable.dart';
import '../models/category_model.dart';
import '../models/section_model.dart';
import 'remote_datasource.dart';
import 'sellio_api.dart';

final logger = Logger();

@LazySingleton(as: IRemoteDataSource)
class RemoteDataSourceImpl implements IRemoteDataSource {
  final SellioApi api;

  RemoteDataSourceImpl({required this.api});

  @override
  Future<List<SectionModel>> fetchSections() async {
    try {
      logger.i('Fetching sections');
      final sections = await api.fetchSections();
      logger.d('Fetched ${sections.length} sections');
      return sections;
    } catch (e) {
      throw _handleError(e);
    }
  }

  @override
  Future<List<SectionModel>> createSection(SectionModel section) async {
    try {
      logger.i('Creating section: ${section.sectionTitle}');
      final created = await api.createSection(section);
      logger.d('Created sections list with ${created.length} items');
      return created;
    } catch (e) {
      throw _handleError(e);
    }
  }

  @override
  Future<void> updateSection(String id, Map<String, dynamic> updates) async {
    try {
      logger.i('Updating section $id');
      await api.updateSection(id, updates);
      logger.d('Update successful');
    } catch (e) {
      throw _handleError(e);
    }
  }

  @override
  Future<void> deleteSection(String id) async {
    try {
      logger.i('Deleting section $id');
      await api.deleteSection(id);
      logger.d('Delete successful');
    } catch (e) {
      throw _handleError(e);
    }
  }

  @override
  Future<List<CategoryModel>> fetchCategories() async {
    try {
      logger.i('Fetching categories');
      final categories = await api.fetchCategories();
      logger.d('Fetched ${categories.length} categories');
      return categories;
    } catch (e) {
      throw _handleError(e);
    }
  }

  String _handleError(dynamic error) {
    logger.e('API Error', error: error);
    if (error is DioException) {
      if (error.type == DioExceptionType.connectionError) {
        return "Connection failed. Is the server running?";
      }
      return error.message ?? "An unexpected API error occurred.";
    }
    return error.toString();
  }
}
