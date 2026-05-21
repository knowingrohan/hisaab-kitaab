-- Add society assignment to staff.
-- One staff member handles one society. Nullable so existing rows are unaffected.
ALTER TABLE public.staff
  ADD COLUMN IF NOT EXISTS society_id uuid REFERENCES public.societies(id) ON DELETE SET NULL;
