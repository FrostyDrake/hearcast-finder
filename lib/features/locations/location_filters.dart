import '../../models/auracast_location.dart';

List<AuracastLocation> filterLocations({
  required List<AuracastLocation> locations,
  String query = '',
  LocationCategory? category,
}) {
  final filtered = locations.where((location) {
    final matchesCategory = category == null || location.category == category;
    return matchesCategory && location.matchesQuery(query);
  }).toList();

  filtered.sort((a, b) => a.name.compareTo(b.name));
  return filtered;
}
