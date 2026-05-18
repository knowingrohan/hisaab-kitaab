-- =============================================================================
-- Hisaab Kitaab — Development Seed Data
-- Run with: supabase db reset  (applies migrations then this seed)
-- Safe to re-run: uses ON CONFLICT DO NOTHING
--
-- NOTE: app_config.owner_uid is left NULL here.
-- It is set automatically when the owner signs in for the first time
-- (the onboarding flow inserts the row with auth.uid()).
-- =============================================================================

-- ---------------------------------------------------------------------------
-- App config (business profile)
-- ---------------------------------------------------------------------------
INSERT INTO public.app_config (
  id, owner_email, owner_name, business_name, upi_id, phone,
  threshold_amount, language, whatsapp_template
)
VALUES (
  1,
  'shivaswamy@gmail.com',         -- replace with real owner email
  'Shivaswamy',
  'Shivaswamy Iron & Laundry',
  'shivaswamy@upi',
  '9876543210',
  200,
  'en',
  'Namaste {name} ji, aapka Hisaab Kitaab balance ₹{balance} ho gaya hai. Kripya payment karein: {upi_link}'
)
ON CONFLICT (id) DO NOTHING;

-- ---------------------------------------------------------------------------
-- Societies
-- Use fixed UUIDs so entries/customers can reference them in seed data below.
-- ---------------------------------------------------------------------------
INSERT INTO public.societies (id, name, sort_order) VALUES
  ('10000000-0000-0000-0000-000000000001', 'Klassik Landmark',  1),
  ('10000000-0000-0000-0000-000000000002', 'Green Valley',      2),
  ('10000000-0000-0000-0000-000000000003', 'Sunrise Heights',   3)
ON CONFLICT (id) DO NOTHING;

-- ---------------------------------------------------------------------------
-- Customers (no auth.users link — added manually by owner in dev)
-- ---------------------------------------------------------------------------
INSERT INTO public.customers (id, name, flat_number, society_id, phone) VALUES
  ('20000000-0000-0000-0000-000000000001', 'Rohan Mahajan',   'G-9H',  '10000000-0000-0000-0000-000000000001', '9876543210'),
  ('20000000-0000-0000-0000-000000000002', 'Priya Sharma',    'B-204', '10000000-0000-0000-0000-000000000001', '9845012345'),
  ('20000000-0000-0000-0000-000000000003', 'Amit Kulkarni',   'C-301', '10000000-0000-0000-0000-000000000001', '9731122334'),
  ('20000000-0000-0000-0000-000000000004', 'Sunita Reddy',    'A-102', '10000000-0000-0000-0000-000000000002', '9900112233'),
  ('20000000-0000-0000-0000-000000000005', 'Deepak Nair',     'D-405', '10000000-0000-0000-0000-000000000002', NULL),
  ('20000000-0000-0000-0000-000000000006', 'Kavita Joshi',    'E-501', '10000000-0000-0000-0000-000000000003', '9123456789'),
  ('20000000-0000-0000-0000-000000000007', 'Ravi Patel',      'F-602', '10000000-0000-0000-0000-000000000003', '9234567890')
ON CONFLICT (id) DO NOTHING;

-- ---------------------------------------------------------------------------
-- Sample staff (no auth.users link — linked on first sign-in)
-- ---------------------------------------------------------------------------
INSERT INTO public.staff (id, name, phone, email, permissions) VALUES
  (
    '30000000-0000-0000-0000-000000000001',
    'Ramesh Kumar',
    '9845011223',
    'ramesh@gmail.com',
    '{
      "view_entries": true,
      "send_reminders": true,
      "add_customers": true,
      "edit_customers": false,
      "view_invoices": false,
      "call_customer": true,
      "whatsapp": true,
      "sms": false
    }'
  ),
  (
    '30000000-0000-0000-0000-000000000002',
    'Suresh Babu',
    '9731099887',
    'suresh@gmail.com',
    '{
      "view_entries": true,
      "send_reminders": false,
      "add_customers": false,
      "edit_customers": false,
      "view_invoices": false,
      "call_customer": true,
      "whatsapp": true,
      "sms": false
    }'
  )
ON CONFLICT (id) DO NOTHING;

-- ---------------------------------------------------------------------------
-- Sample entries  (created_by is left as a placeholder UUID — not a real auth user)
-- In production, created_by = auth.uid() of the owner or staff member.
-- For dev/testing, disable RLS or use service role when seeding entries.
-- ---------------------------------------------------------------------------

-- Rohan Mahajan — balance ₹216 outstanding (gave 384, got 168)
INSERT INTO public.entries (id, customer_id, created_by, total_amount, description, entry_date) VALUES
  ('40000000-0000-0000-0000-000000000001', '20000000-0000-0000-0000-000000000001', '00000000-0000-0000-0000-000000000000', 160, '20 items', '2026-04-24'),
  ('40000000-0000-0000-0000-000000000002', '20000000-0000-0000-0000-000000000001', '00000000-0000-0000-0000-000000000000',  56, '7 items',  '2026-04-16'),
  ('40000000-0000-0000-0000-000000000003', '20000000-0000-0000-0000-000000000001', '00000000-0000-0000-0000-000000000000',  96, '12 items', '2026-04-12'),
  ('40000000-0000-0000-0000-000000000004', '20000000-0000-0000-0000-000000000001', '00000000-0000-0000-0000-000000000000', 128, '16 items', '2026-04-07')
ON CONFLICT (id) DO NOTHING;

INSERT INTO public.payments (id, customer_id, created_by, amount, mode, payment_date) VALUES
  ('50000000-0000-0000-0000-000000000001', '20000000-0000-0000-0000-000000000001', '00000000-0000-0000-0000-000000000000',  96, 'cash',   '2026-04-12'),
  ('50000000-0000-0000-0000-000000000002', '20000000-0000-0000-0000-000000000001', '00000000-0000-0000-0000-000000000000',  80, 'cash',   '2026-04-01')
ON CONFLICT (id) DO NOTHING;

-- Amit Kulkarni — balance ₹340 outstanding
INSERT INTO public.entries (id, customer_id, created_by, total_amount, description, entry_date) VALUES
  ('40000000-0000-0000-0000-000000000005', '20000000-0000-0000-0000-000000000003', '00000000-0000-0000-0000-000000000000', 200, '10 shirts, 10 pants', '2026-04-23'),
  ('40000000-0000-0000-0000-000000000006', '20000000-0000-0000-0000-000000000003', '00000000-0000-0000-0000-000000000000', 140, '7 items',             '2026-04-18'),
  ('40000000-0000-0000-0000-000000000007', '20000000-0000-0000-0000-000000000003', '00000000-0000-0000-0000-000000000000', 200, '20 items',            '2026-04-10')
ON CONFLICT (id) DO NOTHING;

INSERT INTO public.payments (id, customer_id, created_by, amount, mode, payment_date) VALUES
  ('50000000-0000-0000-0000-000000000003', '20000000-0000-0000-0000-000000000003', '00000000-0000-0000-0000-000000000000', 100, 'cash', '2026-04-15'),
  ('50000000-0000-0000-0000-000000000004', '20000000-0000-0000-0000-000000000003', '00000000-0000-0000-0000-000000000000', 100, 'cash', '2026-04-10')
ON CONFLICT (id) DO NOTHING;

-- Sunita Reddy — balance ₹80 outstanding
INSERT INTO public.entries (id, customer_id, created_by, total_amount, description, entry_date) VALUES
  ('40000000-0000-0000-0000-000000000008', '20000000-0000-0000-0000-000000000004', '00000000-0000-0000-0000-000000000000', 80, '4 shirts, 4 pants', '2026-04-22')
ON CONFLICT (id) DO NOTHING;

INSERT INTO public.payments (id, customer_id, created_by, amount, mode, payment_date) VALUES
  ('50000000-0000-0000-0000-000000000005', '20000000-0000-0000-0000-000000000004', '00000000-0000-0000-0000-000000000000', 200, 'cash', '2026-04-10')
ON CONFLICT (id) DO NOTHING;

-- Deepak Nair — balance ₹160 outstanding
INSERT INTO public.entries (id, customer_id, created_by, total_amount, description, entry_date) VALUES
  ('40000000-0000-0000-0000-000000000009', '20000000-0000-0000-0000-000000000005', '00000000-0000-0000-0000-000000000000', 160, '16 items', '2026-04-21')
ON CONFLICT (id) DO NOTHING;

INSERT INTO public.payments (id, customer_id, created_by, amount, mode, payment_date) VALUES
  ('50000000-0000-0000-0000-000000000006', '20000000-0000-0000-0000-000000000005', '00000000-0000-0000-0000-000000000000', 80, 'cash', '2026-04-05')
ON CONFLICT (id) DO NOTHING;

-- Priya Sharma — fully settled
INSERT INTO public.entries (id, customer_id, created_by, total_amount, description, entry_date) VALUES
  ('40000000-0000-0000-0000-000000000010', '20000000-0000-0000-0000-000000000002', '00000000-0000-0000-0000-000000000000', 80, '8 shirts, 2 pants', '2026-04-20')
ON CONFLICT (id) DO NOTHING;

INSERT INTO public.payments (id, customer_id, created_by, amount, mode, payment_date) VALUES
  ('50000000-0000-0000-0000-000000000007', '20000000-0000-0000-0000-000000000002', '00000000-0000-0000-0000-000000000000', 80, 'online', '2026-04-20')
ON CONFLICT (id) DO NOTHING;

-- Ravi Patel — balance ₹96 outstanding
INSERT INTO public.entries (id, customer_id, created_by, total_amount, description, entry_date) VALUES
  ('40000000-0000-0000-0000-000000000011', '20000000-0000-0000-0000-000000000007', '00000000-0000-0000-0000-000000000000', 96, '12 items', '2026-04-23')
ON CONFLICT (id) DO NOTHING;

INSERT INTO public.payments (id, customer_id, created_by, amount, mode, payment_date) VALUES
  ('50000000-0000-0000-0000-000000000008', '20000000-0000-0000-0000-000000000007', '00000000-0000-0000-0000-000000000000', 200, 'cash', '2026-04-15')
ON CONFLICT (id) DO NOTHING;
