import 'package:flutter/services.dart';

import '../models/scan_result.dart';

class DeviceCapabilityResult {
  const DeviceCapabilityResult({
    required this.androidVersion,
    required this.isAndroid13OrNewer,
    required this.hasBluetooth,
    required this.isBluetoothEnabled,
    required this.hasBluetoothScanPermission,
    required this.hasBluetoothConnectPermission,
    required this.hasLocationPermission,
    required this.isLeAudioSupported,
    required this.isLeAudioBroadcastSourceSupported,
  });

  final int androidVersion;
  final bool isAndroid13OrNewer;
  final bool hasBluetooth;
  final bool isBluetoothEnabled;
  final bool hasBluetoothScanPermission;
  final bool hasBluetoothConnectPermission;
  final bool hasLocationPermission;
  final bool isLeAudioSupported;
  final bool isLeAudioBroadcastSourceSupported;

  bool get canStartScan {
    return isAndroid13OrNewer &&
        hasBluetooth &&
        isBluetoothEnabled &&
        hasBluetoothScanPermission &&
        hasBluetoothConnectPermission &&
        hasLocationPermission;
  }

  factory DeviceCapabilityResult.fromMap(Map<String, dynamic> map) {
    return DeviceCapabilityResult(
      androidVersion: map['androidVersion'] as int? ?? 0,
      isAndroid13OrNewer: map['isAndroid13OrNewer'] as bool? ?? false,
      hasBluetooth: map['hasBluetooth'] as bool? ?? false,
      isBluetoothEnabled: map['isBluetoothEnabled'] as bool? ?? false,
      hasBluetoothScanPermission:
          map['hasBluetoothScanPermission'] as bool? ?? false,
      hasBluetoothConnectPermission:
          map['hasBluetoothConnectPermission'] as bool? ?? false,
      hasLocationPermission: map['hasLocationPermission'] as bool? ?? false,
      isLeAudioSupported: map['isLeAudioSupported'] as bool? ?? false,
      isLeAudioBroadcastSourceSupported:
          map['isLeAudioBroadcastSourceSupported'] as bool? ?? false,
    );
  }
}

class NativeScanService {
  const NativeScanService();

  static const channelName = 'hearcast/auracast_scanner';
  static const _channel = MethodChannel(channelName);

  Future<DeviceCapabilityResult> checkCapabilities() async {
    final result = await _channel.invokeMapMethod<String, dynamic>(
      'checkCapabilities',
    );
    if (result == null) {
      throw StateError('No capability result returned from native Android.');
    }
    return DeviceCapabilityResult.fromMap(result);
  }

  Future<void> requestScanPermissions() async {
    await _channel.invokeMethod<void>('requestScanPermissions');
  }

  Future<List<ScanResult>> startScan() async {
    final result = await _channel.invokeListMethod<dynamic>('startScan');
    if (result == null) {
      return [];
    }

    return result
        .map(
          (item) => ScanResult.fromMap(
            Map<String, dynamic>.from(item as Map),
          ),
        )
        .toList();
  }

  Future<void> stopScan() async {
    await _channel.invokeMethod<void>('stopScan');
  }
}
