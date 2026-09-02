import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:geolocator/geolocator.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';

import '../../core/theme/hc_palette.dart';
import '../../core/widgets/hc_states.dart';
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
    final isDark = Theme.of(context).brightness == Brightness.dark;

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
                style: isDark
                    ? MapService.darkMapStyle
                    : MapService.lightMapStyle,
                myLocationEnabled: _hasLocationPermission,
                myLocationButtonEnabled: _hasLocationPermission,
                zoomControlsEnabled: false,
                onMapCreated: (controller) => _mapController = controller,
              ),
            ),
            Positioned.fill(
              child: SafeArea(
                child: Padding(
                  padding: const EdgeInsets.all(HcSpace.md),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      _CountBadge(count: locations.length),
                      const Spacer(),
                      if (locations.isEmpty)
                        const HcEmptyState(
                          icon: Icons.location_off_outlined,
                          title: 'Nothing on the map yet',
                          message: 'Approved locations appear here once an '
                              'admin verifies them.',
                        ),
                      if (_locationMessage != null) ...[
                        const SizedBox(height: HcSpace.sm),
                        _MessageBanner(
                          message: _locationMessage!,
                          onDismiss: () =>
                              setState(() => _locationMessage = null),
                        ),
                      ],
                    ],
                  ),
                ),
              ),
            ),
          ],
        );
      },
      loading: () => const Center(child: CircularProgressIndicator()),
      error: (error, stackTrace) => Center(
        child: Padding(
          padding: const EdgeInsets.all(HcSpace.xxl),
          child: HcErrorState(
            title: 'Could not load the map',
            error: error,
            onRetry: () => ref.invalidate(verifiedLocationsProvider),
          ),
        ),
      ),
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

/// A floating pill over the map. It sits on an opaque surface rather than a
/// translucent one so its text keeps a known contrast ratio no matter what
/// the map tiles underneath happen to look like.
class _CountBadge extends StatelessWidget {
  const _CountBadge({required this.count});

  final int count;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final scheme = theme.colorScheme;
    final palette = context.hcPalette;

    return Align(
      alignment: Alignment.topLeft,
      child: Container(
        padding: const EdgeInsets.symmetric(
          horizontal: HcSpace.lg,
          vertical: HcSpace.md,
        ),
        decoration: ShapeDecoration(
          color: scheme.surfaceContainerLowest,
          shape: StadiumBorder(
            side: BorderSide(color: scheme.outlineVariant),
          ),
          shadows: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.12),
              blurRadius: 12,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            ExcludeSemantics(
              child: Icon(
                Icons.verified_rounded,
                size: MediaQuery.textScalerOf(context).scale(18),
                color: palette.verified.outline,
              ),
            ),
            const SizedBox(width: HcSpace.sm),
            Text(
              '$count verified location${count == 1 ? '' : 's'}',
              style: theme.textTheme.labelLarge?.copyWith(
                color: scheme.onSurface,
              ),
            ),
          ],
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
    final theme = Theme.of(context);
    final scheme = theme.colorScheme;

    return Container(
      padding: const EdgeInsets.fromLTRB(HcSpace.lg, HcSpace.sm, HcSpace.sm, HcSpace.sm),
      decoration: ShapeDecoration(
        color: scheme.surfaceContainerLowest,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(HcRadius.card),
          side: BorderSide(color: scheme.outlineVariant),
        ),
        shadows: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.12),
            blurRadius: 12,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        children: [
          Expanded(
            child: Text(message, style: theme.textTheme.bodyMedium),
          ),
          IconButton(
            onPressed: onDismiss,
            icon: const Icon(Icons.close_rounded),
            tooltip: 'Dismiss message',
          ),
        ],
      ),
    );
  }
}
