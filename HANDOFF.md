# Postmarq — Session Handoff (2026-06-22)

## What was built this session

### My Sites — Builder-tier custom websites
Users can create up to **10 custom sites** hosted at `postmarq.org/:username/:site-name`. Each site is a full raw HTML canvas with a split-pane editor + live preview.

- **viewer.html** — upgraded with a full-screen split-pane editor (left: single HTML textarea, right: live iframe preview, draggable divider). Replaces the old bottom-panel tabbed editor.
- **rooms table** (new Supabase table) — stores each site: `id, user_id, username, room_name, html, css, js, published, created_at, updated_at`
- **My Sites card** — sapphire dark card with animated conic-gradient glowing border, lives at top of right column in my-post.html. Shows each site as a glowing button, with `● Live / ○ Private` toggle and `edit` link.
- **Public/private toggle** — `published` boolean on rooms table. Unpublished sites show a "This site is private" message to visitors.
- **Back to profile pill** — on any `/:username/:room_name` page, a `← username` pill appears bottom-left linking back to the main profile.
- **10 site limit** — enforced in `createNewSite()` before insert.

### Widget System — architecture + Movie Shelf
A reusable widget framework for the profile and office pages. Users add widgets from a library; each widget instance stores its data as JSON in Supabase.

**New Supabase tables:**
- `widget_types` — Postmarq-defined widget catalog: `id (text slug), name, description, icon, schema (jsonb)`. No RLS (public read, manual insert only).
- `widgets` — user widget instances: `id, user_id, widget_type, label, page ('profile'|'office'), position, data (jsonb), created_at, updated_at`

**Seeded widget type:** `movie-shelf` — Movie & Show Shelf 🎬

**Built in my-post.html:**
- Widget Manager card (right column, below My Sites) with `+ Add Widget` button
- Widget Library modal — shows all widget types from Supabase
- Movie Shelf renderer — horizontal scrollable shelf of poster tiles with status badges (Seen / Want / Watching)
- Movie Shelf add modal — title, year, type, status, optional poster URL
- Full CRUD: add widget, add items to widget, remove widget

**How to add a new widget type later:**
1. `INSERT INTO widget_types (id, name, description, icon, schema) VALUES (...)`
2. Add a `renderXxx(el, widget)` function in my-post.html
3. Add a case for it in `renderWidgetContent()`
Done — it appears in the library for all users automatically.

### UX / Design
- **Edit My Post button** — restyled to match sapphire/My Sites aesthetic (dark background, blue glow border, no emoji). Scales correctly on mobile.
- **Single-column order** (mobile, <700px): Profile → My Sites → Feed → My Q → Friends → Candids
- **My Sites** moved to top of right column (above My Friends)

## Current routing (vercel.json)

```
postmarq.org        → redirects to /login
/login              → login.html (XP-style Windows login UI)
/home               → my-post.html (authenticated profile page)
/signup             → signup.html
/:username          → viewer.html (public profile)
/:username/:room    → viewer.html (custom site — rooms table)
```

## Auth flow — DO NOT BREAK THIS

- `login.html` signs in and redirects to `/home`
- `my-post.html` uses `onAuthStateChange` with `INITIAL_SESSION` event
- If no session: shows XP-style overlay login (embedded in my-post.html, no redirect)
- Overlay login calls `overlayLogin()` → `signInWithPassword` → `startApp(session)` directly
- `my-post.html` does NOT redirect to `/login` — doing so causes redirect loops

## Supabase tables (full list)

| Table | Purpose |
|---|---|
| `profiles` | User profile: full_name, handle, bio, avatar_url, city, hood, relationship_status, stamp, candids_label, custom_fields |
| `posts` | Feed posts: user_id, body, media (JSONB) |
| `stamps` | Post stamps (likes): post_id, user_id — unique constraint |
| `pick_six` | Friends grid: user_id, slot_index, name, photo_url |
| `candids` | Candid photos: user_id, photo_url |
| `myq` | Loop schedule items: user_id, type, label, when_text |
| `messages` | DMs: to_user_id, from_user_id, body |
| `friend_requests` | Connection requests: from_user_id, to_user_id, status |
| `pages` | Public post pages (viewer.html main page): username, user_id, html, css, js, display_name |
| `rooms` | Custom sites: username, user_id, room_name, html, css, js, published |
| `widget_types` | Widget catalog (Postmarq-defined, no RLS) |
| `widgets` | User widget instances: user_id, widget_type, page, position, data (jsonb) |

## What's next (priority order)

1. **Widget: Office page** — build office.html with widget slots (same widget engine, `page: 'office'`)
2. **Widget types to build next** — Music Player, Photo Grid, Link Board, Book Log
3. **Public profiles (viewer.html)** — /:username should render real profile data from Supabase
4. **Connections** — friends table + invite flow ("Loop someone in")
5. **Playground** — code sandbox for Builder users; output feeds into custom sites
6. **Widget marketplace phase 2** — community submissions with review flow
7. **Supabase Storage migration** — move avatar/candids from localStorage to Supabase Storage

## Supabase credentials
- URL: `https://udlbdccvspxqlzizpkda.supabase.co`
- Anon key: `sb_publishable_co1yq79BF8oR9Mg651DG5w_ESuACdqn`

## Git / deployment
- GitHub repo: `postmarqadmin/postmarq` (main branch)
- Deployed on Vercel (auto-deploys on push to main)
- **git push via terminal is broken** (SSH not configured) — use GitHub Desktop to push
- After pushing, Vercel deploys in ~30 seconds
