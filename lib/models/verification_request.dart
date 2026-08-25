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
    required this.status,
    required this.createdAt,
  });

  final String id;
  final String scanResultId;
  final String locationId;
  final String locationName;
  final String broadcastName;
  final VerificationStatus status;
  final DateTime createdAt;

  factory VerificationRequest.local({
    required ScanResult scanResult,
    required AuracastLocation location,
    DateTime? createdAt,
  }) {
    final timestamp = createdAt ?? DateTime.now();
    return VerificationRequest(
      id: 'local-${scanResult.id}-${location.id}',
      scanResultId: scanResult.id,
      locationId: location.id,
      locationName: location.name,
      broadcastName: scanResult.broadcastName,
      status: VerificationStatus.pending,
      createdAt: timestamp,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'scanResultId': scanResultId,
      'locationId': locationId,
      'locationName': locationName,
      'broadcastName': broadcastName,
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
      status: status ?? this.status,
      createdAt: createdAt,
    );
  }
}
