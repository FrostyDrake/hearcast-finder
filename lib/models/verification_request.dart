import 'auracast_location.dart';
import 'scan_result.dart';

enum VerificationStatus {
  pending,
  approved,
  rejected,
}

class VerificationRequest {
  const VerificationRequest({
    required this.id,
    required this.scanResultId,
    required this.locationId,
    required this.locationName,
    required this.broadcastName,
    required this.userId,
    required this.status,
    required this.createdAt,
  });

  final String id;
  final String scanResultId;
  final String locationId;
  final String locationName;
  final String broadcastName;
  final String userId;
  final VerificationStatus status;
  final DateTime createdAt;

  factory VerificationRequest.local({
    required ScanResult scanResult,
    required AuracastLocation location,
    required String userId,
    DateTime? createdAt,
  }) {
    final timestamp = createdAt ?? DateTime.now();
    return VerificationRequest(
      id: '',
      scanResultId: scanResult.id,
      locationId: location.id,
      locationName: location.name,
      broadcastName: scanResult.broadcastName,
      userId: userId,
      status: VerificationStatus.pending,
      createdAt: timestamp,
    );
  }

  factory VerificationRequest.fromMap(String id, Map<String, dynamic> map) {
    final createdAtValue = map['createdAt'];
    return VerificationRequest(
      id: id,
      scanResultId: map['scanResultId'] as String? ?? '',
      locationId: map['locationId'] as String? ?? '',
      locationName: map['locationName'] as String? ?? '',
      broadcastName: map['broadcastName'] as String? ?? '',
      userId: map['userId'] as String? ?? '',
      status: VerificationStatus.values.byName(
        map['status'] as String? ?? 'pending',
      ),
      createdAt: createdAtValue is int
          ? DateTime.fromMillisecondsSinceEpoch(createdAtValue)
          : DateTime.fromMillisecondsSinceEpoch(0),
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'scanResultId': scanResultId,
      'locationId': locationId,
      'locationName': locationName,
      'broadcastName': broadcastName,
      'userId': userId,
      'status': status.name,
      'createdAt': createdAt.millisecondsSinceEpoch,
    };
  }

  VerificationRequest copyWith({
    VerificationStatus? status,
  }) {
    return VerificationRequest(
      id: id,
      scanResultId: scanResultId,
      locationId: locationId,
      locationName: locationName,
      broadcastName: broadcastName,
      userId: userId,
      status: status ?? this.status,
      createdAt: createdAt,
    );
  }
}
