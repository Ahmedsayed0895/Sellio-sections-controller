import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart' hide Category;
import 'package:logger/logger.dart';
import '../models/section.dart';
import '../models/category.dart';

final logger = Logger();

class ApiService {
  static String get baseUrl {
    if (defaultTargetPlatform == TargetPlatform.android) {
      return 'http://10.0.2.2:8085/v1';
    }
    return 'http://localhost:8085/v1';
  }

  final Dio _dio = Dio(
    BaseOptions(
      baseUrl: baseUrl,
      connectTimeout: const Duration(seconds: 15),
      receiveTimeout: const Duration(seconds: 13),
      validateStatus: (status) =>
          status! < 600,
      headers: {
        'Authorization':
            'Bearer eyJhbGciOiJIUzI1NiJ9.eyJzdWIiOiI1ODk5NTA3MS1iZTdlLTRkNTktYjgyMC0yNzUyNDk3OGRhYmQiLCJpYXQiOjE3Njg2NzgyNzAsImV4cCI6MTc3MTI3MDI3MH0.LPjTKw-G3rgSY-qmUqC9x6cnMrEjoyfbXPl4Q3f2Bhw',
      },
    ),
  );

  Future<List<CategorySection>> fetchSections() async {
    try {
      logger.i('Fetching sections from $baseUrl/category-sections/active');
      final response = await _dio.get('/category-sections/active');
      logger.d('Fetched sections response status: ${response.statusCode}');
      final List<dynamic> data = response.data;
      return data.map((json) => CategorySection.fromJson(json)).toList();
    } catch (e) {
      throw _handleError(e);
    }
  }

  Future<CategorySection> createSection(CategorySection section) async {
    try {
      logger.i('Creating section: ${section.sectionTitle}');
      final response = await _dio.post(
        '/category-sections',
        data: section.toJson(),
      );
      logger.d('Created section response status: ${response.statusCode}');
      logger.d('Created section response data: ${response.data}');
      if (response.data is List) {
        logger.w(
          'Backend returned a List instead of an object. Attempting to find created section.',
        );
        final List<dynamic> listData = response.data;
        final list = listData
            .map((json) => CategorySection.fromJson(json))
            .toList();

        try {
          final created = list.firstWhere(
            (s) =>
                s.sectionTitle == section.sectionTitle.toString() &&
                s.categoryId == section.categoryId.toString() &&
                s.sortOrder == section.sortOrder,
            orElse: () =>
                list.last,
          );
          return created;
        } catch (e) {
          if (list.isNotEmpty) return list.last;
          throw "Section created but could not be identified in response";
        }
      }

      if (response.data is Map<String, dynamic>) {
        final Map<String, dynamic> json = response.data;
        if (json.containsKey('sectionTitle') || json.containsKey('id')) {
          return CategorySection.fromJson(json);
        }
        logger.w("Response JSON does not look like a CategorySection: $json");
      }

      if (response.statusCode != 200 && response.statusCode != 201) {
        throw "Failed to create section. Status: ${response.statusCode}, Data: ${response.data}";
      }

      return CategorySection.fromJson(response.data);
    } catch (e) {
      throw _handleError(e);
    }
  }

  Future<void> updateSection(String id, Map<String, dynamic> updates) async {
    try {
      logger.i('Updating section $id');
      await _dio.put('/category-sections/$id', data: updates);
      logger.d('Update successful');
    } catch (e) {
      throw _handleError(e);
    }
  }

  Future<void> deleteSection(String id) async {
    try {
      logger.i('Deleting section $id');
      await _dio.delete('/category-sections/$id');
      logger.d('Delete successful');
    } catch (e) {
      throw _handleError(e);
    }
  }

  Future<List<Category>> fetchCategories() async {
    try {
      logger.i('Fetching categories from $baseUrl/category/all-categories');
      final response = await _dio.get('/category/all-categories');
      logger.d('Fetched categories response status: ${response.statusCode}');
      final List<dynamic> data = response.data;
      return data.map((json) => Category.fromJson(json)).toList();
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
