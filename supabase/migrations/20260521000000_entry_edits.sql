-- =============================================================================
-- Entry Edits: audit trail for pickup entry modifications
-- =============================================================================

-- Add edit_count column to track how many times an entry has been edited
ALTER TABLE entries ADD COLUMN edit_count int NOT NULL DEFAULT 0;

-- Audit table: one row per save operation
CREATE TABLE entry_edits (
  id                 uuid PRIMARY KEY DEFAULT gen_random_uuid(),
  entry_id           uuid REFERENCES entries(id) ON DELETE CASCADE NOT NULL,
  edited_by          uuid REFERENCES auth.users(id) NOT NULL,
  edited_by_name     text NOT NULL,
  edited_at          timestamptz DEFAULT now() NOT NULL,
  amount_before      int NOT NULL,
  amount_after       int NOT NULL,
  description_before text,
  description_after  text,
  date_before        date NOT NULL,
  date_after         date NOT NULL
);

CREATE INDEX idx_entry_edits_entry_id ON entry_edits (entry_id);
CREATE INDEX idx_entry_edits_edited_at ON entry_edits (edited_at DESC);

-- Trigger: keep entries.edit_count in sync
CREATE OR REPLACE FUNCTION increment_entry_edit_count()
RETURNS TRIGGER LANGUAGE plpgsql SECURITY DEFINER AS $$
BEGIN
  UPDATE entries SET edit_count = edit_count + 1 WHERE id = NEW.entry_id;
  RETURN NEW;
END;
$$;

CREATE TRIGGER on_entry_edit_inserted
  AFTER INSERT ON entry_edits
  FOR EACH ROW EXECUTE FUNCTION increment_entry_edit_count();

-- =============================================================================
-- Row Level Security
-- =============================================================================
ALTER TABLE entry_edits ENABLE ROW LEVEL SECURITY;

-- Owner: full access
CREATE POLICY "entry_edits_owner_all" ON entry_edits
  FOR ALL
  TO authenticated
  USING (is_owner())
  WITH CHECK (is_owner());

-- Staff: read-only (they can see edit history on entries they can view)
CREATE POLICY "entry_edits_staff_read" ON entry_edits
  FOR SELECT
  TO authenticated
  USING (is_active_staff());

-- Customer: read history for their own entries only
CREATE POLICY "entry_edits_customer_read" ON entry_edits
  FOR SELECT
  TO authenticated
  USING (
    entry_id IN (
      SELECT id FROM entries WHERE customer_id = my_customer_id()
    )
  );

-- =============================================================================
-- Realtime
-- =============================================================================
ALTER PUBLICATION supabase_realtime ADD TABLE entry_edits;
