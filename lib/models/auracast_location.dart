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
    this.ownerId = '',
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
  final String ownerId;

  factory AuracastLocation.fromMap(String id, Map<String, dynamic> map) {
    return AuracastLocation(
      id: id,
      name: map['name'] as String? ?? '',
      address: map['address'] as String? ?? '',
      city: map['city'] as String? ?? '',
      category:
          LocationCategory.values.byName(map['category'] as String? ?? 'other'),
      status:
          LocationStatus.values.byName(map['status'] as String? ?? 'unknown'),
      latitude: (map['latitude'] as num?)?.toDouble() ?? 0,
      longitude: (map['longitude'] as num?)?.toDouble() ?? 0,
      notes: map['notes'] as String? ?? '',
      ownerId: map['ownerId'] as String? ?? '',
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'name': name,
      'address': address,
      'city': city,
      'category': category.name,
      'status': status.name,
      'latitude': latitude,
      'longitude': longitude,
      'notes': notes,
      'ownerId': ownerId,
    };
  }

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
