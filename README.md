# Spikeman Inc.

A Flutter mobile application for **Spikeman Inc.**, a social jobbing platform connecting skilled professionals with clients globally.

## 🚀 Features

- **Splash Screen**: Professional onboarding with auto-navigation.
- **Authentication**:
    - Email & Password Login/Signup.
    - Form validation (Email format, Password strength).
    - Loading states and error handling.
- **Firebase Integration**:
    - **Web**: Pre-configured using `AppOptions` in `lib/firebase_options.dart`.
    - **Android**: Configured via `google-services.json` (Native Assets workaround applied).

## 🛠 Tech Stack

- **Framework**: Flutter (Dart)
- **Backend**: Firebase Authentication
- **State Management**: Provider
- **Design System**: Custom Blue & White theme, Google Fonts (Inter).

## ⚙️ Setup & Installation

### Prerequisites
- Flutter SDK
- Android Studio / VS Code

### 1. Install Dependencies
```bash
flutter pub get
```

### 2. Firebase Configuration
- **Web**: Configuration is already included in `lib/firebase_options.dart`.
- **Android**: Ensure `android/app/google-services.json` is present.
- **iOS**: Place your `GoogleService-Info.plist` in `ios/Runner`.

> **Note on Windows Build**: 
> This project uses `firebase_core` (v2.x) and `firebase_auth` (v4.x) to ensure stability on Windows development environments where spaces in paths (e.g. `C:\Users\John Doe`) can cause build failures with newer versions.

### 3. Run the App
```bash
flutter run
```

## 📂 Project Structure

```
lib/
 ├── ui/
 │    ├── screens/   # Splash, Auth
 │    └── widgets/   # Reusable UI components
 ├── services/       # Firebase Auth logic
 ├── utils/          # Constants, Validators
 └── main.dart       # Entry point & Routing
```
