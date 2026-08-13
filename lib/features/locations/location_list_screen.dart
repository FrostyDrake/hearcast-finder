import 'package:flutter/material.dart';

import '../../models/auracast_location.dart';
import 'sample_locations.dart';

class LocationListScreen extends StatelessWidget {
  const LocationListScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        Text(
          'Candidate locations',
          style: Theme.of(context).textTheme.headlineSmall,
        ),
        const SizedBox(height: 8),
        const Text(
          'These examples are local-only while the data model is being shaped.',
        ),
        const SizedBox(height: 16),
        for (final location in sampleLocations)
          LocationCard(location: location),
      ],
    );
  }
}

class LocationCard extends StatelessWidget {
  const LocationCard({
    required this.location,
    super.key,
  });

  final AuracastLocation location;

  @override
  Widget build(BuildContext context) {
    return Card(
      child: ListTile(
        leading: const Icon(Icons.hearing_outlined),
        title: Text(location.name),
        subtitle: Text(
          '${location.category.label} • ${location.city}\n${location.status.label}',
        ),
        isThreeLine: true,
      ),
    );
  }
}
