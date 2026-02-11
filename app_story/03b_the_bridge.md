# Chapter 3.5: The Bridge .. Mappers

> *"Models and Entities speak different languages. Mappers are the interpreters."*

In the previous chapters, we learned about **Entities** (domain layer) and **Models** (data layer). But there's a critical question: **how do we convert between them?**

This is where **Mappers** come in.

---

## How It Was Before Mappers

Before we see the new approach, let's look at **exactly how the code worked** when models inherited from entities. This was the implementation in earlier chapters .. and it's how many Flutter tutorials teach it.

### Old SectionModel .. Model Extends Entity

```dart
// ❌ THE OLD WAY .. section_model.dart

import 'package:json_annotation/json_annotation.dart';
import '../../domain/entities/section.dart';             // 1

part 'section_model.g.dart';

@JsonSerializable()
class SectionModel extends CategorySection {             // 2
  const SectionModel({
    super.id,                                            // 3
    required super.sectionTitle,
    required super.categoryId,
    required super.sortOrder,
    required super.isActive,
    super.subCategories,
  });

  factory SectionModel.fromEntity(CategorySection entity) {  // 4
    return SectionModel(
      id: entity.id,
      sectionTitle: entity.sectionTitle,
      categoryId: entity.categoryId,
      sortOrder: entity.sortOrder,
      isActive: entity.isActive,
      subCategories: entity.subCategories,
    );
  }

  factory SectionModel.fromJson(Map<String, dynamic> json) =>
      _$SectionModelFromJson(json);

  Map<String, dynamic> toJson() => _$SectionModelToJson(this);
}
```

#### What's happening here?

| Line  | What It Does                                                              | The Problem                                                   |
| ----- | ------------------------------------------------------------------------- | ------------------------------------------------------------- |
| **1** | Imports the Entity from the domain layer                                  | Data layer now **depends on** domain layer through import     |
| **2** | `extends CategorySection` .. inherits ALL entity fields                   | Model IS an entity .. no separation                           |
| **3** | `super.id`, `super.sectionTitle` .. passes fields up to the parent Entity | Tight coupling: if Entity adds a field, Model must update too |
| **4** | `fromEntity()` .. converts an Entity to a Model                           | Conversion logic lives INSIDE the model (not its job)         |

**The sneaky trick:** Because `SectionModel extends CategorySection`, everywhere the code expects a `CategorySection`, you can pass a `SectionModel` directly. The repository didn't even need to convert:

### Old Repository .. No Conversion Needed (Because of Inheritance)

```dart
// ❌ THE OLD WAY .. section_repository_impl.dart

class SectionRepositoryImpl implements ISectionRepository {
  final IRemoteDataSource dataSource;

  @override
  Future<List<CategorySection>> getSections() async {
    return await dataSource.fetchSections();    // 1
  }

  @override
  Future<List<CategorySection>> createSection(CategorySection section) async {
    final model = SectionModel.fromEntity(section);  // 2
    return await dataSource.createSection(model);     // 3
  }
}
```

| Line  | What It Does                                                     | The Problem                                                      |
| ----- | ---------------------------------------------------------------- | ---------------------------------------------------------------- |
| **1** | Returns `List<SectionModel>` directly as `List<CategorySection>` | Works ONLY because Model extends Entity. No explicit conversion. |
| **2** | Uses `fromEntity()` on the Model itself                          | The Model is doing conversion .. that's not its job.             |
| **3** | Returns the created model directly as an entity                  | Again, works through inheritance magic, not explicit design.     |

### Old CategoryModel .. Same Pattern

```dart
// ❌ THE OLD WAY .. category_model.dart

class SubCategoryModel extends SubCategory {           // extends!
  const SubCategoryModel({
    required super.id,
    required super.title,
    super.imageUrl,
    required super.categoryId,
  });
  // fromJson / toJson...
}

class CategoryModel extends Category {                 // extends!
  const CategoryModel({
    required super.id,
    required super.title,
    required super.subCategories,
  });
  // fromJson / toJson...
}
```

### Why Change It?

This approach **works**, but it violates Clean Architecture:

| Issue                      | Explanation                                                                                                             |
| -------------------------- | ----------------------------------------------------------------------------------------------------------------------- |
| **Tight coupling**         | Changing `CategorySection` (entity) forces changes in `SectionModel` (model)                                            |
| **Mixed responsibilities** | The Model handles JSON AND entity conversion (`fromEntity`)                                                             |
| **Invisible conversion**   | Data passes between layers with no explicit boundary .. you can't see where "data world" ends and "domain world" begins |
| **Testing difficulty**     | You can't mock the conversion independently                                                                             |
| **Leaking concerns**       | JSON annotations from models technically exist on entities (through inheritance)                                        |

**In true Clean Architecture, layers should be independent.** The Entity shouldn't know about JSON, and the Model shouldn't care about business rules. That's where **Mappers** come in.

---

## Where Do Mappers Live?

```
lib/
└── data/
    └── mappers/
        ├── section_mapper.dart    ← Converts Section data ↔ domain
        └── category_mapper.dart   ← Converts Category data → domain
```

Mappers live in the **data layer** because they know about Models (which are data-layer classes). They convert TO entities (domain layer), acting as the bridge between the two worlds.

---

## SectionMapper .. A Two-Way Bridge

```dart
// File: lib/data/mappers/section_mapper.dart

import '../../domain/entities/section.dart';
import '../models/section_model.dart';

class SectionMapper {
  /// Converts a data-layer [SectionModel] into a domain-layer [CategorySection].
  static CategorySection toEntity(SectionModel model) {      // 1
    return CategorySection(
      id: model.id,
      sectionTitle: model.sectionTitle,
      categoryId: model.categoryId,
      sortOrder: model.sortOrder,
      isActive: model.isActive,
      subCategories: model.subCategories,
    );
  }

  /// Converts a domain-layer [CategorySection] into a data-layer [SectionModel].
  static SectionModel toModel(CategorySection entity) {      // 2
    return SectionModel(
      id: entity.id,
      sectionTitle: entity.sectionTitle,
      categoryId: entity.categoryId,
      sortOrder: entity.sortOrder,
      isActive: entity.isActive,
      subCategories: entity.subCategories,
    );
  }
}
```

### Line-by-line:

#### Line 1: `static CategorySection toEntity(SectionModel model)`
- `static` means you call it on the class, not an instance: `SectionMapper.toEntity(model)`
- Takes a `SectionModel` (data layer) and returns a `CategorySection` (domain layer)
- This is used when **reading** data .. the API gives us a Model, we convert it to an Entity for the rest of the app

#### Line 2: `static SectionModel toModel(CategorySection entity)`
- The reverse direction .. Entity to Model
- This is used when **writing** data .. the Cubit gives us an Entity, we convert it to a Model to send to the API

**Simple analogy:** Imagine you're at an airport. The `toEntity` function is like converting foreign currency to your local currency (making it usable in your domain). The `toModel` function is converting your local currency back to foreign currency (making it sendable to the API/server).

---

## CategoryMapper .. A One-Way Bridge

```dart
// File: lib/data/mappers/category_mapper.dart

import '../../domain/entities/category.dart';
import '../models/category_model.dart';

class SubCategoryMapper {
  static SubCategory toEntity(SubCategoryModel model) {
    return SubCategory(
      id: model.id,
      title: model.title,
      imageUrl: model.imageUrl,
      categoryId: model.categoryId,
    );
  }
}

class CategoryMapper {
  static Category toEntity(CategoryModel model) {
    return Category(
      id: model.id,
      title: model.title,
      subCategories: model.subCategories                      // 1
          .map((sub) => sub is SubCategoryModel
              ? SubCategoryMapper.toEntity(sub)
              : sub)
          .cast<SubCategory>()
          .toList(),
    );
  }
}
```

### Why only `toEntity`?

We have `toModel` for sections because we CREATE sections (send data TO the server). But we never create categories from this app .. we only READ them. So we only need the one-way conversion.

#### Line 1: Mapping sub-categories
```dart
model.subCategories
    .map((sub) => sub is SubCategoryModel
        ? SubCategoryMapper.toEntity(sub)   // If it's a model, convert it
        : sub)                              // Otherwise, keep it as-is
    .cast<SubCategory>()                    // Cast the list type
    .toList()                               // Convert to a concrete List
```

This handles the nested conversion .. each `SubCategoryModel` inside the `CategoryModel` is also converted to a `SubCategory` entity.

---

## How Models Look Now (Standalone)

Before mappers, models inherited from entities:

```dart
// ❌ BEFORE .. Model extends Entity
class SectionModel extends CategorySection {
  // Inherits: id, sectionTitle, categoryId, sortOrder, isActive
  factory SectionModel.fromEntity(CategorySection entity) { ... }
  factory SectionModel.fromJson(...) => ...;
  Map<String, dynamic> toJson() => ...;
}
```

After mappers, models are completely independent:

```dart
// ✅ AFTER .. Standalone Model
class SectionModel {
  final String? id;
  final String sectionTitle;
  final String categoryId;
  final int sortOrder;
  final bool isActive;
  final List<dynamic>? subCategories;

  const SectionModel({ ... });

  factory SectionModel.fromJson(...) => ...;
  Map<String, dynamic> toJson() => ...;
  // No fromEntity! The mapper handles that.
}
```

The model now only cares about JSON. The entity only cares about business data. They don't know about each other.

---

## How Repositories Use Mappers

The repository is where the mapper is called .. it sits at the boundary between data and domain:

```dart
// File: lib/data/repositories/section_repository_impl.dart

class SectionRepositoryImpl implements ISectionRepository {
  final IRemoteDataSource dataSource;

  @override
  Future<List<CategorySection>> getSections() async {
    final models = await dataSource.fetchSections();        // 1. Get Models
    return models.map(SectionMapper.toEntity).toList();     // 2. Convert to Entities
  }

  @override
  Future<List<CategorySection>> createSection(CategorySection section) async {
    final model = SectionMapper.toModel(section);           // 1. Convert Entity to Model
    final createdModels = await dataSource.createSection(model); // 2. Send to API
    return createdModels.map(SectionMapper.toEntity).toList();   // 3. Convert back to Entities
  }
}
```

### The beautiful pattern:
- **Reading:** `API → Model → Mapper.toEntity() → Entity → Use Case → Cubit → UI`
- **Writing:** `UI → Cubit → Use Case → Entity → Mapper.toModel() → Model → API`

The mapper is the **checkpoint at the border** .. nothing passes between layers without being converted.

---

## Key Takeaways

| Concept               | What It Means                                         |
| --------------------- | ----------------------------------------------------- |
| **Mapper**            | A class that converts between Models and Entities     |
| **`toEntity()`**      | Converts data → domain (reading from API)             |
| **`toModel()`**       | Converts domain → data (writing to API)               |
| **Standalone Models** | Models don't extend entities .. they're independent   |
| **Separation**        | Each layer only knows about its own types             |
| **Repository**        | The place where mappers are used (the layer boundary) |

---

**Next Chapter:** Continue to Chapter 4 .. Repositories & Use Cases.
