# Widget Vault

An archive of widget designs for Postmarq — specced but not yet built. When one gets built, move its entry to the "Shipped" section at the bottom with a date.

## Widget philosophy

Every widget idea gets sorted through three lenses before it earns a build:

1. **Display widgets** (I show you something) — identity. Necessary, but passive.
2. **Response widgets** (you can react on my page) — guestbook, polls, Q&A. Conversation bait. A guestbook is worth ten movie shelves. Every display widget gets better with a tiny response affordance bolted on ("me too," "I've been there").
3. **Tending widgets** (they visibly go stale if ignored) — freshness signals presence. A mood set 3 weeks ago says something. Show "updated X ago" as a norm, not a shame mechanic.

Tiering (non-tech / moderate / advanced) should also happen *within* widgets, not just across them: simple defaults, an "advanced" flap underneath. The advanced user customizes the same guestbook the non-tech user uses.

Hard rule inherited from the platform: widget `data` is per-user JSONB — a widget can never change anyone else's page or settings.

Structural prerequisite for most of these: **viewer.html does not render widgets for visitors yet.** Visitor-facing widgets are the whole point — wire this first or alongside the first response widget.

---

## ★ Common Thread — the connector widget

**One sentence:** Opt-in widget that, once a week, shows you one person on Postmarq who shares one of your threads (plain-text interest tags), and shows them you.

### The experience

- **Setup (once):** add the widget, type 3–5 threads you'd actually want to talk to a stranger about (`sourdough starter`, `Phoenix`, `NBA Jam`). Autocomplete suggests existing threads with counts ("`coffee` · 4 people") — nudges spelling convergence AND doubles as a map of what the community cares about. Adding the widget IS the opt-in.
- **Monday morning:** the widget shows one person — name, avatar, and the single shared thread. Nothing else. "You and Maria both tend a sourdough starter." Maria sees you. Always mutual, always symmetric.
- **During the week:** two actions — visit their Post, or leave a stamp as a wave. (Later maybe: one icebreaker prompt referencing the thread.) No chat inside the widget; the Lounge exists. The widget opens the door, it doesn't furnish the room.
- **Next Monday:** new match. Old one fades into a private "threads past" history. No streaks, no scores, no match-rate. The widget cannot be won.

### Why each constraint matters

- **Weekly, not daily** — long enough to actually visit someone's page, short enough to stay alive.
- **One person, not a list** — one name is a person; five names is an inbox people will rank.
- **Thread is the headline, not the person** — gives both people a reason and a first sentence.
- **No metrics anywhere** — no engagement optimization, ever. Fits "the platform succeeds when you close it."

### Matching mechanics

**Recommended: small Postgres function (Option B).**
- Table `thread_matches` (`week`, `user_a`, `user_b`, `thread`; unique per user per week).
- One SECURITY DEFINER function `compute_week_matches()`: first page-load after Monday 00:00 triggers it; it checks whether this week's rows exist; if not, computes all pairs once and inserts. Everyone else reads stored facts — no drift.
- Inside: seed = ISO year+week; walk threads in deterministic order (rarest first — matching two falconers matters more than the 40th and 41st coffee people); for each thread, collect opted-in not-yet-matched users, sort ids, seeded shuffle, pair adjacent. Everyone gets at most one match per week.
- Same paste-into-SQL-editor workflow as comments.sql / invites.sql.

**Alternative considered: pure client-side deterministic (Option A).** Every client computes identical matches from the same seed — no server at all. Rejected because the pool isn't stable mid-week (opt-ins/outs shift pairs computed later); patchable (snapshot cutoff + lock-in on first render) but Option B stores facts instead of recomputing opinions.

### Small-community honesty

- Empty threads are invitations: "No one shares `falconry` yet — your thread is waiting."
- Avoid back-to-back repeat partners; beyond that, embrace repeats: "You and Charlie again — the thread insists."
- Odd person out in a thread rests that week (multi-thread membership usually catches them elsewhere).
- Unmatched/paused states are first-class UI, not error states. Pause toggle = "resting," costs nothing, signals nothing.

### Privacy / safety

- Threads are public-ish by design — shown on the profile as identity chips (display duty even in unmatched weeks).
- The match itself is private by default (only the two people know).
- Blocks respected at match time — blocked pairs never get computed.
- Opt-in only; removing the widget removes you from the pool.

### Build inventory

- `widget_types` row: `common-thread`
- widget `data`: `{ threads: [...], paused: false }`
- `supabase/common_thread.sql`: `thread_matches` table + `compute_week_matches()` + RLS (users read own matches) + public-read policy on this widget type's rows (powers autocomplete counts)
- Render function + dispatch line in my-post.html
- Threads-as-chips rendering in viewer.html (needs visitor widget rendering wired)

---

## Vault: non-tech tier (fill in a blank, tap a button)

- **Mood Ring** — one tap sets today's color/mood. The tending widget in its purest form.
- **Three Things** — three tiny slots: photo + caption. Rotates whenever they feel like it.
- **Countdown / Counting Up** — "12 days until the Dbacks opener" / "437 days since I quit smoking." Identity-revealing for one text field of effort.
- **The Usual** — your regular order, spot, route. ("Cortado, La Bendición, the corner table.") Pure locality flavor.

## Vault: moderate tier (curate a small collection)

- **Guestbook** — visitors sign it. Highest-value widget on this list; ship first among these.
- **Mixtape** — 5–8 songs in deliberate order with liner notes. A gift to the visitor; more intentional than Now Playing.
- **Been There / Going There** — places list/map; visitors tap "me too."
- **Ask Me Anything** — owner posts one prompt; visitors submit questions; owner answers publicly. Response widget disguised as display.

## Vault: advanced tier (wants a challenge)

- **The Workbench** — raw HTML/CSS/JS sandbox rendering in a sandboxed iframe as a widget card. My Sites machinery at widget scale. Builder-tier velvet rope.
- **Pixel Stamp Studio** — draw a 16×16 personal stamp on a pixel grid; becomes the stamp you leave on friends' posts. Creation tool + identity + travels to other pages without touching their settings.
- **Theme Lab** — sliders/pickers generating CSS variables for your own page (extends Backdrop editor), with a "view CSS" escape hatch that teaches. The bridge from moderate to advanced.

## Earlier concepts (pre-vault, from 2026-06 sessions)

Now Playing (SHIPPED), Movie Shelf (SHIPPED), Mood Ring, Guestbook, Pinboard, Countdown, Currently Into, Visitor Stamp Wall.

## Suggested build order

1. Guestbook (connection value, easy; forces visitor widget rendering in viewer.html)
2. Mood Ring (tending habit, trivial)
3. Common Thread (the differentiator — refuses to scale, which is the point)
4. Workbench (for the builders)

## Shipped

- **Movie Shelf** (`movie-shelf`) — 2026-06
- **Now Playing** (`now-playing`) — 2026-06
