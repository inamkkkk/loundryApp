# 🛠️ Fix Compilation Errors

The errors you are seeing (red lines in `lib/`) are because **generated code files are missing**. This is normal for Flutter projects using `Riverpod` and `Freezed` until you run the build command.

## 🚀 How to Fix

Open your terminal in the project folder and run:

```bash
./fix_project.sh
```

**Or run these two commands manually:**

1.  **Download Plugins:**
    ```bash
    flutter pub get
    ```

2.  **Generate Code:**
    ```bash
    flutter pub run build_runner build --delete-conflicting-outputs
    ```

### Why causes these errors?
- **Undefined Class `_$Order`**: The code generator creates this.
- **Undefined Name `LucideIcons`**: The package needs to be downloaded via `flutter pub get`.
