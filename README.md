# MoodiesApp — Flutter + Firebase

Android (Java/Kotlin + ButterKnife + Retrofit) fully converted to **Flutter + Firebase**.

## What Changed vs REST API Version

| Before (REST API)              | After (Firebase)                        |
|--------------------------------|-----------------------------------------|
| `http` package + Retrofit      | `firebase_auth` + `cloud_firestore`     |
| `ApiService` class             | `FirebaseService` class                 |
| Manual JWT token storage       | Firebase Auth handles tokens auto       |
| `POST /login`                  | `signInWithEmailAndPassword()`          |
| `POST /register`               | `createUserWithEmailAndPassword()`      |
| `POST /user/forgotPassword`    | `sendPasswordResetEmail()`              |
| `POST /user/avatar/add`        | Firestore `users/{uid}/avatar/data`     |
| `POST /user/mood/add`          | Firestore `users/{uid}/moods`           |
| `GET  /user/mood/get`          | Firestore query on `users/{uid}/moods`  |
| `POST /user/event/add`         | Firestore `users/{uid}/events`          |
| `POST /user/event/get`         | Firestore `.where('event_date', ...)`   |
| `POST /user/reminder/add`      | Firestore `users/{uid}/reminders`       |
| `POST /user/therapy/add`       | Firestore `users/{uid}/therapy`         |
| `POST /getChildByCode`         | Firestore `.where('code', ==, code)`    |
| `GET  /user/me`                | Firestore `users/{uid}` document read   |
| `SessionManager` token prefs   | `SessionManager` role/gender/hair only  |

## Project Structure

```
lib/
├── main.dart
├── models/
│   └── models.dart                  # Firestore data models
├── services/
│   └── firebase_service.dart        # ALL Firebase operations
├── utils/
│   ├── app_constants.dart
│   └── session_manager.dart         # Local prefs (role, gender, hair)
├── widgets/
│   └── common_widgets.dart
└── screens/
    ├── splash_screen.dart
    ├── login_screen.dart
    ├── signup_screen.dart
    ├── code_for_kids_screen.dart
    ├── home_parent_screen.dart
    ├── home_kids_screen.dart
    ├── create_character_screen.dart
    ├── feeling_today_screen.dart
    ├── planner_list_screen.dart
    ├── kids_mood_tracker_list_screen.dart
    ├── parents_mood_list_screen.dart
    ├── print_list_screen.dart
    ├── awards_screen.dart
    ├── color_pages_screen.dart
    ├── chill_music_screen.dart
    └── puzzle_screen.dart
```

## Quick Start

```bash
# 1. Follow FIREBASE_SETUP.md to create your Firebase project
# 2. Add google-services.json to android/app/
# 3. Add GoogleService-Info.plist to ios/Runner/

flutter pub get
flutter run
```

See **FIREBASE_SETUP.md** for full step-by-step Firebase configuration.
