-- Co-owners: additional accounts with owner-level access (useful for testing / multi-admin)
-- is_owner() is extended to check this table so all existing RLS policies work automatically.

CREATE TABLE IF NOT EXISTS public.co_owners (
  id         uuid  PRIMARY KEY DEFAULT gen_random_uuid(),
  email      text  NOT NULL UNIQUE,
  created_at timestamptz NOT NULL DEFAULT now()
);

-- Only the primary owner can manage co-owners
ALTER TABLE public.co_owners ENABLE ROW LEVEL SECURITY;

CREATE POLICY "co_owners_primary_owner_all" ON public.co_owners
  FOR ALL
  TO authenticated
  USING (
    EXISTS (SELECT 1 FROM public.app_config WHERE owner_uid = auth.uid())
  )
  WITH CHECK (
    EXISTS (SELECT 1 FROM public.app_config WHERE owner_uid = auth.uid())
  );

-- Co-owners can read their own row (so the function can resolve their role)
CREATE POLICY "co_owners_self_read" ON public.co_owners
  FOR SELECT
  TO authenticated
  USING (
    email = (SELECT email FROM auth.users WHERE id = auth.uid())
  );

-- Update is_owner() to also match co-owners by email
CREATE OR REPLACE FUNCTION public.is_owner()
RETURNS boolean
LANGUAGE sql
SECURITY DEFINER
STABLE
SET search_path = public
AS $$
  SELECT
    -- Primary owner: matched by UID
    EXISTS (SELECT 1 FROM public.app_config WHERE owner_uid = auth.uid())
    OR
    -- Co-owner: matched by email
    EXISTS (
      SELECT 1 FROM public.co_owners
      WHERE email = (SELECT email FROM auth.users WHERE id = auth.uid())
    )
$$;

-- Seed: first co-owner for testing
INSERT INTO public.co_owners (email) VALUES ('santhefresh@gmail.com')
ON CONFLICT (email) DO NOTHING;
