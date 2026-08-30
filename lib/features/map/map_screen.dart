import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:geolocator/geolocator.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';

import '../../models/auracast_location.dart';
import '../../providers/location_providers.dart';
import '../../services/map_service.dart';

class MapScreen extends ConsumerStatefulWidget {
  const MapScreen({super.key});

  @override
  ConsumerState<MapScreen> createState() => _MapScreenState();
}

class _MapScreenState extends ConsumerState<MapScreen> {
  var _showInteractiveMap = false;
  var _hasLocationPermission = false;
  String? _locationMessage;

  @override
  Widget build(BuildContext context) {
    final locationsAsync = ref.watch(verifiedLocationsProvider);

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
            onChanged: _onToggleInteractiveMap,
          ),
        ),
        if (_locationMessage != null) ...[
          const SizedBox(height: 8),
          Text(
            _locationMessage!,
            style: Theme.of(context).textTheme.bodySmall,
          ),
        ],
        const SizedBox(height: 12),
        locationsAsync.when(
          data: (locations) {
            final markers = MapService.markersForLocations(locations);

            return Column(
              children: [
                if (_showInteractiveMap)
                  _InteractiveMap(
                    locations: locations,
                    markers: markers,
                    myLocationEnabled: _hasLocationPermission,
                  )
                else
                  _StaticMapSummary(markers: markers),
                const SizedBox(height: 16),
                Align(
                  alignment: Alignment.centerLeft,
                  child: Text(
                    'Mapped locations',
                    style: Theme.of(context).textTheme.titleMedium,
                  ),
                ),
                const SizedBox(height: 8),
                if (locations.isEmpty)
                  const _EmptyMapState()
                else
                  for (final location in locations)
                    _MapLocationTile(location: location),
              ],
            );
          },
          loading: () => const Padding(
            padding: EdgeInsets.symmetric(vertical: 24),
            child: Center(child: CircularProgressIndicator()),
          ),
          error: (error, stackTrace) => _MapErrorState(error: error),
        ),
      ],
    );
  }

  Future<void> _onToggleInteractiveMap(bool value) async {
    setState(() => _showInteractiveMap = value);
    if (value && !_hasLocationPermission) {
      await _requestLocationPermission();
    }
  }

  /// Only asked for once the user actually opens the interactive map, never
  /// on app startup — the map (and the rest of the app) works fine without it.
  Future<void> _requestLocationPermission() async {
    try {
      final serviceEnabled = await Geolocator.isLocationServiceEnabled();
      if (!serviceEnabled) {
        if (mounted) {
          setState(() {
            _locationMessage =
                'Turn on device location to see your position on the map.';
          });
        }
        return;
      }

      var permission = await Geolocator.checkPermission();
      if (permission == LocationPermission.denied) {
        permission = await Geolocator.requestPermission();
      }

      final granted = permission == LocationPermission.always ||
          permission == LocationPermission.whileInUse;

      if (mounted) {
        setState(() {
          _hasLocationPermission = granted;
          _locationMessage = granted
              ? null
              : 'Location permission denied — the map still works without it.';
        });
      }
    } on Object catch (error) {
      if (mounted) {
        setState(() => _locationMessage = 'Could not check location: $error');
      }
    }
  }
}

class _InteractiveMap extends StatelessWidget {
  const _InteractiveMap({
    required this.locations,
    required this.markers,
    required this.myLocationEnabled,
  });

  final List<AuracastLocation> locations;
  final Set<Marker> markers;
  final bool myLocationEnabled;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 280,
      child: ClipRRect(
        borderRadius: BorderRadius.circular(12),
        child: GoogleMap(
          initialCameraPosition: MapService.cameraForLocations(locations),
          markers: markers,
          myLocationEnabled: myLocationEnabled,
          myLocationButtonEnabled: myLocationEnabled,
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

class _EmptyMapState extends StatelessWidget {
  const _EmptyMapState();

  @override
  Widget build(BuildContext context) {
    return const Card(
      child: ListTile(
        leading: Icon(Icons.location_off_outlined),
        title: Text('No verified locations yet'),
        subtitle: Text('Approved locations will appear here once an admin verifies them.'),
      ),
    );
  }
}

class _MapErrorState extends StatelessWidget {
  const _MapErrorState({required this.error});

  final Object error;

  @override
  Widget build(BuildContext context) {
    return Card(
      child: ListTile(
        leading: const Icon(Icons.error_outline),
        title: const Text('Could not load the map'),
        subtitle: Text('$error'),
      ),
    );
  }
}
