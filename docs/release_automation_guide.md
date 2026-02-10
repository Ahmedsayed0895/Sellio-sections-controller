# Sellio Release Automation Guide

This document outlines the steps taken to automate GitHub Releases for the **Sellio Categories Section Controller** app, the challenges faced, and how they were resolved. It also provides a step-by-step guide on how to create a new release.

## 🚀 Goal
Automate the process of building the Flutter app for **Android** and **Windows**, running tests (optional), and publishing a Release on GitHub with the installer files attached whenever a new version tag (e.g., `v1.0.1`) is pushed.

---

## 🛠️ Phase 1: Initial Setup

### 1. GitHub Actions Workflow
We created a file `.github/workflows/build_and_release.yml` to define the automation pipeline.

**Key Configuration:**
- **Trigger:** `on: push: tags: - 'v*'` (Runs only when a tag starting with 'v' is pushed).
- **Jobs:**
    - `android-build`: Builds the Android APK.
    - `windows-build`: Builds the Windows executable.
    - `release`: Depends on the build jobs, downloads the artifacts, and creates the GitHub Release.

---

## 🔧 Phase 2: Problems & Solutions

### 1. 📉 App Size Optimization (>40MB → ~15MB)
**Problem:** The initial APK was over 40MB because it was a "fat" APK containing compiled code for all Android architectures (arm64, armv7, x86).
**Solution:**
- We modified the build command to **split the APK** by ABI (Application Binary Interface).
- **Command:** `flutter build apk --release --split-per-abi`
- **Result:** This generates 3 separate, smaller APKs (~11-16MB each) tailored for specific devices.

### 2. 🌐 Connection Error (Release Build)
**Problem:** The app worked in Debug mode but failed to connect to the backend in Release mode ("Is server running?").
**Root Cause:** Android requires explicit permission to access the internet. Debug builds grant this automatically, but Release builds do not.
**Solution:**
- Added `<uses-permission android:name="android.permission.INTERNET"/>` to `android/app/src/main/AndroidManifest.xml`.

### 3. 🏷️ Confusing Filenames
**Problem:** The generated files were named technically (`app-release.apk`, `windows-release.zip`), which is confusing for non-technical users.
**Solution:**
- We added a "Rename" step in the workflow to rename assets based on the version tag and intent.
- **Old Name:** `app-arm64-v8a-release.apk`
- **New Name:** `Sellio-v1.0.1-Modern-Android-64bit.apk`

### 4. 📂 Too Many Windows Files
**Problem:** The Windows build produces an `.exe` file plus many `.dll` files and a `data` folder (over 15 files). Uploading them individually made the release messy.
**Solution:**
- Added a step to **Zip** the Windows build output into a single file: `Sellio-v1.0.1-Windows-PC.zip`.

### 5. 🎨 App Icon
**Problem:** The app had the default Flutter icon.
**Solution:**
- Added `flutter_launcher_icons` package.
- Generated a professional icon using the primary brand color (`#530827`).
- Configured `pubspec.yaml` and ran the generation tool to create native icons for Android and iOS.

---

## 📦 How to Create a New Release

Follow these steps whenever you are ready to publish a new version of the app.

### Step 1: Update Version
Open `pubspec.yaml` and increment the version number.
```yaml
version: 1.0.2+1
```

### Step 2: Commit Changes
Run the following commands in your terminal:
```bash
git add pubspec.yaml
git commit -m "chore: bump version to 1.0.2"
git push origin main
```

### Step 3: Trigger Release
Create a tag matching the version and push it. This triggers the GitHub Action.
```bash
# Create the tag (must start with 'v')
git tag v1.0.2

# Push the tag to GitHub
git push origin v1.0.2
```

### Step 4: Verify
1.  Go to your GitHub Repository -> **Actions** tab.
2.  You will see a workflow running for the tag `v1.0.2`.
3.  Once it turns ✅ Green, go to the **Releases** section on the main page.
4.  You will see the new release with the following assets:
    *   📱 `Sellio-v1.0.2-Modern-Android-64bit.apk` (Recommended for phones)
    *   📱 `Sellio-v1.0.2-Older-Android-32bit.apk` (For old devices)
    *   💻 `Sellio-v1.0.2-Intel-Emulator.apk` (For PC emulators)
    *   🖥️ `Sellio-v1.0.2-Windows-PC.zip` (For Desktop)
