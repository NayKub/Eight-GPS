# Firebase Setup Checklist

## ✅ Complete this in 5 minutes

### Phase 1: Create Firebase Project (2 min)

- [ ] Go to [console.firebase.google.com](https://console.firebase.google.com)
- [ ] Click "Create a project"
- [ ] Name: `eight-gps-project`
- [ ] Click "Create project"
- [ ] Wait for project creation
- [ ] Click "Continue"

### Phase 2: Enable Services (2 min)

#### Enable Authentication
- [ ] Left sidebar → Authentication
- [ ] Click "Get Started"
- [ ] Click "Email/Password"
- [ ] Toggle Enable switch → ON
- [ ] Click "Save"

#### Enable Firestore
- [ ] Left sidebar → Firestore Database
- [ ] Click "Create database"
- [ ] Select location (closest to you)
- [ ] Click "Create database"
- [ ] Select "Start in test mode"
- [ ] Click "Create"

### Phase 3: Get Credentials (1 min)

#### For Web/Flutter
- [ ] Click gear icon ⚙️ → Project Settings
- [ ] Scroll to "Your apps" section
- [ ] Find the web app (or create one: click </> icon)
- [ ] Copy the config object

**What you need to copy:**
```
apiKey: "AIzaSy..."
authDomain: "..."
projectId: "eight-gps-project"
storageBucket: "..."
messagingSenderId: "..."
appId: "..."
```

### Phase 4: Update Your App (1 min)

- [ ] Open `lib/firebase_options.dart`
- [ ] Find the `web` section (around line 30)
- [ ] Paste your values:
  ```dart
  static const FirebaseOptions web = FirebaseOptions(
    apiKey: 'PASTE_YOUR_API_KEY_HERE',
    appId: 'PASTE_YOUR_APP_ID_HERE',
    messagingSenderId: 'PASTE_YOUR_SENDER_ID_HERE',
    projectId: 'eight-gps-project',
    authDomain: 'eight-gps-project.firebaseapp.com',
    storageBucket: 'eight-gps-project.appspot.com',
  );
  ```
- [ ] Save the file

### Phase 5: Run App! (1 min)

```bash
cd "/Users/nxnecrx/Desktop/Web:App dev/web_app"
flutter run -d chrome
```

---

## 🔒 Firestore Security Rules (Already Set)

Firebase is already configured for testing:
- ✅ Anyone can read/write
- ⚠️ For production, update security rules

---

## 📱 Optional: Configure for Android/iOS

### For Android
- [ ] In Firebase Console, add Android app
- [ ] Package name: `com.example.eight_gps`
- [ ] Download `google-services.json`
- [ ] Replace file at `android/app/google-services.json`

### For iOS
- [ ] In Firebase Console, add iOS app
- [ ] Bundle ID: `com.example.eightGps`
- [ ] Download `GoogleService-Info.plist`
- [ ] Replace file at `ios/Runner/GoogleService-Info.plist`

---

## ✨ That's It!

You're done! Your app is ready to use with:
- ✅ Login/Signup
- ✅ User data storage
- ✅ Weather API
- ✅ GPS tracking
- ✅ Gyroscope data
- ✅ Camera/video

---

## 🧪 Test It

1. Run: `flutter run -d chrome`
2. Click "Sign Up"
3. Create account with any email/password
4. Navigate through all pages
5. Grant permissions when asked

---

## 🆘 Troubleshooting

### "Firebase is not initialized"
→ Check `firebase_options.dart` has correct credentials

### "Authentication failed"
→ Make sure Firestore database is created

### "Firestore not available"
→ Wait 1-2 minutes for database to activate

### "CORS error on web"
→ Firebase web config is missing or incorrect

---

## 📋 Firebase Checklist Summary

- [ ] Project created
- [ ] Authentication enabled
- [ ] Firestore enabled
- [ ] Web credentials copied
- [ ] firebase_options.dart updated
- [ ] App runs without Firebase errors
- [ ] Can sign up/login
- [ ] Data appears in Firestore Console

---

## 🎉 Ready to Launch!

Once all checks are complete, your app is fully functional!

Estimated time: **5-10 minutes**

