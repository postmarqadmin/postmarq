-- My Q public read policy (2026-07-03)
-- Bug: visitors couldn't see anyone else's loops on public profiles (viewer.html).
-- The myq SELECT policy only allowed owners to read their own rows, so other
-- users / logged-out visitors always got an empty list.
--
-- This lets anyone read non-private items, while owners still see everything.
-- (Private items stay owner-only; legacy rows with NULL visibility count as public.)

DROP POLICY IF EXISTS "Users can view own myq items" ON myq;
DROP POLICY IF EXISTS "Public can read public myq items" ON myq;

CREATE POLICY "Public can read public myq items" ON myq
  FOR SELECT
  USING (
    COALESCE(visibility, 'public') <> 'private'
    OR auth.uid() = user_id
  );
