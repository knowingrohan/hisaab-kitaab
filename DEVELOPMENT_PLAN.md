# Hisaab Kitaab - Flutter Development Plan

## Context

Hisaab Kitaab (PressBook) is a Flutter Android-first app for iron/laundry vendors in Indian residential societies. The vendor uses it as a digital register to log items ironed, track customer balances, and send WhatsApp payment reminders with UPI links. The PRD (`PressBook_PRD_v1.0.docx`) and 6 Stitch UI mockups (`stitch/`) are complete. No Flutter code exists yet — this plan starts from scratch.

---

## Phase M0: Project Setup (This Session)

### Step 1: Create Flutter project & initialize git

```bash
flutter create --org com.hisaabkitaab --project-name hisaab_kitaab --platforms android .
git init && git add -A && git commit -m "Initial Flutter project scaffold"
```

> **Note:** Run `flutter create` in the existing `/Users/rohanmahajan/Desktop/code/hisaab-kitaab` directory. The PRD and stitch folders will coexist with the Flutter project.

### Step 2: Add dependencies to `pubspec.yaml`

```yaml
dependencies:
  flutter:
    sdk: flutter
  # State Management
  flutter_riverpod: ^2.6.1
  riverpod_annotation: ^2.6.1
  # Navigation
  go_router: ^14.8.1
  # Database
  drift: ^2.22.1
  sqlite3_flutter_libs: ^0.5.28
  path_provider: ^2.1.5
  path: ^1.9.1
  # UI
  google_fonts: ^6.2.1
  intl: ^0.19.0
  # Utilities
  url_launcher: ^6.3.1
  share_plus: ^10.1.4
  uuid: ^4.5.1

dev_dependencies:
  flutter_test:
    sdk: flutter
  flutter_lints: ^5.0.0
  # Drift code generation
  drift_dev: ^2.22.1
  build_runner: ^2.4.14
  # Riverpod code generation
  riverpod_generator: ^2.6.3
  custom_lint: ^0.7.5
  riverpod_lint: ^2.6.3
```

### Step 3: Set up folder structure (feature-first clean architecture)

```
lib/
├── main.dart                          # App entry point
├── app.dart                           # MaterialApp with router + theme
├── core/
│   ├── theme/
│   │   ├── app_theme.dart             # Material 3 theme (colors, typography)
│   │   └── app_colors.dart            # Color constants from stitch design
│   ├── database/
│   │   ├── app_database.dart          # Drift database class
│   │   ├── app_database.g.dart        # Generated
│   │   └── tables/
│   │       ├── societies.dart         # Societies table
│   │       ├── customers.dart         # Customers table
│   │       ├── item_types.dart        # Item types table
│   │       ├── entries.dart           # Item entries (transactions)
│   │       ├── entry_items.dart       # Individual items in an entry
│   │       ├── payments.dart          # Payment records
│   │       └── settings.dart          # App settings (KV store)
│   ├── router/
│   │   └── app_router.dart            # go_router config with bottom nav shell
│   └── utils/
│       ├── whatsapp_helper.dart       # WhatsApp deep-link builder
│       └── upi_helper.dart            # UPI deep-link builder
├── features/
│   ├── home/
│   │   ├── presentation/
│   │   │   ├── home_screen.dart       # Customer list + filters
│   │   │   └── widgets/
│   │   │       ├── customer_card.dart
│   │   │       ├── balance_hero.dart
│   │   │       └── filter_tabs.dart
│   │   └── providers/
│   │       └── home_providers.dart
│   ├── customer_detail/
│   │   ├── presentation/
│   │   │   ├── customer_detail_screen.dart
│   │   │   └── widgets/
│   │   │       ├── balance_card.dart
│   │   │       └── transaction_timeline.dart
│   │   └── providers/
│   │       └── customer_detail_providers.dart
│   ├── add_entry/
│   │   ├── presentation/
│   │   │   ├── add_items_sheet.dart    # Bottom sheet modal
│   │   │   └── widgets/
│   │   │       └── item_stepper.dart
│   │   └── providers/
│   │       └── add_entry_providers.dart
│   ├── payment/
│   │   ├── presentation/
│   │   │   ├── record_payment_screen.dart
│   │   │   └── widgets/
│   │   │       ├── amount_chips.dart
│   │   │       └── payment_mode_selector.dart
│   │   └── providers/
│   │       └── payment_providers.dart
│   ├── reminders/
│   │   ├── presentation/
│   │   │   ├── overdue_reminders_screen.dart
│   │   │   └── widgets/
│   │   │       └── overdue_card.dart
│   │   └── providers/
│   │       └── reminder_providers.dart
│   └── settings/
│       ├── presentation/
│       │   ├── settings_screen.dart
│       │   └── widgets/
│       │       ├── business_identity_card.dart
│       │       ├── item_pricing_grid.dart
│       │       └── threshold_config.dart
│       └── providers/
│           └── settings_providers.dart
└── shared/
    └── widgets/
        ├── bottom_nav_shell.dart       # Shared bottom navigation
        └── app_bar.dart                # Shared top app bar
```

### Step 4: Database schema (Drift tables)

**societies**
| Column | Type | Notes |
|--------|------|-------|
| id | INTEGER | PK, autoincrement |
| name | TEXT | e.g., "Klassik Landmark" |
| address | TEXT | nullable |
| created_at | DATETIME | default now |

**customers**
| Column | Type | Notes |
|--------|------|-------|
| id | INTEGER | PK, autoincrement |
| name | TEXT | not null |
| flat_number | TEXT | not null, e.g., "B-204" |
| phone | TEXT | nullable |
| society_id | INTEGER | FK -> societies |
| created_at | DATETIME | default now |

**item_types**
| Column | Type | Notes |
|--------|------|-------|
| id | INTEGER | PK, autoincrement |
| name | TEXT | e.g., "Shirt" |
| rate | INTEGER | price per unit in rupees |
| icon_name | TEXT | Material icon name |
| sort_order | INTEGER | display order |
| is_active | BOOLEAN | default true |

**entries** (item logging transactions)
| Column | Type | Notes |
|--------|------|-------|
| id | INTEGER | PK, autoincrement |
| customer_id | INTEGER | FK -> customers |
| entry_date | DATETIME | date of service |
| total_amount | INTEGER | calculated total in rupees |
| created_at | DATETIME | default now |

**entry_items** (line items within an entry)
| Column | Type | Notes |
|--------|------|-------|
| id | INTEGER | PK, autoincrement |
| entry_id | INTEGER | FK -> entries |
| item_type_id | INTEGER | FK -> item_types (nullable for custom) |
| item_name | TEXT | name (for custom items) |
| quantity | INTEGER | count |
| rate | INTEGER | rate at time of entry |
| amount | INTEGER | quantity * rate |

**payments**
| Column | Type | Notes |
|--------|------|-------|
| id | INTEGER | PK, autoincrement |
| customer_id | INTEGER | FK -> customers |
| amount | INTEGER | payment amount in rupees |
| mode | TEXT | 'cash' / 'upi' / 'other' |
| notes | TEXT | nullable |
| payment_date | DATETIME | date of payment |
| created_at | DATETIME | default now |

**app_settings** (key-value store)
| Column | Type | Notes |
|--------|------|-------|
| key | TEXT | PK, e.g., 'business_name', 'upi_id', 'alert_threshold' |
| value | TEXT | stored as string, parsed by app |

### Step 5: Navigation routes (go_router)

```
/                        -> HomeScreen (customer list)
/customer/:id            -> CustomerDetailScreen
/customer/:id/add-entry  -> AddItemsSheet (shown as bottom sheet)
/customer/:id/payment    -> RecordPaymentScreen
/reminders               -> OverdueRemindersScreen
/settings                -> SettingsScreen
```

Bottom nav shell wraps `/`, `/reminders`, and `/settings` using `StatefulShellRoute`.

### Step 6: Theme setup (from stitch design system)

- **Colors:** primary=#003886, error=#ba1a1a, tertiary=#573500, surface=#f9f9f9 (full M3 palette from stitch HTML)
- **Typography:** Be Vietnam Pro via google_fonts package
- **Border radius:** rounded-2xl (16px), rounded-3xl (24px) for cards
- **Bottom nav:** glassmorphism effect with backdrop blur

### Step 7: Create `agents.md` at project root

Track development progress across sessions.

### Step 8: Seed default data

Insert default item types on first run:
- Shirt (₹10), Pant (₹10), Saree (₹20), Suit/Kurta (₹15), Jacket (₹25)

Insert default settings:
- alert_threshold: "200"
- whatsapp_template: "Namaste! Aapka pressing bill ₹{amount} se zyada ho gaya hai. Kripya payment kar dein. - {business_name}"

---

## Phase M1: Core Features (Future Sessions)

1. **Home screen** — customer list with balance, filter tabs, society filter, search
2. **Add Customer** — dialog/screen with name, flat, phone, society selector
3. **Customer Detail** — balance card, transaction timeline
4. **Add Items Entry** — bottom sheet with steppers, date picker, real-time total
5. **Record Payment** — amount input, quick chips, payment mode, notes

---

## Phase M2: Reminders (Future Sessions)

1. Overdue threshold logic in providers
2. WhatsApp deep-link (single customer)
3. Overdue reminders screen with bulk send
4. UPI deep-link in WhatsApp message
5. Overdue badge on home screen header

---

## Phase M3: Invoices (Future Sessions)

1. PDF bill generation using `pdf` package
2. Share via WhatsApp/share sheet
3. Monthly summary screen

---

## Phase M4: Cloud Backup (Future Sessions)

1. Firebase Auth (phone OTP)
2. Firestore sync
3. Restore flow
4. Backup settings in Settings screen

---

## Phase M5: Polish (Future Sessions)

1. App lock (PIN + biometric)
2. Language toggle (Hindi/English/Hinglish)
3. Onboarding flow
4. Firebase Crashlytics
5. Edge case handling

---

## Verification (M0)

After M0 setup:
1. `flutter run` launches on Android emulator/device
2. App shows bottom navigation with 3 tabs (Home, Add Entry, Settings)
3. Navigation between tabs works
4. Theme matches stitch design (colors, fonts)
5. Database creates successfully with all tables
6. Default item types are seeded
7. `agents.md` exists with correct initial status

---

## Critical Files Reference

| File | Purpose |
|------|---------|
| `PressBook_PRD_v1.0.docx` | Full PRD with use cases & requirements |
| `stitch/code/*.html` | 6 Stitch UI mockups (reference for Flutter widgets) |
| `stitch/images/*.png` | 6 screen screenshots |
| `lib/core/theme/app_colors.dart` | Color constants extracted from stitch |
| `lib/core/database/app_database.dart` | Drift DB with all tables |
| `lib/core/router/app_router.dart` | go_router with shell navigation |
| `agents.md` | Development progress tracker |
