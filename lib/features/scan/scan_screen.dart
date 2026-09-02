import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/theme/hc_palette.dart';
import '../../core/utils/write_timeout.dart';
import '../../core/widgets/hc_category.dart';
import '../../core/widgets/hc_layout.dart';
import '../../core/widgets/hc_signal.dart';
import '../../core/widgets/hc_states.dart';
import '../../core/widgets/hc_status.dart';
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
  HcNoticeTone _messageTone = HcNoticeTone.info;

  @override
  void initState() {
    super.initState();
    _checkCapabilities();
  }

  @override
  Widget build(BuildContext context) {
    final message = _message;

    return HcScreen(
      children: [
        const HcPageHeader(
          title: 'Bluetooth scan',
          subtitle: 'Check whether audio is actually being broadcast where '
              'you are standing right now.',
        ),
        _CapabilityCard(
          capabilities: _capabilities,
          isLoading: _isLoadingCapabilities,
          onRefresh: _checkCapabilities,
        ),
        const SizedBox(height: HcSpace.lg),
        HcActionBar(
          children: [
            FilledButton.icon(
              onPressed: _isScanning ? null : _startScan,
              icon: const Icon(Icons.wifi_tethering_rounded),
              label: const Text('Start scan'),
            ),
            OutlinedButton.icon(
              onPressed: _isScanning ? _stopScan : null,
              icon: const Icon(Icons.stop_rounded),
              label: const Text('Stop'),
            ),
            OutlinedButton.icon(
              onPressed: _isScanning ? null : _requestPermissions,
              icon: const Icon(Icons.lock_open_outlined),
              label: const Text('Permissions'),
            ),
            Tooltip(
              message: 'Inserts a fake result so the submission flow can be '
                  'tested without a transmitter',
              child: TextButton.icon(
                onPressed: _isScanning ? null : _addDemoResult,
                icon: const Icon(Icons.science_outlined),
                label: const Text('Demo result'),
              ),
            ),
          ],
        ),
        if (message != null) ...[
          const SizedBox(height: HcSpace.lg),
          HcNotice(message: message, tone: _messageTone),
        ],
        const SizedBox(height: HcSpace.xxl),
        HcSectionHeader(
          title: 'Scan results',
          subtitle: _results.isEmpty
              ? null
              : 'Only advertisements announcing LE Audio are listed.',
        ),
        if (_isScanning)
          const HcLoadingState(
            message: 'Listening for nearby Auracast broadcasts…',
          )
        else if (_results.isEmpty)
          const HcEmptyState(
            icon: Icons.bluetooth_searching_rounded,
            title: 'No broadcasts found yet',
            message: 'Run a scan to see the Auracast transmitters your phone '
                'can hear from here.',
          )
        else
          HcListGroup(
            dividerIndent: 0,
            children: [
              for (final result in _results)
                _ScanResultTile(
                  result: result,
                  isSubmitting: _isSubmitting,
                  onSubmit: () => _submitEvidence(result),
                ),
            ],
          ),
        if (_submittedRequests.isNotEmpty) ...[
          const SizedBox(height: HcSpace.xxl),
          const HcSectionHeader(
            title: 'Submitted evidence',
            subtitle: 'Waiting for an admin to review.',
          ),
          HcListGroup(
            dividerIndent: 0,
            children: [
              for (final request in _submittedRequests)
                _VerificationRequestTile(request: request),
            ],
          ),
        ],
      ],
    );
  }

  void _setMessage(String? message, [HcNoticeTone tone = HcNoticeTone.info]) {
    setState(() {
      _message = message;
      _messageTone = tone;
    });
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
        _setMessage(
          'Native scanner is only available on Android builds.',
          HcNoticeTone.error,
        );
      }
    } on Object catch (error) {
      if (mounted) {
        _setMessage('Capability check failed: $error', HcNoticeTone.error);
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
      _setMessage('Permission request failed: $error', HcNoticeTone.error);
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
        setState(() => _results = results);
        if (results.isEmpty) {
          _setMessage(
            'Scan finished — no Auracast broadcasts in range.',
            HcNoticeTone.info,
          );
        }
      }
    } on Object catch (error) {
      if (mounted) {
        _setMessage('Scan failed: $error', HcNoticeTone.error);
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
      _setMessage('Stop scan failed: $error', HcNoticeTone.error);
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
    });
    _setMessage(
      'Demo scan result added for local submission testing.',
      HcNoticeTone.info,
    );
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
      _setMessage(
        'You need to be signed in to submit evidence.',
        HcNoticeTone.error,
      );
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
      await repository.submitRequest(request).withWriteTimeout();
      if (!mounted) {
        return;
      }
      setState(() => _submittedRequests = [request, ..._submittedRequests]);
      _setMessage(
        'Evidence submitted for ${location.name}.',
        HcNoticeTone.success,
      );
    } on TimeoutException catch (error) {
      if (mounted) {
        _setMessage(error.message ?? hcWriteTimeoutMessage, HcNoticeTone.error);
      }
    } on Object catch (error) {
      if (mounted) {
        _setMessage('Could not submit evidence: $error', HcNoticeTone.error);
      }
    } finally {
      if (mounted) {
        setState(() => _isSubmitting = false);
      }
    }
  }
}

/// The device's own state, first thing on the screen: if Bluetooth is off or
/// a permission is missing, nothing else on this page matters.
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
    final theme = Theme.of(context);
    final palette = context.hcPalette;
    final value = capabilities;
    final ready = value?.canStartScan ?? false;
    final colors = ready ? palette.verified : palette.candidate;

    return HcCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          HcSectionHeader(
            title: 'Device capabilities',
            trailing: IconButton(
              onPressed: isLoading ? null : onRefresh,
              icon: const Icon(Icons.refresh_rounded),
              tooltip: 'Refresh device capabilities',
            ),
          ),
          if (isLoading)
            const LinearProgressIndicator()
          else if (value == null)
            Text(
              'No capability result yet.',
              style: theme.textTheme.bodyMedium?.copyWith(
                color: theme.colorScheme.onSurfaceVariant,
              ),
            )
          else ...[
            // A single plain-language verdict, before the six details.
            HcStatusBadge(
              semanticPrefix: 'Scanner',
              descriptor: HcStatusDescriptor(
                label: ready ? 'Ready to scan' : 'Not ready to scan',
                icon: ready
                    ? Icons.check_circle_rounded
                    : Icons.warning_amber_rounded,
                colors: colors,
              ),
            ),
            const SizedBox(height: HcSpace.lg),
            Wrap(
              spacing: HcSpace.sm,
              runSpacing: HcSpace.sm,
              children: [
                HcCapabilityChip(
                  label: 'Android ${value.androidVersion}',
                  enabled: value.isAndroid13OrNewer,
                ),
                HcCapabilityChip(
                  label: 'Bluetooth',
                  enabled: value.hasBluetooth && value.isBluetoothEnabled,
                ),
                HcCapabilityChip(
                  label: 'Scan permission',
                  enabled: value.hasBluetoothScanPermission,
                ),
                HcCapabilityChip(
                  label: 'Connect permission',
                  enabled: value.hasBluetoothConnectPermission,
                ),
                HcCapabilityChip(
                  label: 'Location permission',
                  enabled: value.hasLocationPermission,
                ),
                HcCapabilityChip(
                  label: 'LE Audio',
                  enabled: value.isLeAudioSupported,
                ),
              ],
            ),
          ],
        ],
      ),
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
    final theme = Theme.of(context);
    final scheme = theme.colorScheme;
    final name = result.broadcastName.isEmpty
        ? 'Unnamed Bluetooth signal'
        : result.broadcastName;

    return Padding(
      padding: const EdgeInsets.all(HcSpace.lg),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          MergeSemantics(
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                ExcludeSemantics(
                  child: Icon(
                    Icons.graphic_eq_rounded,
                    size: MediaQuery.textScalerOf(context).scale(22),
                    color: scheme.primary,
                  ),
                ),
                const SizedBox(width: HcSpace.md),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(name, style: theme.textTheme.titleMedium),
                      const SizedBox(height: HcSpace.sm),
                      HcSignalMeter(rssi: result.rssi),
                    ],
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: HcSpace.md),
          _TechnicalDetails(result: result),
          const SizedBox(height: HcSpace.sm),
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
    );
  }
}

/// The raw advertisement kept, but folded away: the previous screen printed a
/// truncated hex string with an ellipsis, which is neither readable nor
/// complete. Here nothing is cut off, it is just closed by default.
class _TechnicalDetails extends StatelessWidget {
  const _TechnicalDetails({required this.result});

  final ScanResult result;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final scheme = theme.colorScheme;

    return Theme(
      // Removes ExpansionTile's default top/bottom dividers, which fight the
      // group's own hairlines.
      data: theme.copyWith(dividerColor: Colors.transparent),
      child: ExpansionTile(
        tilePadding: EdgeInsets.zero,
        childrenPadding: const EdgeInsets.only(bottom: HcSpace.sm),
        expandedCrossAxisAlignment: CrossAxisAlignment.start,
        title: Text(
          'Technical details',
          style: theme.textTheme.labelLarge?.copyWith(
            color: scheme.onSurfaceVariant,
          ),
        ),
        children: [
          _DetailLine(label: 'Address', value: result.deviceAddress),
          if (result.deviceName != null && result.deviceName!.isNotEmpty)
            _DetailLine(label: 'Device name', value: result.deviceName!),
          if (result.serviceUuids.isNotEmpty)
            _DetailLine(
              label: 'Service UUIDs',
              value: result.serviceUuids.join('\n'),
            ),
          if (result.rawAdvertisementHex.isNotEmpty)
            _DetailLine(
              label: 'Raw advertisement',
              value: result.rawAdvertisementHex,
            ),
          _DetailLine(
            label: 'Seen at',
            value: _formatTime(result.detectedAt),
          ),
        ],
      ),
    );
  }

  static String _formatTime(DateTime time) {
    String two(int value) => value.toString().padLeft(2, '0');
    return '${two(time.hour)}:${two(time.minute)}:${two(time.second)}';
  }
}

class _DetailLine extends StatelessWidget {
  const _DetailLine({required this.label, required this.value});

  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Padding(
      padding: const EdgeInsets.only(bottom: HcSpace.sm),
      child: MergeSemantics(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              label,
              style: theme.textTheme.bodySmall?.copyWith(
                color: theme.colorScheme.onSurfaceVariant,
                fontWeight: FontWeight.w600,
              ),
            ),
            Text(
              value,
              style: theme.textTheme.bodySmall?.copyWith(
                fontFamily: 'monospace',
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
    final palette = context.hcPalette;

    return HcListRow(
      title: request.locationName,
      subtitle: request.broadcastName,
      badges: [HcStatusBadge.verification(request.status, palette)],
    );
  }
}

class _LocationPickerSheet extends ConsumerWidget {
  const _LocationPickerSheet();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final locationsAsync = ref.watch(verifiedLocationsProvider);
    final height = MediaQuery.sizeOf(context).height * 0.6;

    return SafeArea(
      child: SizedBox(
        height: height,
        child: locationsAsync.when(
          data: (locations) {
            return ListView(
              padding: const EdgeInsets.fromLTRB(
                HcSpace.lg,
                0,
                HcSpace.lg,
                HcSpace.lg,
              ),
              children: [
                Semantics(
                  header: true,
                  child: Text(
                    'Choose location',
                    style: theme.textTheme.titleLarge,
                  ),
                ),
                const SizedBox(height: HcSpace.xs),
                Text(
                  'Which place was this broadcast coming from?',
                  style: theme.textTheme.bodyMedium?.copyWith(
                    color: theme.colorScheme.onSurfaceVariant,
                  ),
                ),
                const SizedBox(height: HcSpace.lg),
                if (locations.isEmpty)
                  const HcEmptyState(
                    icon: Icons.location_off_outlined,
                    title: 'No verified locations yet',
                    message: 'Ask an admin to verify a location first.',
                  )
                else
                  HcListGroup(
                    children: [
                      for (final location in locations)
                        HcListRow(
                          leading: HcCategoryAvatar(
                            category: location.category,
                          ),
                          title: location.name,
                          subtitle:
                              '${location.category.label} · ${location.city}',
                          semanticLabel: '${location.name}, '
                              '${location.category.label} in ${location.city}',
                          onTap: () => Navigator.of(context).pop(location),
                        ),
                    ],
                  ),
              ],
            );
          },
          loading: () => const Center(child: CircularProgressIndicator()),
          error: (error, stackTrace) => Padding(
            padding: const EdgeInsets.all(HcSpace.lg),
            child: HcErrorState(
              title: 'Could not load locations',
              error: error,
            ),
          ),
        ),
      ),
    );
  }
}
