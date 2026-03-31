# Hisaab Kitaab

A Flutter Android app for iron/laundry press vendors to manage customer accounts, log items, track outstanding balances, and send WhatsApp payment reminders. Replaces handwritten paper registers with a fast, offline-first digital ledger.

---

## Table of Contents

- [Features](#features)
- [Tech Stack](#tech-stack)
- [Project Structure](#project-structure)
- [Prerequisites](#prerequisites)
- [Setup](#setup)
- [Running the App](#running-the-app)
- [Building for Release](#building-for-release)
- [Development Guide](#development-guide)
- [Database Schema](#database-schema)
- [Key Architecture Decisions](#key-architecture-decisions)
- [External Service Setup](#external-service-setup)

---

## Features

- **Customer ledger** — add customers with flat number, phone, society; track individual balances
- **Item entry** — log shirts, pants, sarees, etc. with configurable per-item rates; supports custom items
- **Payments** — record cash/UPI/other payments; auto-updates balance
- **WhatsApp reminders** — deep-link to WhatsApp with a templated message + UPI payment link
- **PDF invoices** — generate per-customer invoice and full monthly summary; share via system share sheet
- **Google Drive backup** — manual and auto daily backup of the encrypted SQLite database
- **CSV export** — export all customers or per-customer transaction history
- **App lock** — optional 4-digit PIN + biometric (fingerprint) protection
- **Onboarding** — 3-screen carousel shown once on first launch
- **Language toggle** — English / Hindi (locale persisted in settings)
- **Crash monitoring** — Sentry integration (DSN injected at build time)

---

## Tech Stack

| Layer | Library |
|-------|---------|
| Framework | Flutter 3.x (Android-first) |
| State management | [flutter_riverpod](https://pub.dev/packages/flutter_riverpod) ^2.6 |
| Navigation | [go_router](https://pub.dev/packages/go_router) ^14 |
| Database | [Drift](https://drift.simonbinder.eu) ^2.22 (SQLite ORM) |
| Encryption | [sqlcipher_flutter_libs](https://pub.dev/packages/sqlcipher_flutter_libs) ^0.5 |
| UI | Material 3 · Be Vietnam Pro ([google_fonts](https://pub.dev/packages/google_fonts)) |
| i18n | flutter_localizations (EN + HI) |
| PDF | [pdf](https://pub.dev/packages/pdf) ^3.11 |
| File sharing | [share_plus](https://pub.dev/packages/share_plus) ^10 |
| Cloud backup | google_sign_in · googleapis (Drive `appDataFolder`) |
| Background tasks | [workmanager](https://pub.dev/packages/workmanager) ^0.5 |
| Biometrics / PIN | [local_auth](https://pub.dev/packages/local_auth) ^2.3 |
| Crash monitoring | [sentry_flutter](https://pub.dev/packages/sentry_flutter) ^8.14 |
| WhatsApp / UPI | url_launcher (deep-links) |
| CSV | [csv](https://pub.dev/packages/csv) ^6 |

---

## Project Structure

```
lib/
├── main.dart                        # Entry point — Sentry init, WorkManager init, runApp
├── app.dart                         # Root widget — locale, onboarding overlay, PIN lock overlay
│
├── core/
│   ├── database/
│   │   ├── app_database.dart        # Drift DB class + all DAO methods
│   │   ├── app_database.g.dart      # Generated — do not edit
│   │   ├── tables/                  # One file per Drift table
│   │   └── models/                  # CustomerWithBalance, TransactionItem
│   ├── providers/
│   │   ├── database_provider.dart   # Singleton AppDatabase provider
│   │   ├── settings_provider.dart   # Reactive settings map + alertThresholdProvider
│   │   └── locale_provider.dart     # LocaleNotifier — persists language to DB
│   ├── router/
│   │   └── app_router.dart          # go_router config with StatefulShellRoute
│   ├── theme/
│   │   ├── app_theme.dart           # Material 3 ThemeData
│   │   └── app_colors.dart          # Color constants from Stitch mockups
│   └── utils/
│       ├── whatsapp_helper.dart     # WhatsApp deep-link builder
│       ├── upi_helper.dart          # UPI payment link builder
│       ├── pdf_invoice_helper.dart  # Customer invoice + monthly summary PDF
│       ├── drive_backup_helper.dart # Google Drive backup/restore singleton
│       ├── csv_exporter.dart        # CSV export via share_plus
│       └── backup_scheduler.dart    # WorkManager periodic backup task
│
├── features/
│   ├── home/                        # HomeScreen + CustomerCard + filter tabs
│   ├── customer_detail/             # CustomerDetailScreen + TransactionTimeline
│   ├── add_entry/                   # AddEntryScreen (customer picker) + AddItemsSheet (modal)
│   ├── payment/                     # RecordPaymentScreen
│   ├── reminders/                   # OverdueRemindersScreen
│   ├── settings/                    # SettingsScreen + BackupNotifier
│   ├── app_lock/                    # PinLockScreen + PinSetupSheet + AppLockNotifier
│   └── onboarding/                  # OnboardingScreen (3-screen carousel)
│
└── shared/
    └── widgets/
        └── bottom_nav_shell.dart    # Glassmorphism bottom navigation shell
```

---

## Prerequisites

- Flutter SDK `>=3.11.4` — [install guide](https://docs.flutter.dev/get-started/install)
- Dart SDK `>=3.11.4` (bundled with Flutter)
- Android SDK with API level 21+ target device or emulator
- Java 17 (for Gradle)

Verify your setup:
```bash
flutter doctor
```

---

## Setup

**1. Install dependencies**
```bash
flutter pub get
```

**2. Run code generation** (only needed if you modify Drift tables or add `@riverpod` annotations)
```bash
flutter pub run build_runner build --delete-conflicting-outputs
```

**3. (Optional) Configure Google Drive backup**

Create a Google Cloud Console project, enable the Drive API, and add an OAuth 2.0 Android client ID. Place your `google-services.json` in `android/app/`. See [External Service Setup](#external-service-setup) for details.

**4. (Optional) Configure Sentry crash monitoring**

Create a project at [sentry.io](https://sentry.io) and note your DSN. Pass it at build time — see [Building for Release](#building-for-release).

---

## Running the App

```bash
# Run on connected device or running emulator
flutter run

# Launch a specific emulator then run
flutter emulators --launch Medium_Phone && flutter run

# Run with Sentry DSN (crash reports enabled)
flutter run --dart-define=SENTRY_DSN=https://your-key@sentry.io/your-project-id

# List available emulators
flutter emulators
```

---

## Building for Release

```bash
# Debug APK
flutter build apk --debug

# Release APK (requires signing config in android/app/build.gradle)
flutter build apk --release

# Release APK with Sentry crash monitoring enabled
flutter build apk --release --dart-define=SENTRY_DSN=https://your-key@sentry.io/your-project-id

# App Bundle (for Play Store)
flutter build appbundle --release --dart-define=SENTRY_DSN=https://your-key@sentry.io/your-project-id
```

> **Note:** If `SENTRY_DSN` is not provided, Sentry runs in no-op mode — no crash reports are sent and the app works normally.

---

## Development Guide

### Code generation

Drift (database ORM) and Riverpod (state management) use code generation. Re-run after:
- Adding or modifying a Drift table in `lib/core/database/tables/`
- Adding `@riverpod` annotations to a provider

```bash
# One-time build
flutter pub run build_runner build --delete-conflicting-outputs

# Watch mode (auto-rebuilds on save)
flutter pub run build_runner watch --delete-conflicting-outputs
```

### Static analysis

```bash
flutter analyze          # must report 0 issues before committing
```

### Tests

```bash
flutter test                                  # run all tests
flutter test test/path/to/test.dart           # single file
```

### Adding a new setting key

1. Add a seed row in `AppDatabase._seedDefaultData()` in `lib/core/database/app_database.dart`
2. Read with `db.getSetting('key')` / `db.setSetting('key', value)`
3. React to changes via `db.watchSettings()`

### Adding a new feature

Follow the existing pattern:
```
lib/features/<feature_name>/
├── presentation/
│   └── <feature>_screen.dart
└── providers/
    └── <feature>_providers.dart
```

Register any new top-level routes in `lib/core/router/app_router.dart`.

### Modal bottom sheets

Always pass `useRootNavigator: true` to `showModalBottomSheet`. The root scaffold uses `extendBody: true` for the glassmorphism nav; without `useRootNavigator: true` the sheet renders behind the nav bar.

```dart
showModalBottomSheet(
  context: context,
  useRootNavigator: true,  // required
  ...
)
```

---

## Database Schema

The encrypted SQLite database lives at `<app_documents>/hisaab_kitaab.db` (SQLCipher, key: set in `app_database.dart`).

| Table | Purpose |
|-------|---------|
| `societies` | Residential societies (name, address) |
| `customers` | Customers (name, flat, phone, society FK) |
| `item_types` | Configurable item catalog (Shirt, Pant, Saree…) with rates |
| `entries` | Item-logging transactions (one per visit, with total amount) |
| `entry_items` | Line items within an entry (item type FK, quantity, rate, amount) |
| `payments` | Payment records (amount, mode: cash/upi/other, date, notes) |
| `app_settings` | Key-value store for all app configuration |

**`app_settings` keys**

| Key | Default | Description |
|-----|---------|-------------|
| `business_name` | `My Press Shop` | Vendor's business name |
| `upi_id` | `` | UPI ID for payment links |
| `alert_threshold` | `200` | Min balance (₹) to show in overdue list |
| `whatsapp_template` | (see code) | WhatsApp reminder message template |
| `language` | `en` | App language (`en` or `hi`) |
| `app_lock_enabled` | `false` | Whether PIN lock is active |
| `app_pin` | `` | Hashed 4-digit PIN (set when lock is enabled) |
| `onboarding_done` | `false` | Whether onboarding carousel has been shown |
| `auto_backup_enabled` | `false` | Whether daily Drive backup is scheduled |

---

## Key Architecture Decisions

**No Riverpod code generation for providers** — all providers are written manually as `StreamProvider`, `StateNotifierProvider`, etc. This avoids a `build_runner` dependency for state management (Drift already requires it for DB).

**Sealed class for transactions** — `TransactionItem` is a sealed class with `EntryTransaction` and `PaymentTransaction` subtypes, enabling exhaustive pattern matching in the transaction timeline.

**Modal sheets vs routes** — `AddItemsSheet` and `AddCustomerSheet` are modal bottom sheets rather than routes. This matches the Stitch overlay design and allows them to be invoked from multiple entry points without router coupling.

**Reactive streams throughout** — all DAO methods return `Stream` (not `Future`) so UI rebuilds automatically on any DB change, without manual refresh calls.

**Lock on `paused`, not `inactive`** — `AppLockNotifier.lockApp()` is called on `AppLifecycleState.paused` (app goes to background) rather than `inactive` (covers camera/notification drawer), preventing false locks.

---

## External Service Setup

### Google Drive Backup

1. Go to [Google Cloud Console](https://console.cloud.google.com)
2. Create a project → enable **Google Drive API**
3. Create OAuth 2.0 credentials → **Android** client → enter your app's package name (`com.hisaabkitaab.hisaab_kitaab`) and SHA-1 fingerprint
4. Download `google-services.json` → place at `android/app/google-services.json`
5. The app uses Drive's `appDataFolder` (hidden, app-private) — no Drive storage permission needed

### Sentry Crash Monitoring

1. Create a project at [sentry.io](https://sentry.io) → Platform: Flutter
2. Copy your DSN (format: `https://<key>@<org>.ingest.sentry.io/<project-id>`)
3. Pass at build time: `--dart-define=SENTRY_DSN=<your-dsn>`
4. Without the define, Sentry is disabled — safe for local dev

---

## Reference

- **Full dev history & architecture notes:** `DEVLOG.md`
- **Product requirements:** `hisaab-kitaab.prd.md`
- **UI mockups:** `stitch/images/*.png` (screenshots) · `stitch/code/*.html` (Stitch exports)
