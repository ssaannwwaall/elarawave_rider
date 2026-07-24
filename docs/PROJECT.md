# PROJECT.md — ElaraWave Rider App

## Project Name
**ElaraWave Rider App**

## Brand
**Elara Wave** — "Flow With Freshness" / "Drink Pure. Live Better." A real mineral & alkaline water supply company based in Lahore, Pakistan (elarawave.com). Products: plain mineral & alkaline water in 19L/5L/1.5L/500ml, plus custom branded PET bottles. Head office: Gondal Heights Plaza, 60 Broadway Commercial, Paragon City, Barki Road, Lahore Cantt. UAN 111-999-444. Service areas (matching the `allocated_zones` API's real zone names): Paragon City, DHA (all phases), Barki Road, Green City, Askari 10 & 11, Air Avenue, Park View, Divine Garden, Johar Town, Gulberg.

This app is one of four planned client apps:
1. Customer App
2. Sales / Salesman App
3. **Delivery / Rider App** ← this project
4. Admin App

## Purpose
The Rider App is a field tool for delivery riders, used dozens of times a day on mid-range Android phones, often in direct sunlight. A rider logs in, sees the delivery **zones** allocated to them, and works through a **to-do list of orders** for a given day (today / tomorrow / next 3 days). It is a work-queue app, not a consumer-facing dashboard — priorities are speed, thumb-reachability, and outdoor legibility.

## Design Direction
**"Deep Water / Clear Surface"** — a deliberate break from the Customer App's soft pastel dashboard look. A dark, animated water-effect header (brand emotion, real GLSL caustics shader) sits above a flat, high-contrast, static work surface (the order list). See `DESIGN_SYSTEM.md` and `ANIMATION.md` for the full system and rationale.

## Tech Stack
- **Flutter** (stable channel, null-safety)
- **State management:** GetX (`get` package) — controllers, bindings, reactive `.obs` state, named routes, `CustomTransition` for the rising-water page wipe
- **Architecture:** Clean Architecture — `presentation/` / `domain/` / `data/` layers
- **Networking:** `dio` wrapped in a single `ApiClient`
- **Local persistence:** `get_storage` — stores logged-in rider session only (temporary, until a real auth token endpoint exists)
- **Typography:** Manrope via `google_fonts`
- **Animation:** hand-authored GLSL fragment shader (`shaders/water_caustics.frag`) + `CustomPainter`/`AnimationController` water widgets, `flutter_animate` for micro-interactions, `shimmer` for skeleton loaders, `visibility_detector` for ticker pausing
- **Language:** Dart, null safety throughout

## Target Platforms
- Android
- iOS

## Current Scope (this session)
Built and wired to real APIs:
- **Splash screen** — session check, `LiquidCausticsBackground` + `WaveFill`-filled bottle silhouette + rising bubbles, auto-advance (min 2.0s / max 3.5s)
- **Login screen** — username/password against the real login API, local session persistence, dev-only credential prefill, shake-on-error, network-vs-credentials error distinction
- **Home screen** — water header (greeting, avatar, logout, today's Orders/Sold/Cash stats), Today/Tomorrow/+3-days date tabs, zone filter, search, order list with loading/empty/error/"schedule not published" states, pull-to-refresh with a custom `WaterDropLoader` indicator, and a local-only logout flow

Reusable design system (colors sampled from the real client logo, typography, spacing, shared widgets, the four-widget water animation library) built alongside these screens so future screens can build on them without rework.

## Planned, Not Built Yet
These screens/flows are intentionally **out of scope** for this session. Routes/nav targets may exist as stubs, but no real UI or logic has been built:
- **Order Detail screen** — route stub exists (`/order-detail/:id`, `lib/presentation/order_detail/order_detail_screen.dart`) and the Home order card's tap target is wired to it, but it currently just shows a "coming soon" placeholder. Planned content/actions for when it's built:
  - Full item list (unit price / line amount / empty bottles received per line)
  - **Mark Delivered** action (no order-status-update API yet — see `API.md` "Pending/TBD")
  - **Record cash collection** action (no API yet)
  - **Proof of delivery** capture (no API yet)
  - Customer notes (`notes` field already parsed, not yet surfaced anywhere)
  - `customer.last_days` ("last ordered N days ago" hint)
- Navigate / Map screen — the order card has a Navigate icon (disabled when the customer has no lat/long), but tapping it currently just shows a placeholder toast; no real map screen exists yet.
- Earnings & Wallet screen
- Today's Summary / Performance screen
- Profile screen
- Notifications screen (the header bell is a non-functional placeholder)
- Order status update, proof of delivery, cash collection (no APIs documented yet — see `API.md` "Pending/TBD")
- Date-scoped to-do list — the backend only supports `rider_id` on `todo_list` today; non-today date tabs show a "Schedule not published yet" state rather than faking future-day data (see `API.md` "Known gap")

## Explicitly Out of Scope / Guardrails
- No fake/mock order data — the empty/"not published" states are real, not placeholders for missing work.
- `rider_id` is never hardcoded outside the auth/session layer — always read from the persisted logged-in rider.
- The Rider home screen does **not** copy the Customer app's home layout (hydration ring, product hero, rewards card) — it is a work queue, not a consumer dashboard.
- **Logout is purely local** — no token/session-invalidation endpoint exists yet. It clears `get_storage` and resets every non-permanent GetX controller (`Get.deleteAll()`) so a fresh login never inherits a previous rider's zone/order state. See `API.md` "Pending".
- No action button is ever wired to a fake success response — where an API doesn't exist yet (mark delivered, cash collection, proof of delivery), the affordance is either omitted or rendered visibly disabled with a reason (e.g. the Navigate icon when geo is missing).
