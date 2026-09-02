import 'package:flutter/material.dart';

import 'hc_palette.dart';

/// Builds the light and dark themes.
///
/// Two rules govern this file and are load-bearing for accessibility:
///
/// 1. **No `fontSize` is ever set.** Hierarchy is built from Material's own
///    type roles plus weight, letter-spacing and colour, so the whole app
///    follows the system font-size setting up to 200% (WCAG 2.1 SC 1.4.4).
///    Choosing a different *role* (`labelSmall` instead of `labelMedium`) is
///    not the same as hard-coding a size - the role still scales.
/// 2. **No shadows.** Surfaces are separated by a 1dp hairline outline and a
///    tonal step, never by elevation. `surfaceTintColor` is forced
///    transparent so Material's elevation overlay cannot tint a card and
///    silently change the contrast ratios computed in [HcPalette].
abstract final class AppTheme {
  static ThemeData light() => _build(
        brightness: Brightness.light,
        palette: HcPalette.light,
        scheme: const ColorScheme.light(
          primary: HcPalette.lightPrimary,
          onPrimary: HcPalette.lightOnPrimary,
          primaryContainer: HcPalette.lightPrimaryContainer,
          onPrimaryContainer: HcPalette.lightOnPrimaryContainer,
          secondary: HcPalette.lightPrimary,
          onSecondary: HcPalette.lightOnPrimary,
          secondaryContainer: HcPalette.lightPrimaryContainer,
          onSecondaryContainer: HcPalette.lightOnPrimaryContainer,
          tertiary: HcPalette.lightPrimary,
          onTertiary: HcPalette.lightOnPrimary,
          error: Color(0xFFB3261E),
          onError: Color(0xFFFFFFFF),
          errorContainer: Color(0xFFF8D6D3),
          onErrorContainer: Color(0xFF8C1D18),
          surface: HcPalette.lightSurface,
          onSurface: HcPalette.lightOnSurface,
          onSurfaceVariant: HcPalette.lightOnSurfaceVariant,
          surfaceContainerLowest: HcPalette.lightSurfaceLowest,
          surfaceContainerLow: HcPalette.lightSurfaceLow,
          surfaceContainer: HcPalette.lightSurfaceContainer,
          surfaceContainerHigh: HcPalette.lightSurfaceHigh,
          surfaceContainerHighest: HcPalette.lightSurfaceHighest,
          outline: HcPalette.lightOutline,
          outlineVariant: HcPalette.lightOutlineVariant,
          inverseSurface: HcPalette.darkSurface,
          onInverseSurface: HcPalette.darkOnSurface,
          inversePrimary: HcPalette.darkPrimary,
        ),
      );

  static ThemeData dark() => _build(
        brightness: Brightness.dark,
        palette: HcPalette.dark,
        scheme: const ColorScheme.dark(
          primary: HcPalette.darkPrimary,
          onPrimary: HcPalette.darkOnPrimary,
          primaryContainer: HcPalette.darkPrimaryContainer,
          onPrimaryContainer: HcPalette.darkOnPrimaryContainer,
          secondary: HcPalette.darkPrimary,
          onSecondary: HcPalette.darkOnPrimary,
          secondaryContainer: HcPalette.darkPrimaryContainer,
          onSecondaryContainer: HcPalette.darkOnPrimaryContainer,
          tertiary: HcPalette.darkPrimary,
          onTertiary: HcPalette.darkOnPrimary,
          error: Color(0xFFE48C84),
          onError: Color(0xFF4E1511),
          errorContainer: Color(0xFF4E1511),
          onErrorContainer: Color(0xFFF2B8B5),
          surface: HcPalette.darkSurface,
          onSurface: HcPalette.darkOnSurface,
          onSurfaceVariant: HcPalette.darkOnSurfaceVariant,
          surfaceContainerLowest: HcPalette.darkSurfaceLowest,
          surfaceContainerLow: HcPalette.darkSurfaceLow,
          surfaceContainer: HcPalette.darkSurfaceContainer,
          surfaceContainerHigh: HcPalette.darkSurfaceHigh,
          surfaceContainerHighest: HcPalette.darkSurfaceHighest,
          outline: HcPalette.darkOutline,
          outlineVariant: HcPalette.darkOutlineVariant,
          inverseSurface: HcPalette.lightSurface,
          onInverseSurface: HcPalette.lightOnSurface,
          inversePrimary: HcPalette.lightPrimary,
        ),
      );

  static ThemeData _build({
    required Brightness brightness,
    required ColorScheme scheme,
    required HcPalette palette,
  }) {
    final base = ThemeData(
      brightness: brightness,
      colorScheme: scheme,
      useMaterial3: true,
    );

    final text = _typography(base.textTheme);

    return base.copyWith(
      textTheme: text,
      scaffoldBackgroundColor: scheme.surface,
      extensions: [palette],
      splashFactory: InkSparkle.splashFactory,

      appBarTheme: AppBarTheme(
        backgroundColor: scheme.surface,
        surfaceTintColor: Colors.transparent,
        foregroundColor: scheme.onSurface,
        elevation: 0,
        scrolledUnderElevation: 0,
        centerTitle: false,
        titleTextStyle: text.titleLarge?.copyWith(
          color: scheme.onSurface,
          fontWeight: FontWeight.w700,
          letterSpacing: -0.2,
        ),
      ),

      // Elevation is never used to separate surfaces; a hairline outline is.
      cardTheme: CardThemeData(
        color: scheme.surfaceContainerLowest,
        surfaceTintColor: Colors.transparent,
        elevation: 0,
        margin: EdgeInsets.zero,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(HcRadius.card),
          side: BorderSide(color: scheme.outlineVariant),
        ),
      ),

      dividerTheme: DividerThemeData(
        color: scheme.outlineVariant,
        thickness: 1,
        space: 1,
      ),

      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: scheme.surfaceContainerLowest,
        contentPadding: const EdgeInsets.symmetric(
          horizontal: HcSpace.lg,
          vertical: HcSpace.lg,
        ),
        border: _inputBorder(scheme.outline),
        enabledBorder: _inputBorder(scheme.outline),
        focusedBorder: _inputBorder(scheme.primary, width: 2),
        errorBorder: _inputBorder(scheme.error),
        focusedErrorBorder: _inputBorder(scheme.error, width: 2),
        labelStyle: TextStyle(color: scheme.onSurfaceVariant),
        floatingLabelStyle: TextStyle(color: scheme.primary),
        helperStyle: TextStyle(color: scheme.onSurfaceVariant),
        prefixIconColor: scheme.onSurfaceVariant,
        suffixIconColor: scheme.onSurfaceVariant,
      ),

      // Every button clears the 48dp minimum target of SC 2.5.8 with room to
      // spare, and grows taller as the system font scale grows.
      // Disabled states are resolved explicitly rather than left to
      // Material's 38% tint, which measures ~2.4:1 on this surface and would
      // make a disabled label unreadable. A disabled control here loses its
      // colour and its emphasis but keeps >= 4.5:1 contrast.
      filledButtonTheme: FilledButtonThemeData(
        style: _buttonStyle(text).copyWith(
          backgroundColor: WidgetStateProperty.resolveWith(
            (states) => states.contains(WidgetState.disabled)
                ? scheme.surfaceContainerHighest
                : scheme.primary,
          ),
          foregroundColor: WidgetStateProperty.resolveWith(
            (states) => states.contains(WidgetState.disabled)
                ? scheme.onSurfaceVariant
                : scheme.onPrimary,
          ),
        ),
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: _buttonStyle(text).copyWith(
          backgroundColor: WidgetStateProperty.resolveWith(
            (states) => states.contains(WidgetState.disabled)
                ? scheme.surfaceContainerHighest
                : scheme.primaryContainer,
          ),
          foregroundColor: WidgetStateProperty.resolveWith(
            (states) => states.contains(WidgetState.disabled)
                ? scheme.onSurfaceVariant
                : scheme.onPrimaryContainer,
          ),
          elevation: const WidgetStatePropertyAll(0),
        ),
      ),
      outlinedButtonTheme: OutlinedButtonThemeData(
        style: _buttonStyle(text).copyWith(
          foregroundColor: WidgetStateProperty.resolveWith(
            (states) => states.contains(WidgetState.disabled)
                ? scheme.onSurfaceVariant
                : scheme.primary,
          ),
          side: WidgetStateProperty.resolveWith(
            (states) => states.contains(WidgetState.disabled)
                ? BorderSide(color: scheme.outlineVariant, width: 1.5)
                : BorderSide(color: scheme.outline, width: 1.5),
          ),
        ),
      ),
      textButtonTheme: TextButtonThemeData(
        style: _buttonStyle(text).copyWith(
          foregroundColor: WidgetStateProperty.resolveWith(
            (states) => states.contains(WidgetState.disabled)
                ? scheme.onSurfaceVariant
                : scheme.primary,
          ),
        ),
      ),

      iconButtonTheme: IconButtonThemeData(
        style: ButtonStyle(
          minimumSize: const WidgetStatePropertyAll(Size(48, 48)),
          foregroundColor: WidgetStatePropertyAll(scheme.onSurfaceVariant),
        ),
      ),

      listTileTheme: ListTileThemeData(
        iconColor: scheme.onSurfaceVariant,
        textColor: scheme.onSurface,
        subtitleTextStyle: text.bodyMedium?.copyWith(
          color: scheme.onSurfaceVariant,
        ),
        titleTextStyle: text.titleMedium?.copyWith(color: scheme.onSurface),
        contentPadding: const EdgeInsets.symmetric(
          horizontal: HcSpace.lg,
          vertical: HcSpace.sm,
        ),
        minVerticalPadding: HcSpace.md,
      ),

      chipTheme: ChipThemeData(
        backgroundColor: scheme.surfaceContainerLowest,
        side: BorderSide(color: scheme.outline),
        shape: const StadiumBorder(),
        labelStyle: text.labelLarge?.copyWith(color: scheme.onSurface),
        padding: const EdgeInsets.symmetric(
          horizontal: HcSpace.sm,
          vertical: HcSpace.sm,
        ),
        showCheckmark: false,
      ),

      // The label uses `labelSmall` rather than Material's default
      // `labelMedium`: with seven destinations on a ~384dp phone each tab is
      // only ~55dp wide, and "Locations" wraps onto two lines at the default
      // role. Picking a smaller *role* keeps the text scalable, unlike a
      // hard-coded size. Above a 1.3 text scale the labels are hidden
      // entirely by AppShell and the tooltip carries the name instead.
      navigationBarTheme: NavigationBarThemeData(
        backgroundColor: scheme.surfaceContainerLowest,
        surfaceTintColor: Colors.transparent,
        indicatorColor: scheme.primaryContainer,
        elevation: 0,
        height: 68,
        labelBehavior: NavigationDestinationLabelBehavior.alwaysShow,
        indicatorShape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(HcRadius.control),
        ),
        labelTextStyle: WidgetStateProperty.resolveWith((states) {
          final selected = states.contains(WidgetState.selected);
          return text.labelSmall?.copyWith(
            letterSpacing: -0.2,
            fontWeight: selected ? FontWeight.w700 : FontWeight.w500,
            color: selected ? scheme.onSurface : scheme.onSurfaceVariant,
          );
        }),
        iconTheme: WidgetStateProperty.resolveWith((states) {
          final selected = states.contains(WidgetState.selected);
          return IconThemeData(
            size: 24,
            color: selected ? scheme.onPrimaryContainer : scheme.onSurfaceVariant,
          );
        }),
      ),

      snackBarTheme: SnackBarThemeData(
        backgroundColor: scheme.inverseSurface,
        contentTextStyle: text.bodyMedium?.copyWith(
          color: scheme.onInverseSurface,
        ),
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(HcRadius.control),
        ),
      ),

      dialogTheme: DialogThemeData(
        backgroundColor: scheme.surfaceContainerLowest,
        surfaceTintColor: Colors.transparent,
        elevation: 0,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(HcRadius.card),
          side: BorderSide(color: scheme.outlineVariant),
        ),
        titleTextStyle: text.titleLarge?.copyWith(
          color: scheme.onSurface,
          fontWeight: FontWeight.w700,
        ),
      ),

      bottomSheetTheme: BottomSheetThemeData(
        backgroundColor: scheme.surface,
        surfaceTintColor: Colors.transparent,
        elevation: 0,
        showDragHandle: true,
        dragHandleColor: scheme.outline,
      ),

      segmentedButtonTheme: SegmentedButtonThemeData(
        style: ButtonStyle(
          minimumSize: const WidgetStatePropertyAll(Size(0, 48)),
          side: WidgetStatePropertyAll(BorderSide(color: scheme.outline)),
          textStyle: WidgetStatePropertyAll(
            text.labelLarge?.copyWith(fontWeight: FontWeight.w600),
          ),
        ),
      ),

      progressIndicatorTheme: ProgressIndicatorThemeData(
        color: scheme.primary,
        linearTrackColor: scheme.surfaceContainerHighest,
        circularTrackColor: scheme.surfaceContainerHighest,
      ),
    );
  }

  static OutlineInputBorder _inputBorder(Color color, {double width = 1}) {
    return OutlineInputBorder(
      borderRadius: BorderRadius.circular(HcRadius.control),
      borderSide: BorderSide(color: color, width: width),
    );
  }

  static ButtonStyle _buttonStyle(TextTheme text) {
    return ButtonStyle(
      minimumSize: const WidgetStatePropertyAll(Size(64, 48)),
      padding: const WidgetStatePropertyAll(
        EdgeInsets.symmetric(horizontal: HcSpace.xl, vertical: HcSpace.md),
      ),
      shape: WidgetStatePropertyAll(
        RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(HcRadius.control),
        ),
      ),
      textStyle: WidgetStatePropertyAll(
        text.labelLarge?.copyWith(fontWeight: FontWeight.w600),
      ),
      elevation: const WidgetStatePropertyAll(0),
    );
  }

  /// Weight, letter-spacing and line-height only - never `fontSize`.
  static TextTheme _typography(TextTheme base) {
    return base.copyWith(
      headlineMedium: base.headlineMedium?.copyWith(
        fontWeight: FontWeight.w700,
        letterSpacing: -0.5,
        height: 1.15,
      ),
      headlineSmall: base.headlineSmall?.copyWith(
        fontWeight: FontWeight.w700,
        letterSpacing: -0.4,
        height: 1.2,
      ),
      titleLarge: base.titleLarge?.copyWith(
        fontWeight: FontWeight.w700,
        letterSpacing: -0.2,
      ),
      titleMedium: base.titleMedium?.copyWith(
        fontWeight: FontWeight.w600,
        letterSpacing: -0.1,
        height: 1.3,
      ),
      titleSmall: base.titleSmall?.copyWith(fontWeight: FontWeight.w600),
      bodyLarge: base.bodyLarge?.copyWith(height: 1.45),
      bodyMedium: base.bodyMedium?.copyWith(height: 1.45),
      bodySmall: base.bodySmall?.copyWith(height: 1.4),
      labelLarge: base.labelLarge?.copyWith(fontWeight: FontWeight.w600),
      labelMedium: base.labelMedium?.copyWith(fontWeight: FontWeight.w600),
    );
  }
}
