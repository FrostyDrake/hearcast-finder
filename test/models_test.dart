import 'package:flutter_test/flutter_test.dart';
import 'package:hearcast_finder/models/auracast_location.dart';
import 'package:hearcast_finder/models/scan_result.dart';

void main() {
  test('location category labels are readable', () {
    expect(LocationCategory.conference.label, 'Conference');
    expect(LocationCategory.transport.label, 'Transport');
  });

  test('scan results start as local-only by default', () {
    final result = ScanResult(
      id: 'scan-1',
      broadcastName: 'Main Hall Audio',
      rssi: -62,
      detectedAt: DateTime.utc(2026, 8, 12),
    );

    expect(result.status, ScanResultStatus.localOnly);
  });
}
