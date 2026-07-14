-- ── Guestbook widget ──────────────────────────────────────────────
-- Run this whole file in the Supabase SQL editor.
--
-- The first response widget: visitors sign the owner's Post. Entries live
-- in their own table (NOT in widgets.data) so a visitor can insert their
-- own signature without write access to the owner's widget row.
--   owner_user_id  = whose Post is being signed
--   author_user_id = who signed (always the signed-in visitor)

create table if not exists public.guestbook (
  id             uuid primary key default gen_random_uuid(),
  owner_user_id  uuid not null references auth.users(id) on delete cascade,
  author_user_id uuid not null references auth.users(id) on delete cascade,
  body           text not null check (char_length(body) <= 280 and char_length(btrim(body)) > 0),
  created_at     timestamptz not null default now()
);
create index if not exists guestbook_owner_idx on public.guestbook (owner_user_id, created_at desc);

alter table public.guestbook enable row level security;

-- Anyone can read a guestbook (it's a public wall).
drop policy if exists "guestbook select" on public.guestbook;
create policy "guestbook select" on public.guestbook
  for select using (true);

-- You can only sign as yourself.
drop policy if exists "guestbook insert own" on public.guestbook;
create policy "guestbook insert own" on public.guestbook
  for insert to authenticated
  with check (author_user_id = auth.uid());

-- The author can remove their own entry; the Post owner can remove any
-- entry left on their book.
drop policy if exists "guestbook delete own-or-owner" on public.guestbook;
create policy "guestbook delete own-or-owner" on public.guestbook
  for delete to authenticated
  using (author_user_id = auth.uid() or owner_user_id = auth.uid());

-- Register the widget type so it appears in the Widget Library.
insert into widget_types (id, name, description, icon, schema)
values ('guestbook', 'Guestbook',
        'Let visitors leave a note on your Post — the analog way.',
        'ti-book', '{}'::jsonb)
on conflict (id) do nothing;
