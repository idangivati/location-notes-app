# 📍 Location Notes App

A Flutter mobile app for creating location-based notes with Google Maps integration.

## ✨ Features

- 🔐 User authentication (login/signup)
- 📝 Create and edit notes with automatic location capture
- 🗺️ View notes on Google Maps
- 📱 List view of all your notes
- ☁️ Real-time sync with Firebase
- 🎨 Modern, clean UI

## 🛠️ Tech Stack

- **Flutter** - Mobile app framework
- **Firebase Auth** - User authentication
- **Firestore** - Database and real-time sync
- **Google Maps** - Map integration
- **Geolocator** - Location services

## 🚀 Quick Start

1. Clone the repository
2. Run `flutter pub get`
3. Set up Firebase (add `google-services.json`)
4. Add Google Maps API key to `android/local.properties`
5. Run `flutter run`

## ⚙️ Setup

### Firebase Configuration
1. Create Firebase project
2. Enable Authentication and Firestore
3. Download `google-services.json` to `android/app/`

### Google Maps Setup
1. Get API key from Google Cloud Console
2. Enable "Maps SDK for Android"
3. Create `android/local.properties`:
   ```
   MAPS_API_KEY=your_api_key_here
   ```

## 📋 Requirements

- Flutter 3.0+
- Android SDK
- Google Maps API Key
- Firebase Project

## 🐛 Known Issues

- Currently Android only (iOS support can be added)
- Requires internet connection for sync
- Location permission required

