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

## M3 - PDF/Invoice ✅
- [x] Invoice PDF template (`core/utils/pdf_invoice_helper.dart` — `buildCustomerInvoice()`)
- [x] Monthly summary PDF (`buildMonthlySummary()`)
- [x] Share via WhatsApp (CustomerDetailScreen PDF button + SettingsScreen REPORTS card via `share_plus`)

## M4 - Cloud Backup(Google Drive) ✅
- [x] `google_sign_in`, `googleapis`, `extension_google_sign_in_as_googleapis_auth` added to pubspec
- [x] INTERNET permission added to AndroidManifest.xml
- [x] `AppDatabase.checkpoint()` — WAL flush before backup
- [x] `DriveBackupHelper` singleton (`core/utils/drive_backup_helper.dart`) — sign-in, backup whole .db to Drive appDataFolder, restore with db.close + file swap, getLastBackupTime
- [x] `BackupNotifier` / `backupProvider` (`features/settings/providers/backup_provider.dart`)
- [x] DATA BACKUP card in SettingsScreen — sign-in flow, back-up-now, restore from Drive, last backup time display
- [x] Google Cloud Console OAuth setup (manual one-time by developer)

## M4-Adhoc - Missing FRs
- [x] Edit/delete customer
- [x] Society management UI
- [x] Customer search
- [x] Item rate config
- [x] Edit/delete entry
- [x] WhatsApp template editor
- [x] SQLCipher encryption
- [x] CSV export
- [x] Zero-balance badge


## M5 - Polish ✅
- [x] App lock (PIN + biometric) — `features/app_lock/` (PinLockScreen, PinSetupSheet, AppLockNotifier); `local_auth` package; lifecycle-aware locking in app.dart; toggle + Change PIN in SettingsScreen
- [x] Language toggle (Hindi/English) — `localeNotifierProvider` + `flutter_localizations`; Locale stored in `app_settings`; Language dropdown in SettingsScreen
- [x] Onboarding flow — 3-screen carousel (`features/onboarding/`); `onboarding_done` flag in DB; shown before lock screen on first launch
- [x] Auto daily backup — `workmanager` + `BackupScheduler`; Auto Daily Backup toggle in DATA BACKUP settings card (schedules/cancels periodic WorkManager task)
- [x] Crash monitoring — `sentry_flutter`; DSN injected via `--dart-define=SENTRY_DSN=...` at build time; no-op when DSN not set

---

## Session Log

| Date | Session | What was built | What's next |
|------|---------|----------------|-------------|
| 2026-03-30 | Session 1 | M0 complete — Flutter scaffold, Drift DB (7 tables + seed data), go_router with bottom nav, M3 theme from Stitch, all placeholder screens, agents.md | M1: Customer CRUD, Home screen, Add Entry, Record Payment, Customer Detail |
| 2026-03-30 | Session 2 | M1 complete — CustomerWithBalance + TransactionItem models; AppDatabase DAO methods (async* streams, entry+items transaction); manual Riverpod providers; HomeScreen with filter tabs + FAB; AddCustomerSheet modal; CustomerCard widget (Stitch design); AddEntryScreen (customer picker tab); AddItemsSheet modal (item steppers, custom item, date picker, save); CustomerDetailScreen (balance card, transaction timeline); RecordPaymentScreen (quick chips, mode selector); SettingsScreen (business identity, alert threshold); router updated; `flutter analyze` 0 issues; APK builds cleanly | M2: Overdue logic (alert_threshold), WhatsApp deep-link utility, individual + bulk reminder buttons, UPI link generation |
| 2026-03-30 | Session 3 | M2 complete — `WhatsAppHelper` (template builder + url_launcher deep-link with wa.me fallback); `UpiHelper` (upi://pay link builder); `settingsProvider` + `alertThresholdProvider` (reactive from DB); `overdueCustomersProvider`; `OverdueRemindersScreen` (overdue list, per-card Send Reminder button, bulk Send All in app bar, no-phone fallback); CustomerCard converted to ConsumerWidget with live WhatsApp action; CustomerDetailScreen app bar WhatsApp button wired; HomeScreen alert threshold now dynamic from settings; `flutter analyze` 0 issues; APK builds cleanly | M3: PDF invoice (pdf package, itemised bill template, share via WhatsApp/share_plus) |
| 2026-03-31 | Session 4 | M4-Adhoc Unit 1 — Edit/Delete Customer: `deleteCustomer(int id)` DAO (cascade deletes entries, entry_items, payments); `AddCustomerSheet` refactored to accept optional `editingId`/`initialName`/`initialFlat`/`initialPhone` params for pre-filled edit mode; `CustomerDetailScreen` gains PopupMenuButton (Edit → sheet, Delete → confirm dialog + go('/home')); `flutter analyze` 0 issues | M4-Adhoc Unit 2: Society Management UI |
| 2026-03-31 | Session 4 | M4-Adhoc Unit 2 — Society Management UI: `watchSocieties/insertSociety/updateSociety/deleteSociety` DAO methods; `societiesProvider` StreamProvider; `AddCustomerSheet` gains society DropdownButtonFormField; Settings screen gains Societies section with add/edit/delete dialogs; `flutter analyze` 0 issues | M4-Adhoc Unit 3: Customer Search |
| 2026-03-31 | Session 4 | M4-Adhoc Unit 3 — Customer Search: search bar on HomeScreen filtering by name/flat/phone; works with tab filters; clear button; "No results for '...'" empty state; `flutter analyze` 0 issues | M4-Adhoc Unit 4: Item Rate Config |
| 2026-03-31 | Session 4 | M4-Adhoc Unit 4 — Item Rate Config: `insertItemType/updateItemType/deactivateItemType` DAO methods; Settings screen gains "Item Types & Rates" section with add/edit/deactivate; prevents removing last active item; `flutter analyze` 0 issues | M4-Adhoc Unit 5: Edit/Delete Entry |
| 2026-03-31 | Session 4 | M4-Adhoc Unit 5 — Edit/Delete Entry: `deleteEntry/updateEntryWithItems` DAO methods; AddItemsSheet supports edit mode (existingEntryId/existingDate/existingQuantities params); TransactionTimeline entry cards gain PopupMenuButton (Edit/Delete); delete shows confirmation dialog; `flutter analyze` 0 issues | M4-Adhoc Unit 6: WhatsApp Template Editor |
| 2026-03-31 | Session 4 | M4-Adhoc Unit 6 — WhatsApp Template Editor: `_templateCtrl` + `_defaultTemplate` constant + `_insertVariable()` in SettingsScreen; multi-line TextField; ActionChip variable inserters ({customer_name}, {amount}, {business_name}); AnimatedBuilder live preview (WhatsApp green bubble with sample values); Reset Default + Save Template buttons; template persisted to `whatsapp_template` app_settings key; `flutter analyze` 0 issues | M4-Adhoc Unit 7: SQLCipher Encryption |
| 2026-03-31 | Session 4 | M4-Adhoc Unit 7 — SQLCipher Encryption: swapped `sqlite3_flutter_libs` → `sqlcipher_flutter_libs 0.5.7`; `NativeDatabase.createInBackground` gains `setup` callback executing `PRAGMA key='hk@pressbook2024!'` as first statement for transparent encryption; `flutter analyze` 0 issues; APK builds cleanly | M4-Adhoc Unit 8: CSV Export |
| 2026-03-31 | Session 4 | M4-Adhoc Unit 8 — CSV Export: added `csv: ^6.0.0`; new `CsvExporter` utility with `shareAllCustomers` (summary CSV) and `shareCustomerTransactions` (per-customer CSV with header + transaction rows); shared via `share_plus Share.shareXFiles` with temp file; Settings screen gains "DATA EXPORT" section with Export All Customers button; CustomerDetailScreen popup menu gains "Export CSV" item; `flutter analyze` 0 issues | M4-Adhoc Unit 9: Zero-Balance Badge |
| 2026-03-31 | Session 4 | M4-Adhoc Unit 9 — Zero-Balance Badge: CustomerCard replaces plain "SETTLED" text with green bordered chip (check_circle icon + "SETTLED" label, color #059669) when balance ≤ 0; DUE/OVERDUE text unchanged; `flutter analyze` 0 issues; APK builds cleanly | M3: PDF Invoice |
| 2026-03-31 | Session 6 | M5 complete — Unit 1: App Lock (PIN + biometric via `local_auth`; `AppLockNotifier`; `PinLockScreen` + `PinSetupSheet`; lifecycle locking on `paused`; APP LOCK card in Settings); Unit 2: Onboarding Flow (3-screen carousel; `onboarding_done` DB flag; shown on first launch before lock); Unit 3: Auto Daily Backup (`workmanager`; `BackupScheduler.scheduleDaily/cancel`; DATA BACKUP card in Settings with sign-in, back-up-now, auto toggle); Unit 4: Language Toggle (`flutter_localizations`; `localeNotifierProvider`; Language dropdown in Settings; en/hi supported); Unit 5: Crash Monitoring (`sentry_flutter`; DSN via `--dart-define=SENTRY_DSN`; no-op without DSN); also fixed: google_sign_in/googleapis/checkpoint missing from pubspec + DB; `flutter analyze` 0 issues | All milestones complete — app ready for release |
