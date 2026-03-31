# Hisaab Kitaab - Build Tracker

## Status Legend
- [ ] Not started
- [~] In progress
- [x] Complete

---

## M0 - Project Scaffold ✅
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

## M1 - Core CRUD ✅
- [x] Customer DAO + Add Customer sheet
- [x] Home screen (outstanding card, filters, customer list)
- [x] Customer card widget (matching Stitch design)
- [x] Add Entry bottom sheet (item steppers, total, save)
- [x] Entry DAO (entry + entry_items transaction)
- [x] Record Payment screen (amount input, quick chips, mode selector)
- [x] Payment DAO
- [x] Customer Detail screen (header, balance card, transaction timeline)
- [x] Riverpod providers wired end-to-end

## M2 - Reminders ✅
- [x] Overdue Reminders screen
- [x] WhatsApp deep-link utility (`core/utils/whatsapp_helper.dart`)
- [x] UPI link generation (`core/utils/upi_helper.dart`)
- [x] Individual + Bulk reminder buttons (OverdueRemindersScreen)
- [x] WhatsApp button wired on CustomerCard + CustomerDetailScreen
- [x] Alert threshold read dynamically from DB (settingsProvider / alertThresholdProvider)

## M3 - PDF/Invoice ✅
- [x] `pdf: ^3.11.1` + `share_plus: ^10.1.4` added to pubspec
- [x] `core/utils/pdf_invoice_helper.dart` — `buildCustomerInvoice()` + `buildMonthlySummary()`
- [x] CustomerDetailScreen PDF button wired — spinner, generates invoice + opens share sheet
- [x] SettingsScreen REPORTS card — Export Monthly Summary button with loading state

## M4 - Cloud Backup (Google Drive) ✅
- [x] `google_sign_in`, `googleapis`, `extension_google_sign_in_as_googleapis_auth` added to pubspec
- [x] INTERNET permission added to AndroidManifest.xml
- [x] `AppDatabase.checkpoint()` — WAL flush before backup
- [x] `DriveBackupHelper` singleton (`core/utils/drive_backup_helper.dart`) — sign-in, backup whole .db to Drive appDataFolder, restore with db.close + file swap, getLastBackupTime
- [x] `BackupNotifier` / `backupProvider` (`features/settings/providers/backup_provider.dart`)
- [x] DATA BACKUP card in SettingsScreen — sign-in flow, back-up-now, restore from Drive, last backup time display
- [x] Google Cloud Console OAuth setup (manual one-time by developer)

## M4-Adhoc - Missing Functional Requirements (Must complete before M5)

### Customer Management
- [ ] Edit Customer — name, flat number, phone, society (FR-02)
- [ ] Delete Customer — confirmation dialog + shows outstanding balance before deletion (FR-03)
- [ ] Search customers by name or flat number on Home screen (FR-06)
- [ ] Society Management UI in Settings — add, rename, delete societies; block delete if active customers exist (FR-30 / UC-07)
- [ ] Zero balance "Paid" green badge on customer card (FR-19)

### Item Entry
- [ ] Per-item rate config in Settings — vendor can edit Shirt/Pant/Saree/etc. prices (FR-10)
- [ ] Configurable item types — vendor can add or deactivate item types (FR-09)
- [ ] Edit / Delete entry — with automatic balance recalculation (FR-14)

### Reminders
- [ ] Editable WhatsApp reminder message template in Settings (FR-24)

### Data & Security
- [ ] SQLCipher DB encryption — encrypt local SQLite at rest (NFR-05)
- [ ] CSV data export of all customer data (FR-34)

## M5 - Polish
- [ ] App lock (PIN + biometric) (FR-32)
- [ ] Language toggle (Hindi / English / Hinglish) (FR-33)
- [ ] Onboarding flow for first-time vendors
- [ ] Crash monitoring (Sentry or similar) (NFR-04)
- [ ] Auto daily backup trigger (FR-38)

---

## Session Log

| Date | Session | What was built | What's next |
|------|---------|----------------|-------------|
| 2026-03-30 | Session 1 | M0 complete — Flutter scaffold, Drift DB (7 tables + seed data), go_router with bottom nav, M3 theme from Stitch, all placeholder screens | M1: Customer CRUD, Home screen, Add Entry, Record Payment, Customer Detail |
| 2026-03-30 | Session 2 | M1 complete — CustomerWithBalance + TransactionItem models; AppDatabase DAO methods (async* streams, entry+items transaction); manual Riverpod providers; HomeScreen with filter tabs + FAB; AddCustomerSheet modal; CustomerCard widget; AddEntryScreen + AddItemsSheet modal; CustomerDetailScreen; RecordPaymentScreen; SettingsScreen; `flutter analyze` 0 issues | M2: Overdue logic, WhatsApp deep-link utility, individual + bulk reminder buttons, UPI link generation |
| 2026-03-30 | Session 3 | M2 complete — `WhatsAppHelper` + `UpiHelper`; `settingsProvider` + `alertThresholdProvider`; `overdueCustomersProvider`; `OverdueRemindersScreen` (per-card + bulk Send All); CustomerCard WhatsApp button live; CustomerDetailScreen app bar WhatsApp button wired; `flutter analyze` 0 issues | M3: PDF invoice (pdf package, itemised bill template, share via share_plus) |
| 2026-03-30 | Session 4 | M3 complete — `PdfInvoiceHelper` with `buildCustomerInvoice()` + `buildMonthlySummary()`; CustomerDetailScreen PDF button + spinner; SettingsScreen REPORTS card; Bug fix: `useRootNavigator: true` on all `showModalBottomSheet` calls; `flutter analyze` 0 issues | M4: Cloud backup |
| 2026-03-31 | Session 5 | M4 complete (Google Drive instead of Firebase) — `DriveBackupHelper` singleton (WAL checkpoint, upload/download whole .db to Drive appDataFolder, file-swap restore); `BackupNotifier`/`backupProvider`; DATA BACKUP card in SettingsScreen (sign-in, back-up-now with spinner, restore with confirm + mandatory restart dialog); GCP OAuth setup done; `flutter analyze` 0 issues | M5: Polish (app lock, language toggle, onboarding) |
