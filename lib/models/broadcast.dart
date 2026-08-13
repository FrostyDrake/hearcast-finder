enum BroadcastAccessType {
  public,
  private,
  unknown,
}

class Broadcast {
  const Broadcast({
    required this.id,
    required this.locationId,
    required this.name,
    required this.language,
    this.accessType = BroadcastAccessType.unknown,
  });

  final String id;
  final String locationId;
  final String name;
  final String language;
  final BroadcastAccessType accessType;
}
