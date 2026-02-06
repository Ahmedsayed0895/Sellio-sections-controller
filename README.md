# Sellio Categories Section Controller

A Panel that designed for managing Home Screen Category Sections in the Sellio application. This tool empowers administrators to organize, prioritize, and manage the visibility of product categories with a seamless and responsive user interface.

## Key Features

*   **Section Management**: Create, Read, Update, and Delete (CRUD) sections with ease.
*   **Optimistic UI Updates**: Instant feedback on actions (like toggling active status or reordering) ensures a snappy user experience, with automatic rollback in case of server errors.
*   **Smart Merging**: Intelligently merges server data with local state to ensure inactive sections remain visible and editable for administrators.
*   **Sorting & Organization**: Manually control the display order of sections via a sort order field.
*   **Active/Inactive Toggling**: Quickly enable or disable sections from the main list.
*   **Error Handling**: Comprehensive error handling with user-friendly snackbars and retry mechanisms.

## Tech Stack

*   **Framework**: [Flutter](https://flutter.dev/) (Dart)
*   **Networking**: [Dio](https://pub.dev/packages/dio) for robust HTTP requests.
*   **State Management**: `ChangeNotifier` with `AnimatedBuilder` for clean, reactive UI updates.
*   **Linting**: `flutter_lints` for code quality and consistency.
*   **Design**: Material Design 3 with custom theming.

## Project Structure

```
lib/
├── controllers/      # Business logic and state management
│   └── admin_panel_controller.dart
├── models/           # Data models (Category, Section)
├── screens/          # UI Screens
│   ├── admin_panel.dart
│   └── components/   # Screen-specific widgets (Dialogs)
├── services/         # API and external communication
│   └── api_service.dart
├── theme/            # App-wide styling and colors
│   └── app_colors.dart
└── main.dart         # Entry point and theme configuration
```

## Getting Started

### Prerequisites

*   [Flutter SDK](https://docs.flutter.dev/get-started/install) (version 3.10.4 or higher)
*   Dart SDK

### Installation

1.  **Clone the repository**
    ```bash
    git clone https://github.com/yourusername/sellio_categories_section_controller.git
    cd sellio_categories_section_controller
    ```

2.  **Install dependencies**
    ```bash
    flutter pub get
    ```

3.  **Run the application**
    ```bash
    flutter run
    ```

## Usage

### Managing Sections

1.  **Add a Section**: Tap the floating "+" button. Enter the section title, select a category, and define the sort order.
2.  **Edit a Section**: Tap on any section card to open the edit dialog. You can modify the title, linked category, or sort order.
3.  **Toggle Visibility**: Use the toggle switch on the section card to mark it as Active or Inactive.
4.  **Delete a Section**: Click the trash icon on a section card to permanently remove it.


