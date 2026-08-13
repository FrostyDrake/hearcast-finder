import 'package:flutter_test/flutter_test.dart';
import 'package:hearcast_finder/features/locations/location_filters.dart';
import 'package:hearcast_finder/features/locations/sample_locations.dart';
import 'package:hearcast_finder/models/auracast_location.dart';

void main() {
  test('filters locations by query', () {
    final result = filterLocations(
      locations: sampleLocations,
      query: 'station',
    );

    expect(result.map((location) => location.id), [
      'central-station-platform',
    ]);
  });

  test('filters locations by category', () {
    final result = filterLocations(
      locations: sampleLocations,
      category: LocationCategory.museum,
    );

    expect(result.map((location) => location.id), ['museum-auditorium']);
  });
}
