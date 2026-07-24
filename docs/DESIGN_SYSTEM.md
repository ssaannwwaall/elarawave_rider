# DESIGN_SYSTEM.md — ElaraWave Rider App

**Direction: "Deep Water / Clear Surface."** A rider is a working professional clearing a queue under time pressure, often outdoors in Lahore sunlight — not a consumer browsing a lifestyle app. The design reads as a precision instrument, not a dashboard:

- **Upper zone — "the water":** a deep marine gradient with a live water-surface effect (caustics, rising bubbles) behind the header content. This is where the brand emotion lives.
- **Lower zone — "the surface":** near-white, high-contrast, zero decoration. The order list. Text is dark-on-light, large, legible at arm's length in direct sun. No animation, no gradients, no glass behind the list.

The contrast between the two zones *is* the design. Source of truth in code: `lib/core/theme/`.

## Color Palette — sampled from the real logo, not guessed

`assets/brand/logo.png` (the client's own export from elarawave.com) was pixel-sampled via a clustering script during development, rather than eyeballing hex values. The dominant opaque, saturated colors found:

| Sampled hex | H / S / V | Where in the mark |
|---|---|---|
| `#0060A8` | 206° / 100% / 66% | The wave's vivid blue |
| `#24C0D8` | 188° / 83% / 85% | The wave's bright cyan highlight |
| `#184870` | 205° / 79% / 44% | The wordmark's own navy ink (most common cluster) |
| `#408848` | 128° / 53% / 53% | The tagline's leaf green |

Final palette (`lib/core/theme/app_colors.dart`), built from those samples:

| Token | Hex | Source | Usage |
|---|---|---|---|
| `elaraBlue` | `#0062AA` | sampled `#0060A8` | Primary brand blue, buttons, gradient |
| `aqua` | `#22C3E6` | sampled `#24C0D8` | Highlights, caustics, active tab/chip fill |
| `marine` | `#0F4468` | sampled `#184870`/`#0C486C` blend | Header gradient mid-stop, wipe-transition color |
| `abyss` | `#05243F` | extrapolated (same hue as `marine`, pushed darker) | Header gradient deep stop — the logo never gets this dark since it sits on white, so this is the one token without a literal sample |
| `foam` | `#CFEFFA` | tint of `aqua` | Light tint on dark backgrounds, tinted chip fills |
| `mineral` | `#2E8B4E` | sampled `#408848`, brightened slightly for UI legibility | Success/delivered/collected states |
| `mineralLight` | `#6BC47D` | tint of `mineral` | Reserved for future use (e.g. a lighter delivered fill) |
| `snow` | `#FFFFFF` | — | Card surfaces |
| `mist` | `#F4F8FB` | — | Screen background (surface zone) |
| `line` | `#E3EBF2` | — | Hairlines, card borders |
| `ink` | `#0D1B2A` | — | Primary text |
| `inkMuted` | `#5A6C7D` | — | Secondary text |
| `inkFaint` | `#93A4B3` | — | Placeholders, disabled |
| `amber` | `#F2A93B` | — | Pending / ready status |
| `coral` | `#E8544E` | — | Cancelled / overdue balance |

Header gradient: `abyss → marine → elaraBlue`, ~160°, with the `LiquidCausticsBackground` shader layered on top at low-to-moderate intensity (see `ANIMATION.md`).

## Logo assets

- `assets/brand/logo.png` — the full client export (mark + navy wordmark + green tagline), kept for reference/provenance.
- `assets/brand/logo-mark.png` — the icon only (droplet + wave), cropped from the full export via alpha-bbox detection so it can sit directly on the dark water zones. Verified transparent background (`getpixel` alpha == 0 at all four corners) — no white box around it.
- The wordmark ("ELARA WAVE" / "FLOW WITH FRESHNESS") is set in the app's own type (`ElaraLogo` widget), not the logo file's baked-in navy text — that text is illegible against the dark water backgrounds it's mostly shown on.
- `assets/brand/bottle-premium.png` — the splash screen's hero visual (`AnimatedWaterBottle`), used directly per client direction: an earlier version avoided it in favor of a hand-drawn bottle silhouette, reasoning the marketing composite (mineral badges, lemon slice, splash graphics) would clash with the minimal aesthetic — the client overrode that call on review ("use bottle-premium in splash... I like them") and disliked the hand-drawn version outright. `WaveFill` now overlays directly onto the real photo's body region (measured via a grid overlay, see `ANIMATION.md` §3), rather than masking a drawn shape.
- `assets/brand/bottle-refill.webp` — downloaded, not currently used in the 3-screen scope.

## Typography

**Manrope** throughout, via `google_fonts` (`lib/core/theme/app_text_styles.dart`). Because Manrope needs runtime construction (not `const`), the scale is exposed as methods, not fields — e.g. `AppTextStyles.h1(color: ...)`, not `AppTextStyles.h1`.

| Style | Size / Line height | Weight | Usage |
|---|---|---|---|
| `display` | 32 / 38 | 700 | Splash wordmark, big stat values |
| `h1` | 24 / 30 | 700 | Screen titles |
| `h2` | 20 / 26 | 600 | Section headers |
| `title` | 17 / 22 | 600 | Order number, customer name |
| `body` | 15 / 22 | 400 | General text |
| `label` | 13 / 18 | 500 | Field labels, tab text |
| `caption` | 11 / 14 | 600, letter-spacing 0.6 | Badges, uppercase meta |

`AppTextStyles.tabular(style)` layers `FontFeature.tabularFigures()` onto any style used for money/quantity/count values, so digits occupy fixed-width slots and don't jitter when a refresh lands (order amounts, header stats, item quantities).

## Spacing & Geometry

- Spacing scale: `4, 8, 12, 16, 20, 24, 32` → `xs, sm, md, lg, xl, xxl, xxxl`.
- Radius: `button` 16, `chip` 14, `card` 20, `sheet` 28 (top corners only — bottom sheets, the login card), `pill` 999.
- Cards: 1px `line` border **first**, soft shadow **second** (`ink @ 6%`, blur 20, y-offset 6) — reads cleaner and cheaper than a heavy shadow alone.
- Minimum tap target: 48×48 everywhere (`AppSpacing.minTapTarget`) — riders tap with thumbs, sometimes wet or gloved.

## Components (`lib/core/widgets/`)

- **PrimaryButton** — flat `elaraBlue` fill (the surface zone stays clean/flat by design; gradients live only in the water header), 56 tall, `button` radius. Loading state sweeps a `WaveFill` left-to-right instead of a spinner.
- **AppTextField** — `mist` fill, `line` border, `elaraBlue` border + focus state, `button` radius, password show/hide toggle.
- **AppCard** — `snow` surface, `card` radius, border-first shadow.
- **HeaderStatChip` / `HeaderStatsRow`** — translucent glass chips (white-on-white-alpha) for the Orders/Sold/Cash stats that live directly on the water header; tabular figures.
- **DateTabChip** — `chip` radius; selected = `elaraBlue` fill + white text; unselected = `mist` fill + `inkMuted` text + hairline. Triggers a `PurityRipple` on tap-down.
- **ZoneChip** — pill; selected = `foam` fill + `elaraBlue` text + `elaraBlue` border; unselected = `mist` + `inkMuted` + hairline.
- **StatusBadge** — pill, color keyed off the machine-readable `order_status` via an **extensible map**, not a closed enum — an unrecognized status renders with a neutral-`inkMuted` fallback instead of breaking. Only `ready` (→ `amber`, per the brief's status palette) is confirmed; `mineral`/`coral`/`amber` are reserved for delivered/cancelled/pending once those keys are confirmed.
- **EmptyState** — still (non-animated) glyph in an `foam` circle, title, optional subtitle and text-button action ("Retry"/"Refresh"). Motion is reserved for loading, not steady-state empties.
- **OrderCardSkeleton** — `shimmer`-based skeleton card, three shown while the to-do list loads (not a spinner).
- **IconBadge** — circular tinted background + icon, background/icon color passed in by the caller.

## Water animation

See `ANIMATION.md` for the full water-effect system (`LiquidCausticsBackground`, `WaveFill`, `RisingBubbles`, `WaterDropLoader`, `PurityRipple`) and the rising-water page-wipe transition.
