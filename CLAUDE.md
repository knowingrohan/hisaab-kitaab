# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## Project Overview

Hisaab Kitaab (PressBook) is a Flutter Android-first app for iron/laundry vendors in Indian residential societies. Vendors use it as a digital register to log items ironed, track customer balances, and send WhatsApp payment reminders with UPI links. All monetary values are integers (whole rupees).

## Commands

```bash
# Run the app
flutter run

# Run with a specific device
flutter emulators --launch Medium_Phone && flutter run

# Code generation (required after changing Drift tables or adding Riverpod providers)
flutter pub run build_runner build
flutter pub run build_runner watch    # watch mode

# Analysis
flutter analyze

# Tests
flutter test
flutter test test/path/to/test.dart   # single test file
```

## Architecture

**Feature-first clean architecture** with three top-level directories under `lib/`:

- **`core/`** — Shared infrastructure: Drift database (`database/`), go_router config (`router/`), Material 3 theme (`theme/`)
- **`features/`** — Each feature has `presentation/` (screens/widgets) and `providers/` (Riverpod) subdirectories. Features: `home`, `customer_detail`, `add_entry`, `payment`, `reminders`, `settings`
- **`shared/`** — Cross-feature widgets (e.g., `bottom_nav_shell.dart` with glassmorphism bottom nav)

**State management:** Flutter Riverpod with code generation (`@riverpod` annotations + `riverpod_generator`).

**Database:** Drift (SQLite ORM) with 7 tables — `societies`, `customers`, `item_types`, `entries`, `entry_items`, `payments`, `app_settings`. Generated code lives in `app_database.g.dart`. Default seed data is inserted on first run.

**Navigation:** go_router with `StatefulShellRoute.indexedStack` for bottom nav (Home, Add Entry, Settings). Customer detail and payment screens are nested under the home branch.

## Design System

- Material 3 theme defined in `app_theme.dart` with colors from Stitch mockups in `app_colors.dart`
- Typography: Be Vietnam Pro via `google_fonts`
- Primary: `#003886`, Surface: `#F9F9F9`, WhatsApp green: `#25D366`
- Reference mockups: `stitch/images/*.png` (screenshots) and `stitch/code/*.html` (Stitch exports)

## Development Phases

Progress is tracked in `agents.md`. The full roadmap is in `DEVELOPMENT_PLAN.md`.

- **M0 (complete):** Project scaffold, Drift DB, go_router, M3 theme, placeholder screens
- **M1:** Core CRUD — customer management, add entry, record payment, customer detail, Riverpod providers
- **M2:** Reminders — overdue logic, WhatsApp/UPI deep-links
- **M3:** PDF invoices
- **M4:** Cloud backup (Firebase)
- **M5:** Polish (app lock, i18n, onboarding)

## Important Conventions

- Update `agents.md` at the end of every development session with what was built and what's next
- PRD lives in `PressBook_PRD_v1.0.docx` — consult it for requirements and use cases
- After modifying any Drift table or adding `@riverpod` providers, re-run `build_runner build`
