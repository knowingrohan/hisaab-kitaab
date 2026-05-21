-- Fix: get_my_role() must be VOLATILE because it contains UPDATE statements
-- STABLE functions cannot perform DML, causing the 0A000 error on first staff/customer sign-in.
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
  SELECT email INTO v_email FROM auth.users WHERE id = auth.uid();

  IF public.is_owner() THEN RETURN 'owner'; END IF;

  IF public.is_active_staff() THEN RETURN 'staff'; END IF;
  IF EXISTS (SELECT 1 FROM public.staff WHERE email = v_email AND is_active = true) THEN
    UPDATE public.staff SET user_id = auth.uid() WHERE email = v_email AND is_active = true;
    RETURN 'staff';
  END IF;

  IF public.my_customer_id() IS NOT NULL THEN RETURN 'customer'; END IF;
  IF EXISTS (SELECT 1 FROM public.customers WHERE email = v_email AND is_active = true) THEN
    UPDATE public.customers SET user_id = auth.uid() WHERE email = v_email AND is_active = true;
    RETURN 'customer';
  END IF;

  RETURN 'unknown';
END;
$$;
