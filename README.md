# REALTAX — Car Rental App 🚗

A cross-platform car rental mobile application built with **Flutter** and **Firebase**, featuring real-time booking synchronization, secure authentication, smart local notifications, and a sleek dark-themed UI.

---

## 📱 Overview

REALTAX allows users to sign up, browse premium cars by category, search and filter listings, view detailed specs, book a car, and receive automatic pickup-time reminders — all backed by Firebase in real time.

- **App Name:** REALTAX
- **Platform:** Android (primary), with iOS support in the codebase
- **Framework:** Flutter
- **Backend:** Firebase (Firestore, Firebase Auth, Firebase Storage)
- **Alternate stack (explored):** Flutter frontend + Django + PostgreSQL backend
- **Developer:** Syed Noman Shariq (Nu'my) — Freelance Flutter & Firebase Developer

---

## ✨ Key Features

- 🔑 **Sign Up / Login** — Full Name, Email, Password + Confirm Password on sign up; Email + Password login with "Forgot Password?" support
- 🌐 **Social Login UI** — Facebook, Google, and Instagram sign-in buttons (`font_awesome_flutter`)
- 🏠 **Home Dashboard** — Personalized greeting ("Find your dream car"), category filters (All, Audi, BMW, Lamborghini, Tesla), All Collections, Featured Cars carousel, and Popular Deals list
- 🔍 **Live Search** — Real-time "Matching Results" as the user types (e.g. typing "bm" instantly surfaces the BMW M5)
- 🚘 **Car Detail Screen** — Large hero image, rating, specs grid (Horsepower, 0–60 time, Top Speed), description, and favorite (heart) toggle
- 📅 **Booking Flow** — One-tap booking with instant on-screen confirmation ("Booking Successful! Notification set for ...")
- 🔔 **Custom Notification System** — Automatic pickup-time reminder notifications, written in Roman Urdu (e.g. *"Aapka pickup time 4:07 AM hai."*), viewable in a dedicated in-app Notifications screen
- 👤 **Profile Avatar** — Top-right profile icon on the home screen
- 🌗 **Theme Toggle** — Sun/dark-mode icon on the home app bar

---

## 🖼️ App Flow / Screenshots

<table>
<tr>
<td align="center"><b>Sign Up</b></td>
<td align="center"><b>Login</b></td>
<td align="center"><b>Home</b></td>
</tr>
<tr>
<td><img width="286" alt="Sign Up screen" src="https://github.com/user-attachments/assets/5cc6df7e-b791-4863-86d4-ba2550b3885e" /></td>
<td><img width="286" alt="Login screen" src="https://github.com/user-attachments/assets/5b81959f-92b1-4f03-bf2c-7e6157e365a6" /></td>
<td><img width="286" alt="Home screen" src="https://github.com/user-attachments/assets/83df91e1-7e31-4298-900b-d06d3d0d49d1" /></td>
</tr>
<tr>
<td align="center"><b>Car Detail + Booking</b></td>
<td align="center"><b>Live Search</b></td>
<td align="center"><b>Notifications</b></td>
</tr>
<tr>
<td><img width="286" alt="Car detail and booking screen" src="https://github.com/user-attachments/assets/1b23c054-19d4-4849-9788-010672b090f6" /></td>
<td><img width="286" alt="Live search screen" src="https://github.com/user-attachments/assets/079271c4-6445-48c8-8e9a-53104a0d3e48" /></td>
<td><img width="286" alt="Notifications screen" src="https://github.com/user-attachments/assets/55cf3524-45d6-4114-802a-ff8b50fc3661" /></td>
</tr>
<tr>
<td align="center"><b>Favorites</b></td>
<td align="center"><b>Profile / Settings</b></td>
<td align="center"><b>Splash / Onboarding</b></td>
</tr>
<tr>
<td><img width="286" alt="Favorites screen" src="https://github.com/user-attachments/assets/fa570a59-5cce-47a8-8b5d-0bac95950f0c" /></td>
<td><img width="286" alt="Profile and settings screen" src="https://github.com/user-attachments/assets/0dcc6622-681b-4203-8d49-7287d7f3780e" /></td>
<td><img width="286" alt="Splash and onboarding screen" src="https://github.com/user-attachments/assets/40ab78a6-5f37-4254-a962-c3496e4c2a99" /></td>
</tr>
</table>

> Screenshots extracted from an in-app screen recording (`screen-20260813-040713.mp4`).

---

## 🛠️ Tech Stack & Dependencies

| Package | Version (locked) | Purpose |
|---|---|---|
| `firebase_core` | 3.15.2 | Firebase initialization |
| `firebase_auth` | 5.7.0 | Authentication (Sign Up / Login) |
| `cloud_firestore` | 5.6.12 | Real-time car listings & bookings |
| `firebase_storage` | 12.4.10 | Car images / file storage |
| `google_sign_in` | 6.3.0 | Google OAuth login |
| `flutter_local_notifications` | 17.2.4 | Scheduled pickup-reminder notifications |
| `timezone` | 0.9.4 | Timezone-aware scheduling (Asia/Karachi) |
| `font_awesome_flutter` | 11.0.0 | Social login icons (FB / Google / Instagram) |
| `image_picker` | 1.2.1 | Uploading car/profile images |
| `shared_preferences` | 2.5.4 | Local key-value storage |
| `google_fonts` | 6.3.3 | Custom typography |

> ⚠️ Several dependencies have newer major versions available but are currently pinned due to breaking API changes (see Build Issues Log below). Run `flutter pub outdated` before upgrading anything.

---

## 📂 Project Structure

```
Car-RentalApp/
└── car_rental_app/              # ✅ actual Flutter project root (has pubspec.yaml)
    ├── lib/
    │   ├── main.dart
    │   ├── screens/
    │   │   ├── login_screen.dart        # Login + social buttons
    │   │   ├── signup_screen.dart       # Sign up form
    │   │   ├── home_screen.dart         # Categories, collections, featured, deals
    │   │   ├── car_detail_screen.dart   # Specs, description, booking
    │   │   ├── search_screen.dart       # Live search / matching results
    │   │   └── notifications_screen.dart
    │   └── services/
    │       └── notification_service.dart # Local notification scheduling
    ├── pubspec.yaml
    └── android/ ios/                     # platform-specific config
```

> Note: `Car-RentalApp` (top-level) is **not** itself a Flutter project — no `pubspec.yaml` there. Always `cd car_rental_app` before running Flutter commands.

---

## 🔔 Notification System

The `NotificationService` class handles all local notification logic:

- Initializes timezone data and sets local zone to **Asia/Karachi** (falls back to UTC if unavailable)
- Requests Android 13+ notification permission and exact-alarm permission
- Uses a `_initialized` guard flag to prevent duplicate `init()` calls
- Schedules exact, timezone-aware pickup reminders via `zonedSchedule`
- Delivers bilingual reminder text (e.g. *"Reminder: Audi A4 — Aapka pickup time 4:07 AM hai."*)

---

## 🐛 Build Issues & Fixes Log

| Issue | Cause | Fix |
|---|---|---|
| `IconData can't be extended outside of its library` | `font_awesome_flutter` v10.x incompatible with newer Dart SDK (`IconData` became `final`) | Upgraded to `font_awesome_flutter` v11.0.0 |
| `FaIconData can't be assigned to IconData` | v11 introduced its own `FaIconData` type | Updated `_buildSocialButton` parameter type from `IconData` to `FaIconData` |
| `The named parameter 'uiLocalNotificationDateInterpretation' is required` | Parameter is mandatory in `flutter_local_notifications` v17.2.4 (the version actually locked in this project) | Kept the parameter in `zonedSchedule` — do **not** remove it while on v17.x |
| `requestNotificationsPermission not defined for type Function` | Generic type inference breaking when `resolvePlatformSpecificImplementation<...>()` is split across multiple lines | Kept the call — and its generic type argument — on a single line |
| `PlatformException(permissionRequestInProgress)` | `NotificationService.init()` called more than once (e.g. from `main()` and a screen's `initState()`) | Added a static `_initialized` bool guard so `init()` only runs once |
| `Expected to find project root in current working directory` | Running `flutter` commands from `Car-RentalApp/` instead of `Car-RentalApp/car_rental_app/` | Always `cd car_rental_app` first |

---

## 🚀 Getting Started

1. Navigate to the actual project root:
   ```bash
   cd Car-RentalApp/car_rental_app
   ```
2. Install dependencies:
   ```bash
   flutter pub get
   ```
3. Ensure Firebase is configured (`google-services.json` in `android/app/`)
4. Run the app:
   ```bash
   flutter run
   ```

---

## 👨‍💻 Developer

**Syed Noman Shariq (Nu'my)**
BS Computer Science, Iqra University, Karachi
Freelance Flutter & Firebase Developer

---

## 📄 License

This project is licensed under the **MIT License** — free to use, modify, and distribute with attribution.
© 2026 Syed Noman Shariq (Nu'my). All rights reserved to the original author for design and architecture.
