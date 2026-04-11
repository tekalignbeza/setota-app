# Setota Customer App — Copilot Instructions

## Project Overview

Flutter mobile app for **Setota flower & gift delivery marketplace** — the customer-facing app where users browse products, place orders, track deliveries, and send gifts. Backend is a Spring Boot REST API hosted on Azure (`setota-emaagsasfbd6d4ec.uaenorth-01.azurewebsites.net`).

## Build & Run Commands

```bash
# Get dependencies
flutter pub get

# Run code generation (Freezed models, JSON serialization, Riverpod generators)
dart run build_runner build --delete-conflicting-outputs

# Watch mode for code generation during development
dart run build_runner watch --delete-conflicting-outputs

# Run the app
flutter run

# Analyze code
flutter analyze

# Run all tests
flutter test

# Build release APK
flutter build apk --release
```

## Architecture

### Layer Structure (Clean Architecture)

```
lib/
├── core/           # Framework-level: constants, theme, routing, utils
│   ├── constants/  # API endpoints, app-wide constants (ETB currency, minimums)
│   ├── network/    # Dio HTTP client with auth interceptor
│   ├── router/     # GoRouter with ShellRoute (5-tab bottom nav)
│   └── theme/      # Brand colors, text styles, app theme
├── data/           # Data access: Freezed models, API repositories
│   ├── models/     # 9 Freezed models: Product, Order, Cart, Vendor, Address, Review, etc.
│   └── repositories/ # 10 repo classes calling backend REST API
├── domain/         # Business logic (thin — mostly in providers)
├── presentation/   # UI: Riverpod providers, screens, widgets
│   ├── providers/  # 10 provider files: product, cart, order, vendor, etc.
│   ├── screens/    # 24 screen files across auth, home, cart, orders, etc.
│   └── widgets/    # Shared reusable widgets
└── main.dart       # Entry point
```

**Data flows**: `screens` → `providers` → `repositories` → API

### State Management — Riverpod

- All state in `presentation/providers/`
- `AuthNotifier` (StateNotifier) — JWT auth with auto-refresh
- `CartNotifier` — local cart state synced with backend
- `CheckoutNotifier` — multi-step checkout flow
- `AddressNotifier`, `FavoritesNotifier`, `NotificationNotifier` — CRUD state
- Provider dependency: `dioProvider` → repositories → providers → screens

### Navigation — GoRouter with ShellRoute

- `core/router/app_router.dart` — Riverpod-managed router
- **ShellRoute** for 5-tab bottom nav: Home, Search, Cart, Orders, Profile
- Auth redirect: unauthenticated → splash/login, authenticated → home
- Nested routes for product detail, vendor detail, checkout flow, order tracking

### Networking

- **Dio** with auth interceptor (JWT inject, 401 refresh + retry)
- Base URL from `.env` via `flutter_dotenv`
- Timeouts: 30s connect, 30s receive

### Data Models — Freezed + JSON Serializable

All models in `data/models/` use `@freezed` with `@JsonSerializable`. After changes:
```bash
dart run build_runner build --delete-conflicting-outputs
```
Generated files: `*.freezed.dart` and `*.g.dart` — **never edit manually**.

## Key Conventions

### API Response Structure

Backend wraps responses as:
```json
{ "data": { ... }, "message": "...", "status": "..." }
```
Always access `response.data['data']` when parsing.

### API Endpoints

Centralized in `core/constants/app_constants.dart`. Never hardcode URLs.

### Color Palette (Brand)

Defined in `core/theme/app_colors.dart`:
- Primary: Coral Red `#FF6B6B`
- Secondary: Teal `#4ECDC4`
- Accent: Sky Blue `#45B7D1`
- Customer-specific: Gift Pink `#E91E8B`, Star Gold `#FFD700`

### Currency

All prices in **ETB (Ethiopian Birr)**, symbol `Br`. Defined in `AppConstants`:
- `currency = 'ETB'`, `currencySymbol = 'Br'`
- `minimumOrderAmount = 200.0`
- `freeDeliveryThreshold = 1000.0`
- `defaultDeliveryFee = 100.0`

### i18n

- Flutter native l10n with `l10n.yaml` + ARB files (`lib/l10n/`)
- Supported: English (`app_en.arb`), Amharic (`app_am.arb`)
- Access via `AppLocalizations.of(context)!.keyName`

### Environment Config

- `.env` — development (localhost/emulator)
- `.env.production` — production API
- Loaded via `flutter_dotenv`

### Platform Targets

- **Android**: minSDK 26, targetSDK 34, namespace `com.setota.app`
- **iOS**: Bundle ID `com.setota.app`, Team `47Y9DHQW7K`
- iOS signing: Manual with "Setota App" provisioning profile

### Related Repos

| Repo | Purpose |
|------|---------|
| `setota-backend` | Spring Boot REST API |
| `setota-vendor` | Vendor Flutter app |
| `setota-driver` | Driver Flutter app |
| `setota-admin-ui` | Angular admin dashboard |
