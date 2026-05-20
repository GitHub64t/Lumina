# Article Feed — Engineering Agents Guide

## Project Overview

Article Feed is a production-level Flutter Mobile + Web application built using Clean Architecture and Bloc state management.

The frontend communicates with an existing Node.js + Express REST API backend using Dio.

The application supports:

- JWT Authentication
- OTP Verification
- Personalized article feeds
- Article management
- Image uploads using presigned URLs
- Responsive mobile + web layouts
- Scalable modular architecture

This document defines the engineering standards, architecture rules, folder responsibilities, coding practices, and workflow guidelines for all contributors and AI coding agents.

---

# Core Tech Stack

## Frontend
- Flutter
- Dart
- Bloc
- Dio
- go_router
- flutter_secure_storage
- image_picker
- form_validator
- getit

## Backend
- Node.js
- Express.js
- REST APIs
- JWT Authentication

---

# Architecture Standard

The project MUST follow:

- Clean Architecture
- Repository Pattern
- SOLID Principles
- Feature-Based Modular Structure
- Separation of Concerns

---

# Clean Architecture Rules

The application is divided into 3 layers:

## 1. Presentation Layer

Responsible for:
- UI
- Widgets
- Screens
- Bloc state management
- User interactions

Contains:
- pages/
- widgets/
- blocs/

Rules:
- NEVER call APIs directly
- NEVER write business logic in UI
- UI communicates ONLY with Bloc
- Bloc communicates ONLY with UseCases

---

## 2. Domain Layer

Responsible for:
- Business logic
- Application rules
- UseCases
- Entities
- Repository contracts

Contains:
- entities/
- repositories/
- usecases/

Rules:
- PURE Dart layer
- No Flutter imports
- No Dio imports
- No UI logic
- Must remain framework-independent

---

## 3. Data Layer

Responsible for:
- API communication
- DTOs/models
- Repository implementations
- Remote data sources
- Serialization

Contains:
- models/
- datasources/
- repositories/

Rules:
- Handles Dio
- Converts JSON ↔ Models
- Implements repository contracts
- Handles API exceptions

---

# Folder Structure

```txt
lib/
│
├── core/
│   ├── constants/
│   ├── errors/
│   ├── network/
│   ├── services/
│   ├── theme/
│   ├── utils/
│   ├── widgets/
│   └── extensions/
│
├── shared/
│   ├── models/
│   ├── entities/
│   ├── widgets/
│   └── helpers/
│
├── features/
│   ├── auth/
│   ├── dashboard/
│   ├── articles/
│   ├── preferences/
│   ├── settings/
│   └── uploads/
│
├── routes/
├── injection/
└── main.dart
```

---

# Feature Module Structure

```txt
feature_name/
│
├── data/
│   ├── datasources/
│   ├── models/
│   └── repositories/
│
├── domain/
│   ├── entities/
│   ├── repositories/
│   └── usecases/
│
├── presentation/
│   ├── blocs/
│   ├── pages/
│   └── widgets/
```

---

# Bloc Rules

## Bloc Responsibilities
Bloc handles:
- Events
- State transitions
- UseCase execution
- Error mapping

Bloc must NOT:
- Call Dio directly
- Contain UI code
- Store BuildContext

---

# Bloc Flow

```txt
UI
↓
Bloc Event
↓
UseCase
↓
Repository
↓
Datasource
↓
API
↓
Repository
↓
UseCase
↓
Bloc State
↓
UI Rebuild
```

---

# State Management Standards

Each async operation MUST have:

- Initial State
- Loading State
- Success State
- Error State

Pagination MUST include:
- hasReachedMax
- currentPage
- loadingMore

---

# API Layer Standards

## Dio Configuration

Must include:
- Base URL
- Timeout handling
- Authorization interceptor
- Refresh token interceptor
- Request logging
- Error parsing

---

# Authentication Standards

Tokens:
- Access Token
- Refresh Token

Storage:
- flutter_secure_storage ONLY

Rules:
- NEVER store JWT in SharedPreferences
- Auto-refresh expired access tokens
- Logout on refresh failure

---

# Repository Rules

Repositories:
- Abstract contracts in Domain
- Implementations in Data layer

Repositories must:
- Return entities
- Handle failures safely
- Convert models → entities

---

# Performance Rules

Must implement:
- Pagination
- Lazy loading
- Efficient rebuilds
- Cached images
- Debouncing
- Bloc optimization

Avoid:
- Unnecessary rebuilds
- Large widget nesting
- Memory leaks

---

# Testing Standards

Required tests:
- Unit Tests
- Bloc Tests
- Repository Tests
- Widget Tests

Important:
- Mock repositories
- Mock APIs
- Avoid real API calls in tests

---

# Engineering Philosophy

This project prioritizes:
- Scalability
- Maintainability
- Readability
- Performance
- Clean Architecture
- Enterprise standards

Every implementation decision should support long-term product growth.


---

# API Documentation

## Base URL

```txt
https://lumina-058e.onrender.com/api
```

---

# Authentication APIs

## Signup

```http
POST /auth/signup
```

### Request Body

```json
{
  "name": "John Doe",
  "email": "john@example.com",
  "password": "12345678"
}
```

### Purpose
Creates a new user account and sends OTP verification.

---

## Verify Signup OTP

```http
POST /auth/signup/verify-otp
```

### Request Body

```json
{
  "email": "john@example.com",
  "otp": "123456"
}
```

### Purpose
Verifies user OTP and activates account.

---

## Resend Signup OTP

```http
POST /auth/signup/resend-otp
```

### Purpose
Resends account verification OTP.

---

## Login

```http
POST /auth/login
```

### Request Body

```json
{
  "email": "john@example.com",
  "password": "12345678"
}
```

### Response

```json
{
  "accessToken": "jwt_token",
  "refreshToken": "refresh_token"
}
```

### Purpose
Authenticates user and returns JWT tokens.

---

## Refresh Token

```http
POST /auth/refresh-token
```

### Purpose
Generates a new access token using refresh token.

---

## Logout

```http
POST /auth/logout
```

### Purpose
Invalidates current session.

---

# Article APIs

## Create Article

```http
POST /articles
```

### Features
- Create article
- Upload thumbnail URL
- Save content
- Save category

---

## Get Personalized Feed

```http
GET /articles/preferences
```

### Features
- Fetch personalized feed
- Pagination support
- Preference filtering

---

## Get My Articles

```http
GET /articles/me
```

### Features
- Fetch current user's articles
- Analytics support

---

## Get Article Details

```http
GET /articles/{articleId}
```

### Features
- Fetch single article
- Engagement metrics
- Author details

---

## Update Article

```http
PATCH /articles/{articleId}
```

### Features
- Edit title
- Edit content
- Edit image
- Update category

---

## Delete Article

```http
DELETE /articles/{articleId}
```

### Features
- Remove article
- Soft delete support (recommended)

---

# Categories APIs

## Get Categories

```http
GET /categories
```

### Purpose
Fetches available article categories.

---

# Preferences APIs

## Get Preferences

```http
GET /preferences
```

### Purpose
Fetch user selected categories.

---

## Save Preferences

```http
POST /preferences
```

### Purpose
Save/update user category preferences.

---

## Preference Status

```http
GET /preferences/status
```

### Purpose
Checks whether onboarding preferences are completed.

---

# User APIs

## Get Profile

```http
GET /users/profile
```

### Purpose
Fetch current logged-in user profile.

---

## Update Profile

```http
POST /users/profile
```

### Features
- Update username
- Update profile image
- Update bio

---

## Change Password

```http
POST /users/change-password
```

### Purpose
Securely updates user password.

---

# Reaction APIs

## React to Article

```http
POST /reactions/articles/react
```

### Features
- Like article
- Dislike article

---

## Block Article

```http
POST /reactions/articles/block
```

### Purpose
Blocks unwanted articles from feed.

---

# Upload APIs

## Generate Presigned URL

```http
POST /uploads/presigned-url
```

### Purpose
Generates secure upload URL for image upload.

### Upload Flow

```txt
Flutter App
↓
Request Presigned URL
↓
Backend Generates URL
↓
Flutter Uploads Image
↓
Storage Returns Image URL
↓
Save Article
```

---

# API Security Rules

## Required Headers

```http
Authorization: Bearer access_token
Content-Type: application/json
```

---

# API Error Format

Recommended standardized response:

```json
{
  "success": false,
  "message": "Invalid credentials",
  "errorCode": "AUTH_401"
}
```

---

# Recommended HTTP Status Handling

| Status Code | Meaning |
|---|---|
| 200 | Success |
| 201 | Resource Created |
| 400 | Validation Error |
| 401 | Unauthorized |
| 403 | Forbidden |
| 404 | Not Found |
| 500 | Internal Server Error |

---

# Swagger Documentation

Official API Documentation:

https://lumina-058e.onrender.com/api
