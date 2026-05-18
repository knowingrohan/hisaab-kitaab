# CLAUDE.md

This file provides guidance to Claude Code when working in this repository.

## gstack
- Use `/browse` skill from gstack for all web browsing. Never use `mcp__claude-in-chrome__*` tools.
- Available gstack skills: `/office-hours`, `/plan-ceo-review`, `/plan-eng-review`, `/plan-design-review`, `/design-consultation`, `/design-shotgun`, `/design-html`, `/review`, `/ship`, `/land-and-deploy`, `/canary`, `/benchmark`, `/browse`, `/connect-chrome`, `/qa`, `/qa-only`, `/design-review`, `/setup-browser-cookies`, `/setup-deploy`, `/setup-gbrain`, `/retro`, `/investigate`, `/document-release`, `/document-generate`, `/codex`, `/cso`, `/autoplan`, `/plan-devex-review`, `/devex-review`, `/careful`, `/freeze`, `/guard`, `/unfreeze`, `/gstack-upgrade`, `/learn`

## Project Overview

Hisaab Kitaab is a Flutter (Android-first) + Next.js web app for a single iron/laundry business.
- **Mobile app**: vendor owner and staff log pickups/payments; customers view their own balance
- **Web panel**: owner and developer (super-admin) access via browser; same Supabase backend
- All monetary values are integers (whole rupees, no decimals)

## Relevant Skills — load before writing code

| Task | Skill |
|---|---|
| New screen or feature design | `flutter-apply-architecture-best-practices` |
| Riverpod providers / repositories | `dart-flutter-patterns` |
| After writing any Dart file | `flutter-dart-code-review` |
| SQL / Supabase migrations | `postgres-patterns` |
| RLS policies / auth changes | `security-review` |
| Next.js web panel work | `nextjs-turbopack` |

## Commands

```bash
# Flutter
flutter run                          # run on device/emulator
flutter emulators --launch Medium_Phone && flutter run
flutter analyze                      # must be 0 issues before commit
flutter test
flutter test test/path/to/test.dart  # single test file

# Supabase (local dev)
supabase start                       # start local Supabase stack (Docker required)
supabase status                      # get local URLs + anon key
supabase db reset                    # wipe DB + re-apply migrations + seed.sql
supabase db push                     # push local migrations to remote project
supabase migration new <name>        # create a new migration file

# Build (Sentry crash monitoring)
flutter run --dart-define=SENTRY_DSN=https://your-dsn@sentry.io/project
```

## Architecture

**Feature-first clean architecture** under `lib/`:

```
lib/
├── core/
│   ├── supabase/          # supabase_client.dart (singleton), supabase_tables.dart
│   ├── auth/              # UserRole sealed class, AuthNotifier, auth_provider.dart
│   ├── repositories/      # one file per table: customer, entry, payment, staff, society, config
│   ├── router/            # app_router.dart — go_router with auth redirect guard
│   └── theme/             # app_colors.dart, app_theme.dart
├── features/
│   ├── auth/              # login_screen.dart, registration_screen.dart
│   ├── onboarding/        # 6-step first-run wizard
│   ├── home/              # owner/staff home — customer list + search + society tabs
│   ├── customer_home/     # customer role — read-only own transaction view
│   ├── customer_detail/   # transaction history, PDF report
│   ├── add_entry/         # "You Gave" — amount + description + date picker
│   ├── payment/           # "You Got" — amount + mode (cash/online)
│   ├── reminders/         # overdue screen grouped by society
│   ├── staff/             # staff management (owner-only)
│   ├── settings/          # vendor config, societies, app lock
│   └── app_lock/          # PIN + biometric lock
└── shared/
    └── widgets/           # HKGradientHeader, HKAvatar, HKChip, HKBottomSheet, HKFab, BalanceCard
```

**State management**: Flutter Riverpod — `StreamProvider` for real-time DB streams, `AsyncNotifierProvider` for auth state. No build_runner for providers.

**Database**: Supabase (PostgreSQL). Schema in `supabase/migrations/`. No local Drift DB.

**Auth**: Supabase Auth with Google OAuth. Role resolved by calling `get_my_role()` RPC after sign-in.
- `owner` → `HomeScreen` (full access)
- `staff` → `HomeScreen` (permission-filtered)
- `customer` → `CustomerHomeScreen` (read-only own data)
- `unknown` → error screen ("Ask vendor to register you")

**Navigation**: go_router. Auth redirect in `GoRouter.redirect`. No bottom nav shell — navigation is hierarchical (back stack). Routes: `/login`, `/register`, `/` (home), `/customer/:id`, `/customer/:id/entry`, `/customer/:id/payment`, `/customer/:id/report`, `/overdue`, `/staff`, `/settings`, `/onboarding`.

## Design System

- Primary: `#003886`, Primary Dark: `#002560`, Primary Light: `#1A4FAA`
- "You Gave" red: `#C0392B`, light: `#FDECEA`
- "You Got" green: `#16A34A`, light: `#ECFDF5`
- Warn amber: `#F59E0B`
- Background: `#F0F2F5`, Card: `#FFFFFF`, Border: `#E2E4E9`
- Text: `#1A1C1C`, Sub: `#5D5F5F`, Muted: `#9CA3AF`
- Typography: Be Vietnam Pro via `google_fonts`
- Gradient header: `linear-gradient(135deg, #002560, #1A4FAA)` — used on every screen

## Supabase Schema (summary)

| Table | Purpose |
|---|---|
| `app_config` | Single-row vendor profile + settings. `owner_uid` set on first sign-in. |
| `societies` | Residential societies served by the vendor |
| `staff` | Staff members. `user_id` null until first sign-in (linked via `get_my_role()`). |
| `customers` | Customers. Same `user_id` link pattern as staff. |
| `entries` | Pickup records ("You Gave"). `entry_date` is DATE for backdated support. |
| `payments` | Payment records ("You Got"). `mode` ∈ {cash, online}. |

Full schema: `supabase/migrations/20260425000000_initial_schema.sql`
RLS policies: `supabase/migrations/20260425000001_rls_policies.sql`
Dev seed data: `supabase/seed.sql`

## Environment Variables

Never commit these. Use `.env` locally (gitignored), Vercel env vars for web.

```
SUPABASE_URL=https://your-project.supabase.co
SUPABASE_ANON_KEY=your-anon-key
```

## Development Status

**Active redesign — see `TODO.md` for full phase list.**

- **Phase 12 ✅** Supabase schema + RLS + seed data
- **Phase 13 🔲** Flutter: replace Drift with Supabase (NEXT)
- **Phases 1–11 🔲** Flutter UI redesign (after Phase 13)
- **Phase 14 🔲** Next.js web admin panel

## Important Conventions

- Update `DEVLOG.md` at the end of every development session
- `flutter analyze` must report 0 issues before any commit
- All Supabase writes use `created_by = supabase.auth.currentUser!.id`
- `entry_date` and `payment_date` are `date` (not `DateTime`) — vendor records the day of pickup, not the exact time
- Monetary amounts are always integers (whole rupees)
- `showModalBottomSheet` calls must use `useRootNavigator: true`
- Never expose the Supabase service-role key in Flutter or web client code — anon key only

## Skill routing

When the user's request matches an available skill, invoke it via the Skill tool. When in doubt, invoke the skill.

Key routing rules:
- Product ideas/brainstorming → invoke /office-hours
- Strategy/scope → invoke /plan-ceo-review
- Architecture → invoke /plan-eng-review
- Design system/plan review → invoke /design-consultation or /plan-design-review
- Full review pipeline → invoke /autoplan
- Bugs/errors → invoke /investigate
- QA/testing site behavior → invoke /qa or /qa-only
- Code review/diff check → invoke /review
- Visual polish → invoke /design-review
- Ship/deploy/PR → invoke /ship or /land-and-deploy
- Save progress → invoke /context-save
- Resume context → invoke /context-restore
