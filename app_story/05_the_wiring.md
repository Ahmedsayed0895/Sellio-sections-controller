# Chapter 5: The Wiring .. Dependency Injection

> *"DI is an electrician. It connects the right wires to the right sockets so everything just works."*

We've built all the pieces: Entities, Models, API, Data Sources, Repositories, Use Cases. But how do they connect? Who creates what? That's what Dependency Injection (DI) solves.

---

## The Problem Without DI

Without DI, you'd create everything manually:

```dart
// ❌ THE UGLY WAY .. Creating everything by hand
void main() {
  final dio = Dio(BaseOptions(baseUrl: 'https://app.sell-io.app/v1'));
  final api = SellioApi(dio);
  final dataSource = RemoteDataSourceImpl(api: api);
  final sectionRepo = SectionRepositoryImpl(dataSource);
  final categoryRepo = CategoryRepositoryImpl(dataSource);
  final getSections = GetSections(sectionRepo);
  final createSection = CreateSection(sectionRepo);
  final updateSection = UpdateSection(sectionRepo);
  final deleteSection = DeleteSection(sectionRepo);
  final getCategories = GetCategories(categoryRepo);
  final cubit = AdminPanelCubit(
    getSections: getSections,
    createSection: createSection,
    updateSection: updateSection,
    deleteSection: deleteSection,
    getCategories: getCategories,
  );

  // ... Now finally use the cubit
}
```

That's 12 lines of wiring! And every time you add a new dependency, you have to update this code. Imagine doing this in a real app with 50+ classes.

## The Solution: GetIt + Injectable

With DI, you write annotations on your classes, and a code generator wires everything together automatically:

```dart
// ✅ THE CLEAN WAY .. Let the robot do it
void main() {
  configureDependencies();  // One line. Done.
  runApp(const MyApp());
}
```

---

## Step 1: The Setup File (injection.dart)

```dart
// File: lib/injection.dart

import 'package:get_it/get_it.dart';        // 1
import 'package:injectable/injectable.dart';  // 2
import 'injection.config.dart';              // 3

final getIt = GetIt.instance;               // 4

@InjectableInit(                             // 5
  initializerName: 'init',
  preferRelativeImports: true,
  asExtension: true,
)
void configureDependencies() => getIt.init(); // 6
```

### Line-by-line:

#### Line 1: `GetIt`
The **Service Locator** .. a big dictionary that maps types to instances. You ask it: "Give me an `ISectionRepository`" and it returns the correct object.

#### Line 4: `final getIt = GetIt.instance;`
`GetIt` is a **Singleton** .. there's only one dictionary for the entire app. `GetIt.instance` gives us that single instance. We store it in a global variable for easy access.

#### Line 5-6: `@InjectableInit(...)`
This annotation tells the code generator: "Generate a function called `init()` that registers all annotated classes into GetIt."

The generated code (`injection.config.dart`) looks like this:

```dart
// AUTO-GENERATED .. key parts simplified
extension GetItInjectableX on GetIt {
  GetIt init(...) {
    // Step 1: Register third-party libraries
    gh.lazySingleton<Dio>(() => registerModule.dio);
    gh.lazySingleton<SellioApi>(() => registerModule.getSellioApi(gh<Dio>()));

    // Step 2: Register Data Sources
    gh.lazySingleton<IRemoteDataSource>(
      () => RemoteDataSourceImpl(api: gh<SellioApi>()),
    );

    // Step 3: Register Repositories
    gh.lazySingleton<ISectionRepository>(
      () => SectionRepositoryImpl(gh<IRemoteDataSource>()),
    );

    // Step 4: Register Use Cases
    gh.lazySingleton<GetSections>(() => GetSections(gh<ISectionRepository>()));
    // ... other use cases

    // Step 5: Register Cubit
    gh.factory<AdminPanelCubit>(() => AdminPanelCubit(
      getSections: gh<GetSections>(),
      createSection: gh<CreateSection>(),
      // ...
    ));

    return this;
  }
}
```

Notice how it automatically resolves the **dependency chain**:
- `AdminPanelCubit` needs `GetSections`
- `GetSections` needs `ISectionRepository`
- `ISectionRepository` → `SectionRepositoryImpl` needs `IRemoteDataSource`
- `IRemoteDataSource` → `RemoteDataSourceImpl` needs `SellioApi`
- `SellioApi` needs `Dio`

The generator figures all of this out from your annotations!

---

## Step 2: Registering Third-Party Libraries (register_module.dart)

Some classes (like `Dio`) come from external packages .. we can't add `@injectable` annotations to them. So we use a **module**:

```dart
// File: lib/data/register_module.dart

import 'package:dio/dio.dart';
import 'package:injectable/injectable.dart';
import 'datasources/sellio_api.dart';

@module                                          // 1
abstract class RegisterModule {
  @lazySingleton                                 // 2
  Dio get dio => Dio(                            // 3
    BaseOptions(
      baseUrl: 'https://app.sell-io.app/v1',     // 4
      connectTimeout: const Duration(seconds: 15),
      receiveTimeout: const Duration(seconds: 13),
      validateStatus: (status) => status! < 600, // 5
      headers: {
        'Authorization': 'Bearer eyJhbG...',     // 6
      },
    ),
  );

  @lazySingleton
  SellioApi getSellioApi(Dio dio) => SellioApi(dio); // 7
}
```

### Line-by-line:

#### Line 1: `@module`
"This class provides third-party dependencies." The generator reads this and registers the provided objects.

#### Line 2-3: `@lazySingleton` + `Dio get dio =>`
A getter that creates and configures `Dio`. It's created once (lazy singleton) and reused everywhere.

#### Line 4: `baseUrl: 'https://app.sell-io.app/v1'`
The root URL of our API. All endpoints are relative to this.

#### Line 5: `validateStatus: (status) => status! < 600`
Accept ALL HTTP status codes (even errors like 404 or 500). This lets us handle errors ourselves instead of Dio throwing exceptions for non-200 responses.

#### Line 6: `'Authorization': 'Bearer eyJhbG...'`
The API authentication token. Every request includes this header so the server knows who's calling.

#### Line 7: `SellioApi getSellioApi(Dio dio) => SellioApi(dio);`
Creates the Retrofit API client. Notice `Dio dio` is a parameter .. the generator automatically resolves it from the registration above!

---

## How It All Connects

When `configureDependencies()` runs at app startup:

```
1. Dio gets created with the base URL and auth token
2. SellioApi gets created with the Dio instance
3. RemoteDataSourceImpl gets created with the SellioApi
4. SectionRepositoryImpl gets created with the RemoteDataSourceImpl
5. Use Cases get created with the Repository
6. AdminPanelCubit gets registered (but not created until requested)
```

Then when the UI needs the cubit:
```dart
getIt<AdminPanelCubit>()  // ← "Give me an AdminPanelCubit, please"
// GetIt creates one with all its dependencies automatically injected
```

---

## Singleton vs Factory

| Registration Type            | What Happens                   | Use For                               |
| ---------------------------- | ------------------------------ | ------------------------------------- |
| `@lazySingleton`             | Created ONCE, reused forever   | Dio, Repositories, Use Cases          |
| `@injectable` / `gh.factory` | Created NEW every time you ask | Cubits (each screen gets a fresh one) |

Why is the Cubit a **factory**? Because if you navigate away from the Admin Panel and come back, you want a *fresh* cubit that reloads data. You don't want stale data from the old one.

---

## Key Takeaways

| Concept                       | What It Means                                       |
| ----------------------------- | --------------------------------------------------- |
| **GetIt**                     | A dictionary that maps types to instances           |
| **Injectable**                | A code generator that auto-registers classes        |
| **`@lazySingleton`**          | One instance, created when first needed             |
| **`@injectable`**             | New instance every time                             |
| **`@module`**                 | Provides third-party dependencies                   |
| **`configureDependencies()`** | Initializes all registrations at app startup        |
| **`getIt<T>()`**              | Retrieves an instance of type T from the dictionary |

---

**Next Chapter:** The brain of the UI .. Cubit and state management.
