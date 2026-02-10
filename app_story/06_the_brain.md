# Chapter 6: The Brain — State Management with Cubit

> *"The UI is the face. The Cubit is the brain behind it."*

State management is the single most important concept in any Flutter app. It answers the question: **"How does the UI know what to show?"**

---

## What Is State?

**State** is a snapshot of everything the screen needs to display at a given moment:

```
At 10:00 AM → State: { status: loading, sections: [],      error: null }
At 10:01 AM → State: { status: success, sections: [3 items], error: null }
At 10:02 AM → State: { status: success, sections: [4 items], error: null }    ← User added one
At 10:03 AM → State: { status: success, sections: [4 items], error: "Network error" } ← Error
```

Each row is a **state**. The UI reads the current state and draws accordingly.

## What Is a Cubit?

A **Cubit** is a class that:
1. **Holds** the current state
2. **Emits** new states when something happens
3. The UI **listens** and rebuilds automatically

Think of it like a TV remote control:
- The remote has **buttons** (methods like `loadData()`, `addSection()`)
- When you press a button, the **TV changes** (new state is emitted)
- The screen **automatically updates** (UI rebuilds)

---

## Part 1: The State Definition

```dart
// File: lib/presentation/cubits/admin_panel_state.dart

import 'package:equatable/equatable.dart';         // 1
import '../../domain/entities/category.dart';
import '../../domain/entities/section.dart';

enum AdminPanelStatus { initial, loading, success, failure }  // 2

class AdminPanelState extends Equatable {            // 3
  final AdminPanelStatus status;                     // 4
  final List<CategorySection> sections;
  final List<Category> categories;
  final String? errorMessage;

  const AdminPanelState({                            // 5
    this.status = AdminPanelStatus.initial,
    this.sections = const [],
    this.categories = const [],
    this.errorMessage,
  });

  AdminPanelState copyWith({                         // 6
    AdminPanelStatus? status,
    List<CategorySection>? sections,
    List<Category>? categories,
    String? errorMessage,
  }) {
    return AdminPanelState(
      status: status ?? this.status,
      sections: sections ?? this.sections,
      categories: categories ?? this.categories,
      errorMessage: errorMessage,                    // 7
    );
  }

  @override
  List<Object?> get props => [status, sections, categories, errorMessage]; // 8
}
```

### Line-by-line:

#### Line 1: `Equatable`
This package makes state comparison easy. Without it, Dart compares objects by **identity** (are they the exact same object in memory?). With Equatable, Dart compares by **value** (do they have the same data?).

**Why does this matter?** Because the UI only rebuilds when the state **changes**. If two states have the same data, the UI should NOT rebuild (waste of performance).

```dart
// Without Equatable:
final a = AdminPanelState(status: AdminPanelStatus.loading);
final b = AdminPanelState(status: AdminPanelStatus.loading);
print(a == b); // false ❌ (different objects in memory)

// With Equatable:
print(a == b); // true ✅ (same values = same state)
```

#### Line 2: `enum AdminPanelStatus { initial, loading, success, failure }`
An **enum** (enumeration) is a fixed set of possible values. Like a traffic light can only be red, yellow, or green — the screen status can only be one of these four values:

| Status    | Meaning              | UI Shows      |
| --------- | -------------------- | ------------- |
| `initial` | App just started     | Nothing yet   |
| `loading` | Fetching data        | Spinner       |
| `success` | Data loaded          | The list      |
| `failure` | Something went wrong | Error message |

#### Line 5: Default values
```dart
this.status = AdminPanelStatus.initial,
this.sections = const [],
```
When you create an `AdminPanelState()` with no arguments, it starts with `initial` status and empty lists. This is the **starting state**.

#### Line 7: `errorMessage: errorMessage` (WITHOUT `??`)
Notice this line does NOT use `??`. Why? Because we WANT the error message to be cleared (set to null) when a new state is emitted without an error. If we used `??`, old error messages would stick around forever.

#### Line 8: `props`
Equatable uses this list to compare states. Two states are equal only if ALL props are equal.

---

## Part 2: The Cubit

```dart
// File: lib/presentation/cubits/admin_panel_cubit.dart

@injectable                                              // 1
class AdminPanelCubit extends Cubit<AdminPanelState> {   // 2
  final GetSections _getSections;                        // 3
  final CreateSection _createSection;
  final UpdateSection _updateSection;
  final DeleteSection _deleteSection;
  final GetCategories _getCategories;

  AdminPanelCubit({                                      // 4
    required GetSections getSections,
    required CreateSection createSection,
    required UpdateSection updateSection,
    required DeleteSection deleteSection,
    required GetCategories getCategories,
  }) : _getSections = getSections,                       // 5
       _createSection = createSection,
       _updateSection = updateSection,
       _deleteSection = deleteSection,
       _getCategories = getCategories,
       super(const AdminPanelState()) {                  // 6
    loadData();                                          // 7
  }
```

#### Line 1: `@injectable`
Registers with GetIt as a **factory** (new instance each time). A new Cubit = fresh state.

#### Line 2: `extends Cubit<AdminPanelState>`
"This Cubit manages `AdminPanelState`." The generic type `<AdminPanelState>` tells the Cubit what kind of state it holds.

#### Line 3: Private fields (the `_` prefix)
```dart
final GetSections _getSections;
```
The underscore `_` makes this field **private** — only this class can access it. The UI can't call `cubit._getSections()` directly. It must use the cubit's public methods (like `loadData()`).

#### Line 5: Initializer list
```dart
: _getSections = getSections,
```
This runs BEFORE the constructor body. It assigns the public parameters to private fields. Think of it as "unpacking the delivery" before you start working.

#### Line 6: `super(const AdminPanelState())`
Passes the **initial state** to the parent `Cubit` class. The cubit starts with `status: initial, sections: [], categories: []`.

#### Line 7: `loadData();`
Automatically loads data as soon as the cubit is created. No need for the UI to manually trigger it.

---

## The loadData Method — A Complete Walkthrough

```dart
Future<void> loadData() async {
  // Step 1: Tell the UI "I'm loading"
  emit(state.copyWith(status: AdminPanelStatus.loading));

  try {
    // Step 2: Preserve local inactive sections
    final localInactive = state.sections.where((s) => !s.isActive).toList();

    // Step 3: Fetch data from server (both at the same time!)
    final results = await Future.wait([_getSections(), _getCategories()]);

    final fetchedActiveSections = results[0] as List<CategorySection>;
    final categories = results[1] as List<Category>;

    // Step 4: Merge server data with local inactive sections
    final mergedSections = <CategorySection>[...localInactive];

    for (final fetched in fetchedActiveSections) {
      final index = mergedSections.indexWhere((s) => s.id == fetched.id);
      if (index != -1) {
        mergedSections[index] = fetched;  // Update existing
      } else {
        mergedSections.add(fetched);      // Add new
      }
    }

    mergedSections.sort((a, b) => a.sortOrder.compareTo(b.sortOrder));

    // Step 5: Tell the UI "Here's the data!"
    emit(state.copyWith(
      status: AdminPanelStatus.success,
      sections: mergedSections,
      categories: categories,
    ));
  } catch (e) {
    // Step 6: Tell the UI "Something went wrong"
    emit(state.copyWith(
      status: AdminPanelStatus.failure,
      errorMessage: e.toString(),
    ));
  }
}
```

### The `emit` function
`emit(newState)` is the **magic word**. It broadcasts a new state to all listeners (the UI). The UI automatically rebuilds with the new data.

### `Future.wait` — Parallel execution
```dart
final results = await Future.wait([_getSections(), _getCategories()]);
```
This fetches sections AND categories **at the same time**, not one after the other. If each takes 1 second, this takes ~1 second total instead of ~2 seconds.

### The Merge Logic
Why merge? Because the server only returns **active** sections. If the admin just deactivated a section, it would disappear from the list on refresh. We preserve locally deactivated sections by merging them with the fresh server data.

---

## Optimistic UI — The Delete Example

```dart
Future<void> removeSection(String id) async {
  // 1. Save a backup of the current sections
  final originalSections = List<CategorySection>.from(state.sections);

  // 2. Remove from UI IMMEDIATELY (before server responds)
  final updatedList = List<CategorySection>.from(originalSections)
    ..removeWhere((s) => s.id == id);
  emit(state.copyWith(sections: updatedList));

  try {
    // 3. Actually delete on the server
    await _deleteSection(id);
  } catch (e) {
    // 4. Server failed? UNDO the UI change!
    emit(state.copyWith(
      sections: originalSections,
      errorMessage: "Failed to delete: ${e.toString()}",
    ));
  }
}
```

This is called **Optimistic UI** — we assume the operation will succeed and update the UI immediately. If it fails, we revert. This makes the app feel incredibly fast because the user sees the change instantly.

---

## Key Takeaways

| Concept           | What It Means                                 |
| ----------------- | --------------------------------------------- |
| **State**         | A snapshot of everything the screen needs     |
| **Cubit**         | Holds state and emits new states              |
| **`emit()`**      | Broadcasts a new state to the UI              |
| **`Equatable`**   | Compares objects by value, not identity       |
| **`copyWith()`**  | Creates a modified copy of an immutable state |
| **`enum`**        | A fixed set of named values                   |
| **Optimistic UI** | Update UI immediately, revert on error        |
| **`Future.wait`** | Run multiple async operations in parallel     |

---

**Next Chapter:** The final piece — building the UI that brings everything to life.
