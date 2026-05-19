# Hisaab Kitaab

A Flutter Android-first app for iron/laundry press vendors to manage customer accounts, log pickups, track outstanding balances, send WhatsApp payment reminders, and generate PDF reports. Replaces handwritten paper registers with a real-time digital ledger backed by Supabase.

---

## Table of Contents

- [App Features](#app-features)
- [Roles](#roles)
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
- [Reference](#reference)

---

## App Features

### Authentication & Roles
- **Google Sign-In** via Supabase Auth — no username/password
- **Role-based routing** — Owner, Staff, and Customer each land on a different home screen after sign-in
- **Self-registration** — new customers fill a form (name, phone, flat, society) and await owner link
- **Unknown-role screen** — prompts the user to ask the vendor to register them

### Onboarding Wizard (Owner first-run)
- **6-step guided setup** — Welcome → Business Profile → UPI Setup → Societies → Alert Settings → All Set
- Progress bar and back navigation across form steps
- Live UPI payment link preview as the vendor types their VPA
- Society chips (add/remove, max 5, Enter key support)
- Quick-select overdue threshold (₹100 / ₹200 / ₹300 / ₹500 / ₹1000)
- Summary card on the final step before entering the app

### Home Screen (Owner & Staff)
- Gradient header with business name, role badge, and total outstanding balance
- **Overdue badge** (amber ⚠ N) — taps through to the overdue screen
- **Society chip tabs** — filter the customer list by society (All + one chip per society)
- **Customer search** — filter by name, flat number, or society in real time
- Customer cards show flat · name, society, balance in red/green, and OVERDUE/SETTLED/DUE status badges with amber left border when overdue
- **Add Customer** FAB (owner always; staff only if `add_customers` permission)

### Customer Detail Screen
- Gradient header with customer avatar (initials), flat · name, society, phone; one-tap call and settings icons
- **Balance card** — "YOU WILL GET" (or SETTLED) with total gave / total got breakdown
- **Quick action row** — PDF Report, Send Reminder, CSV Export
- **Transaction table** — You Gave / You Got columns, newest-first, red/green left border per row; long-press for edit or delete
- **Real-time updates** — streams from Supabase so any device update reflects instantly
- Dual FABs: red "YOU GAVE ₹" (bottom-left) + green "YOU GOT ₹" (bottom-right)
- **Customer settings sheet** — edit name, flat, phone, society; remove customer (soft delete `is_active = false`)
- **Reminder sheet** — WhatsApp message preview + send button; SMS button; no-phone warning

### Pickup Entry — "You Gave" (Owner & Staff)
- Large ₹ amount input with red accent border
- Free-text description textarea
- Date picker defaulting to today; amber **Past entry** badge when backdated
- Saves to `entries` via `EntryRepository` with `created_by` stamped

### Payment Recording — "You Got" (Owner & Staff)
- Green gradient header showing customer name and outstanding balance
- Large ₹ amount input with green accent border
- Quick-tap chips — ₹50 / ₹100 / ₹200 / ₹500 / **Full balance** (deduplicated)
- **Cash / Online** mode selector (two clear buttons)
- Optional note field
- Saves to `payments` via `PaymentRepository`

### PDF Report Screen
- Date range filter (From / To pickers, clear button) — filters in memory
- Invoice card preview: gradient business header, customer info + period badge, 3 summary boxes (Total Laundry / Total Paid / Balance Due in red/green), alternating-row transaction table, UPI payment footer when balance > 0
- Export FAB → Share PDF or Share via WhatsApp (both via `share_plus`)

### Overdue Reminders Screen
- Amber/orange gradient header
- 3-box summary: Overdue count, Total Due, Can Remind
- Customers **grouped by society** with a society-level total due
- Per-customer: WhatsApp send button (spinner → checkmark animation), call button, balance progress bar showing how far over threshold
- "Send All" bulk WhatsApp action

### Staff Management (Owner only)
- List of staff cards — purple avatar with initials, name, phone/email, active-permission pills
- **Edit** (pre-filled sheet) and **Remove** (soft delete) per staff member
- **Add Staff** sheet — name, phone, email + 8-permission toggle list:
  `view_customers`, `add_customers`, `add_entries`, `add_payments`, `edit_entries`, `delete_entries`, `send_reminders`, `export_data`

### Customer Home Screen (Customer role — read-only)
- Gradient header with customer's own name, flat, society, and logout button
- Balance summary card — "You Owe" / "You're Settled", laundry total, paid total
- Quick actions: Pay via WhatsApp (UPI deep-link, disabled when balance = 0), Download Report, Request SMS
- Read-only transaction table — "YOU OWE" / "YOU PAID" columns; no add buttons

### Settings Screen
- Gradient header with vendor avatar, business name, UPI ID
- Grouped sections: Business Profile, Reminders (overdue threshold), Manage (Staff, Societies), App (Language, App Lock), Data (Export CSV)
- **Societies management** — add/remove societies from the database
- **App Lock** — 4-digit PIN + biometric (fingerprint) protection; toggle in Settings; lock on app background

---

## Roles

| Role | Home Screen | Can Add Entries/Payments | Can Manage Staff | Can See All Customers |
|------|-------------|--------------------------|------------------|-----------------------|
| Owner | HomeScreen | Yes | Yes | Yes |
| Staff | HomeScreen | Permission-gated | No | Yes (filtered by permissions) |
| Customer | CustomerHomeScreen | No | No | Own data only (RLS) |

Role is resolved via `get_my_role()` Supabase RPC after every sign-in.

---

## Tech Stack

| Layer | Library |
|-------|---------|
| Framework | Flutter 3.x (Android-first) |
| State management | [flutter_riverpod](https://pub.dev/packages/flutter_riverpod) ^2.6 |
| Navigation | [go_router](https://pub.dev/packages/go_router) ^14 |
| Backend | [supabase_flutter](https://pub.dev/packages/supabase_flutter) ^2.8 (PostgreSQL + Realtime) |
| Auth | Supabase Auth + Google OAuth |
| UI | Material 3 · Be Vietnam Pro ([google_fonts](https://pub.dev/packages/google_fonts)) |
| i18n | flutter_localizations (EN + HI) |
| PDF | [pdf](https://pub.dev/packages/pdf) ^3.11 |
| File sharing | [share_plus](https://pub.dev/packages/share_plus) ^10 |
| Biometrics / PIN | [local_auth](https://pub.dev/packages/local_auth) ^2.3 |
| Crash monitoring | [sentry_flutter](https://pub.dev/packages/sentry_flutter) ^8.14 |
| WhatsApp / UPI | url_launcher (deep-links) |
| CSV | [csv](https://pub.dev/packages/csv) ^6 |
| Env vars | [flutter_dotenv](https://pub.dev/packages/flutter_dotenv) ^5 |
| Local storage | [shared_preferences](https://pub.dev/packages/shared_preferences) ^2 (PIN + locale only) |

---

## Project Structure

```
lib/
├── main.dart                   # flutter_dotenv load + Supabase.initialize + runApp
├── app.dart                    # HisaabKitaabApp — locale, lock, auth redirect
│
├── core/
│   ├── auth/                   # HKAuthState sealed class, AuthNotifier, authProvider
│   ├── models/                 # customer.dart, transaction_item.dart, society.dart
│   ├── repositories/           # customer, entry, payment, config, society, staff, transaction
│   ├── providers/              # settingsProvider (re-export), localeProvider
│   ├── router/                 # app_router.dart — go_router + auth guard redirect
│   ├── supabase/               # supabase_client.dart, supabase_tables.dart
│   ├── theme/                  # app_theme.dart, app_colors.dart
│   └── utils/                  # whatsapp_helper, upi_helper, pdf_invoice_helper, csv_exporter
│
├── features/
│   ├── auth/                   # LoginScreen (Google OAuth), RegistrationScreen
│   ├── home/                   # HomeScreen, CustomerCard, society chip tabs, search
│   ├── customer_detail/        # CustomerDetailScreen, TransactionTable, PDF report screen
│   ├── customer_home/          # CustomerHomeScreen (read-only, customer role)
│   ├── add_entry/              # AddItemsSheet modal (pickup entry)
│   ├── payment/                # RecordPaymentScreen
│   ├── reminders/              # OverdueRemindersScreen (society-grouped)
│   ├── settings/               # SettingsScreen (societies, config, app lock, staff link)
│   ├── staff/                  # StaffSettingsScreen, AddEditStaffSheet
│   ├── app_lock/               # PinLockScreen, PinSetupSheet, AppLockNotifier
│   └── onboarding/             # 6-step OnboardingScreen wizard
│
└── shared/
    └── widgets/
        ├── hk_gradient_header.dart   # standard blue gradient header for every screen
        ├── hk_avatar.dart            # circular avatar with initials
        ├── hk_chip.dart              # pill filter chip (active/inactive states)
        ├── hk_bottom_sheet.dart      # modal sheet with drag handle
        ├── hk_fab.dart               # extended FAB (primary / gave / got variants)
        └── balance_card.dart         # "You Will Get" summary card
```

---

## Prerequisites

- Flutter SDK `>=3.11.4` — [install guide](https://docs.flutter.dev/get-started/install)
- Dart SDK `>=3.11.4` (bundled with Flutter)
- Android SDK with API level 21+ target device or emulator
- Java 17 (for Gradle)
- [Supabase CLI](https://supabase.com/docs/guides/cli) — `brew install supabase/tap/supabase`

Verify your Flutter setup:
```bash
flutter doctor
```

---

## Setup

**1. Install dependencies**
```bash
flutter pub get
```

**2. Create your `.env` file** (gitignored — never commit this)
```
SUPABASE_URL=https://your-project.supabase.co
SUPABASE_ANON_KEY=your-anon-key
```

**3. Apply the Supabase schema**
```bash
supabase db push       # push migrations to your remote project
```

Or for local dev:
```bash
supabase start         # start local Supabase stack (Docker required)
supabase db reset      # wipe + re-apply migrations + seed data
```

**4. Set up Google OAuth**

1. [Google Cloud Console](https://console.cloud.google.com) → create a project → enable **Google Identity API**
2. Create OAuth credentials → **Web application** type
3. Authorised redirect URI: `https://<your-project>.supabase.co/auth/v1/callback`
4. Copy Client ID + Secret → Supabase dashboard → Auth → Providers → Google

**5. (Optional) Configure Sentry crash monitoring**

Create a project at [sentry.io](https://sentry.io) and note your DSN — see [Building for Release](#building-for-release).

---

## Running the App

```bash
# Run on connected device or running emulator
flutter run

# Launch a specific emulator then run
flutter emulators --launch Medium_Phone && flutter run
flutter emulators --launch Pixel_7 && flutter run

# List available emulators
flutter emulators

# Run with Sentry crash reporting enabled
flutter run --dart-define=SENTRY_DSN=https://your-key@sentry.io/your-project-id
```

---

## Building for Release

```bash
# Debug APK
flutter build apk --debug

# Release APK (requires signing config in android/app/build.gradle)
flutter build apk --release

# Release APK with Sentry crash monitoring
flutter build apk --release --dart-define=SENTRY_DSN=https://your-key@sentry.io/your-project-id

# App Bundle (for Play Store)
flutter build appbundle --release --dart-define=SENTRY_DSN=https://your-key@sentry.io/your-project-id
```

> **Note:** If `SENTRY_DSN` is not provided, Sentry runs in no-op mode — no crash reports are sent and the app works normally.

---

## Development Guide

### Static analysis

```bash
flutter analyze          # must report 0 issues before committing
```

### Tests

```bash
flutter test                         # run all tests
flutter test test/path/to/test.dart  # single file
```

### Supabase local dev

```bash
supabase start           # start local Supabase stack
supabase status          # get local URLs + anon key
supabase db reset        # wipe + re-apply migrations + seed
supabase db push         # push migrations to remote project
supabase migration new <name>   # create a new migration file
```

### Adding a new feature

Follow the existing feature-first pattern:
```
lib/features/<feature_name>/
├── presentation/
│   ├── <feature>_screen.dart
│   └── widgets/
└── providers/
    └── <feature>_providers.dart
```

Register new routes in `lib/core/router/app_router.dart`.

### Modal bottom sheets

Always pass `useRootNavigator: true` to `showModalBottomSheet`. The root scaffold uses `extendBody: true`; without this flag the sheet renders behind the nav bar.

```dart
showModalBottomSheet(
  context: context,
  useRootNavigator: true,  // required
  ...
)
```

---

## Database Schema

All data lives in Supabase (PostgreSQL). Schema is in `supabase/migrations/`. Row-Level Security (RLS) is enabled on every table.

| Table | Purpose |
|-------|---------|
| `app_config` | Single-row vendor profile — business name, UPI ID, alert threshold, owner UID, onboarding flag |
| `societies` | Residential societies served by the vendor |
| `staff` | Staff members; `user_id` null until first sign-in (linked via `get_my_role()`) |
| `customers` | Customers; same `user_id` link pattern as staff; `is_active` flag for soft delete |
| `entries` | Pickup records ("You Gave"); `entry_date` is DATE for backdated support |
| `payments` | Payment records ("You Got"); `mode` ∈ {cash, online} |

**Key design notes:**
- All monetary amounts are `int` (whole rupees — no decimals)
- IDs are UUID strings throughout
- `entry_date` / `payment_date` are `date` type — the vendor records the day of pickup, not exact time
- `created_by` on entries/payments stores `auth.uid()` of the staff/owner who made the record

---

## Key Architecture Decisions

**Supabase real-time throughout** — all repository methods use Supabase `.stream()` returning `Stream` so UI rebuilds automatically on any database change across any device, without manual refresh.

**No Riverpod code generation** — all providers are written manually as `StreamProvider`, `AsyncNotifierProvider`, etc. No `build_runner` dependency for state management.

**Role resolved server-side** — `get_my_role()` is a Postgres RPC that returns `owner | staff | customer | unknown`. The app never trusts client-side role claims.

**Hierarchical navigation, no bottom nav shell** — go_router uses a back stack. No `StatefulShellRoute`. Auth redirect in `GoRouter.redirect`, refreshed via `_AuthNotifierListenable` that listens to both auth state and onboarding state.

**App lock stored locally** — PIN hash and locale preference live in `shared_preferences` (device-local). All business data lives in Supabase.

**Modal sheets vs routes** — entry and payment are modal bottom sheets invokable from multiple entry points; PDF report and staff management are full routes.

**Lock on `paused`, not `inactive`** — `AppLockNotifier.lockApp()` fires on `AppLifecycleState.paused` (app goes to background) rather than `inactive`, preventing false locks from camera or notification drawer.

---

## External Service Setup

### Supabase (required)

1. Create a project at [supabase.com](https://supabase.com)
2. Copy **Project URL** and **anon key** → add to `.env`
3. Run `supabase db push` to apply migrations
4. Configure Google OAuth (see Setup step 4)
5. Update `supabase/seed.sql` line 16: replace the placeholder email with the real owner's email

### Sentry Crash Monitoring (optional)

1. Create a project at [sentry.io](https://sentry.io) → Platform: Flutter
2. Copy your DSN (format: `https://<key>@<org>.ingest.sentry.io/<project-id>`)
3. Pass at build time: `--dart-define=SENTRY_DSN=<your-dsn>`
4. Without the define, Sentry is disabled — safe for local dev

---

## Reference

- **Full dev history & architecture decisions:** `DEVLOG.md`
- **Implementation roadmap:** `TODO.md`
- **Design tokens:** `lib/core/theme/app_colors.dart`
- **Supabase schema:** `supabase/migrations/`
- **Seed data:** `supabase/seed.sql`
