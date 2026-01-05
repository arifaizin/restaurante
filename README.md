# 🍽️ Restaurante - Your Personal Dining Companion

[![Flutter](https://img.shields.io/badge/Flutter-02569B?style=for-the-badge&logo=flutter&logoColor=white)](https://flutter.dev)
[![Dart](https://img.shields.io/badge/Dart-0175C2?style=for-the-badge&logo=dart&logoColor=white)](https://dart.dev)
[![License: MIT](https://img.shields.io/badge/License-MIT-yellow.svg?style=for-the-badge)](https://opensource.org/licenses/MIT)

**Restaurante** is a premium, high-performance mobile application built with Flutter that allows users to discover, search, and manage their favorite restaurants. Designed with a sleek, modern UI and robust background services, it provides a seamless dining discovery experience.

---

## 🚀 Key Features

- **🔍 Smart Search**: Real-time restaurant discovery with debouncing and intelligent error handling.
- **❤️ Favorites System**: Save your preferred restaurants locally for quick access, even when offline.
- **📅 Daily Recommendations**: Native background tasks that notify you of a random restaurant suggestion every morning.
- **🌘 Dynamic Themes**: Support for both Light and Dark modes with persistent settings using Shared Preferences.
- **💬 Community Reviews**: Read detailed feedback from other diners and submit your own reviews directly from the app.
- **📦 Offline Capability**: Robust handling of network availability with user-friendly guidance.
- **✨ Animated Experience**: Rich UI featuring Lottie animations and custom splash screens for a premium feel.

---

## 🛠️ Technology Stack

| Category | Technology |
| :--- | :--- |
| **Framework** | [Flutter](https://flutter.dev) |
| **State Management** | [Provider](https://pub.dev/packages/provider) |
| **Local Database** | [Sqflite](https://pub.dev/packages/sqflite) |
| **Networking** | [http](https://pub.dev/packages/http) |
| **Background Tasks** | [Workmanager](https://pub.dev/packages/workmanager) & [Android Alarm Manager](https://pub.dev/packages/android_alarm_manager_plus) |
| **Notifications** | [Flutter Local Notifications](https://pub.dev/packages/flutter_local_notifications) |
| **Storage** | [Shared Preferences](https://pub.dev/packages/shared_preferences) & [Path Provider](https://pub.dev/packages/path_provider) |
| **Animations** | [Lottie](https://pub.dev/packages/lottie) & [Animated Text Kit](https://pub.dev/packages/animated_text_kit) |

---

## 🏗️ Architecture & Structure

The project follows a modular and clean architecture to ensure maintainability and testability:

```text
lib/
├── common/        # Shared constants, styles, and themes
├── data/          # Local and remote data sources
├── model/         # Data models and DTOs
├── providers/     # Business logic and state management
├── screens/       # UI Pages (Main, Detail, Search, Favorites, Settings)
├── services/      # External API and System services
├── utils/         # Helper classes and extensions
└── widgets/       # Reusable UI components
```

---

## 🧪 Testing Excellence

Quality is a priority. The codebase includes a comprehensive test suite:

- **Unit Tests**: Validating `ApiService` and various `Provider` logic.
- **Widget Tests**: Ensuring UI components and error states (like `SearchScreen`) behave correctly.
- **Integration Tests**: End-to-end testing of critical user journeys.

To run the tests:
```bash
flutter test
```

---

## 📦 Installation & Setup

1. **Clone the repository**
   ```bash
   git clone https://github.com/arifaizin/restaurante.git
   ```

2. **Install dependencies**
   ```bash
   flutter pub get
   ```

3. **Run the application**
   ```bash
   flutter run
   ```

---

## 📝 License

This project is licensed under the MIT License - see the [LICENSE](LICENSE) file for details.

---

## 👨‍💻 Author

Developed with ❤️ by **Arif Aizin**.
Connect with me on [LinkedIn](https://linkedin.com/in/arifaizin) or check out my [Portfolio](https://github.com/arifaizin).
