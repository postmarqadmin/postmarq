-- ── Invite links ("Loop someone in") ─────────────────────────────
-- Run this whole file in the Supabase SQL editor.
--
-- Flow: inviter generates a code → texts the link (postmarq.org/login?invite=CODE)
-- → friend sees "X looped you in" on the login page → signs up →
-- claim_invite() marks the invite used AND creates an accepted friendship.
-- No email sending needed anywhere.

create table if not exists invites (
  id           uuid primary key default gen_random_uuid(),
  from_user_id uuid not null references auth.users(id) on delete cascade,
  created_at   timestamptz not null default now()
);

-- `invites` already existed on this project from an OLDER, email-based invite
-- feature (to_email) that predates "Loop Someone In" — create table if not
-- exists was a no-op against it, so the code-link columns below never got
-- added. Bring it up to date without touching existing rows. `code` is added
-- as UNIQUE but nullable (not NOT NULL) since old rows have no code value and
-- multiple NULLs are fine in a unique column; every new row the app inserts
-- always supplies one (see createInviteLink() in my-post.html).
alter table invites add column if not exists code text unique;
alter table invites add column if not exists note text;
alter table invites add column if not exists status text not null default 'pending';
alter table invites add column if not exists used_by uuid references auth.users(id);
-- to_email is unused by the current app code — left in place, harmless.

alter table invites enable row level security;

-- Inviter can create and see their own invites. Nobody else can read the
-- table directly — lookups by code go through get_invite() below, so the
-- table can't be enumerated.
drop policy if exists "insert own invites" on invites;
create policy "insert own invites" on invites
  for insert to authenticated
  with check (from_user_id = auth.uid());

drop policy if exists "read own invites" on invites;
create policy "read own invites" on invites
  for select to authenticated
  using (from_user_id = auth.uid());

-- Look up an invite by code (works logged-out, for the login-page banner).
-- SECURITY DEFINER so it bypasses RLS but only returns one row for an exact
-- code match — unguessable codes make this safe.
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

-- Claim an invite as the logged-in user: marks it used and creates an
-- ACCEPTED friendship with the inviter (both users see each other as
-- friends immediately — the whole point of a personal invite).
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

  -- Upgrade an existing request in either direction, else create accepted
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
