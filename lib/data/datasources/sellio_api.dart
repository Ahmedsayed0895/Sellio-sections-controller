import 'package:dio/dio.dart';
import 'package:retrofit/retrofit.dart';
import '../models/section_model.dart';
import '../models/category_model.dart';

part 'sellio_api.g.dart';

@RestApi()
abstract class SellioApi {
  factory SellioApi(Dio dio, {String baseUrl}) = _SellioApi;

  @GET('/category-sections/active')
  Future<List<SectionModel>> fetchSections();

  @POST('/category-sections')
  Future<List<SectionModel>> createSection(@Body() SectionModel section);

  @PUT('/category-sections/{id}')
  Future<void> updateSection(
    @Path('id') String id,
    @Body() Map<String, dynamic> updates,
  );

  @DELETE('/category-sections/{id}')
  Future<void> deleteSection(@Path('id') String id);

  @GET('/category/all-categories')
  Future<List<CategoryModel>> fetchCategories();
}
