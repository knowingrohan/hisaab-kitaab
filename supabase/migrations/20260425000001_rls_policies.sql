-- =============================================================================
-- Hisaab Kitaab — Row Level Security Policies
-- Must be applied AFTER 20260425000000_initial_schema.sql
--
-- Role hierarchy:
--   owner       → full CRUD on everything
--   staff       → read customers/societies; write entries/payments per permissions
--   customer    → read-only their own entries and payments
--   unauthenticated → no access
-- =============================================================================

-- =============================================================================
-- app_config
-- =============================================================================
ALTER TABLE public.app_config ENABLE ROW LEVEL SECURITY;

-- Any authenticated user can read (staff and customers need threshold, business name, etc.)
CREATE POLICY "config_authenticated_read" ON public.app_config
  FOR SELECT
  TO authenticated
  USING (true);

-- Only the owner can update (matched by owner_uid = auth.uid())
CREATE POLICY "config_owner_update" ON public.app_config
  FOR UPDATE
  TO authenticated
  USING (auth.uid() = owner_uid)
  WITH CHECK (auth.uid() = owner_uid);

-- First-run insert: allowed only when the table is empty (no owner registered yet)
CREATE POLICY "config_initial_insert" ON public.app_config
  FOR INSERT
  TO authenticated
  WITH CHECK (NOT EXISTS (SELECT 1 FROM public.app_config));

-- =============================================================================
-- societies
-- =============================================================================
ALTER TABLE public.societies ENABLE ROW LEVEL SECURITY;

-- Owner: full access
CREATE POLICY "societies_owner_all" ON public.societies
  FOR ALL
  TO authenticated
  USING (public.is_owner())
  WITH CHECK (public.is_owner());

-- Staff and customers: read-only (needed for dropdowns and display)
CREATE POLICY "societies_others_read" ON public.societies
  FOR SELECT
  TO authenticated
  USING (public.is_active_staff() OR public.my_customer_id() IS NOT NULL);

-- =============================================================================
-- staff
-- =============================================================================
ALTER TABLE public.staff ENABLE ROW LEVEL SECURITY;

-- Owner: full CRUD (create/edit/remove staff)
CREATE POLICY "staff_owner_all" ON public.staff
  FOR ALL
  TO authenticated
  USING (public.is_owner())
  WITH CHECK (public.is_owner());

-- Staff: read their own record only (to load their permissions)
CREATE POLICY "staff_read_own" ON public.staff
  FOR SELECT
  TO authenticated
  USING (user_id = auth.uid());

-- Staff: update their own user_id on first sign-in (handled via get_my_role function)
-- The SECURITY DEFINER function handles the UPDATE directly; no policy needed here.

-- =============================================================================
-- customers
-- =============================================================================
ALTER TABLE public.customers ENABLE ROW LEVEL SECURITY;

-- Owner: full CRUD
CREATE POLICY "customers_owner_all" ON public.customers
  FOR ALL
  TO authenticated
  USING (public.is_owner())
  WITH CHECK (public.is_owner());

-- Staff: read all active customers (needed to select customer for entry)
CREATE POLICY "customers_staff_read" ON public.customers
  FOR SELECT
  TO authenticated
  USING (public.is_active_staff() AND is_active = true);

-- Staff: insert new customer if they have add_customers permission
CREATE POLICY "customers_staff_insert" ON public.customers
  FOR INSERT
  TO authenticated
  WITH CHECK (
    public.is_active_staff()
    AND public.has_staff_permission('add_customers')
  );

-- Staff: update customer details if they have edit_customers permission
CREATE POLICY "customers_staff_update" ON public.customers
  FOR UPDATE
  TO authenticated
  USING (
    public.is_active_staff()
    AND public.has_staff_permission('edit_customers')
  );

-- Customer: read only their own record
CREATE POLICY "customers_self_read" ON public.customers
  FOR SELECT
  TO authenticated
  USING (user_id = auth.uid());

-- =============================================================================
-- entries  (You Gave)
-- =============================================================================
ALTER TABLE public.entries ENABLE ROW LEVEL SECURITY;

-- Owner: full CRUD
CREATE POLICY "entries_owner_all" ON public.entries
  FOR ALL
  TO authenticated
  USING (public.is_owner())
  WITH CHECK (public.is_owner());

-- Staff: read all entries (view_entries permission)
CREATE POLICY "entries_staff_read" ON public.entries
  FOR SELECT
  TO authenticated
  USING (
    public.is_active_staff()
    AND public.has_staff_permission('view_entries')
  );

-- Staff: insert entries (core job, always allowed for active staff)
CREATE POLICY "entries_staff_insert" ON public.entries
  FOR INSERT
  TO authenticated
  WITH CHECK (
    public.is_active_staff()
    AND created_by = auth.uid()
  );

-- Staff: update/delete their own entries (owner can do all)
CREATE POLICY "entries_staff_update_own" ON public.entries
  FOR UPDATE
  TO authenticated
  USING (public.is_active_staff() AND created_by = auth.uid());

-- Customer: read only their own entries
CREATE POLICY "entries_customer_read" ON public.entries
  FOR SELECT
  TO authenticated
  USING (customer_id = public.my_customer_id());

-- =============================================================================
-- payments  (You Got)
-- =============================================================================
ALTER TABLE public.payments ENABLE ROW LEVEL SECURITY;

-- Owner: full CRUD
CREATE POLICY "payments_owner_all" ON public.payments
  FOR ALL
  TO authenticated
  USING (public.is_owner())
  WITH CHECK (public.is_owner());

-- Staff: read all payments (view_entries permission covers this)
CREATE POLICY "payments_staff_read" ON public.payments
  FOR SELECT
  TO authenticated
  USING (
    public.is_active_staff()
    AND public.has_staff_permission('view_entries')
  );

-- Staff: insert payments (core job, always allowed for active staff)
CREATE POLICY "payments_staff_insert" ON public.payments
  FOR INSERT
  TO authenticated
  WITH CHECK (
    public.is_active_staff()
    AND created_by = auth.uid()
  );

-- Staff: update/delete their own payments
CREATE POLICY "payments_staff_update_own" ON public.payments
  FOR UPDATE
  TO authenticated
  USING (public.is_active_staff() AND created_by = auth.uid());

-- Customer: read only their own payments
CREATE POLICY "payments_customer_read" ON public.payments
  FOR SELECT
  TO authenticated
  USING (customer_id = public.my_customer_id());
