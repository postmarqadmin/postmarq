-- ═══════════════════════════════════════════════════════════════════
--  POSTMARQ — RUN-ALL MIGRATION BUNDLE
--  Paste this ENTIRE file into the Supabase SQL editor and hit Run.
--  Safe to run more than once (every statement is idempotent).
--  Covers: comments, My Q public read, invite links, Lounge read-state.
-- ═══════════════════════════════════════════════════════════════════


-- ─── 1. POST REPLIES / COMMENTS (140-char) ─────────────────────────
create table if not exists public.comments (
  id         uuid primary key default gen_random_uuid(),
  post_id    uuid not null references public.posts(id) on delete cascade,
  user_id    uuid not null references auth.users(id) on delete cascade,
  body       text not null check (char_length(body) <= 140 and char_length(btrim(body)) > 0),
  created_at timestamptz not null default now()
);
create index if not exists comments_post_id_idx on public.comments (post_id);
alter table public.comments enable row level security;

drop policy if exists "comments select" on public.comments;
create policy "comments select" on public.comments
  for select to authenticated using (true);

drop policy if exists "comments insert own" on public.comments;
create policy "comments insert own" on public.comments
  for insert to authenticated with check (auth.uid() = user_id);

drop policy if exists "comments delete own" on public.comments;
create policy "comments delete own" on public.comments
  for delete to authenticated using (auth.uid() = user_id);


-- ─── 2. MY Q PUBLIC READ ───────────────────────────────────────────
drop policy if exists "Users can view own myq items" on myq;
drop policy if exists "Public can read public myq items" on myq;
create policy "Public can read public myq items" on myq
  for select
  using (
    coalesce(visibility, 'public') <> 'private'
    or auth.uid() = user_id
  );


-- ─── 3. INVITE LINKS ("Loop someone in") ───────────────────────────
create table if not exists invites (
  id           uuid primary key default gen_random_uuid(),
  from_user_id uuid not null references auth.users(id) on delete cascade,
  created_at   timestamptz not null default now()
);
alter table invites add column if not exists code text unique;
alter table invites add column if not exists note text;
alter table invites add column if not exists status text not null default 'pending';
alter table invites add column if not exists used_by uuid references auth.users(id);
alter table invites enable row level security;

drop policy if exists "insert own invites" on invites;
create policy "insert own invites" on invites
  for insert to authenticated
  with check (from_user_id = auth.uid());

drop policy if exists "read own invites" on invites;
create policy "read own invites" on invites
  for select to authenticated
  using (from_user_id = auth.uid());

create or replace function get_invite(invite_code text)
returns table (inviter_name text, inviter_handle text, inviter_avatar text, note text, status text)
language sql
security definer
set search_path = public
as $$
  select p.full_name, p.handle, p.avatar_url, i.note, i.status
  from invites i
  join profiles p on p.id = i.from_user_id
  where i.code = invite_code;
$$;

create or replace function claim_invite(invite_code text)
returns json
language plpgsql
security definer
set search_path = public
as $$
declare
  inv invites;
  inviter_profile profiles;
begin
  select * into inv from invites where code = invite_code and status = 'pending';
  if inv.id is null then
    return json_build_object('ok', false, 'reason', 'invalid_or_used');
  end if;
  if inv.from_user_id = auth.uid() then
    return json_build_object('ok', false, 'reason', 'own_invite');
  end if;

  update invites set status = 'accepted', used_by = auth.uid() where id = inv.id;

  if exists (
    select 1 from friend_requests
    where (from_user_id = inv.from_user_id and to_user_id = auth.uid())
       or (from_user_id = auth.uid() and to_user_id = inv.from_user_id)
  ) then
    update friend_requests set status = 'accepted'
    where (from_user_id = inv.from_user_id and to_user_id = auth.uid())
       or (from_user_id = auth.uid() and to_user_id = inv.from_user_id);
  else
    insert into friend_requests (from_user_id, to_user_id, status)
    values (inv.from_user_id, auth.uid(), 'accepted');
  end if;

  select * into inviter_profile from profiles where id = inv.from_user_id;
  return json_build_object(
    'ok', true,
    'inviter_name', inviter_profile.full_name,
    'inviter_handle', inviter_profile.handle
  );
end;
$$;

grant execute on function get_invite(text) to anon, authenticated;
grant execute on function claim_invite(text) to authenticated;


-- ─── 4. LOUNGE READ-STATE (durable unread) ─────────────────────────
create table if not exists lounge_reads (
  user_id      uuid not null references auth.users(id) on delete cascade,
  room_id      uuid not null references lounge_rooms(id) on delete cascade,
  last_read_at timestamptz not null default now(),
  primary key (user_id, room_id)
);
alter table lounge_reads enable row level security;

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

-- ─── 5. GUESTBOOK WIDGET ───────────────────────────────────────────
create table if not exists public.guestbook (
  id             uuid primary key default gen_random_uuid(),
  owner_user_id  uuid not null references auth.users(id) on delete cascade,
  author_user_id uuid not null references auth.users(id) on delete cascade,
  body           text not null check (char_length(body) <= 280 and char_length(btrim(body)) > 0),
  created_at     timestamptz not null default now()
);
create index if not exists guestbook_owner_idx on public.guestbook (owner_user_id, created_at desc);
alter table public.guestbook enable row level security;

drop policy if exists "guestbook select" on public.guestbook;
create policy "guestbook select" on public.guestbook
  for select using (true);

drop policy if exists "guestbook insert own" on public.guestbook;
create policy "guestbook insert own" on public.guestbook
  for insert to authenticated
  with check (author_user_id = auth.uid());

drop policy if exists "guestbook delete own-or-owner" on public.guestbook;
create policy "guestbook delete own-or-owner" on public.guestbook
  for delete to authenticated
  using (author_user_id = auth.uid() or owner_user_id = auth.uid());

insert into widget_types (id, name, description, icon, schema)
values ('guestbook', 'Guestbook',
        'Let visitors leave a note on your Post — the analog way.',
        'ti-book', '{}'::jsonb)
on conflict (id) do nothing;


-- ═══════════════════════════════════════════════════════════════════
--  Done. Also confirm (one-time, safe to re-run):
--    alter publication supabase_realtime add table lounge_messages;
--  If it errors "already member", that's fine — it's already enabled.
-- ═══════════════════════════════════════════════════════════════════
