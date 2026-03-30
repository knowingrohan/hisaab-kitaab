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
- [x] Customer DAO + Add Customer sheet
- [x] Home screen (outstanding card, filters, customer list)
- [x] Customer card widget (matching Stitch design)
- [x] Add Entry bottom sheet (item steppers, total, save)
- [x] Entry DAO (entry + entry_items transaction)
- [x] Record Payment screen (amount input, quick chips, mode selector)
- [x] Payment DAO
- [x] Customer Detail screen (header, balance card, transaction timeline)
- [x] Riverpod providers wired end-to-end

## M2 - Reminders
- [x] Overdue Reminders screen
- [x] WhatsApp deep-link utility (`core/utils/whatsapp_helper.dart`)
- [x] UPI link generation (`core/utils/upi_helper.dart`)
- [x] Individual + Bulk reminder buttons (OverdueRemindersScreen)
- [x] WhatsApp button wired on CustomerCard + CustomerDetailScreen
- [x] Alert threshold read dynamically from DB (settingsProvider / alertThresholdProvider)

## M3 - PDF/Invoice
- [ ] Invoice PDF template
- [ ] Monthly summary PDF
- [ ] Share via WhatsApp

## M4-Adhoc - Missing FRs
- [x] Edit/delete customer
- [ ] Society management UI
- [ ] Customer search
- [ ] Item rate config
- [ ] Edit/delete entry
- [ ] WhatsApp template editor
- [ ] SQLCipher encryption
- [ ] CSV export
- [ ] Zero-balance badge

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
| 2026-03-30 | Session 2 | M1 complete — CustomerWithBalance + TransactionItem models; AppDatabase DAO methods (async* streams, entry+items transaction); manual Riverpod providers; HomeScreen with filter tabs + FAB; AddCustomerSheet modal; CustomerCard widget (Stitch design); AddEntryScreen (customer picker tab); AddItemsSheet modal (item steppers, custom item, date picker, save); CustomerDetailScreen (balance card, transaction timeline); RecordPaymentScreen (quick chips, mode selector); SettingsScreen (business identity, alert threshold); router updated; `flutter analyze` 0 issues; APK builds cleanly | M2: Overdue logic (alert_threshold), WhatsApp deep-link utility, individual + bulk reminder buttons, UPI link generation |
| 2026-03-30 | Session 3 | M2 complete — `WhatsAppHelper` (template builder + url_launcher deep-link with wa.me fallback); `UpiHelper` (upi://pay link builder); `settingsProvider` + `alertThresholdProvider` (reactive from DB); `overdueCustomersProvider`; `OverdueRemindersScreen` (overdue list, per-card Send Reminder button, bulk Send All in app bar, no-phone fallback); CustomerCard converted to ConsumerWidget with live WhatsApp action; CustomerDetailScreen app bar WhatsApp button wired; HomeScreen alert threshold now dynamic from settings; `flutter analyze` 0 issues; APK builds cleanly | M3: PDF invoice (pdf package, itemised bill template, share via WhatsApp/share_plus) |
| 2026-03-31 | Session 4 | M4-Adhoc Unit 1 — Edit/Delete Customer: `deleteCustomer(int id)` DAO (cascade deletes entries, entry_items, payments); `AddCustomerSheet` refactored to accept optional `editingId`/`initialName`/`initialFlat`/`initialPhone` params for pre-filled edit mode; `CustomerDetailScreen` gains PopupMenuButton (Edit → sheet, Delete → confirm dialog + go('/home')); `flutter analyze` 0 issues | M4-Adhoc Unit 2: Society Management UI |
