# 🔥 Firebase Setup Guide for MoodiesApp

Follow these steps to connect your app to Firebase.

---

## Step 1 — Create Firebase Project

1. Go to **https://console.firebase.google.com**
2. Click **"Add project"**
3. Name it `MoodiesApp` → Continue
4. Disable Google Analytics (optional) → **Create project**

---

## Step 2 — Enable Firebase Auth

1. In Firebase Console → **Authentication** → **Get started**
2. Click **"Email/Password"** → Enable → **Save**

---

## Step 3 — Create Firestore Database

1. In Firebase Console → **Firestore Database** → **Create database**
2. Choose **"Start in test mode"** (for development)
3. Select your region → **Done**

### Firestore Security Rules (for production)
Replace the default rules with:

```
rules_version = '2';
service cloud.firestore {
  match /databases/{database}/documents {

    // Users can only read/write their own document
    match /users/{userId} {
      allow read, write: if request.auth != null && request.auth.uid == userId;

      // Allow reading sub-collections (moods, events, etc.)
      match /{subcollection}/{docId} {
        allow read, write: if request.auth != null && request.auth.uid == userId;
      }
    }

    // Parents can read their linked child's moods
    match /users/{childId}/moods/{moodId} {
      allow read: if request.auth != null;
    }

    // Allow searching users by code (for parent linking)
    match /users/{userId} {
      allow read: if request.auth != null;
    }
  }
}
```

---

## Step 4 — Add Flutter App to Firebase

### For Android:
1. In Firebase Console → **Project Settings** → **Add app** → Android icon
2. **Android package name**: `com.moodiesapp` (or your package name from `build.gradle`)
3. Click **"Register app"**
4. Download **`google-services.json`**
5. Place it in: `android/app/google-services.json`

### For iOS:
1. In Firebase Console → **Project Settings** → **Add app** → iOS icon
2. **iOS bundle ID**: `com.moodiesapp` (or your bundle ID)
3. Click **"Register app"**
4. Download **`GoogleService-Info.plist`**
5. Place it in: `ios/Runner/GoogleService-Info.plist`

---

## Step 5 — Configure Android build files

### `android/build.gradle` — add at the bottom of dependencies:
```gradle
dependencies {
    // ... existing dependencies
    classpath 'com.google.gms:google-services:4.4.0'
}
```

### `android/app/build.gradle` — add at the very bottom:
```gradle
apply plugin: 'com.google.gms.google-services'
```

Also make sure `minSdkVersion` is at least **21**:
```gradle
android {
    defaultConfig {
        minSdkVersion 21
        // ...
    }
}
```

---

## Step 6 — Run the app

```bash
flutter pub get
flutter run
```

---

## 📁 Firestore Data Structure

When the app runs, it automatically creates this structure:

```
users/
  {uid}/                          ← Created on registration
    name: "John Doe"
    email: "john@example.com"
    role: "parent"                ← "parent" or "kides"
    is_child: 0                   ← 0=parent, 1=kids
    code: "ABC123"                ← Unique 6-char linking code
    parent_email: ""
    created_at: timestamp
    linked_child_uid: ""          ← Set when parent links to child

    avatar/
      data/                       ← Single document
        gender: "male"
        hair_color: "blonde"
        skin: "tan"
        updated_at: timestamp

    moods/
      {autoId}/
        mood: "Happy"
        created_at: timestamp

    events/
      {autoId}/
        title: "Doctor visit"
        type: "Health"
        event_date: "2024-12-01"
        reminder: "Tomorrow"
        notes: "Bring insurance card"
        created_at: timestamp

    reminders/
      {autoId}/
        reminder: "Take medicine"
        reminder_datetime: "2024-12-01 09:00"
        created_at: timestamp

    therapy/
      {autoId}/
        therapist: "Dr. Smith"
        therapy_datetime: "2024-12-05 14:00"
        created_at: timestamp
```

---

## 🔗 Parent–Child Linking Flow

1. **Child registers** → Gets a unique 6-character `code` (e.g. `ABC123`)
2. **Parent registers** → Goes to Code For Kids screen
3. **Parent enters child's code** → App searches Firestore for matching user
4. **Match found** → Parent's profile gets `linked_child_uid` set
5. **Parent can now view** child's mood history

---

## ⚠️ Important Notes

- The `google-services.json` / `GoogleService-Info.plist` files are **NOT** included in this project — you must generate them from your own Firebase console
- **Never commit** these files to public git repos as they contain API keys
- For production, tighten the Firestore security rules above
- Firebase Auth handles all token management automatically — no manual token storage needed
