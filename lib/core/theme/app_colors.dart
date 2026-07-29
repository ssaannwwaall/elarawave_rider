import 'package:flutter/material.dart';

/// Brand palette — "Real Water", sampled directly from the client's actual
/// product photo (assets/brand/bottle-premium.png) via pixel-cluster
/// analysis, not guessed or invented.
///
/// This replaces an earlier "Deep Water" direction built on a dark navy
/// header gradient — the client rejected that on review ("dont use dark
/// color... I never like this... I need real water feel in whole app") and
/// asked for the palette to come only from the bottle photo's own colors:
/// the light, bright splash-water blues, not a deep-ocean navy.
///
///   - `aqua`      <- sampled #78B4D2 (the splash graphic's clear water blue)
///   - `waterMid`  <- sampled #5A96AA (a mid-tone from the same splash)
///   - `waterDeep` <- sampled #3C788C (the deepest blue found in the image —
///                    still a light-to-mid teal, never navy-dark)
///   - `elaraBlue` <- sampled #286482 (the richest/most saturated blue found —
///                    used for primary buttons/CTAs, deliberately not
///                    darkened further than what's actually in the photo)
///   - `mineral`   <- sampled #3C8C00 (the Ca/Na/SO4/Mg mineral badge green)
///   - `mineralLight` <- sampled #6EAA00 (a lighter badge green)
///   - `amber`     <- derived from the lemon slice's hue (~52°), value
///                    lowered for text legibility (the sampled lemon itself
///                    is a very pale ~94% V, too washed out to read as text)
/// `coral` has no source in the photo — there is no red in it at all — and
/// is kept as the one deliberate exception: a danger/cancelled state needs
/// to read as a warning color regardless of brand imagery.
/// See docs/DESIGN_SYSTEM.md for the full rationale and sampling method.
class AppColors {
  AppColors._();

  // Water — light and bright, the actual color of the splash in the photo
  static const Color waterPale = Color(0xFFD2F0FA);
  static const Color waterLight = Color(0xFFAAD2E6);
  static const Color aqua = Color(0xFF78B4D2);
  static const Color waterMid = Color(0xFF5A96AA);
  static const Color waterDeep = Color(0xFF3C788C);
  static const Color elaraBlue = Color(0xFF286482);
  static const Color foam = Color(0xFFD2F0FA);

  // Hero water backgrounds — the ONE pair every full-bleed water surface
  // (splash, login header, home header) uses, so all screens read the same:
  // clear, near-white water like the splash in bottle-premium.png, never a
  // dark navy slab. Deeper blues (waterDeep/elaraBlue) are reserved for small
  // accents and the bottle fill, where a hint of depth reads as real water.
  static const Color heroDeep = aqua;
  static const Color heroLight = waterPale;

  // Mineral (from the badges on the bottle photo)
  static const Color mineral = Color(0xFF3C8C00);
  static const Color mineralLight = Color(0xFF6EAA00);

  // Surface
  static const Color snow = Color(0xFFFFFFFF);
  static const Color mist = Color(0xFFF4F8FB);
  static const Color line = Color(0xFFE3EBF2);

  // Ink
  static const Color ink = Color(0xFF0D1B2A);
  static const Color inkMuted = Color(0xFF5A6C7D);
  static const Color inkFaint = Color(0xFF93A4B3);

  // Status
  static const Color amber = Color(0xFFB7A52D);
  static const Color coral = Color(0xFFE8544E);

  /// Hero gradient (also the shader's graceful-degradation fallback): near-white
  /// water at top easing into a light aqua — bright throughout, never dark navy.
  static const LinearGradient waterGradient = LinearGradient(
    begin: Alignment(-0.4, -1),
    end: Alignment(0.5, 1),
    colors: [waterPale, waterLight, aqua],
    stops: [0.0, 0.55, 1.0],
  );

  static Color cardShadow = ink.withValues(alpha: 0.06);
}
