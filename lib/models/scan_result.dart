enum ScanResultStatus {
  localOnly,
  submitted,
  accepted,
  rejected,
}

class ScanResult {
  const ScanResult({
    required this.id,
    required this.broadcastName,
    required this.rssi,
    required this.detectedAt,
    this.status = ScanResultStatus.localOnly,
  });

  final String id;
  final String broadcastName;
  final int rssi;
  final DateTime detectedAt;
  final ScanResultStatus status;
}
