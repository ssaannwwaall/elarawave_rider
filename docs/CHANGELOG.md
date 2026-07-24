# CHANGELOG.md — ElaraWave Rider App

## [Unreleased]

### v2 redesign — "Deep Water / Clear Surface"
Full visual rewrite superseding the earlier navy/teal design (kept the working API/data/state layer underneath — see `STATE_ARCHITECTURE.md`).
- Downloaded and pixel-sampled the client's real logo (`assets/brand/logo.png`) for the palette instead of estimating hex values; cropped an icon-only `logo-mark.png` (verified transparent background) for use on dark water backgrounds. See `DESIGN_SYSTEM.md`.
- New palette (`elaraBlue`, `aqua`, `marine`, `abyss`, `mineral`, `mist`, `ink`, `amber`, `coral`, etc.), Manrope typography via `google_fonts` with tabular figures for money/quantities, new spacing/radius scale.
- Built the water animation library (`lib/presentation/widgets/water/`): `LiquidCausticsBackground` (hand-authored GLSL shader, `shaders/water_caustics.frag`), `WaveFill`, `WaterDropLoader`, `PurityRipple`; a `MotionConfig` singleton disables all of them live via one flag, synced with the platform's reduce-motion setting.
- Rebuilt Splash, Login, and Home around the two-zone "water header / flat surface" structure, including a rising-water page-wipe transition (`WaterWipeTransition`, a GetX `CustomTransition`) for splash→login, splash→home, and logout.
- Added local-only logout: bottom sheet confirmation, clears `get_storage`, and resets every non-permanent GetX controller (`Get.deleteAll()`) so a fresh login never inherits stale rider state. No token-invalidation endpoint exists yet — documented in `API.md`.
- Home header now carries *today's* Orders/Sold/Cash stats as translucent glass chips (previously a white card below the tabs); non-today date tabs show a "Schedule not published yet" state instead of the backend's `rider_id`-only `todo_list` response.
- Added `flutter_animate` entrance staggers (first ~8 order cards), `shimmer` skeleton loading cards, `visibility_detector` for ticker pausing.
- **Fixed during build:** `FlutterFragCoord()` requires `#include <flutter/runtime_effect.glsl>` and already returns `vec2` (no `.xy`); `WaveFill` needs `TickerProviderStateMixin` (drives two controllers, not one); `LiquidCausticsBackground`/`WaterHeader` needed non-`expand` `Stack` fits to avoid an infinite-height crash inside a `SliverToBoxAdapter`; the zone filter strip never re-rendered because its `Obx` read the `RxList` reference without invoking `.length`/`.toList()`, so GetX never registered a dependency.

### Client feedback: remove bubbles, use the real bottle photo
- **Removed `RisingBubbles` entirely** (file deleted, not just unused) from Splash, Login, and the Home header — it read as carbonation/boiling ("we are not water boiling company"), which is off-brand for a still mineral water product. The caustics shader alone now carries the header's motion.
- **Replaced the hand-drawn splash bottle** (`BottleClipper`, a generic `CustomClipper<Path>` silhouette) with the client's actual product photo (`assets/brand/bottle-premium.png`), per direct feedback ("I never liked the bottle in splash... use bottle-premium in splash also animate that water"). `AnimatedWaterBottle` overlays `WaveFill` directly onto the real bottle's body region, measured against the source image via a grid overlay rather than guessed.

### Real order data from `todo_list`
- Replaced the placeholder/raw-JSON `ToDoOrder` model with the confirmed schema: `ToDoOrder`, `OrderCustomer`, `OrderItem` (`lib/domain/entities/todo_order.dart`, `lib/data/models/todo_order_model.dart`).
- `docs/API.md` updated with the confirmed `orders[]` schema (replacing the old "shape unknown" note) and field-by-field usage notes.
- Rebuilt the Home order card (`lib/presentation/home/widgets/order_list_item.dart`): order number + status badge + time header, customer row with zone tag, call and navigate affordances, compact multi-item summary, amount/received/outstanding row, and an "Empties due" chip.
- `StatusBadge` reworked to key off the machine-readable `order_status` via an extensible color map with a neutral-gray fallback, instead of guessing from a display label — only `ready` is confirmed so far.
- Call action guards against placeholder phone values (e.g. `"+92"`) by requiring ≥10 digits before enabling; added `url_launcher` + iOS `LSApplicationQueriesSchemes` (`tel`) to actually place the call.
- Navigate action is disabled (not hidden) whenever the customer has no `latitude`/`longitude`.
- `delivery_due_date`'s `"0000-00-00"` backend null-placeholder is parsed to `null` and hidden rather than displayed literally.
- Added an `/order-detail/:id` route stub (`lib/presentation/order_detail/order_detail_screen.dart`) so the order card's tap target goes somewhere real; full Order Detail screen remains planned-not-built (see `PROJECT.md`).

### Initial setup
- Created `/docs` with `PROJECT.md`, `API.md`, `DESIGN_SYSTEM.md`, `STATE_ARCHITECTURE.md`, `CHANGELOG.md`.
- Added dependencies: `get`, `dio`, `get_storage`, `intl`.
- Set up Clean Architecture folder structure (`core/`, `domain/`, `data/`, `presentation/`) per `STATE_ARCHITECTURE.md`.
- Built shared design system (colors, text styles, spacing/radius constants) and shared widgets (PrimaryButton, AppTextField, AppCard, StatTile, DateTabChip, ZoneChip, StatusBadge, EmptyState, WaterLoader, IconBadge).
- Built Splash screen with session check and water-drop/wave animation, auto-advances to Login or Home after a minimum display time.
- Built Login screen wired to the real login API (`GET /login`), with local session persistence via `get_storage`, inline error handling, and loading state on the button.
- Built Home screen: date tabs (Today/Tomorrow/+3 days), zone filter chips from `allocated_zones`, summary strip (Orders/Sold/Cash) and search bar wired to `todo_list`, defensive order list item widget, empty state for zero orders, pull-to-refresh.
- Documented all confirmed APIs and explicitly listed pending/TBD endpoints (logout, order status update, proof of delivery, cash collection, push notifications, date-scoped to-do list) so nothing is silently assumed.
