# Atomic Commits Guide

This project follows an **Atomic Commit** strategy where possible. This means keeping commits small, focused, and often limited to a single file change. This makes the project history easier to read, revert, and understand.

## Why Atomic Commits?

1.  **Clarity**: Each commit message describes exactly what changed in that specific file.
2.  **Revertibility**: If a specific file has a bug, you can revert just that commit without undoing other unrelated changes.
3.  **Code Review**: It's easier to review a series of small, logical changes than one massive "mega-commit".

## How We Automate It

Manually committing 30 files one by one is tedious. We use a **PowerShell script** (`commit_all.ps1`) to automate this.

### The Script (`commit_all.ps1`)

The script defines a list of files and their corresponding commit messages.

```powershell
$files = @{
    "lib/main.dart" = "Refactor main.dart to use Dependency Injection";
    "lib/injection.dart" = "Configure GetIt and Injectable setup";
    # ... more files ...
}
```

It then iterates through this list:
1.  **Checks** if the file exists or was deleted.
2.  **Stages** the file (`git add`).
3.  **Commits** it with the specific message (`git commit -m "..."`).

### Usage

To run the script:

1.  Open your terminal/PowerShell.
2.  Navigate to the project root.
3.  Run:
    ```powershell
    powershell -ExecutionPolicy Bypass -File commit_all.ps1
    ```

> [!TIP]
> You can modify the `$files` list in `commit_all.ps1` to include any new files you're working on.

## Best Practices

*   **Descriptive Messages**: specific messages like "Implement GetSections use case" are better than "Update file".
*   **Logical Grouping**: If two files are tightly coupled (e.g., a Model and its generated `.g.dart` file), you might choose to commit them together. Our script currently handles them individually for maximum granularity, but you can adjust this.
