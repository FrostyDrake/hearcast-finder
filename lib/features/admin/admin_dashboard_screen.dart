import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/theme/hc_palette.dart';
import '../../core/utils/write_timeout.dart';
import '../../core/utils/validators.dart';
import '../../core/widgets/hc_category.dart';
import '../../core/widgets/hc_layout.dart';
import '../../core/widgets/hc_states.dart';
import '../../models/auracast_location.dart';
import '../../models/verification_request.dart';
import '../../providers/firebase_providers.dart';
import '../../providers/location_providers.dart';
import '../../providers/verification_providers.dart';
import '../../services/admin_location_service.dart';

class AdminDashboardScreen extends ConsumerStatefulWidget {
  const AdminDashboardScreen({super.key});

  @override
  ConsumerState<AdminDashboardScreen> createState() =>
      _AdminDashboardScreenState();
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
  HcNoticeTone _messageTone = HcNoticeTone.info;

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
    final requestsAsync = ref.watch(pendingVerificationRequestsProvider);

    return HcScreen(
      children: [
        const HcPageHeader(
          title: 'Admin review',
          subtitle: 'Nothing reaches the public map until it is approved '
              'here.',
        ),
        _QueueSummary(
          candidatesAsync: candidatesAsync,
          requestsAsync: requestsAsync,
        ),
        const SizedBox(height: HcSpace.xxl),
        const HcSectionHeader(
          title: 'Pending locations',
          subtitle: 'Submitted by owners, waiting for a decision.',
        ),
        candidatesAsync.when(
          data: (candidates) {
            if (candidates.isEmpty) {
              return const HcEmptyState(
                icon: Icons.check_circle_outline,
                title: 'Nothing waiting for review',
                message: 'Owner submissions appear here the moment they are '
                    'sent in.',
              );
            }

            return Column(
              children: [
                for (final location in candidates)
                  Padding(
                    padding: const EdgeInsets.only(bottom: HcSpace.md),
                    child: _CandidateReviewCard(
                      location: location,
                      isBusy: _busyLocationId == location.id,
                      onApprove: () => _approve(location),
                      onReject: () => _reject(location),
                    ),
                  ),
              ],
            );
          },
          loading: () => const HcLoadingState(
            message: 'Loading pending locations…',
          ),
          error: (error, stackTrace) => HcErrorState(
            title: 'Could not load pending locations',
            error: error,
            onRetry: () => ref.invalidate(candidateLocationsProvider),
          ),
        ),
        const SizedBox(height: HcSpace.xxl),
        const HcSectionHeader(
          title: 'Verification requests',
          subtitle: 'Scan evidence submitted by users, matched to a location.',
        ),
        requestsAsync.when(
          data: (requests) {
            if (requests.isEmpty) {
              return const HcEmptyState(
                icon: Icons.fact_check_outlined,
                title: 'No verification requests pending',
                message: 'Scans users submit from the Scan tab land here.',
              );
            }

            return Column(
              children: [
                for (final request in requests)
                  Padding(
                    padding: const EdgeInsets.only(bottom: HcSpace.md),
                    child: _VerificationRequestReviewCard(
                      request: request,
                      isBusy: _busyRequestId == request.id,
                      onApprove: () => _setRequestStatus(
                        request,
                        VerificationStatus.approved,
                      ),
                      onReject: () => _setRequestStatus(
                        request,
                        VerificationStatus.rejected,
                      ),
                    ),
                  ),
              ],
            );
          },
          loading: () => const HcLoadingState(
            message: 'Loading verification requests…',
          ),
          error: (error, stackTrace) => HcErrorState(
            title: 'Could not load verification requests',
            error: error,
            onRetry: () => ref.invalidate(pendingVerificationRequestsProvider),
          ),
        ),
        const SizedBox(height: HcSpace.xxl),
        _buildCreateLocationForm(context),
      ],
    );
  }

  Widget _buildCreateLocationForm(BuildContext context) {
    final message = _message;

    return HcCard(
      padding: const EdgeInsets.all(HcSpace.xl),
      child: Form(
        key: _formKey,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const HcSectionHeader(
              title: 'Add a verified location',
              subtitle: 'Skips the queue — published immediately.',
            ),
            TextFormField(
              controller: _nameController,
              decoration: const InputDecoration(labelText: 'Location name'),
              textInputAction: TextInputAction.next,
              validator: (value) =>
                  Validators.requiredText(value, 'Location name'),
            ),
            const SizedBox(height: HcSpace.lg),
            TextFormField(
              controller: _addressController,
              decoration: const InputDecoration(labelText: 'Address'),
              textInputAction: TextInputAction.next,
              validator: (value) => Validators.requiredText(value, 'Address'),
            ),
            const SizedBox(height: HcSpace.lg),
            TextFormField(
              controller: _cityController,
              decoration: const InputDecoration(labelText: 'City'),
              textInputAction: TextInputAction.next,
              validator: (value) => Validators.requiredText(value, 'City'),
            ),
            const SizedBox(height: HcSpace.lg),
            DropdownButtonFormField<LocationCategory>(
              initialValue: _category,
              decoration: const InputDecoration(labelText: 'Category'),
              items: LocationCategory.values
                  .map(
                    (category) => DropdownMenuItem(
                      value: category,
                      child: Row(
                        children: [
                          Icon(category.icon, size: 18),
                          const SizedBox(width: HcSpace.sm),
                          Text(category.label),
                        ],
                      ),
                    ),
                  )
                  .toList(),
              onChanged: (category) {
                if (category != null) {
                  setState(() => _category = category);
                }
              },
            ),
            const SizedBox(height: HcSpace.xl),
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
            if (message != null) ...[
              const SizedBox(height: HcSpace.lg),
              HcNotice(message: message, tone: _messageTone),
            ],
          ],
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
      await ref
          .read(verificationRepositoryProvider)
          .setStatus(request.id, status)
          .withWriteTimeout();
    } on TimeoutException catch (error) {
      _showSnackBar(error.message ?? hcWriteTimeoutMessage);
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
      setState(() {
        _message = 'Location created and verified.';
        _messageTone = HcNoticeTone.success;
      });
    } on AdminActionException catch (error) {
      if (mounted) {
        setState(() {
          _message = error.message;
          _messageTone = HcNoticeTone.error;
        });
      }
    } on Object catch (error) {
      if (mounted) {
        setState(() {
          _message = 'Could not create: $error';
          _messageTone = HcNoticeTone.error;
        });
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
    ScaffoldMessenger.of(context)
        .showSnackBar(SnackBar(content: Text(message)));
  }
}

/// Two counters side by side, so an admin sees the size of both queues before
/// scrolling into either of them.
class _QueueSummary extends StatelessWidget {
  const _QueueSummary({
    required this.candidatesAsync,
    required this.requestsAsync,
  });

  final AsyncValue<List<AuracastLocation>> candidatesAsync;
  final AsyncValue<List<VerificationRequest>> requestsAsync;

  @override
  Widget build(BuildContext context) {
    final candidates = candidatesAsync.valueOrNull;
    final requests = requestsAsync.valueOrNull;

    final tiles = [
      _CountTile(
        icon: Icons.pending_actions_outlined,
        // Kept as one string so the count and its noun are never read as two
        // separate fragments by a screen reader.
        label: candidates == null
            ? 'Loading locations…'
            : '${candidates.length} pending '
                'location${candidates.length == 1 ? '' : 's'}',
        emphasised: (candidates?.length ?? 0) > 0,
      ),
      _CountTile(
        icon: Icons.fact_check_outlined,
        label: requests == null
            ? 'Loading evidence…'
            : '${requests.length} scan '
                'submission${requests.length == 1 ? '' : 's'}',
        emphasised: (requests?.length ?? 0) > 0,
      ),
    ];

    // Side by side each tile is only half the screen, and at 200% text
    // "submissions" no longer fits on one line and breaks mid-word. Past that
    // point the tiles stack and get the full width instead.
    if (MediaQuery.textScalerOf(context).scale(1) > 1.3) {
      return Column(
        children: [
          tiles[0],
          const SizedBox(height: HcSpace.md),
          tiles[1],
        ],
      );
    }

    // IntrinsicHeight gives the two tiles a shared height; a bare
    // `stretch` Row inside a vertical ListView would be handed an infinite
    // height constraint.
    return IntrinsicHeight(
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Expanded(child: tiles[0]),
          const SizedBox(width: HcSpace.md),
          Expanded(child: tiles[1]),
        ],
      ),
    );
  }
}

class _CountTile extends StatelessWidget {
  const _CountTile({
    required this.icon,
    required this.label,
    required this.emphasised,
  });

  final IconData icon;
  final String label;
  final bool emphasised;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final palette = context.hcPalette;
    final colors = emphasised ? palette.candidate : palette.neutral;

    return HcCard(
      color: colors.fill,
      borderColor: colors.outline,
      padding: const EdgeInsets.all(HcSpace.lg),
      child: MergeSemantics(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            ExcludeSemantics(
              child: Icon(
                icon,
                size: MediaQuery.textScalerOf(context).scale(22),
                color: colors.onFill,
              ),
            ),
            const SizedBox(height: HcSpace.sm),
            Text(
              label,
              style: theme.textTheme.titleMedium?.copyWith(
                color: colors.onFill,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _CandidateReviewCard extends StatelessWidget {
  const _CandidateReviewCard({
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
    final theme = Theme.of(context);

    return HcCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          MergeSemantics(
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                HcCategoryAvatar(category: location.category),
                const SizedBox(width: HcSpace.md),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        location.name,
                        style: theme.textTheme.titleMedium,
                      ),
                      const SizedBox(height: 2),
                      Text(
                        '${location.category.label} · ${location.city}',
                        style: theme.textTheme.bodyMedium?.copyWith(
                          color: theme.colorScheme.onSurfaceVariant,
                        ),
                      ),
                      Text(
                        location.address,
                        style: theme.textTheme.bodySmall?.copyWith(
                          color: theme.colorScheme.onSurfaceVariant,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: HcSpace.lg),
          _DecisionButtons(
            isBusy: isBusy,
            onApprove: onApprove,
            onReject: onReject,
          ),
        ],
      ),
    );
  }
}

class _VerificationRequestReviewCard extends StatelessWidget {
  const _VerificationRequestReviewCard({
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
    final theme = Theme.of(context);
    final scheme = theme.colorScheme;

    return HcCard(
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
                      Text(
                        request.locationName,
                        style: theme.textTheme.titleMedium,
                      ),
                      const SizedBox(height: 2),
                      Text(
                        'Broadcast "${request.broadcastName}"',
                        style: theme.textTheme.bodyMedium?.copyWith(
                          color: scheme.onSurfaceVariant,
                        ),
                      ),
                      Text(
                        'Submitted by ${request.userId}',
                        style: theme.textTheme.bodySmall?.copyWith(
                          color: scheme.onSurfaceVariant,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: HcSpace.lg),
          _DecisionButtons(
            isBusy: isBusy,
            onApprove: onApprove,
            onReject: onReject,
          ),
        ],
      ),
    );
  }
}

class _DecisionButtons extends StatelessWidget {
  const _DecisionButtons({
    required this.isBusy,
    required this.onApprove,
    required this.onReject,
  });

  final bool isBusy;
  final VoidCallback onApprove;
  final VoidCallback onReject;

  @override
  Widget build(BuildContext context) {
    final palette = context.hcPalette;

    return HcActionBar(
      children: [
        FilledButton.icon(
          onPressed: isBusy ? null : onApprove,
          icon: isBusy
              ? const SizedBox.square(
                  dimension: 16,
                  child: CircularProgressIndicator(strokeWidth: 2),
                )
              : const Icon(Icons.check_rounded),
          label: const Text('Approve'),
        ),
        OutlinedButton.icon(
          onPressed: isBusy ? null : onReject,
          icon: const Icon(Icons.close_rounded),
          label: const Text('Reject'),
          style: OutlinedButton.styleFrom(
            foregroundColor: palette.danger.outline,
            side: BorderSide(color: palette.danger.outline, width: 1.5),
          ),
        ),
      ],
    );
  }
}
