# Hisaab Kitaab — Implementation Roadmap

Full redesign + Supabase backend + Next.js web panel.
Pick up any phase by telling Claude: **"start Phase X"** — each phase is self-contained.

Design reference: `supabase/` for DB schema, design prototype at Claude Design link in session history.

---

## ✅ Phase 12 — Supabase Backend Setup  `DONE`

- [x] Schema SQL: `supabase/migrations/20260425000000_initial_schema.sql`
- [x] RLS policies: `supabase/migrations/20260425000001_rls_policies.sql`
- [x] Dev seed data: `supabase/seed.sql`

### Manual steps still required (do once)
1. Install Supabase CLI: `brew install supabase/tap/supabase`
2. Create project at [supabase.com](https://supabase.com) → copy Project URL and anon key
3. `cd hisaab-kitaab && supabase init` → generates `supabase/config.toml`
4. `supabase db push` → applies migrations to remote project
5. **Set up Google OAuth** *(see steps below)*
   - Go to [Google Cloud Console](https://console.cloud.google.com) → create a project (or reuse one)
   - Enable the **Google Identity** API: APIs & Services → Enable APIs → search "Identity"
   - Create OAuth credentials: APIs & Services → Credentials → Create Credentials → OAuth Client ID
     - Application type: **Web application**
     - Authorized redirect URI: `https://<your-supabase-project>.supabase.co/auth/v1/callback`
     - (For local dev also add: `http://localhost:54321/auth/v1/callback`)
   - Copy the **Client ID** and **Client Secret**
   - Paste them in Supabase dashboard → Auth → Providers → Google
   - For local dev: add to `supabase/config.toml`:
     ```toml
     [auth.external.google]
     enabled = true
     client_id = "env(GOOGLE_CLIENT_ID)"
     secret = "env(GOOGLE_CLIENT_SECRET)"
     ```
   - Add `GOOGLE_CLIENT_ID=` and `GOOGLE_CLIENT_SECRET=` to your local `.env`
6. Update `supabase/seed.sql` line 16: replace `shivaswamy@gmail.com` with the real owner email
7. `supabase db reset` → applies migrations + seed to local dev DB
8. Save these as env vars (never commit them):
   - Flutter: `.env` → `SUPABASE_URL=`, `SUPABASE_ANON_KEY=`
   - Web: Vercel env vars → `NEXT_PUBLIC_SUPABASE_URL=`, `NEXT_PUBLIC_SUPABASE_ANON_KEY=`
   - Web: `DEVELOPER_EMAILS=email1@x.com,email2@x.com` (super-admin access)

---

## ✅ Phase 13 — Flutter: Replace Drift with Supabase  `DONE`

**Effort**: Large (data layer rewrite — unblocks all UI phases)
**Key files**: `pubspec.yaml`, `lib/core/`, all `*_providers.dart`

### What to do
- Remove from `pubspec.yaml`: `drift`, `sqlcipher_flutter_libs`, `sqlite3`, `path_provider`, `path`, `workmanager`, `google_sign_in`, `googleapis`, `extension_google_sign_in_as_googleapis_auth`, `drift_dev`, `build_runner`
- Add: `supabase_flutter: ^2.8.4`
- Delete: `lib/core/database/`, `lib/core/utils/drive_backup_helper.dart`, `lib/core/utils/backup_scheduler.dart`
- Create: `lib/core/supabase/supabase_client.dart` — singleton, init in `main.dart` with URL + anon key from env
- Create: `lib/core/auth/` — `UserRole` sealed class + `AuthNotifier` (calls `get_my_role()` RPC after sign-in)
- Create: `lib/core/repositories/` — one file per table: `customer_repository.dart`, `entry_repository.dart`, `payment_repository.dart`, `staff_repository.dart`, `society_repository.dart`, `config_repository.dart`
- Rewrite all `*_providers.dart` to use repositories instead of Drift DAOs
- Update `app_router.dart`: add `/login`, `/register` routes; add `redirect` guard using `AuthNotifier`; wire `GoRouter.refreshListenable` to Supabase auth stream
- Update `CLAUDE.md`: remove Drift conventions, add Supabase commands

### Supabase commands (add to CLAUDE.md after this phase)
```bash
supabase start          # start local Supabase stack
supabase db reset       # wipe + re-apply migrations + seed
supabase db push        # push local migrations to remote
supabase status         # get local URLs + keys
```

---

## ✅ Phase 1 — Design System & Shared Widgets  `DONE`

**Effort**: Medium (foundation for all UI phases)
**Key files**: `lib/core/theme/`, `lib/shared/widgets/`

- Update `app_colors.dart`: add semantic tokens — `cardBackground (#FFFFFF)`, `scaffoldBackground (#F0F2F5)`, `gaveRed (#C0392B)`, `gaveRedLight (#FDECEA)`, `gotGreen (#16A34A)`, `gotGreenLight (#ECFDF5)`, `warnAmber (#F59E0B)`, `textSub (#5D5F5F)`, `textMuted (#9CA3AF)`, `borderColor (#E2E4E9)`
- Update `app_theme.dart`: set `scaffoldBackgroundColor` to `#F0F2F5`
- Create `lib/shared/widgets/hk_gradient_header.dart` — standard blue gradient header used on every screen
- Create `lib/shared/widgets/hk_avatar.dart` — circular avatar with initials
- Create `lib/shared/widgets/hk_chip.dart` — pill filter chip (active/inactive states)
- Create `lib/shared/widgets/hk_bottom_sheet.dart` — modal sheet with drag handle
- Create `lib/shared/widgets/hk_fab.dart` — extended FAB (red/green variants)
- Create `lib/shared/widgets/balance_card.dart` — "You Will Get" summary card

---

## ✅ Phase 8 — Auth Screens (Login + Registration)  `DONE`

**Effort**: Medium — depends on Phase 13
**Key files**: `lib/features/auth/`

- `login_screen.dart`: Google Sign-In button (Supabase `signInWithOAuth`), demo role picker cards (Owner/Staff/Customer), "Register here" link
- `registration_screen.dart`: Name + Phone + Email + Society dropdown + Flat; "Register with Google" submits to Supabase then triggers owner to link the new customer
- Role routing: after sign-in call `get_my_role()` RPC → route Owner/Staff to `HomeScreen`, Customer to `CustomerHomeScreen`, unknown to error screen

---

## ✅ Phase 2 — Home Screen Redesign  `DONE`

**Effort**: Medium
**Key files**: `lib/features/home/`

- Gradient header (`HKGradientHeader`) with vendor avatar, business name, role badge
- Summary card inside header: Total Outstanding + Customer count (computed from Supabase)
- Overdue badge (amber ⚠ N) clickable → overdue screen
- Settings gear icon (owner-only)
- Logout button
- Search bar: filter by name/flat/society (client-side on loaded list)
- Society chip tabs (`HKChip`): "All Societies" + one chip per society from DB
- Customer list: redesigned `CustomerCard` — `Flat · Name`, society subtitle, balance in red/green, `OVERDUE`/`SETTLED` pill badges, amber left border when overdue
- FAB "Add Customer" (owner always, staff only if `add_customers` permission)

---

## ✅ Phase 3 — Customer Detail Screen Redesign  `DONE`

**Effort**: Medium
**Key files**: `lib/features/customer_detail/`

- Gradient header: back, phone icon (→ `tel:` URI launch), settings icon
- Customer avatar + `Flat · Name` + society + phone
- Balance card: "You Will Get" (large), Gave total / Got total
- Quick action row: Report, Reminder, WhatsApp, SMS — each hidden if missing role/permission
- Transaction table: `Entries | You Gave | You Got` columns, newest first, red/green left border per row
- Real-time: stream entries + payments from Supabase so any device update reflects instantly
- Red "YOU GAVE ₹" FAB (bottom-left) + Green "YOU GOT ₹" FAB (bottom-right)
- Settings bottom sheet: edit name/phone + remove customer (soft delete `is_active = false`)
- Reminder bottom sheet: WhatsApp message preview + send buttons

---

## ✅ Phase 4 — Pickup Entry Screen (You Gave)  `DONE`

**Effort**: Small
**Key files**: `lib/features/add_entry/`

- Replace item-stepper UI entirely
- Large `₹` amount input (number keyboard, red accent border)
- Free-text description textarea
- Date picker defaulting to today (`CURRENT_DATE`); shows amber "Past entry" badge when backdated
- No photo upload in MVP (defer to future version)
- On save: insert into `entries` via `EntryRepository`; `created_by = supabase.auth.currentUser!.id`

---

## ✅ Phase 5 — Payment Screen (You Got)  `DONE`

**Effort**: Small
**Key files**: `lib/features/payment/`

- Green gradient header showing customer name + outstanding balance
- Large `₹` amount input
- Quick-tap chips: ₹50 / ₹100 / ₹200 / ₹500 / Full balance (deduplicated)
- Payment mode: **Cash** / **Online** only (two buttons, no other options)
- Optional note field
- On save: insert into `payments` via `PaymentRepository`

---

## ✅ Phase 6 — Settings + Overdue Screen Redesign  `DONE`

**Effort**: Medium
**Key files**: `lib/features/settings/`, `lib/features/reminders/`

**Settings**:
- Gradient header with vendor avatar, business name, UPI ID
- Grouped list: SMS Settings, Payment Settings, Item Pricing, Alert Threshold, Recycle Bin, App Lock toggle, Language, Backup Info
- "Staff Management" row (owner-only) → navigates to Phase 9 screen
- "Societies" management row → add/remove societies from DB

**Overdue screen**:
- Amber/orange gradient header (`#92400E → #F59E0B`)
- 3-box summary: Overdue count, Total Due, Can Remind count
- "Send All" WhatsApp button with staggered send animation per customer
- Customers grouped by society with society-level total due
- Per-customer: WhatsApp button (spinner → checkmark animation), call button
- Balance bar showing how far over threshold

---

## ✅ Phase 7 — PDF Report Screen  `DONE`

**Effort**: Small
**Key files**: `lib/features/customer_detail/presentation/pdf_report_screen.dart`, `lib/core/utils/pdf_invoice_helper.dart`

- New `PdfReportScreen` widget (replaces old report bottom sheet)
- Date range filter (From / To date pickers) — filters entries/payments in memory
- Styled invoice card preview:
  - Business header (name + UPI)
  - Customer info + period
  - 3 summary boxes: Total Laundry / Total Paid / Balance Due (colored red/green)
  - Transaction table with alternating row background
  - UPI payment footer when balance > 0
- Export bottom sheet: Save PDF, Print, Share via WhatsApp, Share as Image

---

## ✅ Phase 9 — Staff Management Screen  `DONE`

**Effort**: Medium
**Key files**: `lib/features/staff/`

- `StaffSettingsScreen`: list staff cards — avatar (purple), name, phone/email, permission pills
- Edit + Remove (soft delete) buttons per staff
- "Add Staff" button → `AddEditStaffSheet`
- Sheet: Full Name, Phone, Email (all required) + 8-permission checklist
- On save: upsert `staff` row via `StaffRepository`
- Navigate here from Settings → "Staff Management" (owner-only)

---

## ✅ Phase 10 — Customer Home Screen (Read-only)  `DONE`

**Effort**: Small
**Key files**: `lib/features/customer_home/`

- Gradient header with customer's own name, flat, society
- Balance summary card (outstanding, laundry total, paid total)
- Quick actions: Pay via WhatsApp (opens payment deep-link), Download Report, Request SMS
- Transaction table: `Entries | You Owe | You Paid` (read-only, own data only via RLS)
- No FABs — customers cannot add entries or payments

---

## ✅ Phase 11 — Onboarding Wizard Redesign  `DONE`

**Effort**: Medium
**Key files**: `lib/features/onboarding/`

Replace current carousel with 6-step wizard:
1. **Welcome** — hero (🧺), feature highlights, "Get Started"
2. **Your Profile** — owner name + business name (saved to `app_config`)
3. **UPI Setup (Optional)** — UPI VPA with live payment link preview (Optional)
4. **Societies** — add/remove chips (up to 5), Enter key support; saves to `societies` table
5. **Alert Settings** — overdue threshold (₹100/200/300/500/1000 quick-select); saves to `app_config`
6. **All Set!** — summary card of entered config + "Go to App" button

Progress bar across top (steps 2–5). Step dots at bottom. Back button from step 2 onward.
On step 1 completion: insert `app_config` row with `owner_uid = auth.uid()`.

---

## Phase 14 — Web Admin Panel (Next.js)

**Effort**: Large (new repo)
**Repo**: `hisaab-kitaab-web/` (sibling directory) or monorepo
**Deploy**: Vercel (zero-config, env vars in dashboard)

  How it differs from the mobile app

  ┌────────────────────┬─────────────────────────────────────────────────────────────────────────────┬────────────────────────────────────────────────────────────────────────────────────────────────────┐
  │      Concern       │                              Mobile (Flutter)                               │                                           Web (Next.js)                                            │
  ├────────────────────┼─────────────────────────────────────────────────────────────────────────────┼────────────────────────────────────────────────────────────────────────────────────────────────────┤
  │ Target user        │ Vendor owner, staff, and customers — daily field use                        │ Owner and super-admin (developer) — management and oversight                                       │
  ├────────────────────┼─────────────────────────────────────────────────────────────────────────────┼────────────────────────────────────────────────────────────────────────────────────────────────────┤
  │ Device             │ Android phone, hands-on                                                     │ Desktop/laptop browser                                                                             │
  ├────────────────────┼─────────────────────────────────────────────────────────────────────────────┼────────────────────────────────────────────────────────────────────────────────────────────────────┤
  │ Auth               │ Google OAuth via Supabase, full role routing (Owner/Staff/Customer)         │ Google OAuth via Supabase, but blocks staff and customers at middleware — only owner and           │
  │                    │                                                                             │ super-admin can access                                                                             │
  ├────────────────────┼─────────────────────────────────────────────────────────────────────────────┼────────────────────────────────────────────────────────────────────────────────────────────────────┤
  │ Customer role      │ Has their own read-only home screen                                         │ No access to web panel at all                                                                      │
  ├────────────────────┼─────────────────────────────────────────────────────────────────────────────┼────────────────────────────────────────────────────────────────────────────────────────────────────┤
  │ Entry/payment      │ Primary workflow — optimized for one-handed mobile input (large ₹ taps,     │ Available on customer detail page but secondary to viewing                                         │
  │ input              │ quick chips)                                                                │                                                                                                    │
  ├────────────────────┼─────────────────────────────────────────────────────────────────────────────┼────────────────────────────────────────────────────────────────────────────────────────────────────┤
  │ Data tables        │ Scrollable card lists                                                       │ Full data tables with sort, filter, pagination                                                     │
  ├────────────────────┼─────────────────────────────────────────────────────────────────────────────┼────────────────────────────────────────────────────────────────────────────────────────────────────┤
  │ Bulk actions       │ None                                                                        │ Bulk WhatsApp link generator, CSV export per society                                               │
  ├────────────────────┼─────────────────────────────────────────────────────────────────────────────┼────────────────────────────────────────────────────────────────────────────────────────────────────┤
  │ Super-admin view   │ Doesn't exist                                                               │ /admin route shows cross-vendor stats, only for emails in DEVELOPER_EMAILS                         │
  ├────────────────────┼─────────────────────────────────────────────────────────────────────────────┼────────────────────────────────────────────────────────────────────────────────────────────────────┤
  │ Offline /          │ Supabase Realtime streams — updates live on screen                          │ Server-side rendering + client Supabase subscriptions                                              │
  │ real-time          │                                                                             │                                                                                                    │
  ├────────────────────┼─────────────────────────────────────────────────────────────────────────────┼────────────────────────────────────────────────────────────────────────────────────────────────────┤
  │ PDF reports        │ Generated in-app with pdf package, shared via share sheet                   │ Same layout, generated server-side or client-side, downloaded directly                             │
  ├────────────────────┼─────────────────────────────────────────────────────────────────────────────┼────────────────────────────────────────────────────────────────────────────────────────────────────┤
  │ Deployment         │ APK / Play Store                                                            │ Vercel (zero-config, env vars in dashboard)                                                        │
  └────────────────────┴─────────────────────────────────────────────────────────────────────────────┴────────────────────────────────────────────────────────────────────────────────────────────────────┘


### Setup
```bash
npx create-next-app@latest hisaab-kitaab-web \
  --typescript --tailwind --app --src-dir --import-alias "@/*"
cd hisaab-kitaab-web
npx shadcn@latest init
npm install @supabase/supabase-js @supabase/ssr
```

### Auth middleware (`middleware.ts`)
- Refresh Supabase session on every request
- Redirect unauthenticated users to `/login`
- After sign-in: call `get_my_role()` RPC; block staff/customer with 403; allow owner/super-admin

### Pages (App Router)

**Phase 14a** — Dashboard + Customer List
- `/login` — Google Sign-In via Supabase
- `/` — Dashboard: Total Outstanding card, Overdue summary card, Recent activity feed
- `/customers` — Data table: search, society filter chips, balance column, sort by balance desc

**Phase 14b** — Customer Detail
- `/customers/[id]` — Transaction history table, balance card, You Gave + You Got buttons
- `/customers/[id]/report` — PDF report with date range filter, same layout as mobile

**Phase 14c** — Overdue + Bulk Actions
- `/overdue` — Society-grouped overdue list, bulk WhatsApp link generator, CSV export button

**Phase 14d** — Staff + Settings
- `/staff` — Staff management table with inline permissions matrix
- `/settings` — Vendor profile form, UPI, societies management, threshold slider

**Phase 14e** — Super-admin Panel
- `/admin` — All customers overview, usage stats; only accessible if email in `DEVELOPER_EMAILS`

### Design system (web)
Same HK design tokens as Flutter: `#003886` primary, `#C0392B` red, `#16A34A` green, `#F0F2F5` background. Override shadcn/ui CSS variables in `globals.css`.

---

## Future Versions (post-MVP)

- **Photo upload** — Supabase Storage bucket `entry-photos`, 2 photos per entry, shown in customer detail
- **Offline queue** — Drift as local write-ahead cache that syncs to Supabase on reconnect
- **Push notifications** — Supabase Edge Functions + FCM for overdue payment alerts
- **Multi-language** — Hindi full translation (framework already in place)
- **Analytics** — Monthly revenue chart, top customers by volume (web panel Phase 14e+)
- **Customer self-pay** — UPI deep-link from customer home screen
