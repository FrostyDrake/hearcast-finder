import 'package:flutter/material.dart';

import '../../core/theme/hc_palette.dart';

@immutable
class HcNavItem {
  const HcNavItem({
    required this.icon,
    required this.selectedIcon,
    required this.label,
    required this.tooltip,
  });

  final IconData icon;
  final IconData selectedIcon;
  final String label;
  final String tooltip;
}

/// The app's bottom navigation.
///
/// Material's own `NavigationBar` is the obvious choice, but it cannot be made
/// to fit seven destinations here: each tab gets a seventh of a ~384dp screen,
/// and "Locations" is wider than that in the system font on a Samsung device,
/// so the label wrapped onto a second line and had its last letter clipped by
/// the bar's edge. `NavigationDestination.label` takes a `String`, not a
/// widget, so there is no way to tell Material's own label not to wrap.
///
/// This does three things Material's version cannot:
///
/// * the label is one line, always - scaled down slightly if the font is
///   wider than the tab, never wrapped and never clipped;
/// * past a 1.3 text scale the labels are dropped entirely rather than
///   shrunk, because a label small enough to fit is no use to the low-vision
///   users this app is for. The tooltip and the semantics label still carry
///   each destination's name, so nothing is lost to a screen reader;
/// * every tab is a full-height target, comfortably past the 48dp of
///   WCAG 2.1 SC 2.5.8.
class HcBottomNav extends StatelessWidget {
  const HcBottomNav({
    required this.items,
    required this.selectedIndex,
    required this.onSelected,
    super.key,
  });

  final List<HcNavItem> items;
  final int selectedIndex;
  final ValueChanged<int> onSelected;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final scaler = MediaQuery.textScalerOf(context);
    final showLabels = scaler.scale(1) <= 1.3;

    return Material(
      color: scheme.surfaceContainerLowest,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(height: 1, color: scheme.outlineVariant),
          SafeArea(
            top: false,
            child: Row(
              children: [
                for (var i = 0; i < items.length; i++)
                  Expanded(
                    child: _NavTab(
                      item: items[i],
                      selected: i == selectedIndex,
                      showLabel: showLabels,
                      onTap: () => onSelected(i),
                    ),
                  ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _NavTab extends StatelessWidget {
  const _NavTab({
    required this.item,
    required this.selected,
    required this.showLabel,
    required this.onTap,
  });

  final HcNavItem item;
  final bool selected;
  final bool showLabel;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final scheme = theme.colorScheme;
    final scaler = MediaQuery.textScalerOf(context);

    final iconColor =
        selected ? scheme.onPrimaryContainer : scheme.onSurfaceVariant;

    return Semantics(
      button: true,
      selected: selected,
      label: item.label,
      excludeSemantics: true,
      child: Tooltip(
        message: item.tooltip,
        child: InkWell(
          onTap: onTap,
          child: Padding(
            padding: const EdgeInsets.symmetric(vertical: HcSpace.sm),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                // Selection is carried by the filled indicator, the switch to
                // a solid icon AND the heavier label - three cues, so it is
                // never colour alone.
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: HcSpace.lg,
                    vertical: 6,
                  ),
                  decoration: ShapeDecoration(
                    color: selected
                        ? scheme.primaryContainer
                        : Colors.transparent,
                    shape: const StadiumBorder(),
                  ),
                  child: Icon(
                    selected ? item.selectedIcon : item.icon,
                    size: scaler.scale(22),
                    color: iconColor,
                  ),
                ),
                if (showLabel) ...[
                  const SizedBox(height: HcSpace.xs),
                  // scaleDown only ever shrinks, and only when the glyphs are
                  // genuinely wider than the tab.
                  FittedBox(
                    fit: BoxFit.scaleDown,
                    child: Text(
                      item.label,
                      maxLines: 1,
                      softWrap: false,
                      style: theme.textTheme.labelMedium?.copyWith(
                        color: selected
                            ? scheme.onSurface
                            : scheme.onSurfaceVariant,
                        fontWeight:
                            selected ? FontWeight.w700 : FontWeight.w500,
                        letterSpacing: -0.1,
                      ),
                    ),
                  ),
                ],
              ],
            ),
          ),
        ),
      ),
    );
  }
}
