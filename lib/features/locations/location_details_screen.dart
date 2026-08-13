import 'package:flutter/material.dart';

import '../../models/auracast_location.dart';

class LocationDetailsScreen extends StatelessWidget {
  const LocationDetailsScreen({
    required this.location,
    super.key,
  });

  final AuracastLocation location;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Location details')),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          Text(
            location.name,
            style: Theme.of(context).textTheme.headlineSmall,
          ),
          const SizedBox(height: 8),
          Text(
            [location.address, location.city].join(', '),
            style: Theme.of(context).textTheme.bodyLarge,
          ),
          const SizedBox(height: 16),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: [
              Chip(
                avatar: const Icon(Icons.category_outlined),
                label: Text(location.category.label),
              ),
              Chip(
                avatar: const Icon(Icons.info_outline),
                label: Text(location.status.label),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Card(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Text(
                location.notes.isEmpty
                    ? 'No notes have been added for this candidate yet.'
                    : location.notes,
              ),
            ),
          ),
          const SizedBox(height: 16),
          Card(
            child: ListTile(
              leading: const Icon(Icons.location_on_outlined),
              title: const Text('Approximate coordinates'),
              subtitle: Text(
                '${location.latitude.toStringAsFixed(4)}, '
                '${location.longitude.toStringAsFixed(4)}',
              ),
            ),
          ),
          const SizedBox(height: 24),
          OutlinedButton.icon(
            onPressed: () => Navigator.of(context).pop(),
            icon: const Icon(Icons.arrow_back),
            label: const Text('Back to list'),
          ),
        ],
      ),
    );
  }
}
