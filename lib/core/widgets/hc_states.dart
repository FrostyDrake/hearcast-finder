import 'package:flutter/material.dart';

import '../theme/hc_palette.dart';
import 'hc_layout.dart';

/// "There is nothing here, and here is why."
///
/// An empty screen with no explanation reads as a broken app; one line of
/// text makes the same screen read as working. Every data-backed surface in
/// the app has one of these.
class HcEmptyState extends StatelessWidget {
  const HcEmptyState({
    required this.icon,
    required this.title,
    required this.message,
    this.action,
    super.key,
  });

  final IconData icon;
  final String title;
  final String message;
  final Widget? action;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final scheme = theme.colorScheme;
    final scaler = MediaQuery.textScalerOf(context);

    return HcCard(
      padding: const EdgeInsets.symmetric(
        horizontal: HcSpace.lg,
        vertical: HcSpace.xxl,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          ExcludeSemantics(
            child: Container(
              width: scaler.scale(56),
              height: scaler.scale(56),
              decoration: ShapeDecoration(
                color: scheme.surfaceContainerHigh,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(HcRadius.card),
                ),
              ),
              child: Icon(
                icon,
                size: scaler.scale(26),
                color: scheme.onSurfaceVariant,
              ),
            ),
          ),
          const SizedBox(height: HcSpace.lg),
          Text(
            title,
            textAlign: TextAlign.center,
            style: theme.textTheme.titleMedium,
          ),
          const SizedBox(height: HcSpace.xs),
          Text(
            message,
            textAlign: TextAlign.center,
            style: theme.textTheme.bodyMedium?.copyWith(
              color: scheme.onSurfaceVariant,
            ),
          ),
          if (action != null) ...[
            const SizedBox(height: HcSpace.lg),
            action!,
          ],
        ],
      ),
    );
  }
}

/// A failure that does not take the rest of the screen down with it. The raw
/// error is kept, but demoted below a sentence a non-developer can read.
class HcErrorState extends StatelessWidget {
  const HcErrorState({
    required this.title,
    required this.error,
    this.onRetry,
    super.key,
  });

  final String title;
  final Object error;
  final VoidCallback? onRetry;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final palette = context.hcPalette;
    final colors = palette.danger;
    final scaler = MediaQuery.textScalerOf(context);

    return HcCard(
      color: colors.fill,
      borderColor: colors.outline,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              ExcludeSemantics(
                child: Icon(
                  Icons.error_rounded,
                  size: scaler.scale(22),
                  color: colors.onFill,
                ),
              ),
              const SizedBox(width: HcSpace.md),
              Expanded(
                child: Text(
                  title,
                  style: theme.textTheme.titleMedium?.copyWith(
                    color: colors.onFill,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: HcSpace.sm),
          Text(
            '$error',
            style: theme.textTheme.bodySmall?.copyWith(color: colors.onFill),
          ),
          if (onRetry != null) ...[
            const SizedBox(height: HcSpace.md),
            OutlinedButton.icon(
              onPressed: onRetry,
              icon: const Icon(Icons.refresh_rounded),
              label: const Text('Try again'),
              style: OutlinedButton.styleFrom(
                foregroundColor: colors.onFill,
                side: BorderSide(color: colors.outline),
              ),
            ),
          ],
        ],
      ),
    );
  }
}

/// A loading placeholder that says what it is loading, so the screen is
/// never a bare spinner on an empty page.
class HcLoadingState extends StatelessWidget {
  const HcLoadingState({required this.message, super.key});

  final String message;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return HcCard(
      child: Row(
        children: [
          const SizedBox.square(
            dimension: 20,
            child: CircularProgressIndicator(strokeWidth: 2.5),
          ),
          const SizedBox(width: HcSpace.lg),
          Expanded(
            child: Text(
              message,
              style: theme.textTheme.bodyMedium?.copyWith(
                color: theme.colorScheme.onSurfaceVariant,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
