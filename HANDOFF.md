# POSTMARQ — SESSION HANDOFF
*For Claude Code | Built by Dave Michael, User #1*

---

## WHAT THIS IS
Postmarq is a personal web platform built for genuine human connection. Single static HTML/CSS/JS files. Built with Claude Code. Backend: Supabase (auth + user metadata). Deployed via GitHub → Vercel (auto-deploy on push).

## PROJECT LOCATION
- **Home feed:** `/Users/davecontreras/postmarq/index.html`
- **Office page:** `/Users/davecontreras/postmarq/office.html`
- **Living Room:** `/Users/davecontreras/postmarq/living-room.html`
- **Lounge:** `/Users/davecontreras/postmarq/lounge.html`
- **Playground (onboarding proto):** `/Users/davecontreras/postmarq/playground.html`
- **Signup:** `/Users/davecontreras/postmarq/signup.html`
- **Login:** `/Users/davecontreras/postmarq/login.html`
- **My Post (user dashboard):** `/Users/davecontreras/postmarq/my-post.html`
- Assets: `/Users/davecontreras/postmarq/`
- Biz page assets: `/Users/davecontreras/postmarq/biz page/`

## HOW TO DEPLOY
Git push to GitHub → Vercel auto-deploys (~30 sec).
Push from VS Code Source Control panel → "Commit & Push" dropdown.
Local preview: Live Server in VS Code → http://127.0.0.1:5500

---

## SUPABASE
- **Project URL:** `https://vzvgqkxhhjubylojhohn.supabase.co`
- **Anon key:** `sb_publishable_JFEpFZi63RZja2WorNkBdQ_L3E4mZ6q`
- **Auth:** Email + password via `client.auth.signUp()` / `signInWithPassword()`
- **User metadata:** `full_name` stored in `user.user_metadata.full_name`
- **No database tables yet** — all user content saved to localStorage keyed by `currentUser.id`

---

## GIT LOG
```
65091b1 — Add profile editor, composer, and post feed to my-post.html
6c1f4c7 — Add beta signup login and post pages (login.html, signup.html, my-post.html)
1522153 — Initial Postmarq commit (all assets + playground.html)
14d26ff — Add Lounge page and fix cross-tab post rendering
4f69bf3 — Update HANDOFF.md for new session
c76b5a3 — Add Reddit widget, redesign clock, fix news feed names
```

---

## CSS VARIABLES (shared palette)

### Dark theme (index, living-room, office, lounge)
- `--bg: #0f0f14`, `--w-bg: #1e1e28`, `--w-head: #17171f`, `--w-border: rgba(255,255,255,0.07)`
- `--accent: #9b8fd4` (purple), `--teal: #4ab5aa`, `--amber: #e8992a`
- `--ink / --ink-2 / --ink-3` (white at decreasing opacity)
- `--font: 'Nunito', sans-serif`

### Light/warm theme (signup, login, my-post, playground)
- `--glass-white: rgba(255,255,255,0.52)`, `--glass-border: rgba(255,255,255,0.75)`
- `--amber: #e8992a`, `--amber-light: #f5c462`, `--amber-pale: #fef3d8`
- `--teal: #4ab5aa`, `--lavender: #9b8fd4`
- `--ink: #26180e`, `--ink-2: #5a3e28`
- Body background: `linear-gradient(135deg, #f5d5a0 0%, #e8aa60 40%, #c87840 100%)`

CDNs: Tabler Icons, Nunito (Google Fonts), GridStack v10, Supabase JS v2

---

## USER ACCOUNT FLOW (signup → login → my-post)

### signup.html
- Fields: Name, Email, Password (min 8 chars)
- Calls `client.auth.signUp()` with `full_name` in metadata
- On success: shows "Check your email to confirm" message
- Supabase sends a confirmation email before login is allowed
- Links to `/login.html`

### login.html
- Fields: Email, Password
- Calls `client.auth.signInWithPassword()`
- On success: redirects to `/my-post.html`
- Links to `/signup.html`

### my-post.html — USER DASHBOARD (owner mode only for now)
- Checks Supabase session on load; redirects to `/login.html` if not logged in
- `IS_OWNER = true` for anyone logged in (no visitor view differentiation yet)
- **Profile card:** shows name (from metadata or localStorage), postmarq handle, bio
  - "Edit Profile" button opens modal → saves name + bio to `localStorage[pm_profile_${user.id}]`
- **Composer:** textarea → "Post" button or Cmd+Enter → saves to `localStorage[pm_posts_${user.id}]`
- **Feed:** renders posts newest-first with timestamp + delete button (owner only)
- **Log out:** calls `client.auth.signOut()` → redirects to `/login.html`

### localStorage keys (per user, keyed by Supabase user.id)
- `pm_profile_${user.id}` — `{ name, bio }`
- `pm_posts_${user.id}` — array of `{ id, text, name, ts }`

---

## NEXT SESSION GOAL: SIGNUP → MY POST REVISIONS

Dave wants to improve the full new-user journey from account creation through having an editable Post. Priority areas:

1. **signup.html** — review UX, copy, field order. Does it feel right for Postmarq's tone?
2. **login.html** — same check. Any friction to reduce?
3. **my-post.html** — the big one. Right now it has:
   - Profile card with Edit Profile modal (name + bio)
   - Composer + post feed
   - Placeholder widget grid (4 "coming soon" widgets that do nothing)
   - What should the widget grid actually let users do/add?
   - What does a visitor (not logged in) see? Currently: redirected to login. Should they see a read-only Post instead?
4. **Owner vs Visitor mode** — currently all logged-in users see owner mode. Need to build:
   - A way to view your Post as a visitor would see it ("Preview as visitor" toggle)
   - Eventually: public URL for a Post that anyone can visit

### Decisions to make next session
- What widgets should users be able to add to their Post? (Reference: index.html has Pick Six, Candids, My Q, Marquee, etc.)
- Should visitors be able to see my-post.html without logging in? If yes, what do they see?
- Does the signup flow need more steps (like the playground.html 6-screen onboarding) or keep it simple?

---

## INDEX.HTML — HOME FEED (Dave Michael's personal Post)

**Design:** Windows XP / Frutiger Aero — frosted glass, warm amber/lavender gradients
**Layout:** 280px left col / 1fr right col

### Left column (top → bottom):
1. **My Post Card** — profile module, MySpace-style. Teal/lavender frosted glass. Meta: Phoenix AZ, Uptown PHX, In a Relationship 1yr, Last Update Jun 11 2026. Current Stamp: `Stamp_odesza.png`.
2. **My Q** — schedule module. Header: live day number + day name (purple→blue gradient) + "My Q" title (purple→amber gradient). Two types: Loops (purple) / Invites (amber). localStorage `myqItems`.
3. **My Pick Six** — 3×2 friend portrait grid. Friends in `/friends/`.
4. **Candids Wall** — 430px, 3-row grid of 24 candid photos/videos, internal scroll.
5. **The Marquee** — movie tracking, 3 tabs (Recently Watched / Watchlist / Must Watch). TMDB API: `8aa40129d309ada1f40a0145f66c1068`.
6. **Neighborhood** — Phoenix AZ card.

### Right column:
- **Composer** — avatar + auto-expanding textarea. Photo/Video/Link toolbar. Link preview via Microlink API.
- **Tab bar** — Daily / Weekly (default) / My Yearbook
- **Permanent posts** hardcoded in HTML (newest first).

### localStorage:
- `posts` — dynamic posts (JSON with base64 media + optional link object)
- `myqItems` — My Q loop/invite items

---

## OFFICE.HTML — OFFICE PAGE

### Profile Header:
- Full-width photo left (`biz page/biz profile.jpg`, 200px wide)
- Bio info right (name, title, bio summary)
- **Biz card tile** — spotlight on click. Options: "Add to Rolodex" / "Request to Connect"

### Message Row: Avatar + text input + send button + Send Business Card button
### Right column: Portfolio/Socials bar, Education, Skills & Tools (tabbed), Clients & Projects

---

## LIVING-ROOM.HTML — LIVING ROOM

### Tech Stack: GridStack.js v10, drag/resize grid, Edit mode via gear icon

### Widget Types (12):
| Type | Key feature |
|------|------------|
| `clock` | Date left + time right (purple→amber gradient) + My Q items from localStorage |
| `weather` | Open-Meteo API, Phoenix lat=33.4484 lon=-112.0740, 3-day forecast |
| `gmail` | Seed data only — OAuth not implemented |
| `youtube` | Persistent URL bar; iframe; info cover; autoplay OFF |
| `friendfeed` | Mock friend post feed |
| `im` | AOL IM-style mock messages |
| `quicknotes` | Auto-save textarea |
| `newsfeed` | RSS via rss2json; NPR / The Verge / ESPN |
| `reddit` | r/popular/hot.rss default; configurable URL |
| `neighborhood` | Mock Postmarq neighbor activity |
| `snake` | Playable Snake game |

### Seed Layout (LAYOUT_VERSION = 3):
clock x:0 y:0 w:3 h:2 | weather x:3 y:0 w:3 h:3 | gmail x:6 y:0 w:6 h:3
youtube x:0 y:2 w:6 h:5 | friendfeed x:6 y:3 w:6 h:5 | im x:6 y:8 w:6 h:3
quicknotes x:0 y:7 w:2 h:3 | neighborhood x:2 y:7 w:4 h:2
newsfeed x:0 y:11 w:4 h:3 (NPR) | newsfeed x:4 y:11 w:4 h:3 (Verge) | newsfeed x:8 y:11 w:4 h:3 (ESPN)
reddit x:0 y:14 w:6 h:5

---

## PLAYGROUND.HTML — ONBOARDING PROTOTYPE
- 6-screen flow: Choose path → fork → setup form → confirmation → Loop someone in → welcome
- Three paths: Personal (free) / Builder (power user) / Business ($12/mo placeholder)
- **Front-end only — nothing saves, no backend wired**
- Paused pending finances + backend setup

---

## KNOWN GAPS / NEXT STEPS
- **my-post.html visitor mode** — logged-out users redirected to login; no public Post view yet
- **Widget grid on my-post.html** — 4 placeholder tiles do nothing; needs real widget options
- **Gmail widget** — needs Google OAuth + hosted domain
- **My Q → Living Room sync** — clock reads myqItems but only set on index.html
- **All user data in localStorage** — no server persistence yet
- **Office biz card flow** — fully client-side mock
- **Supabase email confirmation** — new signups must confirm email before login works

---

## DAVE MICHAEL — PERSONAL DETAILS
Phoenix, AZ · Photographer, video creator · Dog: Trixton (goldendoodle)
Tagline: "Here to make real connections while learning how to code. Welcome to Postmarq."
Interests: Movies, Photography, Adventure, Trixton, Phoenix
