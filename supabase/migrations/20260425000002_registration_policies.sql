-- Phase 8: Allow self-registration for new users
-- Any authenticated user (including UnknownRole) can:
--   1. Read societies (to populate the registration dropdown)
--   2. Insert a pending customer record for themselves

-- Widen societies read to any authenticated user (society names are not sensitive)
DROP POLICY IF EXISTS "societies_others_read" ON public.societies;
CREATE POLICY "societies_authenticated_read" ON public.societies
  FOR SELECT
  TO authenticated
  USING (true);

-- Allow a signed-in user to self-register as a pending customer.
-- is_active must be false so they cannot act as a customer until owner approves.
-- user_id must equal auth.uid() so users can only insert their own record.
CREATE POLICY "customers_self_register" ON public.customers
  FOR INSERT
  TO authenticated
  WITH CHECK (user_id = auth.uid() AND is_active = false);

-- Allow a pending/active customer to read their own record.
-- (The existing customers_self_read policy already handles this if user_id matches,
--  but adding explicit coverage for pending customers here for clarity.)
-- Note: customers_self_read already exists, so no duplicate needed.
