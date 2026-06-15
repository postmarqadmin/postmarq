# POSTMARQ — SESSION HANDOFF
*For Claude Code | Built by Dave Michael, User #1*

---

## WHAT THIS IS
Postmarq is a personal web platform built for genuine human connection. Single static HTML/CSS/JS file. Built with Claude Code.

## PROJECT LOCATION
- Main file: `/Users/davecontreras/postmarq/index.html`
- Assets: `/Users/davecontreras/postmarq/`
- Candids: `/Users/davecontreras/postmarq/candids/`
- Friends: `/Users/davecontreras/postmarq/friends/`
- Videos: `dbacks.MOV` in root
- Images: `MyQ.png`, `Stamp_odesza.png`, `post_01x.JPG`, `Profile Pic_01x.JPG`

## HOW TO RUN
Live Server in VS Code → http://127.0.0.1:5500
Git initialized. Save: `git add index.html && git commit -m "..."`. Rollback: `git checkout index.html`.

---

## CURRENT PAGE LAYOUT

**Top bar** — sticky Postmarq banner (purple-to-teal gradient), nav links: home · search · browse · invite · help · logout

**Two-column main layout** — 280px left / 1fr right

### Left column (280px fixed), top to bottom:

1. **My Post Card** — MySpace-style profile module. Photo + Dave Michael. Meta fields: My Townsquare: Phoenix, AZ / My Hood: Uptown PHX / In a Relationship: 1 Year / Last Update: June 11, 2026. My Marq bio. Current Stamp (Stamp_odesza.png). Contacting Dave (6 action links). Teal/lavender frosted glass gradient.

2. **My Q** — Schedule module. Dark background `rgba(26,26,31,0.90)`. Header: live date (large day number, day name in purple→blue gradient, month/year) + "My Q" title (purple→amber gradient) + "loop schedule" subtitle. Two post types: **Loops** (purple accent bar, recurring habits) and **Invites** (amber accent bar, specific events). Private items show "P" dot. Collapsed to 3 items, "+ see more (n)" expands. × removes item. Click item body → detail/edit modal (view mode + edit mode + delete). "+ Add" button → create modal (type, title, when/cadence, details, visibility). localStorage persistence. Module title stored in `MYQ_TITLE_VAR` for future renaming. Seeded with 5 items: Canal walk with Trixton (Loop/public), Zia Records browse (Loop/public), Game night (Invite/private), Luci's coffee (Loop/public), Chase Field — Diamondbacks (Invite/public).

3. **My Pick Six** — 3×2 grid of 6 friend portraits (3×4 aspect ratio). Same lavender→teal glass background as Post Card. Amber-accented tile borders with hover scale. Names below each tile. Friends: Charlie, Keller, Tom, Trixton, Camille Jeff, Sunny Rich. Images in `/friends/` folder.

4. **Candids Wall** — 430px height, 3-row grid of 24 candid photos/videos, internal scroll, teal/lavender gradient.

5. **The Marquee** — Movie tracking, THREE tabs (Recently Watched / Watchlist / Must Watch). Carousel with large poster (140×210px). TMDB API key: `8aa40129d309ada1f40a0145f66c1068`. DVD shelf aesthetics.

6. **Neighborhood** — Phoenix AZ card, The Square link.

### Right column (1fr):

**Composer** (always visible, above tab bar) — avatar (sized to match single textarea line height) inline with auto-expanding textarea ("What's on your mind?"). No Post/Quorum toggle, no "New post" label. Toolbar below textarea: 📷 Photo, 🎬 Video, 🔗 Link, Post button. Link button reveals a URL input; fetches preview via YouTube thumbnail shortcut or Microlink API (free, no key). Preview renders as a clickable card with image, domain, title, description. Link data saved with post and re-rendered on load.

**Tab bar** (below composer) — Daily / Weekly / My Yearbook. **Weekly is the default active tab**.

- **Daily tab** — dynamic feed (localStorage) + permanent posts below
- **Weekly tab** — posts grouped by day with thumbnails. Days: Thu Jun 12, Wed Jun 11, Tue Jun 10, Sun Jun 8
- **My Yearbook tab** — 3 stat cards (47 stamps / 24 candids / 6 films) + 3-col tile grid

**Permanent posts (hardcoded, newest first):**
- Updates to Postmarq: composer redesign, link preview, My Q subtitle, tab bar move, and Posts header removal. — June 12, 2026
- Introducing My Q — MyQ.png — June 11, 2026
- My new stamp. What it does... IDK. Need ideas! — Stamp_odesza.png — June 10, 2026
- D-backs walk-off homerun vs Dodgers [3-2] — dbacks.MOV — June 10, 2026
- My first post on Postmarq! — post_01x.JPG — June 8, 2026

*(Quorum post and Guestbook have been removed)*

---

## FILM DATA
- FILMS_SEEN (6): Backrooms (2023) 4★, Masters of the Universe (2025) 4★, Obsession (2024) 4★, Send Help (2025) 3★, The Cider House Rules (1999) 4★, Driving Miss Daisy (1989) 3★
- FILMS_WANT (4): Disclosure Day, The Odyssey (2025), Supergirl: Woman of Tomorrow (2026), Spider-Man: Brand New Day
- FILMS_MUST (1): Obsession (2024) 4★ — featured with amber glow

---

## LOCALSTORAGE
Posts saved as JSON with base64 media and optional `link` object `{ url, title, description, image, domain, ytId? }`. My Q items saved under `myqItems`. Both load on page start.

## p\ SKILL
Type `p\` to create a new permanent post. Asks for text + media + date, inserts directly into HTML above the newest post. Also add to Weekly and Yearbook manually.

## KEYBOARD SHORTCUT
`p` key focuses composer textarea.

---

## DESIGN SYSTEM
- Aesthetic: Windows XP / Frutiger Aero — frosted glass, warm gradients, soft blur
- Font: Nunito (Google Fonts) + Tabler Icons (CDN)
- Background: warm amber/lavender radial gradient, fixed
- Cards: `backdrop-filter: blur(18px)`, white glass border, warm shadow
- Colors: `--amber: #e8992a`, `--teal: #4ab5aa`, `--lavender: #9b8fd4`, `--ink: #26180e`
- Tab bars: `linear-gradient(90deg, rgba(78,58,160,0.97), rgba(50,150,142,0.97))`, active tab = amber gradient
- My Q dark card: `rgba(26,26,31,0.90)`, Loop accent `#7F77DD`, Invite accent `#EF9F27`

## DAVE MICHAEL — PERSONAL DETAILS
Phoenix, AZ · Photographer, video creator · Dog: Trixton (goldendoodle)
Tagline: "Here to make real connections while learning how to code. Welcome to Postmarq."
Interests: Movies, Photography, Adventure, Trixton, Phoenix

---

## GIT LOG
```
e0be7ad — Add Jun 12 Postmarq updates post to Daily, Weekly, and Yearbook
b276463 — Simplify composer, add link preview, remove Posts header
891f615 — Add Introducing My Q post to Daily, Weekly, and Yearbook
296805c — Add My Q module, remove Stamps/Quorum/Guestbook, Pick Six polish, profile card updates
ffd2ee0 — Add My Pick Six module to left column
8dabf03 — Three-tab feed + weekly/yearbook visual polish
2f175fb — Layout flip, Post Card to left col, persistence, new posts
39695c1 — Post Card, Marquee DVD shelf, Candids Wall, site banner
```

---

## PHASE 2 IDEAS
- Identity & address system
- The Directory (opt-in discovery)
- City Hall (settings/privacy)
- The Square (local community feed)
- My Q neighborhood feed — showing neighbors' Loops/Invites
- Stamp interaction on Loops (signal interest without committing)
- Business profiles (e.g. Zia Records posting their own Loops/Invites)
- My Q persistence via backend
- Rename My Q module per user personality
- Real stamp image (cactus in baseball cap, PNG 200×200px)
