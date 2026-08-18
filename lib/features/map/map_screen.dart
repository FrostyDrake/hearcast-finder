import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';

import '../../models/auracast_location.dart';
import '../../services/map_service.dart';
import '../locations/sample_locations.dart';

class MapScreen extends StatefulWidget {
  const MapScreen({super.key});

  @override
  State<MapScreen> createState() => _MapScreenState();
}

class _MapScreenState extends State<MapScreen> {
  var _showInteractiveMap = false;

  @override
  Widget build(BuildContext context) {
    final markers = MapService.markersForLocations(sampleLocations);

    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        Text(
          'Map preview',
          style: Theme.of(context).textTheme.headlineSmall,
        ),
        const SizedBox(height: 8),
        const Text(
          'Google Maps dependency is added. The interactive map is kept optional until Android API key setup is finished.',
        ),
        const SizedBox(height: 16),
        Card(
          child: SwitchListTile(
            title: const Text('Show interactive Google Map'),
            subtitle: const Text('Requires a valid Maps SDK Android key later.'),
            value: _showInteractiveMap,
            onChanged: (value) => setState(() => _showInteractiveMap = value),
          ),
        ),
        const SizedBox(height: 12),
        if (_showInteractiveMap)
          _InteractiveMap(markers: markers)
        else
          _StaticMapSummary(markers: markers),
        const SizedBox(height: 16),
        Text(
          'Mapped candidate locations',
          style: Theme.of(context).textTheme.titleMedium,
        ),
        const SizedBox(height: 8),
        for (final location in sampleLocations)
          _MapLocationTile(location: location),
      ],
    );
  }
}

class _InteractiveMap extends StatelessWidget {
  const _InteractiveMap({required this.markers});

  final Set<Marker> markers;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 280,
      child: ClipRRect(
        borderRadius: BorderRadius.circular(12),
        child: GoogleMap(
          initialCameraPosition:
              MapService.cameraForLocations(sampleLocations),
          markers: markers,
          myLocationButtonEnabled: false,
          zoomControlsEnabled: false,
        ),
      ),
    );
  }
}

class _StaticMapSummary extends StatelessWidget {
  const _StaticMapSummary({required this.markers});

  final Set<Marker> markers;

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Icon(Icons.map_outlined, size: 40),
            const SizedBox(height: 12),
            Text(
              '${markers.length} map markers prepared',
              style: Theme.of(context).textTheme.titleMedium,
            ),
            const SizedBox(height: 8),
            const Text(
              'This static preview keeps the app usable before the Android Maps API key is configured.',
            ),
          ],
        ),
      ),
    );
  }
}

class _MapLocationTile extends StatelessWidget {
  const _MapLocationTile({required this.location});

  final AuracastLocation location;

  @override
  Widget build(BuildContext context) {
    return Card(
      child: ListTile(
        leading: const Icon(Icons.location_on_outlined),
        title: Text(location.name),
        subtitle: Text(
          '${location.city} • ${location.latitude.toStringAsFixed(4)}, '
          '${location.longitude.toStringAsFixed(4)}',
        ),
      ),
    );
  }
}
