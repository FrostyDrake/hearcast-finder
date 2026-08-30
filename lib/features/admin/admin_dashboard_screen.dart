import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/utils/validators.dart';
import '../../models/auracast_location.dart';
import '../../models/verification_request.dart';
import '../../providers/firebase_providers.dart';
import '../../providers/location_providers.dart';
import '../../providers/verification_providers.dart';
import '../../services/admin_location_service.dart';

class AdminDashboardScreen extends ConsumerStatefulWidget {
  const AdminDashboardScreen({super.key});

  @override
  ConsumerState<AdminDashboardScreen> createState() => _AdminDashboardScreenState();
}

class _AdminDashboardScreenState extends ConsumerState<AdminDashboardScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _addressController = TextEditingController();
  final _cityController = TextEditingController();
  LocationCategory _category = LocationCategory.conference;
  var _isCreating = false;
  var _busyLocationId = '';
  var _busyRequestId = '';
  String? _message;

  @override
  void dispose() {
    _nameController.dispose();
    _addressController.dispose();
    _cityController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final candidatesAsync = ref.watch(candidateLocationsProvider);

    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        Text(
          'Admin review',
          style: Theme.of(context).textTheme.headlineSmall,
        ),
        const SizedBox(height: 8),
        const Text(
          'Approve or reject locations owners have submitted, or add one directly.',
        ),
        const SizedBox(height: 16),
        candidatesAsync.when(
          data: (candidates) {
            return Card(
              child: ListTile(
                leading: const Icon(Icons.pending_actions_outlined),
                title: Text('${candidates.length} pending location${candidates.length == 1 ? '' : 's'}'),
                subtitle: const Text('Backed by Firestore and Cloud Functions.'),
              ),
            );
          },
          loading: () => const Card(
            child: ListTile(
              leading: CircularProgressIndicator(),
              title: Text('Loading pending locations…'),
            ),
          ),
          error: (error, stackTrace) => Card(
            child: ListTile(
              leading: const Icon(Icons.error_outline),
              title: const Text('Could not load pending locations'),
              subtitle: Text('$error'),
            ),
          ),
        ),
        const SizedBox(height: 16),
        Text(
          'Pending locations',
          style: Theme.of(context).textTheme.titleMedium,
        ),
        const SizedBox(height: 8),
        candidatesAsync.when(
          data: (candidates) {
            if (candidates.isEmpty) {
              return const Card(
                child: ListTile(
                  leading: Icon(Icons.check_circle_outline),
                  title: Text('Nothing waiting for review'),
                ),
              );
            }

            return Column(
              children: [
                for (final location in candidates)
                  _CandidateReviewTile(
                    location: location,
                    isBusy: _busyLocationId == location.id,
                    onApprove: () => _approve(location),
                    onReject: () => _reject(location),
                  ),
              ],
            );
          },
          loading: () => const SizedBox.shrink(),
          error: (error, stackTrace) => const SizedBox.shrink(),
        ),
        const SizedBox(height: 24),
        Text(
          'Verification requests',
          style: Theme.of(context).textTheme.titleMedium,
        ),
        const SizedBox(height: 8),
        const Text(
          'Scan evidence submitted by users, matched to a location.',
        ),
        const SizedBox(height: 8),
        _buildVerificationRequests(),
        const SizedBox(height: 24),
        _buildCreateLocationForm(context),
      ],
    );
  }

  Widget _buildVerificationRequests() {
    final requestsAsync = ref.watch(pendingVerificationRequestsProvider);

    return requestsAsync.when(
      data: (requests) {
        if (requests.isEmpty) {
          return const Card(
            child: ListTile(
              leading: Icon(Icons.check_circle_outline),
              title: Text('No verification requests pending'),
            ),
          );
        }

        return Column(
          children: [
            for (final request in requests)
              _VerificationRequestReviewTile(
                request: request,
                isBusy: _busyRequestId == request.id,
                onApprove: () => _setRequestStatus(request, VerificationStatus.approved),
                onReject: () => _setRequestStatus(request, VerificationStatus.rejected),
              ),
          ],
        );
      },
      loading: () => const Card(
        child: ListTile(
          leading: CircularProgressIndicator(),
          title: Text('Loading verification requests…'),
        ),
      ),
      error: (error, stackTrace) => Card(
        child: ListTile(
          leading: const Icon(Icons.error_outline),
          title: const Text('Could not load verification requests'),
          subtitle: Text('$error'),
        ),
      ),
    );
  }

  Widget _buildCreateLocationForm(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Add a verified location',
                style: Theme.of(context).textTheme.titleMedium,
              ),
              const SizedBox(height: 12),
              TextFormField(
                controller: _nameController,
                decoration: const InputDecoration(
                  labelText: 'Location name',
                  border: OutlineInputBorder(),
                ),
                validator: (value) =>
                    Validators.requiredText(value, 'Location name'),
              ),
              const SizedBox(height: 12),
              TextFormField(
                controller: _addressController,
                decoration: const InputDecoration(
                  labelText: 'Address',
                  border: OutlineInputBorder(),
                ),
                validator: (value) => Validators.requiredText(value, 'Address'),
              ),
              const SizedBox(height: 12),
              TextFormField(
                controller: _cityController,
                decoration: const InputDecoration(
                  labelText: 'City',
                  border: OutlineInputBorder(),
                ),
                validator: (value) => Validators.requiredText(value, 'City'),
              ),
              const SizedBox(height: 12),
              DropdownButtonFormField<LocationCategory>(
                initialValue: _category,
                decoration: const InputDecoration(
                  labelText: 'Category',
                  border: OutlineInputBorder(),
                ),
                items: LocationCategory.values
                    .map(
                      (category) => DropdownMenuItem(
                        value: category,
                        child: Text(category.label),
                      ),
                    )
                    .toList(),
                onChanged: (category) {
                  if (category != null) {
                    setState(() => _category = category);
                  }
                },
              ),
              const SizedBox(height: 16),
              FilledButton.icon(
                onPressed: _isCreating ? null : _createLocation,
                icon: _isCreating
                    ? const SizedBox.square(
                        dimension: 18,
                        child: CircularProgressIndicator(strokeWidth: 2),
                      )
                    : const Icon(Icons.add_business_outlined),
                label: const Text('Create verified location'),
              ),
              if (_message != null) ...[
                const SizedBox(height: 12),
                Text(
                  _message!,
                  style: TextStyle(color: Theme.of(context).colorScheme.error),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }

  Future<void> _approve(AuracastLocation location) async {
    setState(() => _busyLocationId = location.id);
    try {
      await ref.read(adminLocationServiceProvider).approveLocation(location.id);
    } on AdminActionException catch (error) {
      _showSnackBar(error.message);
    } on Object catch (error) {
      _showSnackBar('Could not approve: $error');
    } finally {
      if (mounted) {
        setState(() => _busyLocationId = '');
      }
    }
  }

  Future<void> _reject(AuracastLocation location) async {
    setState(() => _busyLocationId = location.id);
    try {
      await ref.read(adminLocationServiceProvider).deleteLocation(location.id);
    } on AdminActionException catch (error) {
      _showSnackBar(error.message);
    } on Object catch (error) {
      _showSnackBar('Could not reject: $error');
    } finally {
      if (mounted) {
        setState(() => _busyLocationId = '');
      }
    }
  }

  Future<void> _setRequestStatus(
    VerificationRequest request,
    VerificationStatus status,
  ) async {
    setState(() => _busyRequestId = request.id);
    try {
      await ref.read(verificationRepositoryProvider).setStatus(request.id, status);
    } on Object catch (error) {
      _showSnackBar('Could not update request: $error');
    } finally {
      if (mounted) {
        setState(() => _busyRequestId = '');
      }
    }
  }

  Future<void> _createLocation() async {
    if (!(_formKey.currentState?.validate() ?? false)) {
      return;
    }

    setState(() {
      _isCreating = true;
      _message = null;
    });

    try {
      await ref.read(adminLocationServiceProvider).createLocation(
            name: _nameController.text.trim(),
            address: _addressController.text.trim(),
            city: _cityController.text.trim(),
            category: _category,
            latitude: 0,
            longitude: 0,
          );

      if (!mounted) {
        return;
      }
      _nameController.clear();
      _addressController.clear();
      _cityController.clear();
      setState(() => _message = 'Location created and verified.');
    } on AdminActionException catch (error) {
      if (mounted) {
        setState(() => _message = error.message);
      }
    } on Object catch (error) {
      if (mounted) {
        setState(() => _message = 'Could not create: $error');
      }
    } finally {
      if (mounted) {
        setState(() => _isCreating = false);
      }
    }
  }

  void _showSnackBar(String message) {
    if (!mounted) {
      return;
    }
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(message)));
  }
}

class _VerificationRequestReviewTile extends StatelessWidget {
  const _VerificationRequestReviewTile({
    required this.request,
    required this.isBusy,
    required this.onApprove,
    required this.onReject,
  });

  final VerificationRequest request;
  final bool isBusy;
  final VoidCallback onApprove;
  final VoidCallback onReject;

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.fromLTRB(0, 0, 12, 12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            ListTile(
              leading: const Icon(Icons.bluetooth_outlined),
              title: Text(request.locationName),
              subtitle: Text(
                '${request.broadcastName}\nSubmitted by ${request.userId}',
              ),
              isThreeLine: true,
            ),
            Align(
              alignment: Alignment.centerRight,
              child: Wrap(
                spacing: 8,
                children: [
                  OutlinedButton.icon(
                    onPressed: isBusy ? null : onReject,
                    icon: const Icon(Icons.close),
                    label: const Text('Reject'),
                  ),
                  FilledButton.icon(
                    onPressed: isBusy ? null : onApprove,
                    icon: isBusy
                        ? const SizedBox.square(
                            dimension: 16,
                            child: CircularProgressIndicator(strokeWidth: 2),
                          )
                        : const Icon(Icons.check),
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

class _CandidateReviewTile extends StatelessWidget {
  const _CandidateReviewTile({
    required this.location,
    required this.isBusy,
    required this.onApprove,
    required this.onReject,
  });

  final AuracastLocation location;
  final bool isBusy;
  final VoidCallback onApprove;
  final VoidCallback onReject;

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.fromLTRB(0, 0, 12, 12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            ListTile(
              leading: const Icon(Icons.fact_check_outlined),
              title: Text(location.name),
              subtitle: Text(
                '${location.category.label} • ${location.city}\n${location.address}',
              ),
              isThreeLine: true,
            ),
            Align(
              alignment: Alignment.centerRight,
              child: Wrap(
                spacing: 8,
                children: [
                  OutlinedButton.icon(
                    onPressed: isBusy ? null : onReject,
                    icon: const Icon(Icons.close),
                    label: const Text('Reject'),
                  ),
                  FilledButton.icon(
                    onPressed: isBusy ? null : onApprove,
                    icon: isBusy
                        ? const SizedBox.square(
                            dimension: 16,
                            child: CircularProgressIndicator(strokeWidth: 2),
                          )
                        : const Icon(Icons.check),
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
