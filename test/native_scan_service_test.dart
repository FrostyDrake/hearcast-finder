import 'package:flutter_test/flutter_test.dart';
import 'package:hearcast_finder/models/scan_result.dart';
import 'package:hearcast_finder/services/native_scan_service.dart';

void main() {
  test('capability result reports scan readiness', () {
    final result = DeviceCapabilityResult.fromMap({
      'androidVersion': 33,
      'isAndroid13OrNewer': true,
      'hasBluetooth': true,
      'isBluetoothEnabled': true,
      'hasBluetoothScanPermission': true,
      'hasBluetoothConnectPermission': true,
      'hasLocationPermission': true,
      'isLeAudioSupported': false,
      'isLeAudioBroadcastSourceSupported': false,
    });

    expect(result.canStartScan, isTrue);
  });

  test('scan result parses native map values', () {
    final result = ScanResult.fromMap({
      'id': 'AA:BB',
      'broadcastName': 'Main Hall Audio',
      'deviceName': 'Hall transmitter',
      'rssi': -62,
      'rawAdvertisementHex': '020106',
      'deviceAddress': 'AA:BB',
      'serviceUuids': ['0000184f-0000-1000-8000-00805f9b34fb'],
      'detectedAt': 1787060000000,
    });

    expect(result.broadcastName, 'Main Hall Audio');
    expect(result.rssi, -62);
    expect(result.serviceUuids, hasLength(1));
  });
}
