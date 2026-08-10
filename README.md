# 🌟 Lumina — Article Publishing & Discovery Platform

[![Flutter](https://img.shields.io/badge/Flutter-3.10%2B-02569B?style=for-the-badge&logo=flutter&logoColor=white)](https://flutter.dev)
[![Dart](https://img.shields.io/badge/Dart-3.10%2B-0175C2?style=for-the-badge&logo=dart&logoColor=white)](https://dart.dev)
[![Architecture](https://img.shields.io/badge/Architecture-Clean%20Architecture-4CAF50?style=for-the-badge)](https://flutter.dev)
[![State Management](https://img.shields.io/badge/State%20Management-BLoC%20%2F%20Cubit-ff69b4?style=for-the-badge)](https://bloclibrary.dev)
[![Platform](https://img.shields.io/badge/Platform-iOS%20%7C%20Android%20%7C%20Web%20%7C%20macOS%20%7C%20Windows-blue?style=for-the-badge)](#-platform-support)

> **"Share what you know."** — Lumina is a modern, cross-platform mobile and web application built with **Flutter**, utilizing **feature-first Clean Architecture**, **BLoC/Cubit state management**, and adaptive responsive design.

---

## 📋 Table of Contents

- [Overview](#-overview)
- [Key Features](#-key-features)
- [Architecture & Design System](#-architecture--design-system)
- [Project Structure](#-project-structure)
- [Tech Stack & Dependencies](#-tech-stack--dependencies)
- [API Endpoints & Integration](#-api-endpoints--integration)
- [Getting Started](#-getting-started)
  - [Prerequisites](#prerequisites)
  - [Installation & Setup](#installation--setup)
  - [Running the App](#running-the-app)
- [Build & Deployment](#-build--deployment)
- [Testing & Quality Assurance](#-testing--quality-assurance)
- [Contributing & License](#-contributing--license)

---

## 🚀 Overview

**Lumina** provides a seamless, content-centric platform for reading, creating, and discovering articles across topics. Designed with performance, accessibility, and elegance in mind, Lumina scales gracefully from mobile screens to desktop browsers.

The app connects to a REST backend service powered by direct presigned S3 media uploads, robust token authentication with session restoration, real-time search, category filters, and rich-text editing.

---

## ✨ Key Features

### 🔐 Authentication & Session Management
- **Secure Token Storage**: Persists JWT access and refresh tokens securely via `flutter_secure_storage`.
- **Auto-Login & Session Restoration**: `AuthBloc` automatically restores user sessions on startup (`AuthStarted`).
- **Complete Auth Flow**: Onboarding, Login, Signup, OTP Email Verification, Forgot Password, and Reset Password.
- **Route Protection**: Automated navigation guards powered by `GoRouter` (`RouteGuards.authRedirect`).
- **Token Refresh Interceptor**: Handles `401 Unauthorized` responses gracefully using custom `DioAuthInterceptor`.

### 📰 Dynamic Article Feed & Discovery
- **Personalized Feed**: Infinite scrolling feed supported by `FeedBloc` and paginated REST calls.
- **Instant Search**: Debounced search query dispatching `FeedSearchChanged`.
- **Category Navigation**: Filter articles by dynamic categories and trending topics (`FeedCategoryChanged`).
- **Interactive Cards**: Like, block, save, share, and view depth tracking.

### ✍️ Rich Text Publishing & Workspace
- **WYSIWYG Editor**: Built with `flutter_quill`, enabling rich formatting, headers, lists, blockquotes, and HTML delta conversions.
- **Direct S3 Uploads**: Multipart image selection with `image_picker` integrated with presigned S3 URL upload flows (`POST /uploads/presigned-url` -> Direct `PUT`).
- **Personal Articles Hub**: Manage published posts and drafts from the "My Articles" screen.

### 🎨 Adaptive Design & Responsive UI
- **Multi-Platform UI**: Adapts automatically across screen breakpoints defined in `AppSizes`:
  - **Mobile (< 700px)**: Bottom navigation bar, stacked article cards, touch-optimized UI.
  - **Tablet (700px – 1023px)**: Constrained content layout, refined typography.
  - **Desktop / Web (≥ 1024px)**: Extended navigation rail/sidebar, horizontal wide cards, hover ink effects.
- **Dark & Light Mode**: Persistent theme switching managed by `ThemeCubit`, with customized high-contrast palettes (deep navy/off-black for dark mode, crisp whites/grays for light mode).
- **Smooth Feedback**: Skeleton loaders, shimmer effects, animated transitions, empty state graphics, and inline error retry triggers.

---

## 🏗 Architecture & Design System

Lumina strictly adheres to **Feature-First Clean Architecture**, ensuring modularity, testability, and clear separation of concerns.

```text
┌─────────────────────────────────────────────────────────────┐
│                    PRESENTATION LAYER                       │
│     Pages (UI) │ Reusable Widgets │ BLoC / Cubit (State)    │
└──────────────────────────────┬──────────────────────────────┘
                               │ (Calls Use Cases & Repositories)
┌──────────────────────────────▼──────────────────────────────┐
│                       DOMAIN LAYER                          │
│     Entities │ Repository Contracts (Interfaces) │ Use Cases│
└──────────────────────────────┬──────────────────────────────┘
                               │ (Implemented by Data Layer)
┌──────────────────────────────▼──────────────────────────────┐
│                        DATA LAYER                           │
│   DTO Models │ REST Data Sources (Dio) │ Repository Impl    │
└─────────────────────────────────────────────────────────────┘
```

### Key Modules:
- **`core/`**: Infrastructure, global constants, Dio HTTP client, secure storage, route definitions, theme tokens, and primitive UI components.
- **`features/`**: Self-contained business domains (`article`, `auth`, `categories`, `dashboard`, `notifications`, `preferences`, `profile`, `reactions`, `settings`, `uploads`).
- **`shared/`**: Common models, layout shells, enums, and cross-feature UI widgets.
- **`injection_container.dart`**: Dependency injection container configured with `get_it`.

---

## 📂 Project Structure

```text
lumina/
├── lumina_frontend/              # Primary Flutter Application Root
│   ├── android/                  # Android native project configuration
│   ├── ios/                      # iOS native project configuration
│   ├── web/                      # Web platform entry points
│   ├── macos/                    # macOS desktop support
│   ├── windows/                  # Windows desktop support
│   ├── linux/                    # Linux desktop support
│   ├── assets/                   # Static images, logos, and fonts
│   ├── docs/                     # Architecture blueprints & technical design
│   │   └── article_feed_architecture_blueprint.md
│   ├── lib/
│   │   ├── main.dart             # App entry point, global BLoC initialization & router
│   │   ├── injection_container.dart # Service locator (GetIt) registration root
│   │   ├── core/                 # Shared foundation & infrastructure
│   │   │   ├── auth/             # Session management & token controller
│   │   │   ├── constants/        # API routes, strings, sizes, palette definitions
│   │   │   ├── errors/           # Custom Exception & Failure definitions
│   │   │   ├── network/          # Dio HTTP Client, ApiResult, interceptors
│   │   │   ├── routes/           # GoRouter definitions, route guards, refresh streams
│   │   │   ├── storage/          # SecureStorage service wrappers
│   │   │   ├── theme/            # Material 3 ThemeData (Light & Dark)
│   │   │   └── widgets/          # Reusable UI primitives (Buttons, Inputs, Cards, Loaders)
│   │   ├── features/             # Business Features (Clean Architecture)
│   │   │   ├── article/          # Article details, rich-text editor, my-articles
│   │   │   ├── auth/             # Login, signup, OTP, password recovery, BLoC
│   │   │   ├── categories/       # Category topics & selection chips
│   │   │   ├── dashboard/        # Main feed, responsive shell, FeedBloc
│   │   │   ├── notifications/    # User notification state & pages
│   │   │   ├── preferences/      # User category interests & onboarding prefs
│   │   │   ├── profile/          # User profile editing & user metrics
│   │   │   ├── reactions/        # Article likes, blocks, bookmarks
│   │   │   ├── settings/         # App settings, ThemeCubit, security options
│   │   │   └── uploads/          # Image picker & presigned URL S3 uploaders
│   │   └── shared/               # Cross-feature widgets, models, & navigation shell
│   ├── pubspec.yaml              # Package dependencies & asset configuration
│   └── analysis_options.yaml     # Dart static analyzer lints
└── README.md                     # Project documentation (this file)
```

---

## 🛠 Tech Stack & Dependencies

| Category | Technology / Package | Purpose |
| :--- | :--- | :--- |
| **Framework** | [Flutter](https://flutter.dev) (SDK ^3.10.4) | Cross-platform UI framework |
| **Language** | [Dart](https://dart.dev) | Strongly-typed object-oriented language |
| **Architecture** | Feature-First Clean Architecture | Scalable, maintainable code structure |
| **State Management** | [`flutter_bloc`](https://pub.dev/packages/flutter_bloc) | Predictable state management with BLoCs & Cubits |
| **Dependency Injection** | [`get_it`](https://pub.dev/packages/get_it) | Fast service locator for dependency resolution |
| **Routing** | [`go_router`](https://pub.dev/packages/go_router) | Declarative routing with guard middleware |
| **Networking** | [`dio`](https://pub.dev/packages/dio) | Feature-rich HTTP client with token refresh interceptors |
| **Secure Storage** | [`flutter_secure_storage`](https://pub.dev/packages/flutter_secure_storage) | Keychain / Keystore encrypted token persistence |
| **Rich Text Editor** | [`flutter_quill`](https://pub.dev/packages/flutter_quill) | WYSIWYG rich text editor for article publishing |
| **HTML Parsing** | [`flutter_widget_from_html_core`](https://pub.dev/packages/flutter_widget_from_html_core) | Render HTML strings inside native widgets |
| **Validation** | [`form_validator`](https://pub.dev/packages/form_validator) | Declarative form field validation |
| **Image Handling** | [`cached_network_image`](https://pub.dev/packages/cached_network_image), [`image_picker`](https://pub.dev/packages/image_picker) | Image caching and local gallery/camera selection |

---

## 🌐 API Endpoints & Integration

Lumina interfaces with a REST API backend (default host: `https://lumina-058e.onrender.com`). Key routes include:

| Domain | Method | Endpoint | Description |
| :--- | :--- | :--- | :--- |
| **Auth** | `POST` | `/auth/login` | Authenticate user & issue tokens |
| | `POST` | `/auth/signup` | Register new user profile |
| | `POST` | `/auth/signup/verify-otp` | Verify registration email OTP |
| | `POST` | `/auth/refresh-token` | Obtain new access token via refresh token |
| | `POST` | `/auth/forgot-password` | Request password reset OTP |
| **User** | `GET/PUT`| `/users/profile` | Retrieve or update user profile details |
| | `POST` | `/users/change-password` | Update current user password |
| **Articles** | `GET` | `/articles` | Retrieve paginated article feed (with category/search filters) |
| | `GET` | `/articles/:id` | Fetch detailed article content |
| | `POST` | `/articles` | Create a new article post |
| | `PUT` | `/articles/:id` | Edit an existing article |
| | `DELETE`| `/articles/:id` | Delete article |
| | `GET` | `/articles/me` | Fetch articles authored by logged-in user |
| **Uploads** | `POST` | `/uploads/presigned-url` | Generate S3 upload URL for cover images |
| **Reactions**| `POST` | `/reactions/articles/react` | Like, save, or react to an article |

---

## 💻 Getting Started

### Prerequisites

Ensure you have the following installed on your developer machine:
- **Flutter SDK**: `>= 3.10.4` ([Installation Guide](https://docs.flutter.dev/get-started/install))
- **Dart SDK**: Compatible with Flutter SDK
- **Git**: For version control
- Target development environment:
  - **Android Studio** & Android SDK (for Android build)
  - **Xcode** 14+ & CocoaPods (for iOS/macOS build)
  - **Google Chrome** (for Web build)

### Installation & Setup

1. **Clone the repository**:
   ```bash
   git clone https://github.com/YourUsername/lumina.git
   cd lumina/lumina_frontend
   ```

2. **Install Flutter packages**:
   ```bash
   flutter pub get
   ```

3. **Verify Flutter environment**:
   ```bash
   flutter doctor
   ```

### Running the App

You can run Lumina on your target platform using standard Flutter commands.

- **Run on Chrome (Web)**:
  ```bash
  flutter run -d chrome
  ```

- **Run on macOS Desktop**:
  ```bash
  flutter run -d macos
  ```

- **Run on Connected Mobile Device / Emulator**:
  ```bash
  flutter run
  ```

- **Run with Custom API Base URL**:
  ```bash
  flutter run --dart-define=API_BASE_URL=https://your-custom-backend.com
  ```

---

## 📦 Build & Deployment

To compile production bundles for release:

- **Web Build**:
  ```bash
  flutter build web --release
  ```
  *Output location: `build/web/`*

- **Android APK**:
  ```bash
  flutter build apk --release
  ```
  *Output location: `build/app/outputs/flutter-apk/app-release.apk`*

- **Android App Bundle (AAB)**:
  ```bash
  flutter build appbundle --release
  ```

- **iOS App Store Package**:
  ```bash
  flutter build ipa --release
  ```

- **macOS Desktop Executable**:
  ```bash
  flutter build macos --release
  ```

---

## 🧪 Testing & Quality Assurance

Lumina includes static code analysis rules and unit/widget test suites.

- **Run Static Code Analyzer**:
  ```bash
  flutter analyze
  ```

- **Run Unit & Widget Tests**:
  ```bash
  flutter test
  ```

---

## 🤝 Contributing & License

Contributions are welcome! If you'd like to improve Lumina or add new features:
1. Fork the project repository.
2. Create your feature branch (`git checkout -b feature/AmazingFeature`).
3. Commit your changes (`git commit -m 'Add some AmazingFeature'`).
4. Push to the branch (`git push origin feature/AmazingFeature`).
5. Open a Pull Request.

---

<p align="center">
  Crafted with ❤️ using <strong>Flutter</strong> & <strong>Clean Architecture</strong>.
</p>
