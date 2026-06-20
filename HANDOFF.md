# Postmarq — Session Handoff (2026-06-20)

## What was built this session

The new user signup and profile experience was rebuilt from scratch:

- **my-post.html** — full 3-column MySpace-style profile page (left: profile/My Q, center: composer/feed, right: Pick Six/Candids). This is the authenticated home for every user.
- **Supabase tables** — `posts` and `stamps` tables created (old posts table renamed `posts_legacy`). Posts and stamps are fully in Supabase.
- **signup.html** — creates a default profile row in Supabase on signup.
- **Auth flow** — resolved a persistent redirect loop. See critical notes below.

## Current routing (vercel.json)

```
postmarq.org       → redirects to /login
/login             → login.html (XP-style Windows login UI)
/home              → my-post.html (authenticated profile page)
/signup            → signup.html
/:username         → viewer.html (public profile — currently placeholder)
```

## Auth flow — DO NOT BREAK THIS

This took many hours to get right. The key insight:

- `login.html` signs in and redirects to `/home`
- `my-post.html` uses `onAuthStateChange` with `INITIAL_SESSION` event — NOT `getSession()` alone
- If no session on `INITIAL_SESSION`: shows XP-style overlay login (embedded HTML in my-post.html)
- Overlay login calls `overlayLogin()` → `signInWithPassword` → `startApp(session)` **directly, no page navigation**
- `my-post.html` does NOT redirect to `/login` when no session — it shows the overlay instead
- Any redirect loop between login.html and my-post.html will break everything

## What's stored where

**Supabase:**
- `profiles` table: id, full_name, handle, bio
- `posts` table: id, user_id, body, media (JSONB base64 array), created_at
- `stamps` table: id, post_id, user_id — unique(post_id, user_id)

**localStorage (temporary — needs migration):**
- `pm_${userId}_profile` — avatarUrl (base64), city, hood, relationship, stamp emoji
- `pm_${userId}_pickSix` — array of Pick Six friends
- `pm_${userId}_candids` — array of candid photo objects
- `pm_${userId}_myq` — array of My Q loop schedule items

## Next steps (in priority order)

### 1. Public profiles (`viewer.html`)
Currently shows a placeholder "Hello, neighbor." It needs to:
- Read the username from the URL path (e.g. `/davemichael`)
- Look up the profile in Supabase `profiles` table by `handle` field
- Fetch that user's posts from the `posts` table
- Render a read-only version of the 3-column profile layout
- Show a "stamp" button for logged-in visitors (inserts into `stamps` table)
- If the viewer is the owner, redirect to `/home`

### 2. Connections / "Loop someone in"
- Create a `connections` table in Supabase: `id, requester_id, recipient_id, status, created_at`
- Build an invite flow: user enters email → Postmarq sends invite → recipient signs up → connection created
- Show connected friends in Pick Six slots and Lounge

### 3. Move media to Supabase Storage
Currently avatars and candid photos are stored as base64 strings in localStorage. This will hit browser storage limits quickly.
- Create a Supabase Storage bucket: `avatars`, `candids`
- Update `uploadAvatar()` in my-post.html to upload to Supabase Storage
- Store the public URL in the `profiles` table instead of localStorage
- Same pattern for candids

### 4. Move My Q items to Supabase
- Add a `myq` table: `id, user_id, day, time, label, created_at`
- Update `renderMyQ()` and related functions in my-post.html to read/write Supabase

## Supabase credentials
- URL: `https://vzvgqkxhhjubylojhohn.supabase.co`
- Anon key: `sb_publishable_JFEpFZi63RZja2WorNkBdQ_L3E4mZ6q`

## Git / deployment
- GitHub repo: `postmarqadmin/postmarq` (main branch)
- Deployed on Vercel (auto-deploys on push to main)
- **git push via terminal is broken** (SSH not configured) — use GitHub Desktop to push
- After pushing, Vercel deploys in ~30 seconds
