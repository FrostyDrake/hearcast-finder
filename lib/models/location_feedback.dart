enum LocationReportReason {
  incorrectInfo,
  noBroadcastFound,
  accessibilityIssue,
}

extension LocationReportReasonLabel on LocationReportReason {
  String get label {
    return switch (this) {
      LocationReportReason.incorrectInfo => 'Incorrect information',
      LocationReportReason.noBroadcastFound => 'No broadcast found',
      LocationReportReason.accessibilityIssue => 'Accessibility issue',
    };
  }
}

class FavoriteLocation {
  const FavoriteLocation({
    required this.id,
    required this.userId,
    required this.locationId,
    required this.createdAt,
  });

  final String id;
  final String userId;
  final String locationId;
  final DateTime createdAt;

  factory FavoriteLocation.local({
    required String locationId,
    String userId = 'local-user',
    DateTime? createdAt,
  }) {
    final timestamp = createdAt ?? DateTime.now();
    return FavoriteLocation(
      id: 'favorite-$locationId',
      userId: userId,
      locationId: locationId,
      createdAt: timestamp,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'userId': userId,
      'locationId': locationId,
      'createdAt': createdAt.millisecondsSinceEpoch,
    };
  }
}

class LocationReview {
  const LocationReview({
    required this.id,
    required this.userId,
    required this.locationId,
    required this.rating,
    required this.comment,
    required this.createdAt,
  });

  final String id;
  final String userId;
  final String locationId;
  final int rating;
  final String comment;
  final DateTime createdAt;

  factory LocationReview.local({
    required String locationId,
    required int rating,
    required String comment,
    String userId = 'local-user',
    DateTime? createdAt,
  }) {
    final timestamp = createdAt ?? DateTime.now();
    return LocationReview(
      id: 'review-$locationId-${timestamp.millisecondsSinceEpoch}',
      userId: userId,
      locationId: locationId,
      rating: rating,
      comment: comment.trim(),
      createdAt: timestamp,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'userId': userId,
      'locationId': locationId,
      'rating': rating,
      'comment': comment,
      'createdAt': createdAt.millisecondsSinceEpoch,
    };
  }
}

class LocationReport {
  const LocationReport({
    required this.id,
    required this.userId,
    required this.locationId,
    required this.reason,
    required this.createdAt,
  });

  final String id;
  final String userId;
  final String locationId;
  final LocationReportReason reason;
  final DateTime createdAt;

  factory LocationReport.local({
    required String locationId,
    required LocationReportReason reason,
    String userId = 'local-user',
    DateTime? createdAt,
  }) {
    final timestamp = createdAt ?? DateTime.now();
    return LocationReport(
      id: 'report-$locationId-${timestamp.millisecondsSinceEpoch}',
      userId: userId,
      locationId: locationId,
      reason: reason,
      createdAt: timestamp,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'userId': userId,
      'locationId': locationId,
      'reason': reason.name,
      'createdAt': createdAt.millisecondsSinceEpoch,
    };
  }
}
