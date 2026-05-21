-- =============================================================================
-- Hisaab Kitaab — Initial Schema
-- Single-tenant: one laundry business, one owner, N staff, N customers
-- =============================================================================

-- ---------------------------------------------------------------------------
-- APP CONFIG  (enforced single row via CHECK id = 1)
-- Stores vendor profile and app settings.
-- owner_uid is set during first-run onboarding when the owner signs in.
-- ---------------------------------------------------------------------------
CREATE TABLE IF NOT EXISTS public.app_config (
  id                integer      PRIMARY KEY DEFAULT 1 CHECK (id = 1),
  owner_uid         uuid         REFERENCES auth.users,         -- set after owner's first sign-in
  owner_email       text         NOT NULL DEFAULT '',
  owner_name        text         NOT NULL DEFAULT '',
  business_name     text         NOT NULL DEFAULT '',
  upi_id            text,
  phone             text,
  threshold_amount  integer      NOT NULL DEFAULT 200,
  language          text         NOT NULL DEFAULT 'en',
  whatsapp_template text,
  app_lock_enabled  boolean      NOT NULL DEFAULT false,
  updated_at        timestamptz  NOT NULL DEFAULT now()
);

-- ---------------------------------------------------------------------------
-- SOCIETIES
-- Residential societies the vendor serves.
-- ---------------------------------------------------------------------------
CREATE TABLE IF NOT EXISTS public.societies (
  id         uuid         PRIMARY KEY DEFAULT gen_random_uuid(),
  name       text         NOT NULL,
  sort_order integer      NOT NULL DEFAULT 0,
  created_at timestamptz  NOT NULL DEFAULT now()
);

-- ---------------------------------------------------------------------------
-- STAFF
-- Created by the owner. user_id is null until the staff member signs in for
-- the first time with Google — the app links their auth UID at that point.
-- permissions stores a JSON object with 8 boolean capability flags.
-- ---------------------------------------------------------------------------
CREATE TABLE IF NOT EXISTS public.staff (
  id          uuid         PRIMARY KEY DEFAULT gen_random_uuid(),
  user_id     uuid         REFERENCES auth.users,     -- null until first sign-in
  name        text         NOT NULL,
  phone       text         NOT NULL,
  email       text         NOT NULL UNIQUE,            -- matched on sign-in
  permissions jsonb        NOT NULL DEFAULT '{
    "view_entries":    true,
    "send_reminders":  false,
    "add_customers":   false,
    "edit_customers":  false,
    "view_invoices":   false,
    "call_customer":   true,
    "whatsapp":        true,
    "sms":             false
  }',
  is_active   boolean      NOT NULL DEFAULT true,
  created_at  timestamptz  NOT NULL DEFAULT now()
);

-- ---------------------------------------------------------------------------
-- CUSTOMERS
-- Created by the owner or (if permitted) staff.
-- user_id is null until the customer self-registers — matched via email.
-- ---------------------------------------------------------------------------
CREATE TABLE IF NOT EXISTS public.customers (
  id          uuid         PRIMARY KEY DEFAULT gen_random_uuid(),
  user_id     uuid         REFERENCES auth.users,     -- null until customer registers
  name        text         NOT NULL,
  flat_number text         NOT NULL,
  society_id  uuid         NOT NULL REFERENCES public.societies,
  phone       text,
  email       text,                                   -- matched on customer sign-in
  is_active   boolean      NOT NULL DEFAULT true,
  created_at  timestamptz  NOT NULL DEFAULT now()
);

-- ---------------------------------------------------------------------------
-- ENTRIES  (You Gave — pickup records)
-- entry_date is DATE (not timestamptz) to support backdated entries.
-- The vendor picks up bags and may record them the next day with yesterday's date.
-- created_at records when the row was inserted into Supabase.
-- ---------------------------------------------------------------------------
CREATE TABLE IF NOT EXISTS public.entries (
  id           uuid         PRIMARY KEY DEFAULT gen_random_uuid(),
  customer_id  uuid         NOT NULL REFERENCES public.customers,
  created_by   uuid         NOT NULL REFERENCES auth.users,     -- owner or staff uid
  total_amount integer      NOT NULL CHECK (total_amount > 0),
  description  text,
  entry_date   date         NOT NULL DEFAULT CURRENT_DATE,
  created_at   timestamptz  NOT NULL DEFAULT now()
);

-- ---------------------------------------------------------------------------
-- PAYMENTS  (You Got — payment records)
-- Same date logic as entries.
-- mode is constrained to 'cash' | 'online' only.
-- ---------------------------------------------------------------------------
CREATE TABLE IF NOT EXISTS public.payments (
  id           uuid         PRIMARY KEY DEFAULT gen_random_uuid(),
  customer_id  uuid         NOT NULL REFERENCES public.customers,
  created_by   uuid         NOT NULL REFERENCES auth.users,
  amount       integer      NOT NULL CHECK (amount > 0),
  mode         text         NOT NULL DEFAULT 'cash'
                              CHECK (mode IN ('cash', 'online')),
  notes        text,
  payment_date date         NOT NULL DEFAULT CURRENT_DATE,
  created_at   timestamptz  NOT NULL DEFAULT now()
);

-- =============================================================================
-- INDEXES
-- =============================================================================

-- Customer list: filter active customers by society (home screen tabs)
CREATE INDEX IF NOT EXISTS idx_customers_society   ON public.customers (society_id) WHERE is_active = true;
CREATE INDEX IF NOT EXISTS idx_customers_is_active ON public.customers (is_active);

-- Customer detail: fetch all entries/payments for one customer, newest first
CREATE INDEX IF NOT EXISTS idx_entries_customer  ON public.entries  (customer_id, entry_date   DESC);
CREATE INDEX IF NOT EXISTS idx_payments_customer ON public.payments (customer_id, payment_date DESC);

-- Balance calculation: sum amounts per customer (used on home and detail screens)
CREATE INDEX IF NOT EXISTS idx_entries_customer_amount  ON public.entries  (customer_id, total_amount);
CREATE INDEX IF NOT EXISTS idx_payments_customer_amount ON public.payments (customer_id, amount);

-- Role resolution on sign-in: look up email in staff and customers tables
CREATE INDEX IF NOT EXISTS idx_staff_email     ON public.staff     (email)    WHERE is_active = true;
CREATE INDEX IF NOT EXISTS idx_customers_email ON public.customers (email)    WHERE is_active = true;
CREATE INDEX IF NOT EXISTS idx_staff_user_id   ON public.staff     (user_id)  WHERE is_active = true;

-- =============================================================================
-- ROLE RESOLUTION FUNCTIONS  (SECURITY DEFINER — bypass RLS)
-- These are called from the Flutter app and from RLS policies themselves.
-- SECURITY DEFINER means they run as the function owner (postgres) and can
-- read any table without being blocked by RLS.
-- =============================================================================

-- Returns true if the current authenticated user is the business owner.
CREATE OR REPLACE FUNCTION public.is_owner()
RETURNS boolean
LANGUAGE sql
SECURITY DEFINER
STABLE
SET search_path = public
AS $$
  SELECT EXISTS (
    SELECT 1 FROM public.app_config
    WHERE owner_uid = auth.uid()
  )
$$;

-- Returns true if the current user is an active staff member.
CREATE OR REPLACE FUNCTION public.is_active_staff()
RETURNS boolean
LANGUAGE sql
SECURITY DEFINER
STABLE
SET search_path = public
AS $$
  SELECT EXISTS (
    SELECT 1 FROM public.staff
    WHERE user_id = auth.uid() AND is_active = true
  )
$$;

-- Returns the customer row ID for the current user (null if not a customer).
CREATE OR REPLACE FUNCTION public.my_customer_id()
RETURNS uuid
LANGUAGE sql
SECURITY DEFINER
STABLE
SET search_path = public
AS $$
  SELECT id FROM public.customers
  WHERE user_id = auth.uid() AND is_active = true
  LIMIT 1
$$;

-- Returns the staff row ID for the current user (null if not staff).
CREATE OR REPLACE FUNCTION public.my_staff_id()
RETURNS uuid
LANGUAGE sql
SECURITY DEFINER
STABLE
SET search_path = public
AS $$
  SELECT id FROM public.staff
  WHERE user_id = auth.uid() AND is_active = true
  LIMIT 1
$$;

-- Checks a specific permission for the current staff member.
-- Example: has_staff_permission('add_customers')
CREATE OR REPLACE FUNCTION public.has_staff_permission(perm text)
RETURNS boolean
LANGUAGE sql
SECURITY DEFINER
STABLE
SET search_path = public
AS $$
  SELECT COALESCE(
    (permissions ->> perm)::boolean,
    false
  )
  FROM public.staff
  WHERE user_id = auth.uid() AND is_active = true
  LIMIT 1
$$;

-- Single function the Flutter app calls after sign-in to determine role.
-- Returns: 'owner' | 'staff' | 'customer' | 'unknown'
-- Flutter uses this to route to the correct home screen.
CREATE OR REPLACE FUNCTION public.get_my_role()
RETURNS text
LANGUAGE plpgsql
SECURITY DEFINER
VOLATILE
SET search_path = public
AS $$
DECLARE
  v_email text;
BEGIN
  -- Get email of the signed-in user
  SELECT email INTO v_email FROM auth.users WHERE id = auth.uid();

  -- Owner check (by uid stored in app_config)
  IF public.is_owner() THEN RETURN 'owner'; END IF;

  -- Staff check (by user_id after first sign-in, or by email before)
  IF public.is_active_staff() THEN RETURN 'staff'; END IF;
  IF EXISTS (SELECT 1 FROM public.staff WHERE email = v_email AND is_active = true) THEN
    -- First time this staff member signs in — link their auth UID
    UPDATE public.staff SET user_id = auth.uid() WHERE email = v_email AND is_active = true;
    RETURN 'staff';
  END IF;

  -- Customer check (by user_id or email)
  IF public.my_customer_id() IS NOT NULL THEN RETURN 'customer'; END IF;
  IF EXISTS (SELECT 1 FROM public.customers WHERE email = v_email AND is_active = true) THEN
    UPDATE public.customers SET user_id = auth.uid() WHERE email = v_email AND is_active = true;
    RETURN 'customer';
  END IF;

  RETURN 'unknown';
END;
$$;

-- =============================================================================
-- REALTIME  (enable for tables that need live sync across devices)
-- =============================================================================
ALTER PUBLICATION supabase_realtime ADD TABLE public.entries;
ALTER PUBLICATION supabase_realtime ADD TABLE public.payments;
ALTER PUBLICATION supabase_realtime ADD TABLE public.customers;
