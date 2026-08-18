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
    this.deviceName,
    this.rawAdvertisementHex = '',
    this.deviceAddress = '',
    this.serviceUuids = const [],
    this.status = ScanResultStatus.localOnly,
  });

  final String id;
  final String broadcastName;
  final int rssi;
  final DateTime detectedAt;
  final String? deviceName;
  final String rawAdvertisementHex;
  final String deviceAddress;
  final List<String> serviceUuids;
  final ScanResultStatus status;

  factory ScanResult.fromMap(Map<String, dynamic> map) {
    final detectedAtValue = map['detectedAt'];
    return ScanResult(
      id: map['id'] as String? ?? '',
      broadcastName: map['broadcastName'] as String? ?? '',
      rssi: map['rssi'] as int? ?? 0,
      detectedAt: detectedAtValue is int
          ? DateTime.fromMillisecondsSinceEpoch(detectedAtValue)
          : DateTime.fromMillisecondsSinceEpoch(0),
      deviceName: map['deviceName'] as String?,
      rawAdvertisementHex: map['rawAdvertisementHex'] as String? ?? '',
      deviceAddress: map['deviceAddress'] as String? ?? '',
      serviceUuids: (map['serviceUuids'] as List<dynamic>? ?? [])
          .map((value) => value.toString())
          .toList(),
      status: ScanResultStatus.localOnly,
    );
  }
}
