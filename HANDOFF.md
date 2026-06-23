# Postmarq — Session Handoff (2026-06-22)

## What was built this session

### My Sites — Builder-tier custom websites
Users can create up to **10 custom sites** hosted at `postmarq.org/:username/:site-name`.

- **viewer.html** — full-screen split-pane editor (left: HTML textarea, right: live iframe preview)
- **rooms table** — stores each site: `id, user_id, username, room_name, html, css, js, published, created_at, updated_at`
- **My Sites card** — sapphire dark (#080d1e) with animated conic-gradient glowing border. Top of right column in my-post.html. Shows site name as clickable link, `● Live / ○ Private` toggle, `Open Editor →` button.
- **Public/private toggle** — `published` boolean on rooms. Unpublished = private placeholder for visitors.
- **Back to profile pill** — on any `/:username/:room` page, `← username` pill bottom-left links back to profile.
- **10 site limit** — enforced in `createNewSite()` before insert.
- **Edit My Post button** — restyled to match sapphire aesthetic (dark bg, blue glow border).

### Widget System
Reusable component framework for profile and office pages.

**Supabase tables:**
- `widget_types` — Postmarq-defined catalog (no RLS): `id, name, description, icon, schema (jsonb)`
- `widgets` — user instances: `id, user_id, widget_type, label, page, position, data (jsonb)`

**Seeded:** `movie-shelf` — Movie & Show Shelf 🎬

**Built in my-post.html:**
- Widget Manager card (right column, below My Sites)
- Widget Library modal — fetches all widget_types from Supabase
- Movie Shelf renderer — horizontal scrollable poster tiles with Seen/Want/Watching badges
- Movie add modal — title, year, type, status, poster URL
- Full CRUD: add widget instance, add items, remove widget

**To add a new widget type:**
1. `INSERT INTO widget_types (id, name, description, icon, schema) VALUES (...)`
2. Add `renderXxx(el, widget)` function in my-post.html
3. Add case in `renderWidgetContent()`

**7 widget concepts designed (not yet built):**
Now Playing (violet), Mood Ring (coral), Guestbook (parchment), Pinboard (pastel), Countdown (electric green), Currently Into (b&w editorial), Visitor Stamp Wall (amber)

### Feed Controls (edit feature, not a widget)
Single-line glass card above the feed composer in the feed column.

- **Audience:** Everyone / Friends / Just Me (`<select>` dropdown)
- **Frequency:** Hour / 12h / Day / Week — controls cache TTL before re-fetch
- **↻ icon** refresh button forces immediate re-fetch
- Prefs saved to `localStorage` keyed to user ID
- "Everyone" fetches all posts joined with profiles; "Friends" filters via friend_requests table
- "Updated X ago" label ticks every 60s

### Backdrop Editor
Owner-only background customization for the profile page.

- **🎨 Backdrop** floating button (fixed bottom-right, owner-only)
- Slide-up panel with: image URL input, Cover/Tile fit toggle, Frost blur slider (0–20px)
- Live preview as you type/adjust
- Frost = blur + proportional white rgba overlay so cards stay readable
- Saves to `profiles`: `bg_image_url`, `bg_blur`, `bg_repeat`
- Loads and applies on every page visit

**New SQL columns added to profiles:**
```sql
alter table public.profiles 
  add column bg_image_url text,
  add column bg_blur integer default 8,
  add column bg_repeat boolean default false;
```

### Mobile / Layout
- Single-column order (< 700px): Profile → My Sites → Feed → My Q → Friends → Candids
- My Sites moved to top of right column

## Current routing (vercel.json)

```
postmarq.org        → redirects to /login
/login              → login.html
/home               → my-post.html
/signup             → signup.html
/:username          → viewer.html (public profile)
/:username/:room    → viewer.html (custom site)
```

## Auth flow — DO NOT BREAK THIS

- `login.html` signs in → redirects to `/home`
- `my-post.html` uses `onAuthStateChange` INITIAL_SESSION event
- No session → shows embedded XP-style overlay login (no redirect)
- Overlay: `overlayLogin()` → `signInWithPassword` → `startApp(session)` directly
- Never redirect my-post.html to /login — causes loops

## Supabase tables (full list)

| Table | Purpose |
|---|---|
| `profiles` | User profile + bg_image_url, bg_blur, bg_repeat |
| `posts` | Feed posts: user_id, body, media (JSONB) |
| `stamps` | Post stamps: post_id, user_id — unique constraint |
| `pick_six` | Friends grid: user_id, slot_index, name, photo_url |
| `candids` | Candid photos: user_id, photo_url |
| `myq` | Loop schedule: user_id, type, label, when_text |
| `messages` | DMs: to_user_id, from_user_id, body |
| `friend_requests` | Connections: from_user_id, to_user_id, status |
| `pages` | Public post pages: username, user_id, html, css, js, display_name |
| `rooms` | Custom sites: username, user_id, room_name, html, css, js, published |
| `widget_types` | Widget catalog (no RLS, Postmarq-defined) |
| `widgets` | User widget instances: user_id, widget_type, page, position, data (jsonb) |

## Next steps (priority order)

1. **Verify Backdrop editor** on live site
2. **Office page** — office.html with widget slots (same widget engine, `page: 'office'`)
3. **Widget types** — Now Playing, Mood Ring, Guestbook, Pinboard, Countdown, Currently Into, Visitor Stamp Wall
4. **Public profiles** — viewer.html `/:username` renders real Supabase profile data
5. **Connections** — "Loop someone in" invite flow
6. **Profile editor** — background themes, color/font customization
7. **Playground** — code sandbox for Builder users
8. **Supabase Storage** — migrate avatar/candids from localStorage

## Supabase credentials
- URL: `https://udlbdccvspxqlzizpkda.supabase.co`
- Anon key: `sb_publishable_co1yq79BF8oR9Mg651DG5w_ESuACdqn`

## Git / deployment
- GitHub repo: `postmarqadmin/postmarq` (main branch)
- Deployed on Vercel (auto-deploys on push to main)
- **git push via terminal is broken** (SSH not configured) — use GitHub Desktop
- After pushing, Vercel deploys in ~30 seconds
