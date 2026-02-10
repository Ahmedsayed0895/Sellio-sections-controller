# Clean Architecture in Sellio Categories Sections

This project follows the principles of **Clean Architecture** to ensure separation of concerns, scalability, and testability. The code is organized into three main layers: **Domain**, **Data**, and **Presentation**.

## 1. Domain Layer (`lib/domain`)
The core of the application logic. It is independent of any external libraries (like Flutter, Dio, or database implementations).

### Components:
- **Entities** (`lib/domain/entities`): Pure Dart classes representing the core business objects.
    - Example: `CategorySection`, `Category`.
- **Repositories (Interfaces)** (`lib/domain/repositories`): Abstract classes defining the contract for data operations.
    - Example: `ISectionRepository`, `ICategoryRepository`.
- **Use Cases** (`lib/domain/usecases`): Classes that encapsulate specific business logic. They interact with repositories to fulfill a single task.
    - Example: `GetSections`, `CreateSection`, `UpdateSection`.

## 2. Data Layer (`lib/data`)
Responsible for data retrieval and storage. It implements the interfaces defined in the Domain layer.

### Components:
- **Models** (`lib/data/models`): Data transfer objects (DTOs) used for API communication. They extend Entities and handle JSON serialization/deserialization.
    - Example: `SectionModel`, `CategoryModel`.
- **Data Sources** (`lib/data/datasources`): Handle the actual data fetching (API calls, local database).
    - **RemoteDataSource**: Defined by an interface (`IRemoteDataSource`) and implementation (`RemoteDataSourceImpl`) that uses **Retrofit** (`SellioApi`) to make network requests.
- **Repositories (Implementations)** (`lib/data/repositories`): Concrete implementations of the Domain repositories. They coordinate data from data sources and return Entities to the Domain layer.
    - Example: `SectionRepositoryImpl`, `CategoryRepositoryImpl`.

## 3. Presentation Layer (`lib/presentation` & `lib/screens`)
Responsible for the UI and user interaction.

### Components:
- **ViewModels** (`lib/presentation/viewmodels`): Manage the state of the UI and handle business logic by calling Use Cases.
    - Example: `AdminPanelViewModel`.
- **UI** (`lib/screens`): Flutter widgets that display data and react to user input. They observe the ViewModels.
    - Example: `AdminPanel`.

## Dependency Flow
The dependency rule is strictly followed: **Source code dependencies only point inwards.**
- **Presentation** depends on **Domain**.
- **Data** depends on **Domain**.
- **Domain** depends on **Nothing**.

```mermaid
graph TD
    UI[Presentation (UI)] --> ViewModel[Presentation (ViewModel)]
    ViewModel --> UseCase[Domain (Use Case)]
    UseCase --> RepoInterface[Domain (Repository Interface)]
    RepoImpl[Data (Repository Implementation)] --> RepoInterface
    RepoImpl --> DataSource[Data (Data Source)]
    DataSource --> API[External API]
```
