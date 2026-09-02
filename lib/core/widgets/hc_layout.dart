import 'package:flutter/material.dart';

import '../theme/hc_palette.dart';

/// The standard scrolling page body. Every tab uses it, so the horizontal
/// margin and the space under the last item are identical everywhere.
class HcScreen extends StatelessWidget {
  const HcScreen({required this.children, super.key});

  final List<Widget> children;

  @override
  Widget build(BuildContext context) {
    return ListView(
      padding: const EdgeInsets.fromLTRB(
        HcSpace.lg,
        HcSpace.sm,
        HcSpace.lg,
        HcSpace.xxxl,
      ),
      children: children,
    );
  }
}

/// The title block at the top of a tab: an eyebrow-free headline plus one
/// plain-language sentence explaining what the screen is for.
class HcPageHeader extends StatelessWidget {
  const HcPageHeader({
    required this.title,
    required this.subtitle,
    super.key,
  });

  final String title;
  final String subtitle;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Padding(
      padding: const EdgeInsets.only(bottom: HcSpace.xl),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Semantics(
            header: true,
            child: Text(title, style: theme.textTheme.headlineSmall),
          ),
          const SizedBox(height: HcSpace.sm),
          Text(
            subtitle,
            style: theme.textTheme.bodyMedium?.copyWith(
              color: theme.colorScheme.onSurfaceVariant,
            ),
          ),
        ],
      ),
    );
  }
}

/// A heading above a group, optionally with a count and a trailing action.
class HcSectionHeader extends StatelessWidget {
  const HcSectionHeader({
    required this.title,
    this.subtitle,
    this.trailing,
    super.key,
  });

  final String title;
  final String? subtitle;
  final Widget? trailing;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final label = subtitle;

    return Padding(
      padding: const EdgeInsets.only(bottom: HcSpace.md),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Semantics(
                  header: true,
                  child: Text(title, style: theme.textTheme.titleMedium),
                ),
                if (label != null) ...[
                  const SizedBox(height: HcSpace.xs),
                  Text(
                    label,
                    style: theme.textTheme.bodySmall?.copyWith(
                      color: theme.colorScheme.onSurfaceVariant,
                    ),
                  ),
                ],
              ],
            ),
          ),
          if (trailing != null) trailing!,
        ],
      ),
    );
  }
}

/// A bordered, shadowless panel. Content that is *about one thing* lives in
/// one of these; a list of many things uses [HcListGroup] instead.
class HcCard extends StatelessWidget {
  const HcCard({
    required this.child,
    this.padding = const EdgeInsets.all(HcSpace.lg),
    this.color,
    this.borderColor,
    super.key,
  });

  final Widget child;
  final EdgeInsetsGeometry padding;
  final Color? color;
  final Color? borderColor;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;

    // A Material rather than a DecoratedBox: anything tappable inside a card
    // paints its ink on the nearest Material ancestor, and a plain
    // DecoratedBox would swallow those splashes.
    return Material(
      color: color ?? scheme.surfaceContainerLowest,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(HcRadius.card),
        side: BorderSide(color: borderColor ?? scheme.outlineVariant),
      ),
      child: Padding(padding: padding, child: child),
    );
  }
}

/// One bordered ledger holding many rows, with hairline dividers inset to
/// align under the text column.
///
/// This replaces the app's previous stack of floating `Card`s - the single
/// most recognisable "unstyled Flutter" signature - with one calm container.
class HcListGroup extends StatelessWidget {
  const HcListGroup({
    required this.children,
    this.dividerIndent = 72,
    super.key,
  });

  final List<Widget> children;
  final double dividerIndent;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    if (children.isEmpty) {
      return const SizedBox.shrink();
    }

    final rows = <Widget>[];
    for (var i = 0; i < children.length; i++) {
      if (i > 0) {
        rows.add(
          Divider(
            height: 1,
            thickness: 1,
            // The indent tracks the text scale so the divider keeps aligning
            // under the text column as the avatar grows.
            indent: MediaQuery.textScalerOf(context).scale(dividerIndent),
            color: scheme.outlineVariant,
          ),
        );
      }
      rows.add(children[i]);
    }

    return Material(
      clipBehavior: Clip.antiAlias,
      color: scheme.surfaceContainerLowest,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(HcRadius.card),
        side: BorderSide(color: scheme.outlineVariant),
      ),
      child: Column(children: rows),
    );
  }
}

/// A row inside an [HcListGroup].
///
/// The whole row is one tap target and one screen-reader node, so TalkBack
/// reads "Aalborg Cathedral, Church, Aalborg, Status: Verified" as a single
/// announcement instead of four disconnected fragments.
class HcListRow extends StatelessWidget {
  const HcListRow({
    required this.title,
    this.leading,
    this.subtitle,
    this.badges = const [],
    this.trailing,
    this.onTap,
    this.semanticLabel,
    super.key,
  });

  final String title;
  final Widget? leading;
  final String? subtitle;
  final List<Widget> badges;
  final Widget? trailing;
  final VoidCallback? onTap;
  final String? semanticLabel;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final sub = subtitle;

    final content = Padding(
      padding: const EdgeInsets.symmetric(
        horizontal: HcSpace.lg,
        vertical: HcSpace.md,
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (leading != null) ...[
            leading!,
            const SizedBox(width: HcSpace.md),
          ],
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(title, style: theme.textTheme.titleMedium),
                if (sub != null) ...[
                  const SizedBox(height: 2),
                  Text(
                    sub,
                    style: theme.textTheme.bodyMedium?.copyWith(
                      color: theme.colorScheme.onSurfaceVariant,
                    ),
                  ),
                ],
                if (badges.isNotEmpty) ...[
                  const SizedBox(height: HcSpace.sm),
                  // Wrap, never Row: at 200% text the badges stack instead of
                  // colliding.
                  Wrap(
                    spacing: HcSpace.sm,
                    runSpacing: HcSpace.sm,
                    children: badges,
                  ),
                ],
              ],
            ),
          ),
          if (trailing != null) ...[
            const SizedBox(width: HcSpace.sm),
            trailing!,
          ],
        ],
      ),
    );

    if (onTap == null) {
      return MergeSemantics(child: content);
    }

    return MergeSemantics(
      child: Semantics(
        button: true,
        label: semanticLabel,
        child: InkWell(
          onTap: onTap,
          // A row is always at least a 48dp target (SC 2.5.8); in practice
          // the two-line content makes it considerably taller.
          child: ConstrainedBox(
            constraints: const BoxConstraints(minHeight: 48),
            child: content,
          ),
        ),
      ),
    );
  }
}

/// A label/value pair inside a detail card. Always stacked, never a Row, so
/// a long value cannot squeeze the label into a single character column at
/// large text sizes.
class HcDetailRow extends StatelessWidget {
  const HcDetailRow({
    required this.icon,
    required this.label,
    required this.value,
    super.key,
  });

  final IconData icon;
  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final iconSize = MediaQuery.textScalerOf(context).scale(20);

    return MergeSemantics(
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          ExcludeSemantics(
            child: Icon(
              icon,
              size: iconSize,
              color: theme.colorScheme.onSurfaceVariant,
            ),
          ),
          const SizedBox(width: HcSpace.md),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  label,
                  style: theme.textTheme.bodySmall?.copyWith(
                    color: theme.colorScheme.onSurfaceVariant,
                    fontWeight: FontWeight.w600,
                    letterSpacing: 0.3,
                  ),
                ),
                const SizedBox(height: 2),
                Text(value, style: theme.textTheme.bodyLarge),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

/// A group of buttons that stacks instead of overflowing. Never a bare Row.
class HcActionBar extends StatelessWidget {
  const HcActionBar({required this.children, super.key});

  final List<Widget> children;

  @override
  Widget build(BuildContext context) {
    return Wrap(
      spacing: HcSpace.sm,
      runSpacing: HcSpace.sm,
      children: children,
    );
  }
}

/// An inline message strip - used for form results and scan feedback.
/// Carries an icon and a tinted, outlined container so the meaning survives
/// without colour perception.
class HcNotice extends StatelessWidget {
  const HcNotice({
    required this.message,
    this.tone = HcNoticeTone.info,
    super.key,
  });

  final String message;
  final HcNoticeTone tone;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final palette = context.hcPalette;
    final (colors, icon) = switch (tone) {
      HcNoticeTone.success => (palette.verified, Icons.check_circle_rounded),
      HcNoticeTone.error => (palette.danger, Icons.error_rounded),
      HcNoticeTone.info => (palette.neutral, Icons.info_rounded),
    };
    final iconSize = MediaQuery.textScalerOf(context).scale(20);

    return MergeSemantics(
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.all(HcSpace.md),
        decoration: ShapeDecoration(
          color: colors.fill,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(HcRadius.control),
            side: BorderSide(color: colors.outline),
          ),
        ),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            ExcludeSemantics(
              child: Icon(icon, size: iconSize, color: colors.onFill),
            ),
            const SizedBox(width: HcSpace.md),
            Expanded(
              child: Text(
                message,
                style: theme.textTheme.bodyMedium?.copyWith(
                  color: colors.onFill,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

enum HcNoticeTone { info, success, error }
