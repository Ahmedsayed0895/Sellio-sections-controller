# Chapter 1: The Foundation .. Entities

> *"Before you build a house, you need to know what rooms it will have."*

Entities are the **most important** part of any application. They define **what things exist** in your app. They don't know about databases, APIs, or screens. They are pure Dart classes.

---

## Where Do Entities Live?

```
lib/
└── domain/
    └── entities/
        ├── section.dart     ← A home screen section
        └── category.dart    ← A product category
```

Notice they live in the `domain/` folder. Domain = business logic = the heart of the app.

---

## Entity 1: CategorySection

This represents one section on the home screen (like "Electronics" or "Fashion").

```dart
// File: lib/domain/entities/section.dart

class CategorySection {
  final String? id;              // Unique identifier from the server (nullable because new sections don't have one yet)
  final String sectionTitle;      // The display name, e.g. "Top Electronics"
  final String categoryId;        // Which category this section belongs to
  final int sortOrder;            // Position in the list (1 = first, 2 = second, etc.)
  final bool isActive;            // Is this section visible on the home screen?
  final List<dynamic>? subCategories; // Optional list of sub-categories

  const CategorySection({
    this.id,
    required this.sectionTitle,
    required this.categoryId,
    required this.sortOrder,
    required this.isActive,
    this.subCategories,
  });

  // ...copyWith method below
}
```

### Let's break this down line by line:

#### `class CategorySection {`
We're creating a new type called `CategorySection`. Think of a class like a **blueprint** .. it describes what a section looks like, but it's not an actual section yet.

#### `final String? id;`
- `final` means this value can never change after it's set. Once a section has an id, it stays that id forever. This is called **immutability**.
- `String?` .. the `?` means this can be `null` (empty/nothing). Why? Because when you *create* a new section, it doesn't have an `id` yet .. the server assigns one.

#### `required this.sectionTitle`
- `required` means you MUST provide this value when creating a `CategorySection`. You can't have a section without a title .. that would be meaningless.

#### `final int sortOrder;`
- `int` is a whole number (1, 2, 3...). This controls the order sections appear on screen.

#### `final bool isActive;`
- `bool` is either `true` or `false`. This is like a light switch .. the section is either visible or hidden.

### The `copyWith` Method .. The Clone Machine

```dart
CategorySection copyWith({
  String? id,
  String? sectionTitle,
  String? categoryId,
  int? sortOrder,
  bool? isActive,
  List<dynamic>? subCategories,
}) {
  return CategorySection(
    id: id ?? this.id,                         // Use new id if provided, otherwise keep the old one
    sectionTitle: sectionTitle ?? this.sectionTitle,
    categoryId: categoryId ?? this.categoryId,
    sortOrder: sortOrder ?? this.sortOrder,
    isActive: isActive ?? this.isActive,
    subCategories: subCategories ?? this.subCategories,
  );
}
```

**Why do we need this?** Because our objects are `final` (immutable). You can't do:
```dart
// ❌ THIS DOESN'T WORK
section.isActive = false;
```

Instead, you create a **copy** with the change:
```dart
// ✅ THIS IS HOW WE DO IT
final updatedSection = section.copyWith(isActive: false);
```

**The `??` operator** means "if the left side is null, use the right side." So `id ?? this.id` means "use the new id if I gave you one, otherwise keep my current id."

**Real-world analogy:** Imagine you have a printed document. You can't edit a printed page .. but you can photocopy it and write changes on the copy. That's `copyWith`.

---

## Entity 2: Category and SubCategory

These represent the product categories that sections link to.

```dart
// File: lib/domain/entities/category.dart

class Category {
  final String id;                      // Every category has an ID
  final String title;                   // "Electronics", "Fashion", etc.
  final List<SubCategory> subCategories; // Sub-items inside this category

  const Category({
    required this.id,
    required this.title,
    required this.subCategories,
  });
}
```

Notice that `id` is NOT nullable here (`String` not `String?`). Why? Because categories come from the server .. they always have an id. We never create new categories from this app.

```dart
class SubCategory {
  final String id;
  final String title;
  final String? imageUrl;    // Nullable .. not every sub-category has an image
  final String categoryId;   // Which parent category this belongs to

  const SubCategory({
    required this.id,
    required this.title,
    this.imageUrl,            // Optional .. no 'required' keyword
    required this.categoryId,
  });
}
```

### The `const` Constructor

```dart
const Category({...});
```

The `const` keyword means: "If you create two `Category` objects with the exact same values, Dart will reuse the same object in memory instead of creating two copies." It's a performance optimization.

---

## Key Takeaways

| Concept            | What It Means                                                 |
| ------------------ | ------------------------------------------------------------- |
| **Entity**         | A plain Dart class that represents a core concept in your app |
| **`final`**        | The value can't change after creation (immutability)          |
| **`?` (nullable)** | The value might be `null` (nothing/empty)                     |
| **`required`**     | You must provide this value .. it's not optional              |
| **`copyWith`**     | Creates a modified copy of an immutable object                |
| **`??`**           | "Use this value, OR if it's null, use that one instead"       |
| **`const`**        | Compile-time constant .. saves memory                         |

---

**Next Chapter:** We'll learn how to convert these Dart objects to/from JSON so we can send them over the internet.
