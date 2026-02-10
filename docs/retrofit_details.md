# Using Retrofit in Sellio Categories Sections

**Retrofit** is a type-safe HTTP client generator for Dart and Flutter, inspired by the popular Android library of the same name. It simplifies API interactions by generating the boilerplate code needed for making network requests.

## How Code Was (Manual Dio Implementation)
*Without Retrofit*, you would manually write the network requests using `Dio`. This approach is error-prone, verbose, and harder to maintain.

### Example of Manual Implementation:
```dart
class RemoteDataSource {
  final Dio dio;

  RemoteDataSource(this.dio);

  Future<List<SectionModel>> fetchSections() async {
    try {
      final response = await dio.get('/category-sections/active');
      
      if (response.statusCode == 200) {
        final List<dynamic> data = response.data;
        return data.map((json) => SectionModel.fromJson(json)).toList();
      } else {
        throw Exception('Failed to load sections');
      }
    } catch (e) {
      throw Exception('Network error: $e');
    }
  }

  Future<SectionModel> createSection(SectionModel section) async {
    try {
      final response = await dio.post(
        '/category-sections', 
        data: section.toJson()
      );
      return SectionModel.fromJson(response.data);
    } catch (e) {
      throw Exception('Creation failed: $e');
    }
  }
}
```

## What Is It Now (Retrofit Implementation)
*With Retrofit*, we define an interface with annotations describing the API endpoints. The boilerplate code (request creation, parameter encoding, response parsing) is **automatically generated**.

### 1. Define the API Interface (`lib/data/datasources/sellio_api.dart`)
We use annotations like `@GET`, `@POST`, `@Body`, and `@Path` to describe the API.

```dart
@RestApi()
abstract class SellioApi {
  factory SellioApi(Dio dio, {String baseUrl}) = _SellioApi;

  @GET('/category-sections/active')
  Future<List<SectionModel>> fetchSections();

  @POST('/category-sections')
  Future<SectionModel> createSection(@Body() SectionModel section);

  @PUT('/category-sections/{id}')
  Future<void> updateSection(
    @Path('id') String id,
    @Body() Map<String, dynamic> updates,
  );

  @DELETE('/category-sections/{id}')
  Future<void> deleteSection(@Path('id') String id);
}
```

### 2. Generate the Code
Run the build runner command:
```bash
flutter pub run build_runner build
```
This creates `sellio_api.g.dart`, which contains the implementation of `_SellioApi`. It handles all the low-level Dio operations for you.

### 3. Use the Generated API
Our `RemoteDataSourceImpl` simply delegates calls to the generated `SellioApi`.

```dart
class RemoteDataSourceImpl implements IRemoteDataSource {
  final SellioApi api;

  RemoteDataSourceImpl({required this.api});

  @override
  Future<List<SectionModel>> fetchSections() async {
    // Just one line to call the API!
    return await api.fetchSections();
  }
}
```

## Benefits
- **Less Boilerplate**: No need to manually write request logic.
- **Type Safety**: Request bodies and response types are strictly typed (e.g., `Future<List<SectionModel>>`).
- **Readability**: The API definition is clear and declarative.
- **Maintainability**: Changing an endpoint path or method is as simple as updating an annotation.
