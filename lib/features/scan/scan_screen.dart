import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../models/auracast_location.dart';
import '../../models/scan_result.dart';
import '../../models/verification_request.dart';
import '../../providers/firebase_providers.dart';
import '../../providers/location_providers.dart';
import '../../providers/session_providers.dart';
import '../../services/native_scan_service.dart';

class ScanScreen extends ConsumerStatefulWidget {
  const ScanScreen({super.key});

  @override
  ConsumerState<ScanScreen> createState() => _ScanScreenState();
}

class _ScanScreenState extends ConsumerState<ScanScreen> {
  final _scanService = const NativeScanService();
  DeviceCapabilityResult? _capabilities;
  List<ScanResult> _results = const [];
  List<VerificationRequest> _submittedRequests = const [];
  var _isLoadingCapabilities = false;
  var _isScanning = false;
  var _isSubmitting = false;
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
            OutlinedButton.icon(
              onPressed: _isScanning ? null : _addDemoResult,
              icon: const Icon(Icons.science_outlined),
              label: const Text('Demo result'),
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
          for (final result in _results)
            _ScanResultTile(
              result: result,
              isSubmitting: _isSubmitting,
              onSubmit: () => _submitEvidence(result),
            ),
        if (_submittedRequests.isNotEmpty) ...[
          const SizedBox(height: 24),
          Text(
            'Submitted evidence',
            style: Theme.of(context).textTheme.titleMedium,
          ),
          const SizedBox(height: 8),
          for (final request in _submittedRequests)
            _VerificationRequestTile(request: request),
        ],
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

  void _addDemoResult() {
    final now = DateTime.now();
    setState(() {
      _results = [
        ScanResult(
          id: 'demo-${now.millisecondsSinceEpoch}',
          broadcastName: 'Demo Auracast candidate',
          rssi: -61,
          detectedAt: now,
          deviceName: 'Demo transmitter',
          rawAdvertisementHex: '02010603034F18',
          deviceAddress: 'DE:MO:00:00:00:01',
          serviceUuids: const ['0000184f-0000-1000-8000-00805f9b34fb'],
        ),
        ..._results,
      ];
      _message = 'Demo scan result added for local submission testing.';
    });
  }

  Future<void> _submitEvidence(ScanResult result) async {
    final location = await showModalBottomSheet<AuracastLocation>(
      context: context,
      isScrollControlled: true,
      showDragHandle: true,
      builder: (context) => const _LocationPickerSheet(),
    );
    if (location == null || !mounted) {
      return;
    }

    final user = ref.read(currentAppUserProvider).valueOrNull;
    if (user == null) {
      setState(() => _message = 'You need to be signed in to submit evidence.');
      return;
    }

    setState(() => _isSubmitting = true);

    final repository = ref.read(verificationRepositoryProvider);
    final request = repository.createLocalRequest(
      scanResult: result,
      location: location,
      userId: user.id,
    );

    try {
      await repository.submitRequest(request);
      if (!mounted) {
        return;
      }
      setState(() {
        _submittedRequests = [request, ..._submittedRequests];
        _message = 'Evidence submitted for ${location.name}.';
      });
    } on Object catch (error) {
      if (mounted) {
        setState(() => _message = 'Could not submit evidence: $error');
      }
    } finally {
      if (mounted) {
        setState(() => _isSubmitting = false);
      }
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
  const _ScanResultTile({
    required this.result,
    required this.isSubmitting,
    required this.onSubmit,
  });

  final ScanResult result;
  final bool isSubmitting;
  final VoidCallback onSubmit;

  @override
  Widget build(BuildContext context) {
    final rawPreview = result.rawAdvertisementHex.length <= 24
        ? result.rawAdvertisementHex
        : '${result.rawAdvertisementHex.substring(0, 24)}...';

    return Card(
      child: Padding(
        padding: const EdgeInsets.fromLTRB(0, 0, 12, 12),
        child: Column(
          children: [
            ListTile(
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
            Align(
              alignment: Alignment.centerRight,
              child: OutlinedButton.icon(
                onPressed: isSubmitting ? null : onSubmit,
                icon: isSubmitting
                    ? const SizedBox.square(
                        dimension: 16,
                        child: CircularProgressIndicator(strokeWidth: 2),
                      )
                    : const Icon(Icons.upload_file_outlined),
                label: const Text('Submit evidence'),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _VerificationRequestTile extends StatelessWidget {
  const _VerificationRequestTile({required this.request});

  final VerificationRequest request;

  @override
  Widget build(BuildContext context) {
    return Card(
      child: ListTile(
        leading: const Icon(Icons.fact_check_outlined),
        title: Text(request.locationName),
        subtitle: Text(
          '${request.broadcastName}\nStatus: ${request.status.name}',
        ),
        isThreeLine: true,
      ),
    );
  }
}

class _LocationPickerSheet extends ConsumerWidget {
  const _LocationPickerSheet();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final locationsAsync = ref.watch(verifiedLocationsProvider);
    final height = MediaQuery.sizeOf(context).height * 0.56;

    return SafeArea(
      child: SizedBox(
        height: height,
        child: locationsAsync.when(
          data: (locations) {
            return ListView(
              padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
              children: [
                Text(
                  'Choose location',
                  style: Theme.of(context).textTheme.titleMedium,
                ),
                const SizedBox(height: 8),
                if (locations.isEmpty)
                  const Card(
                    child: ListTile(
                      leading: Icon(Icons.location_off_outlined),
                      title: Text('No verified locations yet'),
                      subtitle: Text('Ask an admin to verify one first.'),
                    ),
                  )
                else
                  for (final location in locations)
                    Card(
                      child: ListTile(
                        leading: const Icon(Icons.place_outlined),
                        title: Text(location.name),
                        subtitle: Text(location.city),
                        onTap: () => Navigator.of(context).pop(location),
                      ),
                    ),
              ],
            );
          },
          loading: () => const Center(child: CircularProgressIndicator()),
          error: (error, stackTrace) => Center(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Text('Could not load locations.\n$error'),
            ),
          ),
        ),
      ),
    );
  }
}
