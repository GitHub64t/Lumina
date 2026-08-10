# 🌟 Lumina Frontend

[![Flutter](https://img.shields.io/badge/Flutter-3.10%2B-02569B?style=for-the-badge&logo=flutter&logoColor=white)](https://flutter.dev)
[![Dart](https://img.shields.io/badge/Dart-3.10%2B-0175C2?style=for-the-badge&logo=dart&logoColor=white)](https://dart.dev)
[![Architecture](https://img.shields.io/badge/Architecture-Clean%20Architecture-4CAF50?style=for-the-badge)](https://flutter.dev)
[![State Management](https://img.shields.io/badge/State%20Management-BLoC%20%2F%20Cubit-ff69b4?style=for-the-badge)](https://bloclibrary.dev)

Frontend codebase for **Lumina**, a modern, cross-platform article publishing and discovery application built with **Flutter**, **Clean Architecture**, and **BLoC/Cubit state management**.

For complete project documentation, architectural blueprints, and full setup guides, please refer to the main [Root README](../README.md).

---

## ⚡ Quick Start

```bash
# Get dependencies
flutter pub get

# Run on Web (Chrome)
flutter run -d chrome

# Run on macOS
flutter run -d macos

# Run unit and widget tests
flutter test
```

---

## 🏛 Architecture Snapshot

This frontend app follows a **Feature-First Clean Architecture**:

- **`lib/core/`**: Central constants, Dio network client, error handling, router setup (`GoRouter`), secure storage, and themes.
- **`lib/features/`**: Modular domain features (`article`, `auth`, `categories`, `dashboard`, `notifications`, `preferences`, `profile`, `reactions`, `settings`, `uploads`).
  - `data/`: REST data sources, models/DTOs, and repository implementations.
  - `domain/`: Business entities, repository interfaces, and use cases.
  - `presentation/`: BLoC / Cubit state containers, pages, and feature-specific UI widgets.
- **`lib/shared/`**: Common models, responsive shells (`AppShell`), and layout helpers.
- **`lib/injection_container.dart`**: Service locator root using `get_it`.

For full technical specifications, see [Article Feed Architecture Blueprint](docs/article_feed_architecture_blueprint.md).
