import 'package:google_maps_flutter/google_maps_flutter.dart';

import '../models/auracast_location.dart';

class MapService {
  const MapService._();

  static const defaultCameraPosition = CameraPosition(
    target: LatLng(55.6761, 12.5683),
    zoom: 11,
  );

  static Set<Marker> markersForLocations(
    List<AuracastLocation> locations, {
    void Function(AuracastLocation location)? onInfoWindowTap,
  }) {
    return locations
        .where(hasUsableCoordinates)
        .map(
          (location) => Marker(
            markerId: MarkerId(location.id),
            position: LatLng(location.latitude, location.longitude),
            icon: BitmapDescriptor.defaultMarkerWithHue(_hueFor(location.status)),
            infoWindow: InfoWindow(
              title: location.name,
              // The status is written into the snippet as well as encoded in
              // the pin colour, so the state is never carried by hue alone.
              snippet: '${location.status.label} · ${location.category.label}'
                  ' in ${location.city} · tap for details',
              onTap: onInfoWindowTap == null
                  ? null
                  : () => onInfoWindowTap(location),
            ),
          ),
        )
        .toSet();
  }

  static double _hueFor(LocationStatus status) {
    return switch (status) {
      LocationStatus.verified => BitmapDescriptor.hueGreen,
      LocationStatus.candidate => BitmapDescriptor.hueOrange,
      LocationStatus.unknown => BitmapDescriptor.hueAzure,
    };
  }

  static CameraPosition cameraForLocations(List<AuracastLocation> locations) {
    final usableLocations = locations.where(hasUsableCoordinates).toList();
    if (usableLocations.isEmpty) {
      return defaultCameraPosition;
    }

    final first = usableLocations.first;
    return CameraPosition(
      target: LatLng(first.latitude, first.longitude),
      zoom: 12,
    );
  }

  static bool hasUsableCoordinates(AuracastLocation location) {
    return location.latitude >= -90 &&
        location.latitude <= 90 &&
        location.longitude >= -180 &&
        location.longitude <= 180 &&
        (location.latitude != 0 || location.longitude != 0);
  }

  /// Hides commercial POI clutter so the app's own pins are the most
  /// prominent thing on the map.
  static const lightMapStyle = '''
[
  {"featureType":"poi.business","stylers":[{"visibility":"off"}]},
  {"featureType":"poi.attraction","elementType":"labels.icon","stylers":[{"visibility":"off"}]},
  {"featureType":"transit","elementType":"labels.icon","stylers":[{"visibility":"off"}]},
  {"featureType":"road","elementType":"labels.icon","stylers":[{"visibility":"off"}]}
]''';

  /// A dark basemap keyed to the app's dark surfaces. Without it, opening the
  /// Map tab at night detonates a full-brightness white rectangle - the exact
  /// glare a dark-mode user turned dark mode on to avoid.
  static const darkMapStyle = '''
[
  {"elementType":"geometry","stylers":[{"color":"#1a2220"}]},
  {"elementType":"labels.text.fill","stylers":[{"color":"#a6b2af"}]},
  {"elementType":"labels.text.stroke","stylers":[{"color":"#0f1513"}]},
  {"featureType":"poi.business","stylers":[{"visibility":"off"}]},
  {"featureType":"poi.park","elementType":"geometry","stylers":[{"color":"#152a1e"}]},
  {"featureType":"road","elementType":"geometry","stylers":[{"color":"#2d3533"}]},
  {"featureType":"road","elementType":"labels.text.fill","stylers":[{"color":"#8c9794"}]},
  {"featureType":"road","elementType":"labels.icon","stylers":[{"visibility":"off"}]},
  {"featureType":"road.highway","elementType":"geometry","stylers":[{"color":"#414a48"}]},
  {"featureType":"transit","elementType":"labels.icon","stylers":[{"visibility":"off"}]},
  {"featureType":"water","elementType":"geometry","stylers":[{"color":"#0a100f"}]}
]''';
}
