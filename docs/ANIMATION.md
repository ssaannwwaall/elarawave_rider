# ANIMATION.md — ElaraWave Rider App

The water animation system for the "Deep Water / Clear Surface" design (see `DESIGN_SYSTEM.md`). Reusable widgets in `lib/presentation/widgets/water/`, each independently usable and independently disableable via a single flag.

## Guiding idea

The client's ask: the animation should communicate that the water is genuinely *pure* — clarity, light, stillness-with-life. Not splashing, not cartoonish, not busy. Motion lives in the water header; the order list below it is static by design — the contrast between the two zones is the point.

**Revision (client feedback, live review):** the original brief called for a `RisingBubbles` particle effect (fine bubbles drifting upward). In practice this read as *carbonation/boiling* — "we are not water boiling company" — which is exactly wrong for a still-mineral-water brand. It has been **removed entirely** (the widget file is deleted, not just unused) from Splash, Login, and the Home header. The caustics shader alone now carries the water header's motion — a slow, waving ripple rather than rising dots. Life without evaporation.

The same review also rejected the splash screen's hand-drawn bottle silhouette ("baby work... I never liked the bottle in splash") in favor of the real product photography the client supplied — see §2.

---

## 1. `LiquidCausticsBackground` (`liquid_caustics_background.dart`)

The hero effect — a GLSL fragment shader (`shaders/water_caustics.frag`) rendering layered, domain-warped value noise as caustic light patterns (the rippling net of light on a pool floor), with a vertical light gradient and a touch of chromatic separation on the highlights to sell refraction.

- **Uniforms:** `uResolution` (vec2), `uTime` (float), `uIntensity` (float, 0–1), `uColorDeep` (vec4), `uColorLight` (vec4).
- **Budget:** 2–3 noise octaves only (see the shader's `fbm()` loop) — this runs behind headers all day on mid-range phones.
- **Loaded via** `ui.FragmentProgram.fromAsset`, wrapped in try/catch. On any failure (missing asset, compile error on an unexpected platform) it falls back to a static `AppColors.waterGradient` `DecoratedBox` — the screen never crashes or shows a blank surface.
- **Ticker discipline:** the raw `Ticker` only runs when *all* of: `MotionConfig.motionEnabled`, the widget is visible (via `visibility_detector`), and `WidgetsBinding.instance.lifecycleState == resumed`. It reacts live to `MotionConfig.reduceMotion` changes via `ever(...)`, not just at creation — toggling motion off pauses every already-mounted instance immediately.
- **Where used:** Splash (full screen), Login (top 45%), Home header (~200px). No particle effect layered on top of it any more (see the bubbles-removal note above) — the caustic ripple alone carries the water's motion.

### A note on `FlutterFragCoord()`

Impeller's fragment shaders require `#include <flutter/runtime_effect.glsl>` before `FlutterFragCoord()` is available, and unlike GLSL's `gl_FragCoord` (`vec4`), Flutter's version already returns a plain `vec2` — no `.xy` swizzle needed. Both were compile-time errors caught during development; see the shader file's top for the include.

## 2. `WaveFill` (`wave_fill.dart`)

Two superimposed sine waves (different amplitude/frequency/phase-speed) filling a container from the bottom up to `progress` (0.0–1.0) — a lighter translucent wave behind a more opaque one. Pure `CustomPainter`, no dependencies.

- **Used for:** the animated water tint inside the splash bottle (see `AnimatedWaterBottle` below), the login button's loading sweep.
- Two `AnimationController`s (phase looping, level animating toward the target `progress`) — the widget mixes in `TickerProviderStateMixin` (not `SingleTickerProviderStateMixin`) specifically because it drives two controllers at once.
- Reacts live to `MotionConfig` the same way as the caustics background.

## 3. `AnimatedWaterBottle` (`presentation/splash/widgets/animated_water_bottle.dart`)

The splash screen's hero visual: the client's own product photo (`assets/brand/bottle-premium.png`, downloaded from elarawave.com) with `WaveFill` overlaid directly onto the bottle's own body — not a hand-drawn silhouette.

- The overlay rect (`_left`/`_right`/`_top`/`_bottom`, as fractions of the 500×500 source image) was measured against the real image via a grid overlay during development, not guessed — the bottle's visible plastic body spans roughly x:236–388, y:95–462 out of 500.
- The wave colors are low-alpha (`aqua`/`elaraBlue` at ~0.32–0.34) so the fill reads as a blue water tint rising inside the bottle without fully hiding the label or ribbed texture beneath it.
- This replaced an earlier hand-drawn `BottleClipper` (a generic bottle-shaped `CustomClipper<Path>`) per direct client feedback — the client wanted their own product shot, not an illustration.

## 4. `WaterDropLoader` (`water_drop_loader.dart`)

A droplet that falls, lands, ripples, and repeats — replaces every `CircularProgressIndicator` in the app (list loading, pull-to-refresh). With motion disabled, it freezes on a resting frame (droplet settled at the surface line) rather than disappearing, so the loading state still reads visually.

## 5. `PurityRipple` (`purity_ripple.dart`)

A single expanding, fading ring — like a droplet landing on still water — inserted as a transient `OverlayEntry` at a tap position. 600ms, ease-out, one ring. Deliberately restrained: this is what makes the feedback feel expensive rather than gimmicky.

- **Triggered on:** login submit (success), day-tab taps (`DateTabChip`).
- No-op entirely when motion is disabled.

## 6. The rising-water page wipe (`core/routes/water_wipe_route.dart`)

Not in `widgets/water/` since it's a GetX `CustomTransition`, not a standalone widget — but part of the same system. A solid `marine` rect rises from the bottom to cover the screen, then recedes off the top to reveal the incoming page, using `Align(heightFactor:)` / `FractionallySizedBox(heightFactor:)` rather than manual pixel math. Registered directly on the Login and Home `GetPage`s (`app_pages.dart`), so splash→login, splash→home, and logout (home→login) all get it for free. Falls back to a plain `FadeTransition` when motion is disabled.

---

## Performance guardrails

1. **Single flag:** `MotionConfig` (`core/theme/motion_config.dart`), a permanent GetX controller. `motion.motionEnabled` gates every water widget above; `motion.toggle()` flips all of them live (each widget listens via `ever(motion.reduceMotion, ...)`, not just at construction).
2. **Platform accessibility:** `main.dart`'s `GetMaterialApp.builder` calls `motion.syncWithPlatform(MediaQuery.disableAnimationsOf(context))` once per frame build — the OS "reduce motion" setting forces `reduceMotion = true` automatically.
3. **Auto-degrade:** a full frame-timing-based auto-degrade (measuring sustained >20ms frames and dropping to the static gradient) was judged too fiddly to make reliable for this scope — per the brief's own fallback instruction, the manual `MotionConfig.toggle()` escape hatch is what ships. `kFrameBudget` (20ms) is defined in `motion_config.dart` as the reference constant for if/when that auto-degrade is added.
4. **Never behind a scrolling list:** the order list (`mist` background, white cards) has zero animation behind it — motion lives only in the header/splash/login zones, which are not scrollable content areas.
5. **Target:** 60fps scrolling the order list on a mid-range Android device — verified by scrolling the live to-do list on the AVD during development; the list itself has no shader/ticker running underneath it, only entrance-stagger transforms on the first ~8 cards (`flutter_animate`, capped so later items don't wait in a queue).
