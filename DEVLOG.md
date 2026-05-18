# Hisaab Kitaab — Development Log

> Single source of truth for project context, architecture decisions, milestone status, and session history.
> PRD: `hisaab-kitaab.prd.md` | UI mockups: `stitch/`

---

## Project Overview

**Hisaab Kitaab (PressBook)** — Flutter Android-first app for iron/laundry vendors in Indian residential societies. Vendors use it as a digital register to log items ironed, track customer balances, and send WhatsApp payment reminders with UPI links. All monetary values are whole rupees (integers).

**Tech Stack**
- Flutter 3.x, Dart
- State: Flutter Riverpod (manual `StreamProvider`/`StateNotifierProvider` — no build_runner for providers)
- DB: **Supabase (PostgreSQL)** — realtime `.stream()` for live queries, `.upsert()` for writes
- Auth: Supabase Auth + Google OAuth; role resolved via `get_my_role()` RPC
- Nav: go_router — hierarchical navigation (no bottom nav shell)
- UI: Material 3, Be Vietnam Pro (google_fonts), primary `#003886`
- Packages: `url_launcher`, `pdf`, `share_plus`, `csv`, `local_auth`, `sentry_flutter`, `flutter_localizations`, `flutter_dotenv`, `shared_preferences`

**Architecture** — feature-first clean architecture:
```
lib/
├── main.dart                   # flutter_dotenv load + Supabase.initialize + runApp
├── app.dart                    # HisaabKitaabApp — locale, lock, auth redirect
├── core/
│   ├── auth/                   # HKAuthState sealed class, AuthNotifier, authProvider
│   ├── models/                 # customer.dart, transaction_item.dart, society.dart
│   ├── repositories/           # customer, entry, payment, config, society, staff, transaction
│   ├── providers/              # settingsProvider (re-export), localeProvider
│   ├── router/                 # app_router.dart (hierarchical go_router + auth guard)
│   ├── supabase/               # supabase_client.dart, supabase_tables.dart
│   ├── theme/                  # app_theme.dart, app_colors.dart
│   └── utils/                  # whatsapp_helper, upi_helper, pdf_invoice_helper, csv_exporter
├── features/
│   ├── auth/                   # LoginScreen (Google OAuth)
│   ├── home/                   # HomeScreen, CustomerCard, filter tabs
│   ├── customer_detail/        # CustomerDetailScreen, TransactionTimeline
│   ├── add_entry/              # AddEntryScreen (customer picker), AddItemsSheet (modal)
│   ├── payment/                # RecordPaymentScreen
│   ├── reminders/              # OverdueRemindersScreen
│   ├── settings/               # SettingsScreen (societies, config, app lock)
│   ├── app_lock/               # PinLockScreen, PinSetupSheet, AppLockNotifier (SharedPrefs)
│   └── onboarding/             # OnboardingScreen (3-screen carousel)
└── shared/widgets/             # HKGradientHeader, HKAvatar, etc.
```

**Supabase schema — 6 tables**
`app_config`, `societies`, `staff`, `customers`, `entries`, `payments`

Config stored in `app_config` (single row, id=1). PIN and locale stored locally in `shared_preferences`.

---

## Milestone Status

| Milestone | Status | Date |
|-----------|--------|------|
| M0 — Scaffold | ✅ Complete | 2026-03-30 |
| M1 — Core CRUD | ✅ Complete | 2026-03-30 |
| M2 — Reminders | ✅ Complete | 2026-03-30 |
| M3 — PDF Invoice | ✅ Complete | 2026-03-30 |
| M4 — Cloud Backup (Google Drive) | ✅ Complete | 2026-03-31 |
| M4-Adhoc — Missing FRs (9 items) | ✅ Complete | 2026-03-31 |
| M5 — Polish | ✅ Complete | 2026-03-31 |
| Phase 12 — Supabase Schema + RLS + Seed | ✅ Complete | 2026-05-19 |
| Phase 13 — Flutter Supabase Migration (data layer) | ✅ Complete | 2026-05-19 |
| Phase 1 — Design System & Shared Widgets | ✅ Complete | 2026-05-19 |
| Phase 8 — Auth Screens (Login + Registration) | ✅ Complete | 2026-05-19 |
| Phase 2 — Home Screen Redesign | ✅ Complete | 2026-05-19 |

**Phase 2 complete — home screen redesigned with HKGradientHeader (business name, role badge, overdue badge, settings/logout actions), summary card (total outstanding + customer count), society chip tabs for filtering, updated CustomerCard (Flat · Name, society subtitle, OVERDUE/SETTLED/DUE badges with amber left border), FAB gated by role/permission. Zero analyzer issues.**

---

## Detailed Milestone Notes

### M0 — Project Scaffold
- Flutter project, pubspec dependencies, feature-first folder structure
- Drift DB schema (7 tables), code generation, seed data (5 item types + default settings)
- go_router with `StatefulShellRoute` (Home / Add Entry / Settings)
- Glassmorphism bottom nav shell, Material 3 theme from Stitch mockups

### M1 — Core CRUD
- `CustomerWithBalance` model (balance = totalBilled − totalPaid)
- `TransactionItem` sealed class (`EntryTransaction` + `PaymentTransaction`)
- All DAO methods as `async*` reactive streams
- HomeScreen (SliverAppBar, filter chips, FAB), CustomerCard (Stitch design), AddCustomerSheet
- AddEntryScreen (customer picker) + AddItemsSheet modal (item steppers, custom item, date picker)
- CustomerDetailScreen (balance card, transaction timeline), RecordPaymentScreen (quick chips, mode selector)
- SettingsScreen (business identity, alert threshold)

### M2 — Reminders
- `WhatsAppHelper` — template builder (`{customer_name}`, `{amount}`, `{business_name}`) + `wa.me` deep-link with `whatsapp://` fallback
- `UpiHelper` — `upi://pay` link builder
- `overdueCustomersProvider` — reactive filter against `alertThresholdProvider`
- `OverdueRemindersScreen` — per-card Send Reminder + bulk Send All
- CustomerCard + CustomerDetailScreen app bar WhatsApp buttons live

### M3 — PDF Invoice
- `pdf: ^3.11.1` + `share_plus: ^10.1.4`
- `PdfInvoiceHelper.buildCustomerInvoice()` — blue header, balance strip, entries table, payments table, footer
- `PdfInvoiceHelper.buildMonthlySummary()` — all-customer summary table
- CustomerDetailScreen PDF button (spinner + share sheet)
- SettingsScreen REPORTS card with Export Monthly Summary button

### M4 — Cloud Backup (Google Drive)
- `google_sign_in`, `googleapis`, `extension_google_sign_in_as_googleapis_auth`
- `DriveBackupHelper` singleton — WAL checkpoint, upload/download whole `.db` to Drive `appDataFolder`, file-swap restore
- `BackupNotifier` / `backupProvider` (StateNotifier)
- DATA BACKUP card in SettingsScreen — sign-in flow, Back Up Now (spinner), Restore from Drive (confirm + restart dialog), last backup time

### M4-Adhoc — Missing Functional Requirements
All 9 items built in a single session:
1. **Edit/Delete Customer** — `deleteCustomer` DAO (cascade); `AddCustomerSheet` pre-filled edit mode; CustomerDetailScreen PopupMenu (Edit → sheet, Delete → confirm)
2. **Society Management UI** — `watchSocieties/insert/update/delete` DAOs; `societiesProvider`; Settings Societies section (add/edit/delete dialogs); blocks delete if customers assigned
3. **Customer Search** — search bar on HomeScreen filtering name/flat/phone; works with tab filters; clear button; empty state
4. **Item Rate Config** — `insertItemType/updateItemType/deactivateItemType` DAOs; Settings Item Types & Rates section; prevents removing last active item
5. **Edit/Delete Entry** — `deleteEntry/updateEntryWithItems` DAOs; AddItemsSheet edit mode params; TransactionTimeline entry PopupMenu (Edit/Delete + confirm)
6. **WhatsApp Template Editor** — multi-line TextField, variable `ActionChip`s, `AnimatedBuilder` live preview (WhatsApp green bubble), Reset Default + Save Template; persisted to `whatsapp_template` setting
7. **SQLCipher Encryption** — swapped `sqlite3_flutter_libs` → `sqlcipher_flutter_libs`; `PRAGMA key='hk@pressbook2024!'` as first statement in `NativeDatabase` setup callback
8. **CSV Export** — `CsvExporter` utility (`shareAllCustomers` summary CSV, `shareCustomerTransactions` per-customer CSV); Settings DATA EXPORT button; CustomerDetailScreen popup Export CSV item
9. **Zero-Balance Badge** — CustomerCard: green bordered chip (check_circle + "SETTLED", color #059669) when balance ≤ 0

### M5 — Polish
1. **App Lock (PIN + biometric)** — `local_auth`; `AppLockNotifier` (StateNotifier); `PinLockScreen` (numpad + biometric prompt); `PinSetupSheet` (2-step confirm); lifecycle locking on `paused`; APP LOCK card in Settings (enable/disable + Change PIN)
2. **Onboarding Flow** — 3-screen carousel (`OnboardingScreen`); `onboarding_done` DB flag; shown before lock screen on first ever launch; Skip button
3. **Auto Daily Backup** — `workmanager`; `BackupScheduler` (`scheduleDaily` / `cancel`); `callbackDispatcher` top-level function; Auto Daily Backup toggle in DATA BACKUP settings card
4. **Language Toggle** — `flutter_localizations`; `LocaleNotifier` (StateNotifier); locale persisted to `language` setting; Language card in Settings (English / हिंदी dropdown); wired to `MaterialApp.router` via `locale` prop
5. **Crash Monitoring** — `sentry_flutter`; DSN injected at build time via `--dart-define=SENTRY_DSN=...`; runs in no-op mode if DSN not provided; `tracesSampleRate: 0.2`

---

## Session Log

| Date | Session | What was built | Status after |
|------|---------|----------------|-------------|
| 2026-03-30 | 1 | M0 — Flutter scaffold, Drift DB (7 tables + seed), go_router + bottom nav, M3 theme, all placeholder screens | M0 ✅ |
| 2026-03-30 | 2 | M1 — All DAO streams, manual Riverpod providers, HomeScreen, CustomerCard, AddCustomerSheet, AddEntryScreen + AddItemsSheet modal, CustomerDetailScreen, RecordPaymentScreen, SettingsScreen | M1 ✅ |
| 2026-03-30 | 3 | M2 — WhatsAppHelper + UpiHelper, settingsProvider + alertThresholdProvider, overdueCustomersProvider, OverdueRemindersScreen (per-card + bulk Send All), CustomerCard + CustomerDetailScreen WhatsApp buttons live | M2 ✅ |
| 2026-03-30 | 4 | M3 — PdfInvoiceHelper (buildCustomerInvoice + buildMonthlySummary), CustomerDetailScreen PDF button, SettingsScreen REPORTS card; bug fix: useRootNavigator: true on all showModalBottomSheet calls | M3 ✅ |
| 2026-03-31 | 5 | M4 — DriveBackupHelper (WAL checkpoint, upload/download .db to Drive appDataFolder, file-swap restore), BackupNotifier/backupProvider, DATA BACKUP card in SettingsScreen (sign-in, back-up-now, restore + restart dialog); GCP OAuth setup done | M4 ✅ |
| 2026-03-31 | 6 | M4-Adhoc Units 1–9 — Edit/delete customer, society management UI, customer search, item rate config, edit/delete entry, WhatsApp template editor, SQLCipher encryption, CSV export, zero-balance badge | M4-Adhoc ✅ |
| 2026-03-31 | 7 | M5 — App lock (PIN+biometric), onboarding carousel, auto daily backup (workmanager), language toggle (flutter_localizations), crash monitoring (sentry_flutter); also fixed pre-existing missing packages (google_sign_in, googleapis, checkpoint DAO method) | M5 ✅ — ALL DONE |
| 2026-05-19 | 8 | Phase 13 — Complete Drift → Supabase migration: repositories (customer, entry, payment, config, society, staff, transaction), removed Drift/SQLCipher/WorkManager/DriveBackup, rewrote all screens/widgets to use Supabase models, replaced bottom nav shell with hierarchical go_router + auth guard, switched app_lock + locale to shared_preferences, `flutter analyze` = 0 issues | Phase 13 ✅ |
| 2026-05-19 | 9 | Phase 1 — Design system & shared widgets: added semantic color tokens (gaveRed, gotGreen, warnAmber, textSub, textMuted, borderColor, etc.) to AppColors; set scaffoldBackgroundColor to #F0F2F5; created `lib/shared/widgets/` — HKGradientHeader, HKAvatar, HKChip, HKBottomSheet (showHKBottomSheet helper), HKFab (primary/gave/got variants), BalanceCard; `flutter analyze` = 0 issues | Phase 1 ✅ |
| 2026-05-19 | 10 | Phase 8 — Auth screens: enhanced LoginScreen (brand hero, 3 role info cards, register link); created RegistrationScreen (two states: pre-auth Google prompt / post-auth profile form with societies dropdown, name/phone/flat); router redirect updated — UnknownRole→/register, CustomerRole→/ (Phase 10 placeholder); added `selfRegister()` + `isPendingRegistration()` to CustomerRepository; added migration `20260425000002_registration_policies.sql` (societies public read, customer self-insert with is_active=false); `flutter analyze` = 0 issues | Phase 8 ✅ |

---

## Key Conventions

- `useRootNavigator: true` on all `showModalBottomSheet` calls (outer scaffold uses `extendBody: true`)
- `ref.read` (not `ref.watch`) inside button/async handlers
- All monetary values are `int` (whole rupees, no decimals)
- IDs are UUID strings — never `int` for customer/entry/payment IDs
- `entry_date` / `payment_date` are DATE — format with `.toIso8601String().substring(0, 10)`
- Supabase anon key lives in `.env` — never in source code, never service-role key in client
- App lock PIN + locale stored in `shared_preferences` (device-local, not Supabase)
- Run `flutter analyze` after every session — must be 0 issues before committing
- To build with Sentry: `flutter run --dart-define=SENTRY_DSN=https://your-dsn@sentry.io/project`

---

## Commands

```bash
flutter run
flutter emulators --launch Pixel_7 && flutter run
flutter pub run build_runner build
flutter analyze
flutter test
```
