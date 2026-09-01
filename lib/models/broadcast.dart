enum BroadcastAccessType {
  public,
  private,
  unknown,
}

extension BroadcastAccessTypeLabel on BroadcastAccessType {
  String get label {
    return switch (this) {
      BroadcastAccessType.public => 'Public',
      BroadcastAccessType.private => 'Private',
      BroadcastAccessType.unknown => 'Unknown',
    };
  }
}

/// A known broadcast profile for a location - metadata about a specific
/// Auracast stream the location is known to offer (e.g. "Main Hall Audio",
/// English, public), separate from any live scan result.
class Broadcast {
  const Broadcast({
    required this.id,
    required this.locationId,
    required this.name,
    required this.language,
    this.accessType = BroadcastAccessType.unknown,
    this.description = '',
  });

  final String id;
  final String locationId;
  final String name;
  final String language;
  final BroadcastAccessType accessType;
  final String description;

  factory Broadcast.fromMap(
    String id,
    String locationId,
    Map<String, dynamic> map,
  ) {
    return Broadcast(
      id: id,
      locationId: locationId,
      name: map['name'] as String? ?? '',
      language: map['language'] as String? ?? '',
      accessType: BroadcastAccessType.values.byName(
        map['accessType'] as String? ?? 'unknown',
      ),
      description: map['description'] as String? ?? '',
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'locationId': locationId,
      'name': name,
      'language': language,
      'accessType': accessType.name,
      'description': description,
    };
  }
}
