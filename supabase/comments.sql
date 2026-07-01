-- Postmarq: post replies / comments (140-char limit, original Twitter)
-- Run once in the Supabase SQL editor.

create table if not exists public.comments (
  id         uuid primary key default gen_random_uuid(),
  post_id    uuid not null references public.posts(id) on delete cascade,
  user_id    uuid not null references auth.users(id) on delete cascade,
  body       text not null check (char_length(body) <= 140 and char_length(btrim(body)) > 0),
  created_at timestamptz not null default now()
);

create index if not exists comments_post_id_idx on public.comments (post_id);

alter table public.comments enable row level security;

-- Anyone signed in can read replies
create policy "comments select" on public.comments
  for select to authenticated using (true);

-- You can only add replies as yourself
create policy "comments insert own" on public.comments
  for insert to authenticated with check (auth.uid() = user_id);

-- You can only delete your own replies
create policy "comments delete own" on public.comments
  for delete to authenticated using (auth.uid() = user_id);
