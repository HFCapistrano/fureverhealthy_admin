# Firebase Setup Guide for FureverHealthy Admin

This guide will help you set up Firebase for your Flutter admin application.

## Prerequisites

1. A Google account
2. Flutter SDK installed
3. Firebase CLI (optional but recommended)

## Step 1: Create a Firebase Project

1. Go to [Firebase Console](https://console.firebase.google.com/)
2. Click "Create a project" or "Add project"
3. Enter a project name (e.g., "fureverhealthy-admin")
4. Choose whether to enable Google Analytics (recommended)
5. Click "Create project"

## Step 2: Add Firebase to Your App

### For Web Platform

1. In your Firebase project console, click the web icon (</>)
2. Register your app with a nickname (e.g., "fureverhealthy-admin-web")
3. Copy the Firebase configuration object

### For Android Platform

1. In your Firebase project console, click the Android icon
2. Register your app with your package name
3. Download the `google-services.json` file
4. Place it in `android/app/` directory

### For iOS Platform

1. In your Firebase project console, click the iOS icon
2. Register your app with your bundle ID
3. Download the `GoogleService-Info.plist` file
4. Place it in `ios/Runner/` directory

## Step 3: Update Configuration Files

### Update Firebase Config

1. Open `lib/config/firebase_config.dart`
2. Replace the placeholder values with your actual Firebase configuration:

```dart
static Future<void> initialize() async {
  await Firebase.initializeApp(
    options: const FirebaseOptions(
      apiKey: "YOUR_ACTUAL_API_KEY",
      authDomain: "YOUR_ACTUAL_AUTH_DOMAIN",
      projectId: "YOUR_ACTUAL_PROJECT_ID",
      storageBucket: "YOUR_ACTUAL_STORAGE_BUCKET",
      messagingSenderId: "YOUR_ACTUAL_MESSAGING_SENDER_ID",
      appId: "YOUR_ACTUAL_APP_ID",
    ),
  );
}
```

### Update Web Configuration

1. Open `web/firebase-config.js`
2. Replace the placeholder values with your actual Firebase configuration:

```javascript
const firebaseConfig = {
  apiKey: "YOUR_ACTUAL_API_KEY",
  authDomain: "YOUR_ACTUAL_AUTH_DOMAIN",
  projectId: "YOUR_ACTUAL_PROJECT_ID",
  storageBucket: "YOUR_ACTUAL_STORAGE_BUCKET",
  messagingSenderId: "YOUR_ACTUAL_MESSAGING_SENDER_ID",
  appId: "YOUR_ACTUAL_APP_ID"
};
```

## Step 4: Enable Firebase Services

### Firestore Database

1. In Firebase Console, go to "Firestore Database"
2. Click "Create database"
3. Choose "Start in test mode" for development
4. Select a location for your database
5. Click "Done"

### Authentication

1. In Firebase Console, go to "Authentication"
2. Click "Get started"
3. Enable the sign-in methods you want to use (Email/Password recommended)
4. Click "Save"

### Storage

1. In Firebase Console, go to "Storage"
2. Click "Get started"
3. Choose "Start in test mode" for development
4. Select a location for your storage
5. Click "Done"

## Step 5: Set Up Security Rules

### Firestore Security Rules

1. In Firestore Database, go to "Rules" tab
2. Update the rules to allow read/write access for authenticated users:

```javascript
rules_version = '2';
service cloud.firestore {
  match /databases/{database}/documents {
    // Allow read/write access to authenticated users
    match /{document=**} {
      allow read, write: if request.auth != null;
    }
  }
}
```

### Storage Security Rules

1. In Storage, go to "Rules" tab
2. Update the rules to allow read/write access for authenticated users:

```javascript
rules_version = '2';
service firebase.storage {
  match /b/{bucket}/o {
    match /{allPaths=**} {
      allow read, write: if request.auth != null;
    }
  }
}
```

## Step 6: Install Dependencies

Run the following command to install Firebase dependencies:

```bash
flutter pub get
```

## Step 7: Test Firebase Connection

1. Run your app
2. Check the console for Firebase initialization messages
3. Verify that you can read/write data to Firestore

## Step 8: Create Initial Data Structure

The app will automatically create the following collections in Firestore:

- `users` - User accounts and profiles
- `vets` - Veterinarian information
- `appointments` - Booking and appointment data
- `petBreeds` - Pet breed information
- `analytics` - Dashboard analytics data

## Troubleshooting

### Common Issues

1. **Firebase not initialized**: Check your configuration values and ensure they match your Firebase project
2. **Permission denied**: Verify your security rules allow the operations you're trying to perform
3. **Network error**: Ensure your app has internet access and Firebase services are enabled

### Getting Help

- [Firebase Documentation](https://firebase.google.com/docs)
- [Flutter Firebase Documentation](https://firebase.flutter.dev/)
- [Firebase Console](https://console.firebase.google.com/)

## Security Notes

⚠️ **Important**: The current security rules allow any authenticated user to read/write all data. For production:

1. Implement proper user role-based access control
2. Restrict data access based on user permissions
3. Validate data on both client and server side
4. Regularly review and update security rules

## Next Steps

After setting up Firebase:

1. Implement user authentication
2. Create data management screens
3. Set up real-time data synchronization
4. Implement offline support
5. Add data validation and error handling

