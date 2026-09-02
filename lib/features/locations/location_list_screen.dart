import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/theme/hc_palette.dart';
import '../../core/widgets/hc_category.dart';
import '../../core/widgets/hc_layout.dart';
import '../../core/widgets/hc_states.dart';
import '../../core/widgets/hc_status.dart';
import '../../models/auracast_location.dart';
import '../../providers/location_providers.dart';
import 'location_details_screen.dart';
import 'location_filters.dart';

class LocationListScreen extends ConsumerStatefulWidget {
  const LocationListScreen({super.key});

  @override
  ConsumerState<LocationListScreen> createState() => _LocationListScreenState();
}

class _LocationListScreenState extends ConsumerState<LocationListScreen> {
  final _searchController = TextEditingController();
  LocationCategory? _selectedCategory;

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final locationsAsync = ref.watch(verifiedLocationsProvider);
    final hasQuery = _searchController.text.trim().isNotEmpty;

    return HcScreen(
      children: [
        const HcPageHeader(
          title: 'Verified locations',
          subtitle: 'Places an admin has confirmed offer Auracast broadcast '
              'audio.',
        ),
        TextField(
          controller: _searchController,
          decoration: InputDecoration(
            // A short label, with the full description as helper text.
            //
            // A floating label lives in the gap of the outline border, which
            // is one line wide and cannot wrap - at 200% system text the long
            // version truncated to "Search by name, city, categ...", which is
            // a loss of content under WCAG 2.1 SC 1.4.4. Helper text has a
            // `helperMaxLines`, so it wraps instead of being cut off.
            labelText: 'Search',
            floatingLabelBehavior: FloatingLabelBehavior.always,
            helperText: 'Search by name, city, category, or note',
            helperMaxLines: 3,
            prefixIcon: const Icon(Icons.search_rounded),
            suffixIcon: hasQuery
                ? IconButton(
                    onPressed: () {
                      _searchController.clear();
                      setState(() {});
                    },
                    icon: const Icon(Icons.close_rounded),
                    tooltip: 'Clear search',
                  )
                : null,
          ),
          textInputAction: TextInputAction.search,
          onChanged: (_) => setState(() {}),
        ),
        const SizedBox(height: HcSpace.lg),
        _CategoryFilter(
          selected: _selectedCategory,
          onChanged: (category) {
            setState(() => _selectedCategory = category);
          },
        ),
        const SizedBox(height: HcSpace.xl),
        locationsAsync.when(
          data: (locations) {
            final filtered = filterLocations(
              locations: locations,
              query: _searchController.text,
              category: _selectedCategory,
            );

            if (filtered.isEmpty) {
              return HcEmptyState(
                icon: locations.isEmpty
                    ? Icons.location_off_outlined
                    : Icons.search_off_rounded,
                title: locations.isEmpty
                    ? 'No verified places yet'
                    : 'No matching locations',
                message: locations.isEmpty
                    ? 'Approved places appear here once an admin verifies '
                        'them.'
                    : 'Try a different search term, or clear the category '
                        'filter.',
                action: locations.isEmpty
                    ? null
                    : OutlinedButton.icon(
                        onPressed: () {
                          _searchController.clear();
                          setState(() => _selectedCategory = null);
                        },
                        icon: const Icon(Icons.filter_alt_off_outlined),
                        label: const Text('Reset filters'),
                      ),
              );
            }

            return Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _ResultCount(shown: filtered.length, total: locations.length),
                const SizedBox(height: HcSpace.md),
                HcListGroup(
                  children: [
                    for (final location in filtered)
                      _LocationRow(
                        location: location,
                        onTap: () => _openLocationDetails(context, location),
                      ),
                  ],
                ),
              ],
            );
          },
          loading: () => const HcLoadingState(
            message: 'Loading verified locations…',
          ),
          error: (error, stackTrace) => HcErrorState(
            title: 'Could not load locations',
            error: error,
            onRetry: () => ref.invalidate(verifiedLocationsProvider),
          ),
        ),
      ],
    );
  }

  Future<void> _openLocationDetails(
    BuildContext context,
    AuracastLocation location,
  ) {
    return Navigator.of(context).push(
      MaterialPageRoute<void>(
        builder: (context) => LocationDetailsScreen(location: location),
      ),
    );
  }
}

class _ResultCount extends StatelessWidget {
  const _ResultCount({required this.shown, required this.total});

  final int shown;
  final int total;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final label = shown == total
        ? '$total place${total == 1 ? '' : 's'}'
        : 'Showing $shown of $total places';

    return Text(
      label,
      style: theme.textTheme.labelLarge?.copyWith(
        color: theme.colorScheme.onSurfaceVariant,
      ),
    );
  }
}

/// A wrapping panel of category chips rather than a dropdown.
///
/// A Wrap keeps every option visible and simply grows taller at large text
/// sizes; a horizontally scrolling row would hide options off-screen, which
/// is exactly the wrong trade for a low-vision audience.
class _CategoryFilter extends StatelessWidget {
  const _CategoryFilter({required this.selected, required this.onChanged});

  final LocationCategory? selected;
  final ValueChanged<LocationCategory?> onChanged;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Category',
          style: theme.textTheme.labelLarge?.copyWith(
            color: theme.colorScheme.onSurfaceVariant,
          ),
        ),
        const SizedBox(height: HcSpace.sm),
        Wrap(
          spacing: HcSpace.sm,
          runSpacing: HcSpace.sm,
          children: [
            _CategoryChip(
              label: 'All',
              icon: Icons.apps_rounded,
              selected: selected == null,
              onSelected: () => onChanged(null),
            ),
            for (final category in LocationCategory.values)
              _CategoryChip(
                label: category.label,
                icon: category.icon,
                selected: selected == category,
                onSelected: () => onChanged(category),
              ),
          ],
        ),
      ],
    );
  }
}

class _CategoryChip extends StatelessWidget {
  const _CategoryChip({
    required this.label,
    required this.icon,
    required this.selected,
    required this.onSelected,
  });

  final String label;
  final IconData icon;
  final bool selected;
  final VoidCallback onSelected;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;

    // Selection is carried by fill, border weight AND a check glyph, so it
    // never rests on colour alone.
    return FilterChip(
      selected: selected,
      onSelected: (_) => onSelected(),
      avatar: Icon(
        selected ? Icons.check_rounded : icon,
        size: MediaQuery.textScalerOf(context).scale(18),
        color: selected ? scheme.onPrimaryContainer : scheme.onSurfaceVariant,
      ),
      label: Text(label),
      selectedColor: scheme.primaryContainer,
      backgroundColor: scheme.surfaceContainerLowest,
      side: BorderSide(
        color: selected ? scheme.primary : scheme.outline,
        width: selected ? 1.5 : 1,
      ),
      labelStyle: TextStyle(
        color: selected ? scheme.onPrimaryContainer : scheme.onSurface,
        fontWeight: selected ? FontWeight.w700 : FontWeight.w600,
      ),
      showCheckmark: false,
      padding: const EdgeInsets.symmetric(
        horizontal: HcSpace.sm,
        vertical: HcSpace.md,
      ),
    );
  }
}

class _LocationRow extends StatelessWidget {
  const _LocationRow({required this.location, required this.onTap});

  final AuracastLocation location;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final palette = context.hcPalette;
    final descriptor = HcStatusDescriptor.forLocation(
      location.status,
      palette,
    );

    return HcListRow(
      onTap: onTap,
      leading: HcCategoryAvatar(category: location.category),
      title: location.name,
      subtitle: '${location.category.label} · ${location.city}',
      badges: [HcStatusBadge(descriptor: descriptor)],
      // One announcement per row instead of four fragments.
      semanticLabel: '${location.name}, ${location.category.label} in '
          '${location.city}, status ${descriptor.label}',
      trailing: Padding(
        padding: const EdgeInsets.only(top: HcSpace.xs),
        child: ExcludeSemantics(
          child: Icon(
            Icons.chevron_right_rounded,
            color: Theme.of(context).colorScheme.onSurfaceVariant,
          ),
        ),
      ),
    );
  }
}
