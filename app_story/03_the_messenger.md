# Chapter 3: The Messenger .. API & Networking

> *"Your app is an island. The server is the mainland. Dio and Retrofit build the bridge."*

In this chapter, we connect our app to the real world .. the server that stores all the sections and categories.

---

## The Two Players

| Package      | Role                                             | Analogy                   |
| ------------ | ------------------------------------------------ | ------------------------- |
| **Dio**      | The HTTP client that sends/receives raw data     | The postal truck          |
| **Retrofit** | Generates type-safe API methods from annotations | The postal address system |

**Dio** does the heavy lifting (sending HTTP requests). **Retrofit** makes it elegant by letting you write clean, declarative code instead of manually building URLs and parsing responses.

---

## Step 1: The API Definition (sellio_api.dart)

This is where we **define** what endpoints exist. We don't write the code that calls them .. Retrofit generates that for us.

```dart
// File: lib/data/datasources/sellio_api.dart

import 'package:dio/dio.dart';           // 1 .. The HTTP engine
import 'package:retrofit/retrofit.dart';  // 2 .. The code generator annotations
import '../models/section_model.dart';    // 3 .. Our data models
import '../models/category_model.dart';

part 'sellio_api.g.dart';                 // 4 .. Auto-generated implementation

@RestApi()                                // 5
abstract class SellioApi {                // 6
  factory SellioApi(Dio dio, {String baseUrl}) = _SellioApi;  // 7

  @GET('/category-sections/active')                           // 8
  Future<List<SectionModel>> fetchSections();                 // 9

  @POST('/category-sections')                                 // 10
  Future<List<SectionModel>> createSection(@Body() SectionModel section);

  @PUT('/category-sections/{id}')                             // 11
  Future<void> updateSection(
    @Path('id') String id,                                    // 12
    @Body() Map<String, dynamic> updates,                     // 13
  );

  @DELETE('/category-sections/{id}')
  Future<void> deleteSection(@Path('id') String id);

  @GET('/category/all-categories')
  Future<List<CategoryModel>> fetchCategories();
}
```

### The Deep Dive:

#### Line 5: `@RestApi()`
This annotation tells Retrofit: "This class defines a REST API. Please generate an implementation."

#### Line 6: `abstract class SellioApi`
The class is `abstract` .. meaning we only write the **signatures** (what methods exist), not the **bodies** (how they work). Retrofit generates the implementation in `sellio_api.g.dart`.

**Real-world analogy:** An abstract class is like a menu at a restaurant. It tells you WHAT dishes are available, but it doesn't tell you HOW to cook them. The kitchen (Retrofit) handles that.

#### Line 7: `factory SellioApi(Dio dio, {String baseUrl}) = _SellioApi;`
This creates the API client. You give it a `Dio` instance (the HTTP engine), and it returns a `_SellioApi` object (the generated implementation).

```dart
// Usage example:
final dio = Dio(BaseOptions(baseUrl: 'https://app.sell-io.app/v1'));
final api = SellioApi(dio);
```

#### Line 8: `@GET('/category-sections/active')`
This is an **HTTP annotation**. It says:
- Use the **GET** method (requesting data, not sending it)
- Hit the `/category-sections/active` endpoint

The full URL becomes: `https://app.sell-io.app/v1/category-sections/active`

#### Line 9: `Future<List<SectionModel>> fetchSections();`
- `Future` means this is an **async** operation .. it takes time (network call)
- `List<SectionModel>` means Retrofit will automatically parse the JSON response into a list of `SectionModel` objects
- You get back real Dart objects, not raw JSON strings!

#### Line 10: `@POST('/category-sections')`
**POST** = "I'm sending new data to the server." Used for creating things.

#### `@Body() SectionModel section`
The `@Body()` annotation means: "Take this `SectionModel`, convert it to JSON using `toJson()`, and put it in the request body."

#### Line 11: `@PUT('/category-sections/{id}')`
**PUT** = "I'm updating existing data." The `{id}` is a **path parameter** .. a placeholder in the URL.

#### Line 12: `@Path('id') String id`
This takes the `id` parameter and plugs it into the `{id}` placeholder in the URL.

```dart
// If id = "abc123", the URL becomes:
// PUT https://app.sell-io.app/v1/category-sections/abc123
```

#### Line 13: `@Body() Map<String, dynamic> updates`
For updates, we send a `Map` (like a JSON object) with only the changed fields:
```dart
// Only update the title .. don't touch anything else
api.updateSection("abc123", {"sectionTitle": "New Name"});
```

---

## Step 2: The Data Source (remote_datasource.dart)

The Data Source is a **wrapper** around the API. Why wrap it? Two reasons:
1. **Error handling** .. catch network errors and convert them to friendly messages
2. **Abstraction** .. the rest of the app talks to `IRemoteDataSource`, not `SellioApi` directly

### The Interface (Contract)

```dart
// File: lib/data/datasources/remote_datasource.dart

abstract class IRemoteDataSource {
  Future<List<SectionModel>> fetchSections();
  Future<List<SectionModel>> createSection(SectionModel section);
  Future<void> updateSection(String id, Map<String, dynamic> updates);
  Future<void> deleteSection(String id);
  Future<List<CategoryModel>> fetchCategories();
}
```

This is an **interface** (abstract class). It's a *contract* that says: "Any class that claims to be a data source MUST have these methods." It doesn't say HOW to implement them.

### The Implementation

```dart
// File: lib/data/datasources/remote_datasource_impl.dart

@LazySingleton(as: IRemoteDataSource)    // 1
class RemoteDataSourceImpl implements IRemoteDataSource {
  final SellioApi api;                    // 2

  RemoteDataSourceImpl({required this.api});

  @override
  Future<List<SectionModel>> fetchSections() async {
    try {                                 // 3
      logger.i('Fetching sections');      // 4
      final sections = await api.fetchSections();
      logger.d('Fetched ${sections.length} sections');
      return sections;
    } catch (e) {
      throw _handleError(e);             // 5
    }
  }

  // ... other methods follow the same pattern

  String _handleError(dynamic error) {   // 6
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
```

#### Line 1: `@LazySingleton(as: IRemoteDataSource)`
This annotation (from `injectable`) tells the DI system:
- Create only ONE instance of this class (Singleton)
- Register it under the type `IRemoteDataSource`
- Create it lazily (only when first needed)

#### Line 2: `final SellioApi api;`
The actual API client is **injected** .. we don't create it here. Someone else provides it.

#### Line 3: `try { ... } catch (e) { ... }`
**Error handling.** Network calls can fail (server down, no internet, timeout). We wrap every call in try/catch so errors don't crash the app.

#### Line 4: `logger.i('Fetching sections');`
**Logging.** The `logger` package prints pretty messages to the console:
- `logger.i(...)` = info (blue)
- `logger.d(...)` = debug (gray)
- `logger.e(...)` = error (red)

#### Line 5: `throw _handleError(e);`
Instead of throwing the raw error, we convert it to a human-readable message.

#### Line 6: `_handleError`
This function checks what kind of error occurred:
- `DioException` with `connectionError` → "Connection failed. Is the server running?"
- Any other `DioException` → use its built-in message
- Anything else → convert to string

---

## Key Takeaways

| Concept                                | What It Means                                 |
| -------------------------------------- | --------------------------------------------- |
| **Dio**                                | The HTTP engine that sends requests           |
| **Retrofit**                           | Generates API client code from annotations    |
| **`@GET`, `@POST`, `@PUT`, `@DELETE`** | HTTP method annotations                       |
| **`@Body()`**                          | Send this parameter as the request body       |
| **`@Path('id')`**                      | Insert this parameter into the URL            |
| **`abstract class`**                   | A contract/interface .. defines WHAT, not HOW |
| **`implements`**                       | "I promise to fulfill this contract"          |
| **`try/catch`**                        | Handle errors gracefully instead of crashing  |
| **`@LazySingleton`**                   | Create one instance, only when needed         |

---

**Next Chapter:** Repositories and Use Cases .. the rules that govern how data flows through the app.
