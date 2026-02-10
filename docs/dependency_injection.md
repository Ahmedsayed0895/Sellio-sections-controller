# Dependency Injection in Sellio Categories Sections

We use **get_it** as our Service Locator and **injectable** for code generation to manage dependencies. This approach decouples the code, makes testing easier, and removes the need for manual dependency wiring.

## Before (Manual Injection)
In the manual approach, `main.dart` was responsible for creating every single instance and passing them down the tree. This becomes unmanageable as the app grows.

```dart
// lib/main.dart (Old way)
void main() {
  // 1. Manually create heavy objects
  final dio = Dio(BaseOptions(...));
  final api = SellioApi(dio);
  final remote = RemoteDataSourceImpl(api: api);

  // 2. Manually wire repositories
  final sectionRepo = SectionRepositoryImpl(remote);
  
  // 3. Manually wire use cases
  final getSections = GetSections(sectionRepo);
  final createSection = CreateSection(sectionRepo);
  // ... more use cases ...

  // 4. Manually create ViewModel
  final viewModel = AdminPanelViewModel(
    getSections: getSections,
    createSection: createSection,
    // ...
  );

  runApp(MyApp(viewModel: viewModel));
}
```

## After (GetIt + Injectable)
Now, we simply annotate our classes, and the generator does the wiring. `main.dart` is clean and focused.

### 1. Annotation
We tag our classes with `@injectable` or `@lazySingleton`.

```dart
@lazySingleton
class GetSections {
  final ISectionRepository repository;
  GetSections(this.repository); // Injectable finds the repo automatically
}

@injectable
class AdminPanelViewModel extends ChangeNotifier {
  final GetSections _getSections;
  AdminPanelViewModel({required GetSections getSections}) ...
}
```

### 2. Configuration (`lib/injection.dart`)
We set up the environment and initialize GetIt.

```dart
final getIt = GetIt.instance;

@InjectableInit()
void configureDependencies() => getIt.init();
```

### 3. Usage (`lib/main.dart`)
We initialize it once and request what we need.

```dart
void main() {
  WidgetsFlutterBinding.ensureInitialized();
  configureDependencies(); // One line to rule them all
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  Widget build(BuildContext context) {
    return MaterialApp(
      // ...
      home: AdminPanel(viewModel: getIt<AdminPanelViewModel>()),
    );
  }
}
```

## Setup
To regenerate the dependency graph after adding new classes:

```bash
flutter pub run build_runner build --delete-conflicting-outputs
```
