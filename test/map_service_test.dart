import 'package:flutter_test/flutter_test.dart';
import 'package:hearcast_finder/features/locations/sample_locations.dart';
import 'package:hearcast_finder/models/auracast_location.dart';
import 'package:hearcast_finder/services/map_service.dart';

void main() {
  test('creates markers for sample locations', () {
    final markers = MapService.markersForLocations(sampleLocations);

    expect(markers.length, sampleLocations.length);
    expect(
      markers.map((marker) => marker.markerId.value),
      contains('city-conference-hall'),
    );
  });

  test('rejects unusable coordinates', () {
    const invalid = AuracastLocation(
      id: 'bad',
      name: 'Bad coordinate',
      address: '',
      city: '',
      category: LocationCategory.other,
      status: LocationStatus.unknown,
      latitude: 91,
      longitude: 0,
    );

    expect(MapService.hasUsableCoordinates(invalid), isFalse);
  });
}
