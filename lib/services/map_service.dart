import 'package:google_maps_flutter/google_maps_flutter.dart';

import '../models/auracast_location.dart';

class MapService {
  const MapService._();

  static const defaultCameraPosition = CameraPosition(
    target: LatLng(55.6761, 12.5683),
    zoom: 11,
  );

  static Set<Marker> markersForLocations(List<AuracastLocation> locations) {
    return locations
        .where(hasUsableCoordinates)
        .map(
          (location) => Marker(
            markerId: MarkerId(location.id),
            position: LatLng(location.latitude, location.longitude),
            infoWindow: InfoWindow(
              title: location.name,
              snippet: '${location.category.label} in ${location.city}',
            ),
          ),
        )
        .toSet();
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
}
