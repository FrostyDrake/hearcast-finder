import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../../models/scan_result.dart';
import '../../services/native_scan_service.dart';

class ScanScreen extends StatefulWidget {
  const ScanScreen({super.key});

  @override
  State<ScanScreen> createState() => _ScanScreenState();
}

class _ScanScreenState extends State<ScanScreen> {
  final _scanService = const NativeScanService();
  DeviceCapabilityResult? _capabilities;
  List<ScanResult> _results = const [];
  var _isLoadingCapabilities = false;
  var _isScanning = false;
  String? _message;

  @override
  void initState() {
    super.initState();
    _checkCapabilities();
  }

  @override
  Widget build(BuildContext context) {
    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        Text(
          'Bluetooth scan',
          style: Theme.of(context).textTheme.headlineSmall,
        ),
        const SizedBox(height: 8),
        const Text(
          'Native Android scan bridge is in place. Real results require an Android 13+ phone with Bluetooth permissions.',
        ),
        const SizedBox(height: 16),
        _CapabilityCard(
          capabilities: _capabilities,
          isLoading: _isLoadingCapabilities,
          onRefresh: _checkCapabilities,
        ),
        const SizedBox(height: 16),
        Wrap(
          spacing: 8,
          runSpacing: 8,
          children: [
            FilledButton.icon(
              onPressed: _isScanning ? null : _requestPermissions,
              icon: const Icon(Icons.lock_open_outlined),
              label: const Text('Permissions'),
            ),
            FilledButton.icon(
              onPressed: _isScanning ? null : _startScan,
              icon: const Icon(Icons.bluetooth_searching),
              label: const Text('Start scan'),
            ),
            OutlinedButton.icon(
              onPressed: _isScanning ? _stopScan : null,
              icon: const Icon(Icons.stop),
              label: const Text('Stop'),
            ),
          ],
        ),
        if (_message != null) ...[
          const SizedBox(height: 12),
          Text(_message!),
        ],
        const SizedBox(height: 24),
        Text(
          'Scan results',
          style: Theme.of(context).textTheme.titleMedium,
        ),
        const SizedBox(height: 8),
        if (_isScanning)
          const Card(
            child: ListTile(
              leading: CircularProgressIndicator(),
              title: Text('Scanning nearby Bluetooth LE advertisements'),
            ),
          )
        else if (_results.isEmpty)
          const Card(
            child: ListTile(
              leading: Icon(Icons.bluetooth_disabled_outlined),
              title: Text('No scan results yet'),
              subtitle: Text('Run a scan on a physical Android phone.'),
            ),
          )
        else
          for (final result in _results) _ScanResultTile(result: result),
      ],
    );
  }

  Future<void> _checkCapabilities() async {
    setState(() {
      _isLoadingCapabilities = true;
      _message = null;
    });
    try {
      final capabilities = await _scanService.checkCapabilities();
      if (mounted) {
        setState(() => _capabilities = capabilities);
      }
    } on MissingPluginException {
      if (mounted) {
        setState(() {
          _message = 'Native scanner is only available on Android builds.';
        });
      }
    } on Object catch (error) {
      if (mounted) {
        setState(() => _message = 'Capability check failed: $error');
      }
    } finally {
      if (mounted) {
        setState(() => _isLoadingCapabilities = false);
      }
    }
  }

  Future<void> _requestPermissions() async {
    try {
      await _scanService.requestScanPermissions();
      await _checkCapabilities();
    } on Object catch (error) {
      setState(() => _message = 'Permission request failed: $error');
    }
  }

  Future<void> _startScan() async {
    setState(() {
      _isScanning = true;
      _message = null;
      _results = const [];
    });
    try {
      final results = await _scanService.startScan();
      if (mounted) {
        setState(() {
          _results = results;
          _message = results.isEmpty ? 'Scan finished with no results.' : null;
        });
      }
    } on Object catch (error) {
      if (mounted) {
        setState(() => _message = 'Scan failed: $error');
      }
    } finally {
      if (mounted) {
        setState(() => _isScanning = false);
      }
    }
  }

  Future<void> _stopScan() async {
    try {
      await _scanService.stopScan();
    } on Object catch (error) {
      setState(() => _message = 'Stop scan failed: $error');
    }
  }
}

class _CapabilityCard extends StatelessWidget {
  const _CapabilityCard({
    required this.capabilities,
    required this.isLoading,
    required this.onRefresh,
  });

  final DeviceCapabilityResult? capabilities;
  final bool isLoading;
  final VoidCallback onRefresh;

  @override
  Widget build(BuildContext context) {
    final value = capabilities;
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Expanded(
                  child: Text(
                    'Device capabilities',
                    style: Theme.of(context).textTheme.titleMedium,
                  ),
                ),
                IconButton(
                  onPressed: isLoading ? null : onRefresh,
                  icon: const Icon(Icons.refresh),
                  tooltip: 'Refresh capabilities',
                ),
              ],
            ),
            if (isLoading)
              const LinearProgressIndicator()
            else if (value == null)
              const Text('No capability result yet.')
            else
              Wrap(
                spacing: 8,
                runSpacing: 8,
                children: [
                  _CapabilityChip(
                    label: 'Android ${value.androidVersion}',
                    enabled: value.isAndroid13OrNewer,
                  ),
                  _CapabilityChip(
                    label: 'Bluetooth',
                    enabled: value.hasBluetooth && value.isBluetoothEnabled,
                  ),
                  _CapabilityChip(
                    label: 'Scan permission',
                    enabled: value.hasBluetoothScanPermission,
                  ),
                  _CapabilityChip(
                    label: 'Connect permission',
                    enabled: value.hasBluetoothConnectPermission,
                  ),
                  _CapabilityChip(
                    label: 'Location permission',
                    enabled: value.hasLocationPermission,
                  ),
                  _CapabilityChip(
                    label: 'LE Audio',
                    enabled: value.isLeAudioSupported,
                  ),
                ],
              ),
          ],
        ),
      ),
    );
  }
}

class _CapabilityChip extends StatelessWidget {
  const _CapabilityChip({
    required this.label,
    required this.enabled,
  });

  final String label;
  final bool enabled;

  @override
  Widget build(BuildContext context) {
    return Chip(
      avatar: Icon(
        enabled ? Icons.check_circle_outline : Icons.cancel_outlined,
      ),
      label: Text(label),
    );
  }
}

class _ScanResultTile extends StatelessWidget {
  const _ScanResultTile({required this.result});

  final ScanResult result;

  @override
  Widget build(BuildContext context) {
    final rawPreview = result.rawAdvertisementHex.length <= 24
        ? result.rawAdvertisementHex
        : '${result.rawAdvertisementHex.substring(0, 24)}...';

    return Card(
      child: ListTile(
        leading: const Icon(Icons.bluetooth_outlined),
        title: Text(result.broadcastName.isEmpty
            ? 'Unnamed Bluetooth signal'
            : result.broadcastName),
        subtitle: Text(
          'RSSI ${result.rssi} dBm\n'
          '${result.deviceAddress}\n'
          '$rawPreview',
        ),
        isThreeLine: true,
      ),
    );
  }
}
