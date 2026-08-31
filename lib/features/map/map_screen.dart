import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:geolocator/geolocator.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';

import '../../models/auracast_location.dart';
import '../../providers/location_providers.dart';
import '../../services/map_service.dart';
import '../locations/location_details_screen.dart';

class MapScreen extends ConsumerStatefulWidget {
  const MapScreen({super.key});

  @override
  ConsumerState<MapScreen> createState() => _MapScreenState();
}

class _MapScreenState extends ConsumerState<MapScreen> {
  GoogleMapController? _mapController;
  var _hasLocationPermission = false;
  String? _locationMessage;

  @override
  void initState() {
    super.initState();
    // The map is the main screen here, so it's reasonable to ask for
    // location the moment this tab opens - never at app startup, and the
    // map stays fully usable if the answer is no.
    _requestLocationPermission();
  }

  @override
  void dispose() {
    _mapController?.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final locationsAsync = ref.watch(verifiedLocationsProvider);

    return locationsAsync.when(
      data: (locations) {
        final markers = MapService.markersForLocations(
          locations,
          onInfoWindowTap: (location) => _openDetails(context, location),
        );

        return Stack(
          children: [
            Positioned.fill(
              child: GoogleMap(
                initialCameraPosition: MapService.cameraForLocations(locations),
                markers: markers,
                myLocationEnabled: _hasLocationPermission,
                myLocationButtonEnabled: _hasLocationPermission,
                zoomControlsEnabled: false,
                onMapCreated: (controller) => _mapController = controller,
              ),
            ),
            Positioned(
              top: 12,
              left: 12,
              right: 12,
              child: _CountBadge(count: locations.length),
            ),
            if (_locationMessage != null)
              Positioned(
                left: 12,
                right: 12,
                bottom: 12,
                child: _MessageBanner(
                  message: _locationMessage!,
                  onDismiss: () => setState(() => _locationMessage = null),
                ),
              ),
            if (locations.isEmpty)
              const Positioned(
                left: 24,
                right: 24,
                bottom: 24,
                child: _EmptyMapBanner(),
              ),
          ],
        );
      },
      loading: () => const Center(child: CircularProgressIndicator()),
      error: (error, stackTrace) => _MapErrorState(error: error),
    );
  }

  void _openDetails(BuildContext context, AuracastLocation location) {
    Navigator.of(context).push(
      MaterialPageRoute<void>(
        builder: (context) => LocationDetailsScreen(location: location),
      ),
    );
  }

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

class _CountBadge extends StatelessWidget {
  const _CountBadge({required this.count});

  final int count;

  @override
  Widget build(BuildContext context) {
    return Align(
      alignment: Alignment.topLeft,
      child: Card(
        elevation: 3,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Icon(Icons.verified_outlined, size: 18),
              const SizedBox(width: 6),
              Text(
                '$count verified location${count == 1 ? '' : 's'}',
                style: Theme.of(context).textTheme.labelLarge,
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _MessageBanner extends StatelessWidget {
  const _MessageBanner({required this.message, required this.onDismiss});

  final String message;
  final VoidCallback onDismiss;

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 3,
      child: Padding(
        padding: const EdgeInsets.fromLTRB(16, 10, 8, 10),
        child: Row(
          children: [
            Expanded(child: Text(message)),
            IconButton(
              onPressed: onDismiss,
              icon: const Icon(Icons.close),
              tooltip: 'Dismiss',
              visualDensity: VisualDensity.compact,
            ),
          ],
        ),
      ),
    );
  }
}

class _EmptyMapBanner extends StatelessWidget {
  const _EmptyMapBanner();

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 3,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Row(
          children: [
            const Icon(Icons.location_off_outlined),
            const SizedBox(width: 12),
            Expanded(
              child: Text(
                'No verified locations yet. Approved locations will appear here once an admin verifies them.',
                style: Theme.of(context).textTheme.bodyMedium,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _MapErrorState extends StatelessWidget {
  const _MapErrorState({required this.error});

  final Object error;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Card(
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Icon(Icons.error_outline, size: 32),
                const SizedBox(height: 8),
                const Text('Could not load the map'),
                const SizedBox(height: 4),
                Text('$error', textAlign: TextAlign.center),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
