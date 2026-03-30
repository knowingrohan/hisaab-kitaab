# Hisaab Kitaab - Build Tracker

## Status Legend
- [ ] Not started
- [~] In progress
- [x] Complete

---

## M0 - Project Scaffold
- [x] Flutter project created (`flutter create`)
- [x] pubspec.yaml dependencies (Riverpod, Drift, go_router, google_fonts, etc.)
- [x] Feature-first folder structure (`core/`, `features/`, `shared/`)
- [x] Theme system (`app_colors.dart`, `app_theme.dart`) — M3 colors from Stitch
- [x] Drift database schema — 7 tables (societies, customers, item_types, entries, entry_items, payments, app_settings)
- [x] Drift code generation (`app_database.g.dart`)
- [x] Seed data — default item types (Shirt ₹10, Pant ₹10, Saree ₹20, Suit/Kurta ₹15, Jacket ₹25) + default settings
- [x] go_router navigation with `StatefulShellRoute` bottom nav
- [x] Bottom navigation shell with glassmorphism effect
- [x] Placeholder screens for all 6 screens
- [x] `main.dart` + `app.dart` wired with ProviderScope + MaterialApp.router
- [x] Flutter analyze: 0 issues
- [x] `agents.md` created

## M1 - Core CRUD
- [ ] Customer DAO + Add Customer sheet
- [ ] Home screen (outstanding card, filters, customer list)
- [ ] Customer card widget (matching Stitch design)
- [ ] Add Entry bottom sheet (item steppers, total, save)
- [ ] Entry DAO (entry + entry_items transaction)
- [ ] Record Payment screen (amount input, quick chips, mode selector)
- [ ] Payment DAO
- [ ] Customer Detail screen (header, balance card, transaction timeline)
- [ ] Riverpod providers wired end-to-end

## M2 - Reminders
- [ ] Overdue Reminders screen
- [ ] WhatsApp deep-link utility
- [ ] Individual + Bulk reminder buttons
- [ ] UPI link generation

## M3 - PDF/Invoice
- [ ] Invoice PDF template
- [ ] Monthly summary PDF
- [ ] Share via WhatsApp

## M4 - Cloud Backup
- [ ] Firebase Auth (phone OTP)
- [ ] Firestore sync engine
- [ ] Restore flow
- [ ] Backup status in Settings

## M5 - Polish
- [ ] App lock (PIN)
- [ ] Language toggle (Hindi/English/Hinglish)
- [ ] Onboarding flow
- [ ] Crash monitoring

---

## Session Log

| Date | Session | What was built | What's next |
|------|---------|----------------|-------------|
| 2026-03-30 | Session 1 | M0 complete — Flutter scaffold, Drift DB (7 tables + seed data), go_router with bottom nav, M3 theme from Stitch, all placeholder screens, agents.md | M1: Customer CRUD, Home screen, Add Entry, Record Payment, Customer Detail |
