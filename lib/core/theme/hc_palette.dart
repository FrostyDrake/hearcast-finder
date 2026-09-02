import 'package:flutter/material.dart';

/// Semantic colour tokens for HearCast Finder.
///
/// Every ratio quoted here was computed from the WCAG 2.1 relative-luminance
/// formula, not estimated by eye. The governing rule of the palette is that
/// **hue is reserved for status**: categories are never colour-coded, so the
/// app only ever carries four semantic hues and a single brand teal.
///
/// The tinted [HcStatusColors.fill] values sit only ~1.25:1 against the page
/// surface. That is deliberate - a tint dark enough to clear 3:1 on its own
/// would crush the text printed on it. WCAG 2.1 SC 1.4.11 (non-text contrast)
/// is therefore carried by [HcStatusColors.outline], which is why the 1dp
/// border on a status badge is structural and not decoration.
@immutable
class HcStatusColors {
  const HcStatusColors({
    required this.fill,
    required this.onFill,
    required this.outline,
  });

  /// Tinted container behind a badge.
  final Color fill;

  /// Text and icon colour on [fill]. Always >= 4.5:1 against it.
  final Color onFill;

  /// 1dp border, and the solid fill used for map pins. Always >= 3:1 against
  /// the page surface, and >= 4.5:1 under white glyphs.
  final Color outline;

  HcStatusColors lerpTo(HcStatusColors other, double t) {
    return HcStatusColors(
      fill: Color.lerp(fill, other.fill, t)!,
      onFill: Color.lerp(onFill, other.onFill, t)!,
      outline: Color.lerp(outline, other.outline, t)!,
    );
  }
}

/// The four state triples, plus the neutral track used by the signal meter.
///
/// Read it with `Theme.of(context).extension<HcPalette>()!` - or, more
/// conveniently, `context.hcPalette`.
@immutable
class HcPalette extends ThemeExtension<HcPalette> {
  const HcPalette({
    required this.verified,
    required this.candidate,
    required this.danger,
    required this.neutral,
  });

  /// Confirmed by a human: an approved location, an approved scan submission.
  final HcStatusColors verified;

  /// Submitted but not yet reviewed.
  final HcStatusColors candidate;

  /// Rejected, failed, or unavailable.
  final HcStatusColors danger;

  /// Unknown or not applicable.
  final HcStatusColors neutral;

  // --- Light theme ------------------------------------------------------

  /// Page background. A near-white with a slight teal cast so it belongs to
  /// the #146C63 family, rather than the cool blue-grey the report used.
  static const lightSurface = Color(0xFFF7FAF9);
  static const lightSurfaceLowest = Color(0xFFFFFFFF);
  static const lightSurfaceLow = Color(0xFFF2F6F5);
  static const lightSurfaceContainer = Color(0xFFECF2F0);
  static const lightSurfaceHigh = Color(0xFFE6ECEB);
  static const lightSurfaceHighest = Color(0xFFDFE6E4);

  /// Body text. 16.81:1 on [lightSurface].
  static const lightOnSurface = Color(0xFF131A19);

  /// Secondary text - timestamps, addresses, RSSI subtitles. 7.75:1.
  ///
  /// Deliberately NOT a 60% grey: `Colors.grey`, `Colors.grey[600]`,
  /// `black54` and Material's 38% disabled tint all fail 4.5:1 on this
  /// surface and are banned throughout the app.
  static const lightOnSurfaceVariant = Color(0xFF46524F);

  /// Control boundaries. 4.24:1 - passes 3:1 for non-text, never used as text.
  static const lightOutline = Color(0xFF6E7A77);

  /// Decorative dividers only. 1.55:1 - never a control boundary.
  static const lightOutlineVariant = Color(0xFFC3CDCA);

  static const lightPrimary = Color(0xFF146C63);
  static const lightOnPrimary = Color(0xFFFFFFFF);
  static const lightPrimaryContainer = Color(0xFFCFE9E5);
  static const lightOnPrimaryContainer = Color(0xFF00382F);

  static const light = HcPalette(
    // text 7.46:1 on fill, outline 6.05:1 on surface
    verified: HcStatusColors(
      fill: Color(0xFFC7E9D5),
      onFill: Color(0xFF0F4E2E),
      outline: Color(0xFF2E6B46),
    ),
    // text 6.69:1, outline 5.20:1. Replaces the report's #C4711F, which
    // measured 3.67:1 on white and failed SC 1.4.3 for normal text.
    candidate: HcStatusColors(
      fill: Color(0xFFF8DCB6),
      onFill: Color(0xFF6E3F06),
      outline: Color(0xFF9A5A16),
    ),
    // text 6.75:1, outline 6.22:1
    danger: HcStatusColors(
      fill: Color(0xFFF8D6D3),
      onFill: Color(0xFF8C1D18),
      outline: Color(0xFFB3261E),
    ),
    // text 8.18:1, outline 5.67:1
    neutral: HcStatusColors(
      fill: Color(0xFFDDE4E3),
      onFill: Color(0xFF37413F),
      outline: Color(0xFF5B6664),
    ),
  );

  // --- Dark theme -------------------------------------------------------

  static const darkSurface = Color(0xFF0F1513);
  static const darkSurfaceLowest = Color(0xFF0A100F);
  static const darkSurfaceLow = Color(0xFF151C1A);
  static const darkSurfaceContainer = Color(0xFF1A2220);
  static const darkSurfaceHigh = Color(0xFF232B29);
  static const darkSurfaceHighest = Color(0xFF2D3533);

  /// 15.02:1 on [darkSurface].
  static const darkOnSurface = Color(0xFFE3E9E7);

  /// 8.45:1 on [darkSurface], and still 5.76:1 on the highest container.
  static const darkOnSurfaceVariant = Color(0xFFA6B2AF);

  static const darkOutline = Color(0xFF8C9794);
  static const darkOutlineVariant = Color(0xFF414A48);

  static const darkPrimary = Color(0xFF6FD9C9);
  static const darkOnPrimary = Color(0xFF003730);
  static const darkPrimaryContainer = Color(0xFF0C4F48);
  static const darkOnPrimaryContainer = Color(0xFF9FF2E3);

  static const dark = HcPalette(
    // text 7.95:1 on fill, outline 5.54:1 on surface
    verified: HcStatusColors(
      fill: Color(0xFF143D28),
      onFill: Color(0xFF9BE0B6),
      outline: Color(0xFF4E9C6E),
    ),
    // text 8.36:1, outline 6.11:1
    candidate: HcStatusColors(
      fill: Color(0xFF40290C),
      onFill: Color(0xFFF5C27A),
      outline: Color(0xFFC08A3E),
    ),
    // text 8.55:1, outline 7.37:1
    danger: HcStatusColors(
      fill: Color(0xFF4E1511),
      onFill: Color(0xFFF2B8B5),
      outline: Color(0xFFE48C84),
    ),
    // text 8.92:1, outline 5.97:1
    neutral: HcStatusColors(
      fill: Color(0xFF232B29),
      onFill: Color(0xFFC4CDCA),
      outline: Color(0xFF8A9591),
    ),
  );

  @override
  HcPalette copyWith({
    HcStatusColors? verified,
    HcStatusColors? candidate,
    HcStatusColors? danger,
    HcStatusColors? neutral,
  }) {
    return HcPalette(
      verified: verified ?? this.verified,
      candidate: candidate ?? this.candidate,
      danger: danger ?? this.danger,
      neutral: neutral ?? this.neutral,
    );
  }

  @override
  HcPalette lerp(covariant HcPalette? other, double t) {
    if (other == null) {
      return this;
    }
    return HcPalette(
      verified: verified.lerpTo(other.verified, t),
      candidate: candidate.lerpTo(other.candidate, t),
      danger: danger.lerpTo(other.danger, t),
      neutral: neutral.lerpTo(other.neutral, t),
    );
  }
}

/// Spacing scale. Every gap in the app is one of these, so the vertical
/// rhythm stays consistent across screens without per-screen guesswork.
abstract final class HcSpace {
  static const xs = 4.0;
  static const sm = 8.0;
  static const md = 12.0;
  static const lg = 16.0;
  static const xl = 20.0;
  static const xxl = 24.0;
  static const xxxl = 32.0;
}

/// Corner radii. Shape carries meaning here: a stadium is reserved for
/// status badges, so a stadium shape in this app always means "this is a
/// state, not an action".
abstract final class HcRadius {
  /// Cards and grouped lists.
  static const card = 16.0;

  /// Buttons and text fields.
  static const control = 12.0;

  /// Category avatars - a squircle, not a circle: it reads more institutional
  /// and costs less width.
  static const avatar = 12.0;
}

extension HcPaletteContext on BuildContext {
  /// The semantic status palette for the active theme.
  HcPalette get hcPalette => Theme.of(this).extension<HcPalette>()!;
}
