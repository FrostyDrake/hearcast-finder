import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

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

    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        Text(
          'Verified locations',
          style: Theme.of(context).textTheme.headlineSmall,
        ),
        const SizedBox(height: 8),
        const Text(
          'Places an admin has confirmed offer Auracast broadcast audio.',
        ),
        const SizedBox(height: 16),
        TextField(
          controller: _searchController,
          decoration: const InputDecoration(
            labelText: 'Search by name, city, category, or note',
            prefixIcon: Icon(Icons.search),
            border: OutlineInputBorder(),
          ),
          onChanged: (_) => setState(() {}),
        ),
        const SizedBox(height: 12),
        DropdownButtonFormField<LocationCategory?>(
          initialValue: _selectedCategory,
          decoration: const InputDecoration(
            labelText: 'Category',
            border: OutlineInputBorder(),
          ),
          items: [
            const DropdownMenuItem<LocationCategory?>(
              value: null,
              child: Text('All categories'),
            ),
            for (final category in LocationCategory.values)
              DropdownMenuItem<LocationCategory?>(
                value: category,
                child: Text(category.label),
              ),
          ],
          onChanged: (category) {
            setState(() => _selectedCategory = category);
          },
        ),
        const SizedBox(height: 16),
        locationsAsync.when(
          data: (locations) {
            final filtered = filterLocations(
              locations: locations,
              query: _searchController.text,
              category: _selectedCategory,
            );

            if (filtered.isEmpty) {
              return const _EmptyLocationsState();
            }

            return Column(
              children: [
                for (final location in filtered)
                  LocationCard(
                    location: location,
                    onTap: () => _openLocationDetails(context, location),
                  ),
              ],
            );
          },
          loading: () => const Padding(
            padding: EdgeInsets.symmetric(vertical: 24),
            child: Center(child: CircularProgressIndicator()),
          ),
          error: (error, stackTrace) => _LocationsErrorState(error: error),
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

class LocationCard extends StatelessWidget {
  const LocationCard({
    required this.location,
    required this.onTap,
    super.key,
  });

  final AuracastLocation location;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Card(
      child: ListTile(
        leading: const Icon(Icons.hearing_outlined),
        title: Text(location.name),
        subtitle: Text(
          '${location.category.label} • ${location.city}\n${location.status.label}',
        ),
        trailing: const Icon(Icons.chevron_right),
        isThreeLine: true,
        onTap: onTap,
      ),
    );
  }
}

class _EmptyLocationsState extends StatelessWidget {
  const _EmptyLocationsState();

  @override
  Widget build(BuildContext context) {
    return const Card(
      child: ListTile(
        leading: Icon(Icons.search_off_outlined),
        title: Text('No matching locations'),
        subtitle: Text('Try a different search or category.'),
      ),
    );
  }
}

class _LocationsErrorState extends StatelessWidget {
  const _LocationsErrorState({required this.error});

  final Object error;

  @override
  Widget build(BuildContext context) {
    return Card(
      child: ListTile(
        leading: const Icon(Icons.error_outline),
        title: const Text('Could not load locations'),
        subtitle: Text('$error'),
      ),
    );
  }
}
