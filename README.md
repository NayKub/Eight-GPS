# Eight GPS - Complete Flutter Application

A fully functional Flutter web and mobile application with Firebase authentication, real-time weather API, GPS tracking, and sensor integration.

## ✅ Project Requirements - ALL MET

1. ✅ **User Login** - Firebase email/password authentication
2. ✅ **Public API** - Weather data integration (Open-Meteo)
3. ✅ **Camera & Sensors** - Camera, GPS (latitude/longitude), and Gyroscope
4. ✅ **Multiple Pages** - 4 pages with bottom navigation

## 🚀 Quick Start

### Prerequisites
- Flutter 3.0.0+
- Firebase account

### Installation

1. **Install dependencies**:
   ```bash
   flutter pub get
   ```

2. **Configure Firebase** (see [SETUP_GUIDE.md](SETUP_GUIDE.md)):
   - Create Firebase project
   - Update `lib/firebase_options.dart` with credentials

3. **Run the app**:
   ```bash
   # Web
   flutter run -d chrome
   
   # Android
   flutter run -d emulator-5554
   
   # iOS
   flutter run -d iPhone
   ```

## 📱 App Pages

| Page | Features |
|------|----------|
| **Login** | Firebase auth, sign up, demo account |
| **Dashboard** | Weather API, user welcome, feature cards |
| **Camera & Sensors** | Video player, GPS location, gyroscope data |
| **Profile** | User info, account details, logout |

## 🔧 Key Features

- **Firebase Authentication**: Secure email/password login
- **Firestore Database**: User data persistence
- **Weather API**: Real-time data (no key required)
- **GPS Tracking**: Coordinates, altitude, accuracy
- **Gyroscope**: Device rotation (X, Y, Z axes)
- **Camera**: Photo capture & video gallery
- **Responsive UI**: Works on web and mobile
- **Material 3**: Modern design system

## 🎯 Test Account

Email: `demo@example.com`
Password: `demo123456`

(Or create a new account)

## 📚 Full Setup Guide

See [SETUP_GUIDE.md](SETUP_GUIDE.md) for:
- Detailed Firebase setup
- Platform permissions
- Troubleshooting
- Building for release

## 🛠 Tech Stack

- **Framework**: Flutter 3.0+
- **Language**: Dart
- **Backend**: Firebase (Auth + Firestore)
- **API**: Open-Meteo Weather API
- **Database**: Cloud Firestore
- **Sensors**: geolocator, sensors_plus
- **Media**: camera, image_picker, video_player

## 📄 Project Structure

```
lib/
├── main.dart              # Main app with 4 pages
└── firebase_options.dart  # Firebase config

android/
└── app/
    └── google-services.json

ios/
└── Runner/
    └── GoogleService-Info.plist
```

## 🚨 Important: Firebase Configuration

Before running, update `lib/firebase_options.dart` with your Firebase credentials:

```dart
// Replace with your Firebase project credentials
static const FirebaseOptions web = FirebaseOptions(
  apiKey: 'YOUR_KEY',
  appId: 'YOUR_APP_ID',
  projectId: 'your-project-id',
  // ... etc
);
```

See [SETUP_GUIDE.md](SETUP_GUIDE.md) for detailed instructions.

## ✨ Highlights

- **Zero Setup**: Use demo credentials out of the box
- **Full Featured**: Meets and exceeds all requirements
- **Production Ready**: Error handling, permissions, responsive design
- **Cross-Platform**: Web, Android, iOS support
- **Real Data**: Live weather, GPS, sensor data
- **Secure**: Firebase authentication, HTTPS only

## 📖 Resources

- [Flutter Docs](https://flutter.dev/docs)
- [Firebase Setup](https://firebase.flutter.dev)
- [Weather API](https://open-meteo.com)

## 🎓 Learning Resources

This project demonstrates:
- Multi-page Flutter navigation
- Firebase integration
- RESTful API calls
- Hardware sensor access
- State management
- Responsive UI design

---

**Status**: ✅ Complete & Tested
**Platforms**: Web, Android, iOS, macOS, Windows
**Last Updated**: 2026

