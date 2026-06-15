# POSTMARQ — SESSION HANDOFF
*For Claude Code | Built by Dave Michael, User #1*

---

## WHAT THIS IS
Postmarq is a personal web platform built for genuine human connection. Single static HTML/CSS/JS files. Built with Claude Code.

## PROJECT LOCATION
- **Home feed:** `/Users/davecontreras/postmarq/index.html`
- **Office page:** `/Users/davecontreras/postmarq/office.html`
- **Living Room:** `/Users/davecontreras/postmarq/living-room.html`
- Assets: `/Users/davecontreras/postmarq/`
- Biz page assets: `/Users/davecontreras/postmarq/biz page/`
- Business card image: `Biz card_v1.png`
- Biz profile photo: `biz page/biz profile.jpg`

## HOW TO RUN
Live Server in VS Code → http://127.0.0.1:5500
Git initialized at `/Users/davecontreras/postmarq/`.

---

## GIT LOG
```
c76b5a3 — Add Reddit widget, redesign clock, fix news feed names
170835a — Fix news feeds, YT info cover, and disable autoplay
bb89c64 — Add Living Room widget grid, redesign Office page layout
e0be7ad — Add Jun 12 Postmarq updates post to Daily, Weekly, and Yearbook
b276463 — Simplify composer, add link preview, remove Posts header
891f615 — Add Introducing My Q post to Daily, Weekly, and Yearbook
296805c — Add My Q module, remove Stamps/Quorum/Guestbook, Pick Six polish, profile card updates
```

---

## CSS VARIABLES (shared palette)
- `--bg: #0f0f14`, `--w-bg: #1e1e28`, `--w-head: #17171f`, `--w-border: rgba(255,255,255,0.07)`
- `--accent: #9b8fd4` (purple), `--teal: #4ab5aa`, `--amber: #e8992a`
- `--ink / --ink-2 / --ink-3` (white at decreasing opacity)
- `--font: 'Nunito', sans-serif`
- CDNs: Tabler Icons, Nunito (Google Fonts), GridStack v10

---

## INDEX.HTML — HOME FEED

**Design:** Windows XP / Frutiger Aero — frosted glass, warm amber/lavender gradients
**Layout:** 280px left col / 1fr right col

### Left column (top → bottom):
1. **My Post Card** — profile module, MySpace-style. Teal/lavender frosted glass. Meta: Phoenix AZ, Uptown PHX, In a Relationship 1yr, Last Update Jun 11 2026. Current Stamp: `Stamp_odesza.png`. Contacting Dave (6 action links).
2. **My Q** — schedule module (dark card `rgba(26,26,31,0.90)`). Header: live day number (large) + day name (purple→blue gradient) + "My Q" title (purple→amber gradient) + "loop schedule" subtitle. Two types: Loops (purple `#7F77DD`) / Invites (amber `#EF9F27`). Private dot. Collapse/expand. Detail/edit modal. localStorage `myqItems`. Seed: 5 items.
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

### Profile Header (`.office-card`):
- Full-width photo left (`biz page/biz profile.jpg`, 200px wide, `object-fit:cover`)
- White 3px vertical divider
- Bio info right (name, title, bio summary)
- **Biz card tile** — bottom-right corner of photo, shows `Biz card_v1.png` spotlight on click. Options: "Add to Rolodex" / "Request to Connect". localStorage: `pm_rolodex`, `pm_connect_requested`, `pm_connect_requests`, `pm_dave_in_rolodex`

### Message Row (below bio summary):
- Avatar + text input + send button + **Send Business Card** button (inline, one row)
- Business card modal: two-path flow — if `pm_my_card` exists → quick confirm; else → form to fill out. Sends to `pm_pending_cards`.
- `IS_OWNER = true` shows incoming cards panel + rolodex panel

### Right column (top → bottom):
1. **View My Portfolio & Socials** — non-clickable bar with icon buttons: LinkedIn, Instagram, Facebook, Portfolio
2. **Education** — collapsible
3. **Skills & Tools** — tabbed (Skills tab / Tools & Technology tab)
4. **Clients & Projects** — collapsible

### Company logos:
- Cactus Shadows: `biz page/Cactus Shadows.jpg`
- Luxium Creative: `biz page/Luxium Creative.jpeg`

---

## LIVING-ROOM.HTML — LIVING ROOM

### Tech Stack:
- **GridStack.js v10** (`gridstack@10/dist/gridstack-all.js`) — drag/resize grid
- Layout seeded from `SEED_LAYOUT` (version 3), persisted in `pm_lr_layout` / `pm_lr_layout_v`
- Edit mode: gear icon toggles `grid.setStatic(false)`, drag handle = `.widget-header`
- Column picker: 1/2/3 maps to GridStack columns 2/6/12 via `COL_MAP`

### Widget Types (11):
| Type | Key feature |
|------|------------|
| `clock` | My Q-style: date left (day num, day name purple→blue, month), time right (no seconds, purple→amber gradient), Loop Schedule items below from `myqItems` |
| `weather` | Open-Meteo API, Phoenix lat=33.4484 lon=-112.0740, WMO codes, 3-day forecast |
| `gmail` | Seed data only — live OAuth not yet implemented |
| `youtube` | Persistent URL bar at bottom always visible; iframe above; info cover hides on idle (`.yt-info-cover` fades on hover); autoplay OFF |
| `friendfeed` | Friend post feed (mock data) |
| `im` | AOL IM-style messages (mock) |
| `quicknotes` | Auto-save textarea → `pm_lr_note_${id}` |
| `newsfeed` | RSS via rss2json (no `&count` param); purple→teal gradient header; custom names by URL via `RSS_NAMES` lookup (NPR News Feed, The Verge News Feed, ESPN News Feed) |
| `reddit` | `r/popular/hot.rss` default; rss2json fetch; shows thumbnail, title, `r/subreddit`, author, date; configurable URL in settings → `pm_lr_rd_${id}` |
| `neighborhood` | Mock Postmarq neighbor activity |
| `snake` | Playable Snake game |

### Seed Layout (LAYOUT_VERSION = 3):
```
clock        x:0 y:0  w:3 h:2
weather      x:3 y:0  w:3 h:3
gmail        x:6 y:0  w:6 h:3
youtube      x:0 y:2  w:6 h:5
friendfeed   x:6 y:3  w:6 h:5
im           x:6 y:8  w:6 h:3
quicknotes   x:0 y:7  w:2 h:3
neighborhood x:2 y:7  w:4 h:2
newsfeed     x:0 y:11 w:4 h:3  (NPR)
newsfeed     x:4 y:11 w:4 h:3  (The Verge)
newsfeed     x:8 y:11 w:4 h:3  (ESPN)
reddit       x:0 y:14 w:6 h:5  (r/popular)
```

### Key localStorage keys:
- `pm_lr_layout` / `pm_lr_layout_v` — grid layout
- `pm_lr_cols` — column choice (1/2/3)
- `pm_lr_rss_${id}` — newsfeed RSS URL per widget
- `pm_lr_rd_${id}` — reddit feed URL per widget
- `pm_yt_vid_${id}` — last YouTube video ID
- `pm_lr_note_${id}` — quicknotes content
- `pm_my_card` — user's saved business card
- `pm_pending_cards` — incoming cards queue
- `pm_rolodex` — accepted cards
- `pm_dave_in_rolodex` — whether viewer added Dave's card

### YouTube notes:
- `extractYTId()` handles `youtube.com/watch`, `/live/`, `youtu.be`, `/embed/`, bare 11-char IDs
- Default video: `EqaDNODFIHM`
- Autoplay is OFF (`?autoplay=0`)

### RSS notes:
- rss2json.com works without `&count` param (free tier rejects it)
- corsproxy.io blocks ESPN and The Verge — use rss2json as primary
- Reddit requires rss2json (reddit.com blocks direct fetch)

---

## KNOWN GAPS / NEXT STEPS
- **Gmail widget** — needs Google OAuth + Google Cloud project + hosted domain (not file://). User asked about connecting real Gmail. Plan: OAuth client ID → hosted page → fetch unread + threads via Gmail API.
- **Reddit widget header** — could get the purple→teal gradient treatment like news feed headers
- **My Q → Living Room sync** — clock widget reads `myqItems` from localStorage but it's set on index.html; items won't appear unless user visits home first
- **Living Room persistence backend** — currently all localStorage, no server
- **Office biz card flow** — fully client-side mock; no real card sending

---

## DAVE MICHAEL — PERSONAL DETAILS
Phoenix, AZ · Photographer, video creator · Dog: Trixton (goldendoodle)
Tagline: "Here to make real connections while learning how to code. Welcome to Postmarq."
Interests: Movies, Photography, Adventure, Trixton, Phoenix

---

## PHASE 2 IDEAS
- Identity & address system
- The Directory (opt-in discovery)
- City Hall (settings/privacy)
- The Square (local community feed)
- My Q neighborhood feed — showing neighbors' Loops/Invites
- Real Gmail OAuth integration
- Backend persistence (My Q, posts, rolodex)
- Business profiles (e.g. Zia Records posting their own Loops/Invites)
- Rename My Q module per user personality
