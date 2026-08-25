import 'package:flutter/material.dart';

import '../../models/scan_result.dart';
import '../../models/verification_request.dart';
import '../locations/sample_locations.dart';

class AdminDashboardScreen extends StatefulWidget {
  const AdminDashboardScreen({super.key});

  @override
  State<AdminDashboardScreen> createState() => _AdminDashboardScreenState();
}

class _AdminDashboardScreenState extends State<AdminDashboardScreen> {
  late List<VerificationRequest> _requests = [
    VerificationRequest.local(
      scanResult: ScanResult(
        id: 'admin-demo-scan',
        broadcastName: 'Main Hall Auracast',
        rssi: -58,
        detectedAt: DateTime.utc(2026, 8, 23),
      ),
      location: sampleLocations.first,
      createdAt: DateTime.utc(2026, 8, 23),
    ),
  ];

  @override
  Widget build(BuildContext context) {
    final pendingCount = _requests
        .where((request) => request.status == VerificationStatus.pending)
        .length;

    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        Text(
          'Admin review',
          style: Theme.of(context).textTheme.headlineSmall,
        ),
        const SizedBox(height: 8),
        const Text(
          'Local review queue for checking scan evidence before locations become verified.',
        ),
        const SizedBox(height: 16),
        Card(
          child: ListTile(
            leading: const Icon(Icons.pending_actions_outlined),
            title: Text('$pendingCount pending verification'),
            subtitle: const Text('Firestore-backed moderation comes later.'),
          ),
        ),
        const SizedBox(height: 16),
        Text(
          'Verification requests',
          style: Theme.of(context).textTheme.titleMedium,
        ),
        const SizedBox(height: 8),
        for (final request in _requests)
          _VerificationReviewTile(
            request: request,
            onApprove: () => _setStatus(request, VerificationStatus.approved),
            onReject: () => _setStatus(request, VerificationStatus.rejected),
          ),
      ],
    );
  }

  void _setStatus(VerificationRequest request, VerificationStatus status) {
    setState(() {
      _requests = [
        for (final current in _requests)
          if (current.id == request.id)
            current.copyWith(status: status)
          else
            current,
      ];
    });
  }
}

class _VerificationReviewTile extends StatelessWidget {
  const _VerificationReviewTile({
    required this.request,
    required this.onApprove,
    required this.onReject,
  });

  final VerificationRequest request;
  final VoidCallback onApprove;
  final VoidCallback onReject;

  @override
  Widget build(BuildContext context) {
    final isPending = request.status == VerificationStatus.pending;

    return Card(
      child: Padding(
        padding: const EdgeInsets.fromLTRB(0, 0, 12, 12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            ListTile(
              leading: const Icon(Icons.fact_check_outlined),
              title: Text(request.locationName),
              subtitle: Text(
                '${request.broadcastName}\nStatus: ${request.status.name}',
              ),
              isThreeLine: true,
            ),
            if (isPending)
              Align(
                alignment: Alignment.centerRight,
                child: Wrap(
                  spacing: 8,
                  children: [
                    OutlinedButton.icon(
                      onPressed: onReject,
                      icon: const Icon(Icons.close),
                      label: const Text('Reject'),
                    ),
                    FilledButton.icon(
                      onPressed: onApprove,
                      icon: const Icon(Icons.check),
                      label: const Text('Approve'),
                    ),
                  ],
                ),
              ),
          ],
        ),
      ),
    );
  }
}
