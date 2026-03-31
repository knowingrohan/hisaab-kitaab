# Hisaab Kitaab — Product Requirements Document

> **Iron Laundry Vendor Payment Tracker**

## Metadata

| Field | Value |
|---|---|
| Product Name | Hisaab Kitaab |
| Version | v1.0 |
| Author | Rohan |
| Date | March 2026 |
| Platform | Flutter (Android-first) |
| Target User | Iron/Laundry vendor in residential societies |
| Scope | Single vendor, multiple societies — Local-first + optional cloud backup |

---

## 1. Executive Summary

Hisaab Kitaab is a Flutter-based, Android-first mobile application designed for iron laundry (press-wala) vendors operating across one or more residential societies. The vendor uses the app as a standalone digital register — logging items ironed per customer visit, tracking running balances, and sending WhatsApp payment reminders with a UPI payment link when dues cross a configurable threshold.

The app is a **vendor-only internal tool**. Customers do not need to install or register. Data is stored locally on-device first, with an optional cloud backup for recovery and multi-device access.

---

## 2. Problem Statement

Iron laundry vendors in Indian residential societies currently manage customer accounts using handwritten registers. Key pain points:

- No visibility into which customers owe money across multiple societies simultaneously
- Manually tracking item counts (shirts, pants, sarees) per visit is error-prone
- Vendors forget to collect dues until they accumulate significantly
- No easy way to send payment reminders or share a UPI link for digital payment
- If the register is lost, all data is lost permanently

---

## 3. Goals & Non-Goals

### 3.1 Goals

- Replace the handwritten register with a fast, offline-capable mobile app
- Allow per-item logging (shirt, pant, saree, etc.) with auto-calculated totals
- Track each customer's running balance across one or more societies
- Alert the vendor when a customer's balance crosses a configurable threshold
- Enable one-tap WhatsApp reminder with a pre-filled Hinglish message and UPI link
- Generate a simple pending invoice/bill for any customer on demand
- Keep data safe with local storage first and optional cloud backup

### 3.2 Non-Goals (v1)

- Customer-facing app or portal — customers do not use Hisaab Kitaab
- Inventory or stock management
- Multi-user / staff accounts
- In-app UPI payment processing (only deep-link to UPI app)
- GST billing or formal accounting
- iOS support (Android-only for v1)

---

## 4. User Persona

| Attribute | Detail |
|---|---|
| Persona | **Raju — The Press-Wala** |
| Age | 28–50 years |
| Literacy | Semi-literate; comfortable with WhatsApp and basic Android apps |
| Device | Budget Android smartphone (4G, 32–64GB storage) |
| Connectivity | Uses mobile data; often works without WiFi at customer doorsteps |
| Societies Served | 1–3 residential societies (e.g., Klassik Landmark, Bengaluru) |
| Customers | 30–80 households across societies |
| Pain Point | Forgetting to collect dues; losing track of who owes how much |
| Goal | Collect payments on time without awkward follow-ups |

---

## 5. Use Cases with Acceptance Criteria

### UC-01: Add a New Customer

- **Actor:** Vendor (Raju)
- **Precondition:** App is installed and open. At least one society has been configured.

**Steps:**
1. Vendor taps "+ Add Customer" on the Home screen
2. Enters customer name and flat number (e.g., B-204)
3. Selects the society from a dropdown of configured societies
4. Optionally adds customer phone number
5. Taps "Save"

**Acceptance Criteria:**
- Customer appears in the Home screen list under the correct society
- Balance shows ₹0 by default
- If phone number is provided, WhatsApp icon is enabled on the customer card
- Flat number + name is displayed as the primary identifier (e.g., "B-204 – Ramesh")
- Customer can be created without a phone number (phone is optional)

---

### UC-02: Log Ironed Items for a Customer

- **Actor:** Vendor (Raju)
- **Precondition:** Customer exists in the app. Vendor has collected clothes for ironing.

**Steps:**
1. Vendor opens the customer detail screen
2. Taps "Add Items" button
3. Uses +/- stepper to select item counts (Shirt, Pant, Saree, Suit, Jacket, Other)
4. App calculates total in real time based on configured per-item rates
5. Vendor confirms date (defaults to today) and taps "Save Entry"

**Acceptance Criteria:**
- Entry appears in the customer's transaction timeline with date, item breakdown, and amount
- Customer's running balance increases by the logged amount
- If the updated balance exceeds the configured threshold, the customer card shows a red overdue indicator on the Home screen
- Total is calculated correctly using the vendor's configured per-item rates
- "Other" item allows free-text name and custom amount entry
- Entry can be saved without an internet connection (offline-first)

---

### UC-03: Record a Payment from a Customer

- **Actor:** Vendor (Raju)
- **Precondition:** Customer has a non-zero balance.

**Steps:**
1. Vendor opens the customer detail screen
2. Taps "Record Payment" button
3. Enters the amount paid (quick-tap chips: ₹50, ₹100, ₹200, ₹500 available)
4. Selects payment mode: Cash | UPI | Other
5. Taps "Mark as Paid"

**Acceptance Criteria:**
- A "Payment Received" entry appears in the customer's transaction timeline
- Customer's running balance decreases by the payment amount
- If balance drops below the threshold, the red overdue indicator is removed
- If balance becomes ₹0, customer card shows a "Paid" status badge
- Payment entry is saved offline without requiring internet

---

### UC-04: Send WhatsApp Payment Reminder

- **Actor:** Vendor (Raju)
- **Precondition:** Customer has a phone number saved and balance is greater than ₹0.

**Steps:**
1. Vendor taps the WhatsApp icon on a customer card (Home screen) or on the customer detail screen
2. App opens WhatsApp with a pre-filled message to the customer's number
3. Message contains: customer name, flat number, outstanding balance, and a UPI payment deep-link
4. Vendor reviews and sends the message

**Acceptance Criteria:**
- WhatsApp opens with the correct customer phone number pre-filled
- Message is in Hinglish and includes exact outstanding balance (e.g., "Aapka bill ₹340 ho gaya hai")
- Message includes a valid UPI deep-link (`upi://pay?pa=...&am=...&tn=Hisaab Kitaab`)
- If no phone number is saved, the WhatsApp icon is disabled and shows a tooltip "Add phone number first"
- Reminder can be sent individually or in bulk from the Overdue Reminders screen

---

### UC-05: View and Send Overdue Reminders (Bulk)

- **Actor:** Vendor (Raju)
- **Precondition:** One or more customers have balances exceeding the configured threshold.

**Steps:**
1. App shows a badge count on the Home screen header indicating overdue count
2. Vendor taps "Overdue" filter tab or the alert badge
3. Overdue list shows all customers above threshold, sorted by balance descending
4. Vendor taps "Send All Reminders" to trigger WhatsApp for each customer with a phone number
5. Vendor can also tap individual "Send WhatsApp" buttons per customer

**Acceptance Criteria:**
- Only customers whose balance exceeds the configured threshold appear in the overdue list
- "Send All Reminders" opens WhatsApp sequentially for each eligible customer (with phone number)
- Customers without a phone number are skipped in bulk send and flagged with a warning icon
- Overdue threshold value is sourced from Settings and can be changed at any time
- Badge count on Home screen updates in real time as balances change

---

### UC-06: Generate Pending Invoice / Bill

- **Actor:** Vendor (Raju)
- **Precondition:** Customer has one or more unpaid entries.

**Steps:**
1. Vendor opens customer detail screen
2. Taps the "Generate Bill" icon (top right)
3. App generates a formatted summary: customer name, flat no., itemised entries, total due
4. Vendor can share via WhatsApp, save to device, or print

**Acceptance Criteria:**
- Bill is generated as a shareable image or PDF
- Bill includes: vendor business name, society name, customer name + flat, date range, item-wise breakdown, and total outstanding amount
- Bill can be shared via WhatsApp share sheet without requiring internet
- Bill is generated only when balance is greater than ₹0

---

### UC-07: Manage Societies

- **Actor:** Vendor (Raju)
- **Precondition:** App is set up for the first time, or vendor is onboarding a new society.

**Steps:**
1. Vendor goes to Settings > Societies
2. Taps "+ Add Society"
3. Enters society name (e.g., "Klassik Landmark") and optional address/notes
4. Taps Save
5. Can also edit or delete existing societies

**Acceptance Criteria:**
- New society appears in the society selector when adding/editing a customer
- Home screen can be filtered by society using a horizontal tab strip
- Deleting a society is blocked if it has active customers (shows warning)
- Society name appears on generated invoices
- Vendor can manage up to 10 societies in v1

---

### UC-08: Configure Item Rates and Alert Threshold

- **Actor:** Vendor (Raju)
- **Precondition:** App is installed. Vendor wants to set custom pricing or change the alert threshold.

**Steps:**
1. Vendor opens Settings
2. Navigates to "Item Pricing" to update per-item rates (Shirt ₹10, Pant ₹10, Saree ₹20, etc.)
3. Navigates to "Alert Threshold" and enters a custom amount (default ₹200)
4. Taps Save

**Acceptance Criteria:**
- Updated rates are immediately reflected in the Add Items entry sheet
- All future balance calculations use the new rates (existing entries are not retroactively changed)
- Alert threshold change is applied immediately — customers whose balance crosses new threshold appear in overdue list at once
- Threshold must be a positive integer between ₹50 and ₹10,000
- WhatsApp reminder message template is also editable from Settings

---

## 6. Functional Requirements

### 6.1 Customer Management

| ID | Requirement | Description | Priority |
|---|---|---|---|
| FR-01 | Add Customer | Vendor can add a customer with name, flat number, society, and optional phone number | Must Have |
| FR-02 | Edit Customer | Vendor can edit any customer's name, flat number, phone, or society | Must Have |
| FR-03 | Delete Customer | Vendor can delete a customer; app prompts confirmation and shows total balance before deletion | Must Have |
| FR-04 | Customer List View | Home screen lists all customers with flat number, name, running balance, and last entry date | Must Have |
| FR-05 | Society Filter | Horizontal tab strip on Home screen to filter customers by society (All \| Society A \| Society B…) | Must Have |
| FR-06 | Search Customer | Vendor can search customers by name or flat number via a search bar on the Home screen | Should Have |
| FR-07 | Overdue Badge | Home screen header displays a count badge of customers whose balance exceeds the alert threshold | Must Have |

### 6.2 Item Entry & Billing

| ID | Requirement | Description | Priority |
|---|---|---|---|
| FR-08 | Add Items Entry | Vendor can log items ironed per visit using +/- steppers for each item type | Must Have |
| FR-09 | Configurable Item Types | Default items: Shirt, Pant, Saree, Suit/Kurta, Jacket; vendor can add custom items | Must Have |
| FR-10 | Per-Item Rate Config | Each item type has a configurable per-unit rate; stored in Settings | Must Have |
| FR-11 | Real-time Total | Total amount is calculated and displayed live as vendor adjusts item quantities | Must Have |
| FR-12 | Date on Entry | Each entry defaults to today's date; vendor can change to a past date | Must Have |
| FR-13 | Transaction Timeline | Customer detail screen shows a chronological list of all entries (items added + payments received) | Must Have |
| FR-14 | Edit/Delete Entry | Vendor can edit or delete any previous entry; balance is recalculated automatically | Should Have |

### 6.3 Payment Tracking

| ID | Requirement | Description | Priority |
|---|---|---|---|
| FR-15 | Record Payment | Vendor can record a cash or UPI payment against a customer; balance decreases accordingly | Must Have |
| FR-16 | Quick Amount Chips | Payment screen shows quick-select chips: ₹50, ₹100, ₹200, ₹500 for fast input | Should Have |
| FR-17 | Payment Mode | Vendor selects payment mode: Cash \| UPI \| Other (for records only; no actual payment processed) | Must Have |
| FR-18 | Running Balance | Net balance is always visible on customer detail screen: Total Charged – Total Paid | Must Have |
| FR-19 | Zero Balance State | When balance reaches ₹0, customer card shows a green "Paid" badge | Should Have |

### 6.4 Reminders & Notifications

| ID | Requirement | Description | Priority |
|---|---|---|---|
| FR-20 | Overdue Alert Threshold | Vendor configures a threshold amount (default ₹200); customers above it are flagged as overdue | Must Have |
| FR-21 | WhatsApp Reminder (Single) | Tapping WhatsApp icon on customer card opens WhatsApp with pre-filled Hinglish message + UPI link | Must Have |
| FR-22 | WhatsApp Reminder (Bulk) | "Send All Reminders" triggers WhatsApp for all overdue customers with phone numbers sequentially | Must Have |
| FR-23 | UPI Deep-Link in Message | Pre-filled message contains a UPI deep-link (`upi://pay`) with the exact outstanding amount | Must Have |
| FR-24 | Editable Message Template | Vendor can customise the WhatsApp reminder message text in Settings | Should Have |
| FR-25 | In-App Overdue List | Dedicated "Overdue" tab/view listing all customers above threshold, sorted by balance descending | Must Have |

### 6.5 Invoice Generation

| ID | Requirement | Description | Priority |
|---|---|---|---|
| FR-26 | Generate Bill | Vendor can generate a bill/invoice for any customer showing item-wise entries and total due | Must Have |
| FR-27 | Bill Sharing | Generated bill can be shared via WhatsApp share sheet as image or PDF | Must Have |
| FR-28 | Bill Content | Bill includes: vendor name, society, customer name + flat, date range, item breakdown, net balance | Must Have |
| FR-29 | Monthly Summary | Vendor can view a monthly summary of total revenue collected and total outstanding across all customers | Should Have |

### 6.6 Society & Settings Management

| ID | Requirement | Description | Priority |
|---|---|---|---|
| FR-30 | Add / Edit Society | Vendor can create, rename, or delete societies (up to 10 in v1) | Must Have |
| FR-31 | Vendor Profile | Vendor sets business name, UPI ID (for links), and optional phone number in Settings | Must Have |
| FR-32 | App Lock (PIN) | Vendor can set a 4-digit PIN to lock the app; biometric unlock supported if device allows | Should Have |
| FR-33 | Language Selection | App supports English and Hindi; Hinglish used in reminder message templates | Should Have |
| FR-34 | Data Export | Vendor can export all customer data as CSV for external backup | Nice to Have |

### 6.7 Data Storage & Backup

| ID | Requirement | Description | Priority |
|---|---|---|---|
| FR-35 | Local-First Storage | All data is stored on-device using a local database (SQLite via Drift); app is fully functional offline | Must Have |
| FR-36 | Cloud Backup (Optional) | Vendor can optionally enable cloud backup (Firebase Firestore) via Settings > Backup; data syncs on WiFi or mobile data | Should Have |
| FR-37 | Restore from Backup | If vendor reinstalls the app or switches device, data can be restored from cloud backup after phone OTP login | Should Have |
| FR-38 | Backup Frequency | Cloud backup runs automatically daily or on demand via "Backup Now" in Settings | Should Have |

---

## 7. Non-Functional Requirements

| ID | Category | Requirement |
|---|---|---|
| NFR-01 | Performance | App cold start must complete in under 2 seconds on a mid-range Android device (3GB RAM). Home screen with up to 100 customers must render in under 500ms. |
| NFR-02 | Offline Capability | All core features (add customer, log items, record payment, view balances) must work fully without internet. WhatsApp reminder requires WhatsApp installed, not internet via the app. |
| NFR-03 | Data Integrity | Balance calculations must be accurate to ₹1. No data loss on app crash or forced close — every entry must be persisted to SQLite before the Save action returns. |
| NFR-04 | Reliability | App must not crash on Android 8.0 and above. Crash-free session rate target: ≥ 99% (monitored via Firebase Crashlytics). |
| NFR-05 | Security | Local database must be encrypted (SQLCipher). Cloud backup data must be transmitted over HTTPS. PIN lock prevents unauthorised access to the app. |
| NFR-06 | Usability | Most common task (log items for a customer) must be completable in ≤ 3 taps from the Home screen. All tap targets must be ≥ 48dp. Font size minimum 16sp for body text. |
| NFR-07 | Accessibility | App must support system font scaling up to 1.3x without layout breakage. Colour contrast ratio ≥ 4.5:1 for all text on backgrounds. |
| NFR-08 | Scalability | App must handle up to 10 societies, 200 customers, and 5,000 transaction entries without performance degradation. |
| NFR-09 | Storage | App must not consume more than 50MB of local storage for 200 customers and 5,000 entries (excluding cloud backup). |
| NFR-10 | Compatibility | Target Android 8.0 (API 26) and above. Tested on Android 8, 10, 12, and 14. |
| NFR-11 | Maintainability | Codebase must follow Flutter clean architecture (feature-first folder structure). Unit test coverage ≥ 70% for business logic layer. |
| NFR-12 | Privacy | Customer phone numbers stored locally only and never transmitted to any third-party server except optionally via the vendor's own cloud backup account. |

---

## 8. Recommended Tech Stack

| Layer | Technology | Rationale |
|---|---|---|
| UI Framework | Flutter 3.x (Dart) | Cross-platform ready, rich widget library, smooth 60fps on budget Android devices |
| State Management | Riverpod | Scalable, testable, reactive state management |
| Local Database | Drift (SQLite) | Type-safe, offline-first, excellent Flutter support |
| DB Encryption | SQLCipher (via drift) | Encrypts local SQLite database at rest |
| Cloud Backup | Firebase Firestore + Auth | OTP-based phone login, real-time sync, free tier sufficient for v1 |
| Crash Monitoring | Firebase Crashlytics | Free, automatic crash reporting |
| Navigation | go_router | Declarative routing, deep-link ready |
| WhatsApp Link | url_launcher (wa.me) | Opens WhatsApp with pre-filled message; no API key needed |
| UPI Deep-Link | url_launcher (upi://) | Opens any UPI app installed on device |
| PDF/Image Gen | pdf package (dart) | Generate invoice as PDF for sharing |
| Notifications | flutter_local_notifications | Local threshold alerts without a server |

---

## 9. Release Plan

| Milestone | Timeline | Deliverables | Success Metric |
|---|---|---|---|
| M0 — Setup | Week 1 | Flutter project scaffold, Drift DB schema, navigation shell, UI designs imported | App builds and runs on emulator |
| M1 — Core | Weeks 2–3 | Customer CRUD, item entry sheet, payment recording, running balance, Home screen | Vendor can log a full day's entries offline |
| M2 — Reminders | Week 4 | Overdue threshold logic, WhatsApp deep-link, bulk remind screen, UPI link in message | Vendor sends a WhatsApp reminder in 1 tap |
| M3 — Invoice | Week 5 | Bill/PDF generation, share via WhatsApp, monthly summary screen | Vendor shares a bill to a customer in < 30s |
| M4 — Backup | Week 6 | Firebase auth (OTP), Firestore sync, restore flow, Settings screen complete | Data survives app reinstall |
| M5 — Polish | Week 7 | App lock (PIN), language toggle, onboarding flow, edge case handling, crash monitoring | Crash-free rate ≥ 99% in internal testing |
| v1.0 Launch | Week 8 | APK delivered to vendor; deployed to Play Store internal track | Vendor uses app daily for 2 weeks with no data issues |

---

## 10. Open Questions & Assumptions

### Open Questions

1. Should the vendor's UPI ID be stored in the app for generating payment links, or should the vendor manually paste their VPA in Settings?
2. What happens when a customer moves out — should their history be archived or permanently deleted?
3. Should the app support multiple languages per society (e.g., Kannada for one society, Hindi for another)?
4. Is there a need for a simple daily cash collection summary (total collected today across all customers)?

### Assumptions

- The vendor owns an Android phone with WhatsApp installed
- All customers are residents of known societies; no walk-in customers
- Per-item rates are fixed by the vendor and do not vary by customer
- The vendor's UPI VPA (e.g., `raju@upi`) is known and configured once in Settings
- Cloud backup is optional; the app works entirely without a Google/Firebase account

---

*End of Document — Hisaab Kitaab PRD v1.0*