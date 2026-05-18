# Graph Report - /Users/rohanmahajan/Desktop/code/hisaab-kitaab  (2026-05-19)

## Corpus Check
- 82 files · ~108,659 words
- Verdict: corpus is large enough that graph structure adds value.

## Summary
- 341 nodes · 508 edges · 26 communities detected
- Extraction: 78% EXTRACTED · 22% INFERRED · 0% AMBIGUOUS · INFERRED: 113 edges (avg confidence: 0.85)
- Token cost: 0 input · 0 output

## Community Hubs (Navigation)
- [[_COMMUNITY_Design System & Conventions|Design System & Conventions]]
- [[_COMMUNITY_Flutter Feature Screens|Flutter Feature Screens]]
- [[_COMMUNITY_DEVLOG & Milestone History|DEVLOG & Milestone History]]
- [[_COMMUNITY_UI Components & Design Prototype|UI Components & Design Prototype]]
- [[_COMMUNITY_Entry & Payment UX|Entry & Payment UX]]
- [[_COMMUNITY_Design Prototype (JSX)|Design Prototype (JSX)]]
- [[_COMMUNITY_Drift Database Layer|Drift Database Layer]]
- [[_COMMUNITY_PRD Requirements|PRD Requirements]]
- [[_COMMUNITY_Feature Architecture|Feature Architecture]]
- [[_COMMUNITY_Visual Assets|Visual Assets]]
- [[_COMMUNITY_Android Frame Components|Android Frame Components]]
- [[_COMMUNITY_Customer & Registration Screens|Customer & Registration Screens]]
- [[_COMMUNITY_Report & Overdue Screens|Report & Overdue Screens]]
- [[_COMMUNITY_Onboarding Wizard|Onboarding Wizard]]
- [[_COMMUNITY_Project Docs|Project Docs]]
- [[_COMMUNITY_Community 15|Community 15]]
- [[_COMMUNITY_Community 16|Community 16]]
- [[_COMMUNITY_Community 17|Community 17]]
- [[_COMMUNITY_Community 18|Community 18]]
- [[_COMMUNITY_Community 19|Community 19]]
- [[_COMMUNITY_Community 20|Community 20]]
- [[_COMMUNITY_Community 21|Community 21]]
- [[_COMMUNITY_Community 22|Community 22]]
- [[_COMMUNITY_Community 23|Community 23]]
- [[_COMMUNITY_Community 24|Community 24]]
- [[_COMMUNITY_Community 25|Community 25]]

## God Nodes (most connected - your core abstractions)
1. `CustomerDetailScreen` - 19 edges
2. `Hisaab Kitaab Implementation Roadmap` - 19 edges
3. `Database Provider` - 18 edges
4. `SettingsScreen` - 15 edges
5. `OverdueRemindersScreen` - 15 edges
6. `Hisaab Kitaab React Design Prototype` - 15 edges
7. `AppDatabase (Drift)` - 14 edges
8. `Supabase PostgreSQL Backend` - 13 edges
9. `RecordPaymentScreen` - 12 edges
10. `Add Items Modal Bottom Sheet` - 12 edges

## Surprising Connections (you probably didn't know these)
- `Recommended Tech Stack` --semantically_similar_to--> `README: Key Architecture Decisions`  [INFERRED] [semantically similar]
  hisaab-kitaab.prd.md → README.md
- `Database Schema (7 Tables)` --semantically_similar_to--> `README: Database Schema`  [INFERRED] [semantically similar]
  DEVLOG.md → README.md
- `SettingsScreen` --references--> `Bottom Navigation Bar (Home / Add Entry / Settings)`  [EXTRACTED]
  lib/features/settings/presentation/settings_screen.dart → stitch/images/settings.png
- `SettingsScreen` --references--> `Pending Balance Badge (₹1,240 Pending)`  [EXTRACTED]
  lib/features/settings/presentation/settings_screen.dart → stitch/images/settings.png
- `SettingsScreen` --references--> `App Version Footer (Hisaab Kitaab V2.4.0)`  [EXTRACTED]
  lib/features/settings/presentation/settings_screen.dart → stitch/images/settings.png

## Hyperedges (group relationships)
- **Offline-First Data Stack (Drift + SQLCipher + Local Storage)** — devlog_db_schema, devlog_sqlcipher_encryption, prd_offline_capability, prd_fr_storage_backup [INFERRED 0.85]
- **WhatsApp + UPI Reminder Flow** — devlog_whatsapp_helper, devlog_upi_helper, devlog_overdue_customers_provider, prd_uc04_whatsapp_reminder [INFERRED 0.88]
- **Shared Stitch Design System Across All Screens** — stitch_home_customer_list, stitch_customer_detail, stitch_record_payment, stitch_add_items_entry, stitch_settings, stitch_overdue_reminders [EXTRACTED 1.00]
- **Supabase Schema (6 Core Tables)** — db_table_app_config, db_table_societies, db_table_staff, db_table_customers, db_table_entries, db_table_payments [EXTRACTED 1.00]
- **Flutter UI Redesign Phases (1-11)** — phase1_design_system, phase2_home_screen, phase3_customer_detail, phase4_add_entry, phase5_payment, phase6_settings_overdue, phase7_pdf_report, phase8_auth_screens, phase9_staff_mgmt, phase10_customer_home, phase11_onboarding [EXTRACTED 1.00]
- **User Role System (owner, staff, customer)** — user_role_owner, user_role_staff, user_role_customer, get_my_role_rpc, google_oauth [EXTRACTED 1.00]
- **Design Prototype Screens** — prototype_login_screen, prototype_home_screen, prototype_customer_detail, prototype_add_gave, prototype_add_got, prototype_overdue_screen, prototype_settings_screen, prototype_onboarding_screen, prototype_pdf_report, prototype_customer_home, prototype_staff_settings, prototype_registration [EXTRACTED 1.00]
- **Post-MVP Future Features** — future_photo_upload, future_offline_queue, future_push_notifications, future_multi_language [EXTRACTED 1.00]
- **Key Development Conventions** — convention_integer_amounts, convention_useRootNavigator, convention_anon_key_only [EXTRACTED 1.00]

## Communities

### Community 0 - "Design System & Conventions"
Cohesion: 0.04
Nodes (72): Be Vietnam Pro Typography, CLAUDE.md Project Guidance, Convention: Never expose Supabase service-role key in client code, Convention: Monetary amounts are integers (whole rupees), DB Table: app_config (vendor profile + settings), DB Table: customers, DB Table: entries (pickup records), DB Table: payments (+64 more)

### Community 1 - "Flutter Feature Screens"
Cohesion: 0.06
Nodes (53): AddCustomerSheet Widget, Add Entry Providers (itemTypesProvider), AddEntryScreen, AddItemsSheet Widget, Alert Threshold Provider, AppColors Design Tokens, AppDatabase (Drift DB), app_database.g.dart (Drift Generated Code) (+45 more)

### Community 2 - "DEVLOG & Milestone History"
Cohesion: 0.08
Nodes (42): alertThresholdProvider, AppLockNotifier, DB Table: app_settings, DEVLOG: Architecture (Feature-First Clean), BackupScheduler Utility (WorkManager), CsvExporter Utility, CustomerWithBalance Model, DB Table: customers (+34 more)

### Community 3 - "UI Components & Design Prototype"
Cohesion: 0.1
Nodes (30): Action Required Badge, Add Entry FAB Button, All Customers Tab, Balance Amount Display on Customer Card, Bottom Navigation Bar (Home / Add Entry / Settings), Customer B-204 Ramesh Sharma, Customer C-301 Suresh Gupta, Customer Card Component (+22 more)

### Community 4 - "Entry & Payment UX"
Cohesion: 0.11
Nodes (28): Add Items Button, Cash Payment Mode, Current Balance Display, Customer Avatar (Initials), CustomerCard Widget, CustomerDetailScreen, Customer: Ramesh Sharma, Due Balance Indicator (+20 more)

### Community 5 - "Design Prototype (JSX)"
Cohesion: 0.11
Nodes (4): formatDate(), getInitials(), Avatar(), TransactionRow()

### Community 6 - "Drift Database Layer"
Cohesion: 0.2
Nodes (19): AppDatabase (Drift), CustomerWithBalance Aggregation, EntryItemInput Typedef, HisaabKitaabApp Widget, GeneratedPluginRegistrant (Android), App Entry Point (main.dart), MainActivity (Android), EntryLineItem Model (+11 more)

### Community 7 - "PRD Requirements"
Cohesion: 0.13
Nodes (19): FR: Customer Management (FR-01 to FR-07), FR: Item Entry and Billing (FR-08 to FR-14), FR: Payment Tracking (FR-15 to FR-19), FR: Reminders and Notifications (FR-20 to FR-25), FR: Society and Settings Management (FR-30 to FR-34), UC-01: Add a New Customer, UC-02: Log Ironed Items, UC-03: Record a Payment (+11 more)

### Community 8 - "Feature Architecture"
Cohesion: 0.27
Nodes (15): Add Entry Feature, Add Items Entry Screen, Add Items Modal Bottom Sheet, Customer Detail Feature, Entry Date Selector, Entry Total Display, Item: Jacket, Item: Pant (+7 more)

### Community 9 - "Visual Assets"
Cohesion: 0.44
Nodes (10): Dark Blue Brand Color (#01579B), Light Blue Brand Color (#54C5F8), Flutter Default App Icon, Flutter Logo Mark (Wing/Chevron Shape), Hisaab Kitaab App, App Launcher Icon (hdpi), App Launcher Icon (mdpi), App Launcher Icon (xhdpi) (+2 more)

### Community 10 - "Android Frame Components"
Cohesion: 0.29
Nodes (0): 

### Community 11 - "Customer & Registration Screens"
Cohesion: 0.5
Nodes (0): 

### Community 12 - "Report & Overdue Screens"
Cohesion: 0.67
Nodes (0): 

### Community 13 - "Onboarding Wizard"
Cohesion: 0.67
Nodes (0): 

### Community 14 - "Project Docs"
Cohesion: 1.0
Nodes (3): DEVLOG: Project Overview, Hisaab Kitaab PRD, README: Hisaab Kitaab

### Community 15 - "Community 15"
Cohesion: 0.67
Nodes (3): FR: Data Storage and Backup (FR-35 to FR-38), Rationale: Local-First + Optional Cloud Backup, NFR-02: Offline Capability

### Community 16 - "Community 16"
Cohesion: 1.0
Nodes (2): FR: Invoice Generation (FR-26 to FR-29), UC-06: Generate Pending Invoice

### Community 17 - "Community 17"
Cohesion: 1.0
Nodes (0): 

### Community 18 - "Community 18"
Cohesion: 1.0
Nodes (0): 

### Community 19 - "Community 19"
Cohesion: 1.0
Nodes (0): 

### Community 20 - "Community 20"
Cohesion: 1.0
Nodes (1): BackupState (immutable)

### Community 21 - "Community 21"
Cohesion: 1.0
Nodes (1): Vendor Persona (Raju the Press-Wala)

### Community 22 - "Community 22"
Cohesion: 1.0
Nodes (1): DEVLOG: Key Conventions

### Community 23 - "Community 23"
Cohesion: 1.0
Nodes (1): Stitch Design System: Be Vietnam Pro Typography

### Community 24 - "Community 24"
Cohesion: 1.0
Nodes (1): Convention: showModalBottomSheet must use useRootNavigator: true

### Community 25 - "Community 25"
Cohesion: 1.0
Nodes (1): Rationale: entry_date is DATE not DateTime — vendor records pickup day, not exact time

## Knowledge Gaps
- **69 isolated node(s):** `Widget Test - App Renders`, `GeneratedPluginRegistrant (Android)`, `app_database.g.dart (Drift Generated Code)`, `AppSettings Table`, `LocaleNotifier StateNotifier` (+64 more)
  These have ≤1 connection - possible missing edges or undocumented components.
- **Thin community `Community 16`** (2 nodes): `FR: Invoice Generation (FR-26 to FR-29)`, `UC-06: Generate Pending Invoice`
  Too small to be a meaningful cluster - may be noise or needs more connections extracted.
- **Thin community `Community 17`** (1 nodes): `build.gradle.kts`
  Too small to be a meaningful cluster - may be noise or needs more connections extracted.
- **Thin community `Community 18`** (1 nodes): `settings.gradle.kts`
  Too small to be a meaningful cluster - may be noise or needs more connections extracted.
- **Thin community `Community 19`** (1 nodes): `build.gradle.kts`
  Too small to be a meaningful cluster - may be noise or needs more connections extracted.
- **Thin community `Community 20`** (1 nodes): `BackupState (immutable)`
  Too small to be a meaningful cluster - may be noise or needs more connections extracted.
- **Thin community `Community 21`** (1 nodes): `Vendor Persona (Raju the Press-Wala)`
  Too small to be a meaningful cluster - may be noise or needs more connections extracted.
- **Thin community `Community 22`** (1 nodes): `DEVLOG: Key Conventions`
  Too small to be a meaningful cluster - may be noise or needs more connections extracted.
- **Thin community `Community 23`** (1 nodes): `Stitch Design System: Be Vietnam Pro Typography`
  Too small to be a meaningful cluster - may be noise or needs more connections extracted.
- **Thin community `Community 24`** (1 nodes): `Convention: showModalBottomSheet must use useRootNavigator: true`
  Too small to be a meaningful cluster - may be noise or needs more connections extracted.
- **Thin community `Community 25`** (1 nodes): `Rationale: entry_date is DATE not DateTime — vendor records pickup day, not exact time`
  Too small to be a meaningful cluster - may be noise or needs more connections extracted.

## Suggested Questions
_Questions this graph is uniquely positioned to answer:_

- **Why does `CustomerDetailScreen` connect `Entry & Payment UX` to `Flutter Feature Screens`, `UI Components & Design Prototype`, `Visual Assets`?**
  _High betweenness centrality (0.061) - this node is a cross-community bridge._
- **Why does `RecordPaymentScreen` connect `Entry & Payment UX` to `Flutter Feature Screens`, `UI Components & Design Prototype`?**
  _High betweenness centrality (0.041) - this node is a cross-community bridge._
- **Why does `SettingsScreen` connect `Flutter Feature Screens` to `Entry & Payment UX`?**
  _High betweenness centrality (0.040) - this node is a cross-community bridge._
- **What connects `Widget Test - App Renders`, `GeneratedPluginRegistrant (Android)`, `app_database.g.dart (Drift Generated Code)` to the rest of the system?**
  _69 weakly-connected nodes found - possible documentation gaps or missing edges._
- **Should `Design System & Conventions` be split into smaller, more focused modules?**
  _Cohesion score 0.04 - nodes in this community are weakly interconnected._
- **Should `Flutter Feature Screens` be split into smaller, more focused modules?**
  _Cohesion score 0.06 - nodes in this community are weakly interconnected._
- **Should `DEVLOG & Milestone History` be split into smaller, more focused modules?**
  _Cohesion score 0.08 - nodes in this community are weakly interconnected._