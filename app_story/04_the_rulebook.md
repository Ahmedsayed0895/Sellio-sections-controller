# Chapter 4: The Rulebook — Repositories & Use Cases

> *"Repositories are the gatekeepers. Use Cases are the rules."*

This is the **Domain Layer** — the heart of Clean Architecture. It contains the business rules that are independent of any framework, database, or UI.

---

## The Big Idea

Imagine a company:
- The **Repository** is like the **warehouse manager**. It knows how to get and store things, but it doesn't decide *when* to do it.
- The **Use Case** is like the **business process**. It says "When a customer orders something, go to the warehouse and get it."

```
UI says: "I need sections!"
    ↓
Use Case says: "OK, let me ask the repository"
    ↓
Repository says: "Sure, let me ask the data source"
    ↓
Data Source says: "I'll call the API"
    ↓
API returns JSON → Model → Entity → back to UI
```

---

## Part 1: Repository Interfaces

### Section Repository

```dart
// File: lib/domain/repositories/section_repository.dart

import '../entities/section.dart';

abstract class ISectionRepository {
  Future<List<CategorySection>> getSections();
  Future<List<CategorySection>> createSection(CategorySection section);
  Future<void> updateSection(String id, Map<String, dynamic> updates);
  Future<void> deleteSection(String id);
}
```

#### Why `abstract`? Why an Interface?

This is one of the MOST important design decisions in the entire project.

The `I` in `ISectionRepository` stands for **Interface**. This class says: "Here's what a section repository CAN DO." But it doesn't say HOW it does it.

**Why bother?** Because right now we fetch sections from an API. But what if:
- We want to add a **local database** cache?
- We want to use **mock data** for testing?
- We switch to a completely different server?

With an interface, we can swap the implementation without changing ANY code that uses it:

```dart
// Today: Real API
class SectionRepositoryImpl implements ISectionRepository { ... }

// Tomorrow: Local database
class LocalSectionRepository implements ISectionRepository { ... }

// For testing: Fake data
class FakeSectionRepository implements ISectionRepository { ... }
```

The UI and business logic don't care which one they're talking to — they only know about `ISectionRepository`.

#### Notice: Return types use ENTITIES, not MODELS

```dart
Future<List<CategorySection>> getSections();  // ← CategorySection, NOT SectionModel
```

The repository returns **entities** (`CategorySection`), not **models** (`SectionModel`). This keeps the domain layer pure — it doesn't know about JSON, APIs, or any data-layer concerns.

### Category Repository

```dart
// File: lib/domain/repositories/category_repository.dart

import '../entities/category.dart';

abstract class ICategoryRepository {
  Future<List<Category>> getCategories();
}
```

This one is simpler — we only READ categories, never create/update/delete them from this app.

---

## Part 2: Repository Implementations

```dart
// File: lib/data/repositories/section_repository_impl.dart

@LazySingleton(as: ISectionRepository)                         // 1
class SectionRepositoryImpl implements ISectionRepository {     // 2
  final IRemoteDataSource dataSource;                          // 3

  SectionRepositoryImpl(this.dataSource);                      // 4

  @override
  Future<List<CategorySection>> getSections() async {          // 5
    final models = await dataSource.fetchSections();
    return models.map(SectionMapper.toEntity).toList();        // 6
  }

  @override
  Future<List<CategorySection>> createSection(CategorySection section) async {
    final model = SectionMapper.toModel(section);              // 7
    final createdModels = await dataSource.createSection(model);
    return createdModels.map(SectionMapper.toEntity).toList(); // 8
  }

  @override
  Future<void> updateSection(String id, Map<String, dynamic> updates) async {
    return await dataSource.updateSection(id, updates);
  }

  @override
  Future<void> deleteSection(String id) async {
    return await dataSource.deleteSection(id);
  }
}
```

### Line-by-line:

#### Line 1: `@LazySingleton(as: ISectionRepository)`
"Register this class as the implementation of `ISectionRepository`." When anyone asks for `ISectionRepository`, they'll get `SectionRepositoryImpl`.

#### Line 2: `implements ISectionRepository`
"I promise to fulfill the contract defined by `ISectionRepository`." The compiler will ERROR if we forget to implement any method.

#### Line 3: `final IRemoteDataSource dataSource;`
The repository depends on a data source. Notice it uses the INTERFACE `IRemoteDataSource`, not the concrete `RemoteDataSourceImpl`. This is called **Dependency Inversion**.

#### Line 4: `SectionRepositoryImpl(this.dataSource);`
**Constructor injection.** The data source is passed in from outside. The repository doesn't create it — it receives it.

#### Line 5: `return await dataSource.fetchSections();`
Simply delegates to the data source. "Hey data source, fetch me the sections."

The magic here is that `dataSource.fetchSections()` returns `List<SectionModel>`, but our method signature says `List<CategorySection>`. This works because `SectionModel extends CategorySection` — every SectionModel IS a CategorySection.

#### Line 6: `final model = SectionModel.fromEntity(section);`
Before sending to the data source, we convert the entity to a model. The data source needs a `SectionModel` (with `toJson()`), but the use case only knows about `CategorySection`.

---

## Part 3: Use Cases

Use Cases are the simplest classes in the project, but they serve an important purpose.

### GetSections Use Case

```dart
// File: lib/domain/usecases/get_sections.dart

import 'package:injectable/injectable.dart';
import '../entities/section.dart';
import '../repositories/section_repository.dart';

@lazySingleton                                        // 1
class GetSections {
  final ISectionRepository repository;                // 2

  GetSections(this.repository);                       // 3

  Future<List<CategorySection>> call() {              // 4
    return repository.getSections();
  }
}
```

#### Line 1: `@lazySingleton`
Only one instance of this use case exists. Makes sense — the "get sections" rule doesn't change.

#### Line 2: `final ISectionRepository repository`
The use case talks to the repository INTERFACE. It doesn't know (or care) how data is actually fetched.

#### Line 3: `GetSections(this.repository);`
The repository is injected through the constructor. This makes testing easy — you can pass a fake repository.

#### Line 4: `call()` — The Special Method
The `call()` method is special in Dart. It lets you use the object like a function:

```dart
final getSections = GetSections(repository);

// These two lines do EXACTLY the same thing:
final sections = await getSections.call();
final sections = await getSections();        // ← Dart magic!
```

When a class has a `call()` method, you can invoke it by just adding `()` to the variable name.

### Other Use Cases

They all follow the exact same pattern:

```dart
// CreateSection — creates a new section
class CreateSection {
  final ISectionRepository repository;
  CreateSection(this.repository);
  Future<List<CategorySection>> call(CategorySection section) {
    return repository.createSection(section);
  }
}

// UpdateSection — updates an existing section
class UpdateSection {
  final ISectionRepository repository;
  UpdateSection(this.repository);
  Future<void> call(String id, Map<String, dynamic> updates) {
    return repository.updateSection(id, updates);
  }
}

// DeleteSection — removes a section
class DeleteSection {
  final ISectionRepository repository;
  DeleteSection(this.repository);
  Future<void> call(String id) {
    return repository.deleteSection(id);
  }
}

// GetCategories — fetches all categories
class GetCategories {
  final ICategoryRepository repository;
  GetCategories(this.repository);
  Future<List<Category>> call() {
    return repository.getCategories();
  }
}
```

### "Why not just call the repository directly?"

Great question! Use Cases serve as **documentation** of what the app can do:

```
📂 usecases/
├── create_section.dart    → "This app can create sections"
├── delete_section.dart    → "This app can delete sections"
├── get_categories.dart    → "This app can fetch categories"
├── get_sections.dart      → "This app can fetch sections"
└── update_section.dart    → "This app can update sections"
```

Just by looking at the folder, you know ALL the operations the app supports. No need to read any code!

They also serve as a **single point of change**. If the business rule for "create section" needs validation (e.g., "title must be at least 3 characters"), you add it HERE — not in the UI, not in the repository, but in the Use Case.

---

## Key Takeaways

| Concept                       | What It Means                                             |
| ----------------------------- | --------------------------------------------------------- |
| **Repository Interface**      | A contract defining what data operations are available    |
| **Repository Implementation** | The actual code that fetches/stores data                  |
| **Use Case**                  | A single business operation, encapsulated in a class      |
| **`call()` method**           | Makes a class callable like a function                    |
| **Dependency Inversion**      | Depend on abstractions (interfaces), not concrete classes |
| **`implements`**              | Fulfills a contract defined by an interface               |
| **`@LazySingleton`**          | One instance, created when first needed                   |

---

**Next Chapter:** How all these pieces get wired together with Dependency Injection.
