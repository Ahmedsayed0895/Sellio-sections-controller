# Chapter 2: The Translator — Models & JSON Serialization

> *"The server speaks JSON. Dart speaks objects. Someone needs to translate."*

When your app talks to a server, data travels as **JSON** — a text format that looks like this:

```json
{
  "id": "abc123",
  "sectionTitle": "Top Electronics",
  "categoryId": "cat456",
  "sortOrder": 1,
  "isActive": true
}
```

But in Dart, we work with **objects** (like our `CategorySection` from Chapter 1). Models are the bridge between these two worlds.

---

## Where Do Models Live?

```
lib/
└── data/
    └── models/
        ├── section_model.dart
        ├── section_model.g.dart      ← Auto-generated!
        ├── category_model.dart
        └── category_model.g.dart     ← Auto-generated!
```

Notice they live in the `data/` folder, not `domain/`. Why? Because JSON is a *data concern* — your business logic (domain) shouldn't care about JSON formats.

---

## The SectionModel

```dart
// File: lib/data/models/section_model.dart

import 'package:json_annotation/json_annotation.dart';  // 1
import '../../domain/entities/section.dart';              // 2

part 'section_model.g.dart';                              // 3

@JsonSerializable()                                       // 4
class SectionModel extends CategorySection {              // 5
  const SectionModel({
    super.id,                                             // 6
    required super.sectionTitle,
    required super.categoryId,
    required super.sortOrder,
    required super.isActive,
    super.subCategories,
  });

  factory SectionModel.fromJson(Map<String, dynamic> json) =>   // 7
      _$SectionModelFromJson(json);

  Map<String, dynamic> toJson() => _$SectionModelToJson(this);  // 8

  factory SectionModel.fromEntity(CategorySection entity) {     // 9
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

### Line-by-line breakdown:

#### Line 1: `import 'package:json_annotation/json_annotation.dart';`
This imports the `json_annotation` package. It provides the `@JsonSerializable()` annotation that tells the code generator: "Hey, generate JSON conversion code for this class."

#### Line 2: `import '../../domain/entities/section.dart';`
We import our Entity from Chapter 1. The model needs to know about the entity because it *extends* it.

#### Line 3: `part 'section_model.g.dart';`
This is the magic line. The `part` keyword tells Dart: "There's another file that is part of this file." The `.g.dart` file is **auto-generated** by `build_runner`. You never write it yourself.

**Think of it like this:** You write the recipe, and a robot writes the cooking instructions.

#### Line 4: `@JsonSerializable()`
This **annotation** (the `@` symbol) tells the code generator: "Please generate `fromJson` and `toJson` methods for this class."

#### Line 5: `class SectionModel extends CategorySection {`
`SectionModel` **extends** `CategorySection`. This means:
- `SectionModel` has ALL the same fields as `CategorySection` (id, sectionTitle, etc.)
- PLUS it adds JSON capabilities (fromJson, toJson)
- A `SectionModel` IS a `CategorySection`, but a `CategorySection` is NOT necessarily a `SectionModel`

**Real-world analogy:** A *Smartphone* extends a *Phone*. Every smartphone can make calls (it's a phone), but it can also browse the internet (extra capability). Similarly, every SectionModel can be used as a CategorySection, but it can also convert to/from JSON.

#### Line 6: `super.id`
The `super` keyword passes values UP to the parent class (`CategorySection`). It's like saying: "Hey parent, here's the id value for you."

#### Line 7: `factory SectionModel.fromJson(Map<String, dynamic> json)`
This is a **factory constructor** — a special constructor that can do logic before creating the object.
- `Map<String, dynamic>` is how Dart represents a JSON object. It's a collection of key-value pairs.
- `_$SectionModelFromJson(json)` calls the auto-generated function that reads the JSON and creates a `SectionModel`.

**Example:**
```dart
// This JSON from the server...
final json = {"id": "abc", "sectionTitle": "Electronics", "sortOrder": 1, "isActive": true, "categoryId": "cat1"};

// ...becomes this Dart object:
final section = SectionModel.fromJson(json);
print(section.sectionTitle); // "Electronics"
```

#### Line 8: `Map<String, dynamic> toJson()`
The reverse — converts a Dart object back to JSON for sending to the server.

```dart
final section = SectionModel(sectionTitle: "Fashion", categoryId: "cat2", sortOrder: 2, isActive: true);
final json = section.toJson();
// json = {"sectionTitle": "Fashion", "categoryId": "cat2", "sortOrder": 2, "isActive": true}
```

#### Line 9: `factory SectionModel.fromEntity(CategorySection entity)`
This converts a plain `CategorySection` entity into a `SectionModel`. Why? Because when the Cubit creates a new section, it creates a `CategorySection` (domain level). But to send it to the server, we need a `SectionModel` (data level) that has `toJson()`.

---

## The CategoryModel

```dart
// File: lib/data/models/category_model.dart

@JsonSerializable()
class CategoryModel extends Category {
  @override
  @JsonKey(fromJson: _subsFromJson, toJson: _subsToJson)   // 1
  final List<SubCategory> subCategories;

  const CategoryModel({
    required super.id,
    required super.title,
    required this.subCategories,
  }) : super(subCategories: subCategories);                 // 2

  factory CategoryModel.fromJson(Map<String, dynamic> json) =>
      _$CategoryModelFromJson(json);

  Map<String, dynamic> toJson() => _$CategoryModelToJson(this);

  // Custom JSON conversion for sub-categories
  static List<SubCategory> _subsFromJson(List<dynamic> json) {    // 3
    return json
        .map((e) => SubCategoryModel.fromJson(e as Map<String, dynamic>))
        .toList();
  }

  static List<Map<String, dynamic>> _subsToJson(List<SubCategory> subs) {
    return subs
        .map((e) => (e is SubCategoryModel)
            ? e.toJson()
            : SubCategoryModel(
                id: e.id,
                title: e.title,
                imageUrl: e.imageUrl,
                categoryId: e.categoryId,
              ).toJson())
        .toList();
  }
}
```

### Key new concepts:

#### `@JsonKey(fromJson: _subsFromJson, toJson: _subsToJson)`
This tells the code generator: "Don't use the default JSON conversion for this field. Use my custom functions instead." We need this because `subCategories` contains a list of complex objects, and the generator needs help knowing how to convert them.

#### `: super(subCategories: subCategories)` (the initializer list)
After the constructor parameters but before the body, we use `:` to call the parent constructor. Think of it as shouting up to the parent: "Here, take these sub-categories!"

#### The `_subsFromJson` function
```dart
static List<SubCategory> _subsFromJson(List<dynamic> json) {
  return json
      .map((e) => SubCategoryModel.fromJson(e as Map<String, dynamic>))
      .toList();
}
```

Let's trace through this:
1. `json` is a `List<dynamic>` — a list of "anything" (because JSON doesn't have types)
2. `.map(...)` transforms each item in the list
3. `e as Map<String, dynamic>` — we tell Dart "trust me, each item is a JSON object"
4. `SubCategoryModel.fromJson(...)` — converts that JSON object into a Dart object
5. `.toList()` — `.map()` returns a lazy iterable, so we convert it to a concrete `List`

---

## The Auto-Generated Code

When you run:
```bash
flutter pub run build_runner build --delete-conflicting-outputs
```

It reads your `@JsonSerializable()` classes and generates `.g.dart` files. For example, `section_model.g.dart` contains something like:

```dart
// AUTO-GENERATED — DO NOT EDIT
SectionModel _$SectionModelFromJson(Map<String, dynamic> json) =>
    SectionModel(
      id: json['id'] as String?,
      sectionTitle: json['sectionTitle'] as String,
      categoryId: json['categoryId'] as String,
      sortOrder: (json['sortOrder'] as num).toInt(),
      isActive: json['isActive'] as bool,
    );
```

You never write this code. The robot writes it for you. That's the beauty of code generation.

---

## Key Takeaways

| Concept                    | What It Means                                              |
| -------------------------- | ---------------------------------------------------------- |
| **Model**                  | A class that extends an Entity and adds JSON conversion    |
| **`@JsonSerializable()`**  | Tells the code generator to create fromJson/toJson         |
| **`part 'file.g.dart'`**   | Links to the auto-generated code file                      |
| **`extends`**              | Inherits all fields from the parent class                  |
| **`super`**                | Passes values to the parent class constructor              |
| **`factory`**              | A constructor that can do logic before creating the object |
| **`Map<String, dynamic>`** | Dart's way of representing a JSON object                   |
| **`build_runner`**         | The tool that generates the `.g.dart` files                |

---

**Next Chapter:** We'll learn how Mappers convert these Models into Entities (and vice versa) to keep the layers independent.
