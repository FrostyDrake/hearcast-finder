enum LocationCategory {
  cinema,
  church,
  museum,
  school,
  conference,
  transport,
  hospital,
  other,
}

extension LocationCategoryLabel on LocationCategory {
  String get label {
    return switch (this) {
      LocationCategory.cinema => 'Cinema',
      LocationCategory.church => 'Church',
      LocationCategory.museum => 'Museum',
      LocationCategory.school => 'School',
      LocationCategory.conference => 'Conference',
      LocationCategory.transport => 'Transport',
      LocationCategory.hospital => 'Hospital',
      LocationCategory.other => 'Other',
    };
  }
}

enum LocationStatus {
  candidate,
  verified,
  unknown,
}

extension LocationStatusLabel on LocationStatus {
  String get label {
    return switch (this) {
      LocationStatus.candidate => 'Candidate',
      LocationStatus.verified => 'Verified',
      LocationStatus.unknown => 'Unknown',
    };
  }
}

class AuracastLocation {
  const AuracastLocation({
    required this.id,
    required this.name,
    required this.address,
    required this.city,
    required this.category,
    required this.status,
    required this.latitude,
    required this.longitude,
    this.notes = '',
  });

  final String id;
  final String name;
  final String address;
  final String city;
  final LocationCategory category;
  final LocationStatus status;
  final double latitude;
  final double longitude;
  final String notes;

  bool matchesQuery(String query) {
    final normalizedQuery = query.trim().toLowerCase();
    if (normalizedQuery.isEmpty) {
      return true;
    }

    return [
      name,
      address,
      city,
      category.label,
      status.label,
      notes,
    ].any((value) => value.toLowerCase().contains(normalizedQuery));
  }
}
