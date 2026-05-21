-- Add staff table to supabase_realtime publication.
-- Without this, stream() subscriptions on the staff table never receive
-- INSERT/UPDATE/DELETE events and the Staff Management screen is not reactive.
DO $$
BEGIN
  IF NOT EXISTS (
    SELECT 1 FROM pg_publication_tables
    WHERE pubname = 'supabase_realtime' AND tablename = 'staff'
  ) THEN
    ALTER PUBLICATION supabase_realtime ADD TABLE public.staff;
  END IF;
END $$;
