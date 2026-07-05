-- ── Lounge read-state ─────────────────────────────────────────────
-- Run this whole file in the Supabase SQL editor.
--
-- Tracks, per user, the last time they read each Lounge room. This is the
-- durable source of truth for "unread" — before this, unread lived only in
-- memory and reset to zero every time the Lounge window closed. With it:
--   • the Lounge sidebar shows unread that survives across sessions
--   • my-post.html can show per-friend unread badges WITHOUT the Lounge open
--   • opening/viewing a conversation clears its notification everywhere

create table if not exists lounge_reads (
  user_id      uuid not null references auth.users(id) on delete cascade,
  room_id      uuid not null references lounge_rooms(id) on delete cascade,
  last_read_at timestamptz not null default now(),
  primary key (user_id, room_id)
);

alter table lounge_reads enable row level security;

-- Each user manages only their own read markers.
drop policy if exists "read own read-state" on lounge_reads;
create policy "read own read-state" on lounge_reads
  for select to authenticated
  using (user_id = auth.uid());

drop policy if exists "upsert own read-state" on lounge_reads;
create policy "upsert own read-state" on lounge_reads
  for insert to authenticated
  with check (user_id = auth.uid());

drop policy if exists "update own read-state" on lounge_reads;
create policy "update own read-state" on lounge_reads
  for update to authenticated
  using (user_id = auth.uid())
  with check (user_id = auth.uid());
