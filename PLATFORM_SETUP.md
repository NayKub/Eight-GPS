# Platform Configuration Guide

## Android Configuration

### Step 1: Permissions
Edit `android/app/src/main/AndroidManifest.xml`:

```xml
<?xml version="1.0" encoding="utf-8"?>
<manifest xmlns:android="http://schemas.android.com/apk/res/android"
    package="com.example.eight_gps">

    <uses-permission android:name="android.permission.CAMERA" />
    <uses-permission android:name="android.permission.ACCESS_FINE_LOCATION" />
    <uses-permission android:name="android.permission.ACCESS_COARSE_LOCATION" />
    <uses-permission android:name="android.permission.READ_EXTERNAL_STORAGE" />
    <uses-permission android:name="android.permission.WRITE_EXTERNAL_STORAGE" />
    <uses-permission android:name="android.permission.INTERNET" />

    <application
        android:label="Eight GPS"
        android:icon="@mipmap/ic_launcher">
        <!-- ... rest of manifest ... -->
    </application>
</manifest>
```

### Step 2: Firebase Setup
- `google-services.json` is already in `android/app/`
- From Firebase Console:
  1. Go to Project Settings → Your apps → Android
  2. Download the latest `google-services.json`
  3. Replace the existing file in `android/app/`

### Step 3: Build & Run
```bash
flutter run -d emulator-5554
# or use Android Studio to select device
flutter run
```

### Step 4: Grant Permissions at Runtime
When first run, grant:
- Camera access
- Location access
- Storage access

---

## iOS Configuration

### Step 1: Info.plist Permissions
Edit `ios/Runner/Info.plist`:

```xml
<?xml version="1.0" encoding="UTF-8"?>
<!DOCTYPE plist PUBLIC "-//Apple//DTD PLIST 1.0//EN" "http://www.apple.com/DTDs/PropertyList-1.0.dtd">
<plist version="1.0">
<dict>
    <!-- ... existing keys ... -->
    
    <!-- Camera Permission -->
    <key>NSCameraUsageDescription</key>
    <string>This app needs camera access to take photos</string>
    
    <!-- Location Permission -->
    <key>NSLocationWhenInUseUsageDescription</key>
    <string>This app needs your location for GPS tracking</string>
    
    <key>NSLocationAlwaysAndWhenInUseUsageDescription</key>
    <string>This app needs your location for GPS tracking</string>
    
    <!-- Photo Library -->
    <key>NSPhotoLibraryUsageDescription</key>
    <string>This app needs access to your photo library</string>
    
    <!-- Microphone (if needed for video) -->
    <key>NSMicrophoneUsageDescription</key>
    <string>This app needs microphone access for video recording</string>
    
    <!-- ... rest of plist ... -->
</dict>
</plist>
```

### Step 2: Firebase Setup
- `GoogleService-Info.plist` is already in `ios/Runner/`
- From Firebase Console:
  1. Go to Project Settings → Your apps → iOS
  2. Download the latest `GoogleService-Info.plist`
  3. In Xcode: Right-click Runner folder → Add Files → GoogleService-Info.plist
  4. Make sure it's added to Runner target

### Step 3: CocoaPods Dependencies
```bash
cd ios
pod install
cd ..
```

### Step 4: Run on Simulator
```bash
flutter run -d iPhone
# or specify simulator:
flutter run -d "iPhone 15"
```

### Step 5: Simulator Permissions
When first run, grant:
- Camera access (in simulator settings)
- Location access
- Photo library access

---

## Web Configuration

### Step 1: Firebase Setup
- From Firebase Console → Project Settings → General
- Find "Your apps" section → Web
- Create web app if not exists
- Copy configuration

### Step 2: Update firebase_options.dart
Update the `web` configuration in `lib/firebase_options.dart`:

```dart
static const FirebaseOptions web = FirebaseOptions(
  apiKey: 'AIzaSy...',           // Copy from Firebase
  appId: '1:123:web:abc...',     // Copy from Firebase
  messagingSenderId: '123...',    // Copy from Firebase
  projectId: 'eight-gps-project', // Copy from Firebase
  authDomain: 'eight-gps-project.firebaseapp.com',
  storageBucket: 'eight-gps-project.appspot.com',
);
```

### Step 3: Run Web App
```bash
flutter run -d chrome
# or Firefox, Edge, etc.
flutter run -d firefox
```

### Step 4: Features to Note
- GPS works only on secure (HTTPS) connections
- Camera requires HTTPS or localhost
- Video playback may have restrictions
- Consider adding `web/index.html` changes if needed

### Step 5: Build for Web
```bash
flutter build web
# Outputs to build/web/
```

---

## macOS Configuration

### Step 1: Permissions (Info.plist)
Edit `macos/Runner/Info.plist`:

```xml
<key>NSCameraUsageDescription</key>
<string>This app needs camera access</string>

<key>NSLocationUsageDescription</key>
<string>This app needs location access</string>

<key>NSPhotoLibraryUsageDescription</key>
<string>This app needs photo library access</string>
```

### Step 2: Firebase Setup
- `GoogleService-Info.plist` should be in `macos/Runner/`
- Download latest from Firebase Console
- Add to Xcode Runner target

### Step 3: Run
```bash
flutter run -d macos
```

---

## Windows Configuration

### Step 1: Firebase Setup
Update `lib/firebase_options.dart` Windows section:

```dart
static const FirebaseOptions windows = FirebaseOptions(
  apiKey: 'YOUR_WINDOWS_API_KEY',
  appId: '1:PROJECT_ID:windows:APP_ID',
  messagingSenderId: 'MESSAGING_SENDER_ID',
  projectId: 'eight-gps-project',
  storageBucket: 'eight-gps-project.appspot.com',
);
```

### Step 2: Permissions
Windows doesn't require manifest permissions, but user must grant:
- Camera access
- Location access

### Step 3: Run
```bash
flutter run -d windows
```

---

## Firebase Credentials Template

When setting up each platform, you'll need to update these values:

```dart
// Get these from Firebase Console
static const FirebaseOptions {PLATFORM} = FirebaseOptions(
  apiKey: 'AIzaSy...',           // API Key
  appId: '1:123:PLATFORM:abc...', // App ID
  messagingSenderId: '123...',    // Sender ID
  projectId: 'eight-gps-project', // Project ID
  authDomain: 'eight-gps-project.firebaseapp.com', // (Web only)
  storageBucket: 'eight-gps-project.appspot.com',  // (Web only)
  iosBundleId: 'com.example.eightGps',             // (iOS/macOS)
);
```

---

## Troubleshooting by Platform

### Android
| Issue | Solution |
|-------|----------|
| Camera not working | Check AndroidManifest.xml permissions |
| GPS returns null | Enable location services, grant permission |
| Video won't play | Check file format (MP4, WebM) |
| Firebase error | Check google-services.json in android/app/ |

### iOS
| Issue | Solution |
|-------|----------|
| Camera permission denied | Check Info.plist NSCameraUsageDescription |
| GPS not working | Add NSLocationWhenInUseUsageDescription |
| Pod error | Run `cd ios && pod install && cd ..` |
| Firebase error | Check GoogleService-Info.plist in Xcode |

### Web
| Issue | Solution |
|-------|----------|
| GPS denied | Run on HTTPS (not localhost:8080 for some features) |
| Camera not available | HTTPS required |
| Firebase error | Check web config in firebase_options.dart |
| Video format error | Use MP4 or WebM format |

### macOS
| Issue | Solution |
|-------|----------|
| Permission denied | Check Info.plist descriptions |
| Firebase error | Verify GoogleService-Info.plist added |

### Windows
| Issue | Solution |
|-------|----------|
| Camera/GPS | Grant permissions when prompted |
| Firebase error | Check firebase_options.dart credentials |

---

## Verification Checklist

After configuration, verify:

- [ ] Firebase console project created
- [ ] Authentication enabled (Email/Password)
- [ ] Firestore database created
- [ ] Platform credentials added (Web/Android/iOS)
- [ ] Permissions configured per platform
- [ ] flutter pub get completed
- [ ] No compilation errors
- [ ] App starts without Firebase errors
- [ ] Can login/signup
- [ ] Weather API displays data
- [ ] GPS returns coordinates
- [ ] Camera/gallery works
- [ ] Gyroscope shows values

---

## Quick Reference: Running on Different Devices

```bash
# List available devices
flutter devices

# Run on specific device
flutter run -d <device-id>

# Web browsers
flutter run -d chrome
flutter run -d firefox
flutter run -d edge

# Android
flutter run -d emulator-5554  # Android Emulator
flutter run -d <android-device-serial>  # Physical device

# iOS
flutter run -d iPhone  # Simulator
flutter run -d <ios-device-name>  # Physical device

# macOS/Windows
flutter run -d macos
flutter run -d windows
```

---

**Last Updated**: 2026
**Platforms**: Android, iOS, Web, macOS, Windows
