import 'package:flutter/material.dart';

import '../theme/hc_palette.dart';

/// How strong a received signal was, as five coarse steps.
///
/// This is deliberately coarse. RSSI swings violently with walls, bodies and
/// transmitter power, so the app reports "Strong" or "Weak" and the raw dBm
/// figure, and never converts either into a distance in metres - a promise
/// it could not keep.
enum HcSignalLevel {
  none(0, 'No signal'),
  veryWeak(1, 'Very weak'),
  weak(2, 'Weak'),
  fair(3, 'Fair'),
  strong(4, 'Strong'),
  excellent(5, 'Excellent');

  const HcSignalLevel(this.bars, this.label);

  final int bars;
  final String label;

  /// Buckets a raw RSSI reading in dBm.
  static HcSignalLevel fromRssi(int rssi) {
    if (rssi >= -55) return HcSignalLevel.excellent;
    if (rssi >= -65) return HcSignalLevel.strong;
    if (rssi >= -75) return HcSignalLevel.fair;
    if (rssi >= -85) return HcSignalLevel.weak;
    if (rssi >= -100) return HcSignalLevel.veryWeak;
    return HcSignalLevel.none;
  }
}

/// Five ascending bars: filled ones solid, the rest drawn as outlined
/// ghosts so the total is always countable rather than implied.
///
/// This is the one drawn object in the app that is specific to what it does
/// - a radio instrument rather than a list of places.
class HcSignalBars extends StatelessWidget {
  const HcSignalBars({required this.level, super.key});

  final HcSignalLevel level;

  @override
  Widget build(BuildContext context) {
    final palette = context.hcPalette;
    final scheme = Theme.of(context).colorScheme;
    final colors = switch (level) {
      HcSignalLevel.excellent || HcSignalLevel.strong => palette.verified,
      HcSignalLevel.fair => palette.candidate,
      HcSignalLevel.weak || HcSignalLevel.veryWeak => palette.danger,
      HcSignalLevel.none => palette.neutral,
    };

    // Every dimension is multiplied by the text scale, so the meter grows
    // with the label beside it instead of shrinking into irrelevance at
    // 200% text.
    final scaler = MediaQuery.textScalerOf(context);

    return ExcludeSemantics(
      child: CustomPaint(
        size: Size(scaler.scale(34), scaler.scale(20)),
        painter: _SignalBarsPainter(
          bars: level.bars,
          fill: colors.outline,
          ghost: scheme.outline,
        ),
      ),
    );
  }
}

class _SignalBarsPainter extends CustomPainter {
  _SignalBarsPainter({
    required this.bars,
    required this.fill,
    required this.ghost,
  });

  final int bars;
  final Color fill;
  final Color ghost;

  @override
  void paint(Canvas canvas, Size size) {
    const count = 5;
    final gap = size.width * 0.12 / (count - 1);
    final barWidth = (size.width - gap * (count - 1)) / count;
    final radius = Radius.circular(barWidth * 0.35);

    final solid = Paint()
      ..color = fill
      ..style = PaintingStyle.fill;
    final outline = Paint()
      ..color = ghost
      ..style = PaintingStyle.stroke
      ..strokeWidth = size.height * 0.075;

    for (var i = 0; i < count; i++) {
      // Shortest bar is 30% of the height, tallest is the full height.
      final heightFactor = 0.3 + (0.7 * i / (count - 1));
      final barHeight = size.height * heightFactor;
      final rect = RRect.fromRectAndRadius(
        Rect.fromLTWH(
          i * (barWidth + gap),
          size.height - barHeight,
          barWidth,
          barHeight,
        ),
        radius,
      );

      if (i < bars) {
        canvas.drawRRect(rect, solid);
      } else {
        // Inset by half the stroke so the ghost outline sits inside the
        // same footprint as a filled bar.
        canvas.drawRRect(rect.deflate(outline.strokeWidth / 2), outline);
      }
    }
  }

  @override
  bool shouldRepaint(_SignalBarsPainter oldDelegate) {
    return oldDelegate.bars != bars ||
        oldDelegate.fill != fill ||
        oldDelegate.ghost != ghost;
  }
}

/// The bars plus their reading in words and dBm - "Strong · -61 dBm".
///
/// The words are what make this pass SC 1.4.1: a user who cannot distinguish
/// the bar colour still gets the strength as text, and a screen reader gets
/// one sentence instead of a decorative graphic.
class HcSignalMeter extends StatelessWidget {
  const HcSignalMeter({required this.rssi, super.key});

  final int rssi;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final level = HcSignalLevel.fromRssi(rssi);

    return Semantics(
      label: 'Signal strength ${level.label}, $rssi dBm',
      excludeSemantics: true,
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          HcSignalBars(level: level),
          const SizedBox(width: HcSpace.sm),
          Flexible(
            child: Text(
              '${level.label} · $rssi dBm',
              style: theme.textTheme.bodySmall?.copyWith(
                color: theme.colorScheme.onSurfaceVariant,
                fontWeight: FontWeight.w600,
                fontFeatures: const [FontFeature.tabularFigures()],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
