import 'package:flutter/material.dart';

import '../../core/theme/hc_palette.dart';
import '../../core/widgets/hc_layout.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({
    required this.onBrowseLocations,
    super.key,
  });

  final VoidCallback onBrowseLocations;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final scheme = theme.colorScheme;

    return HcScreen(
      children: [
        const HcPageHeader(
          title: 'Find public audio locations',
          subtitle:
              'Places that broadcast sound over Bluetooth, so hearing aids '
              'and earbuds can listen in directly.',
        ),
        HcCard(
          color: scheme.primaryContainer,
          borderColor: scheme.primaryContainer,
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              ExcludeSemantics(
                child: Icon(
                  Icons.hearing_rounded,
                  size: MediaQuery.textScalerOf(context).scale(26),
                  color: scheme.onPrimaryContainer,
                ),
              ),
              const SizedBox(width: HcSpace.md),
              Expanded(
                child: Text(
                  'Auracast replaces the hearing loop. It sends audio to '
                  'unlimited listeners at once, with no pairing — but almost '
                  'nowhere signposts it. This app is the map.',
                  style: theme.textTheme.bodyMedium?.copyWith(
                    color: scheme.onPrimaryContainer,
                  ),
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: HcSpace.xxl),
        const HcSectionHeader(
          title: 'How it works',
          subtitle: 'Three steps, and the last one is what makes the data '
              'trustworthy.',
        ),
        const HcListGroup(
          dividerIndent: 60,
          children: [
            _HowToRow(
              step: '1',
              icon: Icons.travel_explore_rounded,
              title: 'Plan before you go',
              body: 'Search the map or the list for a cinema, church or '
                  'station near you.',
            ),
            _HowToRow(
              step: '2',
              icon: Icons.wifi_tethering_rounded,
              title: 'Confirm on the spot',
              body: 'Run a real Bluetooth scan. Only actual audio broadcasts '
                  'are shown — not every gadget in the room.',
            ),
            _HowToRow(
              step: '3',
              icon: Icons.verified_rounded,
              title: 'Send in what you found',
              body: 'Your scan becomes evidence an admin reviews, so the map '
                  'stays true as equipment comes and goes.',
            ),
          ],
        ),
        const SizedBox(height: HcSpace.xxl),
        FilledButton.icon(
          onPressed: onBrowseLocations,
          icon: const Icon(Icons.place_outlined),
          label: const Text('Browse verified locations'),
        ),
      ],
    );
  }
}

class _HowToRow extends StatelessWidget {
  const _HowToRow({
    required this.step,
    required this.icon,
    required this.title,
    required this.body,
  });

  final String step;
  final IconData icon;
  final String title;
  final String body;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final scheme = theme.colorScheme;
    final scaler = MediaQuery.textScalerOf(context);
    final box = scaler.scale(32);

    return MergeSemantics(
      child: Padding(
        padding: const EdgeInsets.all(HcSpace.lg),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            ExcludeSemantics(
              child: Container(
                width: box,
                height: box,
                alignment: Alignment.center,
                decoration: ShapeDecoration(
                  color: scheme.surfaceContainerHigh,
                  shape: const CircleBorder(),
                ),
                child: Text(
                  step,
                  style: theme.textTheme.labelLarge?.copyWith(
                    color: scheme.onSurfaceVariant,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),
            ),
            const SizedBox(width: HcSpace.md),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      ExcludeSemantics(
                        child: Icon(
                          icon,
                          size: scaler.scale(18),
                          color: scheme.primary,
                        ),
                      ),
                      const SizedBox(width: HcSpace.sm),
                      Expanded(
                        child: Text(title, style: theme.textTheme.titleMedium),
                      ),
                    ],
                  ),
                  const SizedBox(height: HcSpace.xs),
                  Text(
                    body,
                    style: theme.textTheme.bodyMedium?.copyWith(
                      color: scheme.onSurfaceVariant,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
