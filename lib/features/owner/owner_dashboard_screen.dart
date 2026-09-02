import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/theme/hc_palette.dart';
import '../../core/utils/validators.dart';
import '../../core/utils/write_timeout.dart';
import '../../core/widgets/hc_category.dart';
import '../../core/widgets/hc_layout.dart';
import '../../core/widgets/hc_states.dart';
import '../../core/widgets/hc_status.dart';
import '../../models/auracast_location.dart';
import '../../providers/firebase_providers.dart';
import '../../providers/location_providers.dart';
import '../../providers/session_providers.dart';

class OwnerDashboardScreen extends ConsumerStatefulWidget {
  const OwnerDashboardScreen({super.key});

  @override
  ConsumerState<OwnerDashboardScreen> createState() =>
      _OwnerDashboardScreenState();
}

class _OwnerDashboardScreenState extends ConsumerState<OwnerDashboardScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _addressController = TextEditingController();
  final _cityController = TextEditingController();
  LocationCategory _category = LocationCategory.conference;
  var _isSubmitting = false;
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
    final myLocationsAsync = ref.watch(myLocationsProvider);

    return HcScreen(
      children: [
        const HcPageHeader(
          title: 'Your locations',
          subtitle: 'Submit a place you run. An admin reviews it before it '
              'appears on the public map.',
        ),
        _buildLocationForm(context),
        const SizedBox(height: HcSpace.xxl),
        const HcSectionHeader(
          title: 'Submitted locations',
          subtitle: 'Status updates here as soon as an admin decides.',
        ),
        myLocationsAsync.when(
          data: (locations) {
            if (locations.isEmpty) {
              return const HcEmptyState(
                icon: Icons.add_location_alt_outlined,
                title: 'No owner locations yet',
                message: 'Submit your first place with the form above.',
              );
            }

            return HcListGroup(
              children: [
                for (final location in locations)
                  _OwnerLocationRow(location: location),
              ],
            );
          },
          loading: () => const HcLoadingState(
            message: 'Loading your submissions…',
          ),
          error: (error, stackTrace) => HcErrorState(
            title: 'Could not load your locations',
            error: error,
            onRetry: () => ref.invalidate(myLocationsProvider),
          ),
        ),
      ],
    );
  }

  Widget _buildLocationForm(BuildContext context) {
    final message = _message;

    return HcCard(
      padding: const EdgeInsets.all(HcSpace.xl),
      child: Form(
        key: _formKey,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const HcSectionHeader(
              title: 'Create location draft',
              subtitle: 'Four details are enough to get started.',
            ),
            TextFormField(
              controller: _nameController,
              decoration: const InputDecoration(
                labelText: 'Location name',
                hintText: 'e.g. Aalborg Congress Centre',
              ),
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
              onPressed: _isSubmitting ? null : _submitLocation,
              icon: _isSubmitting
                  ? const SizedBox.square(
                      dimension: 18,
                      child: CircularProgressIndicator(strokeWidth: 2),
                    )
                  : const Icon(Icons.send_rounded),
              label: const Text('Create draft'),
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

  Future<void> _submitLocation() async {
    if (!(_formKey.currentState?.validate() ?? false)) {
      return;
    }

    final owner = ref.read(currentAppUserProvider).valueOrNull;
    if (owner == null) {
      setState(() {
        _message = 'You need to be signed in to submit a location.';
        _messageTone = HcNoticeTone.error;
      });
      return;
    }

    setState(() {
      _isSubmitting = true;
      _message = null;
    });

    final repository = ref.read(locationRepositoryProvider);
    final candidate = AuracastLocation(
      id: repository.newLocationId(),
      name: _nameController.text.trim(),
      address: _addressController.text.trim(),
      city: _cityController.text.trim(),
      category: _category,
      status: LocationStatus.candidate,
      latitude: 0,
      longitude: 0,
      notes: 'Owner submitted, awaiting admin review.',
      ownerId: owner.id,
    );

    try {
      await repository.saveCandidateLocation(candidate).withWriteTimeout();

      if (!mounted) {
        return;
      }
      _nameController.clear();
      _addressController.clear();
      _cityController.clear();
      setState(() {
        _message = 'Submitted for admin review.';
        _messageTone = HcNoticeTone.success;
      });
    } on TimeoutException catch (error) {
      if (mounted) {
        setState(() {
          _message = error.message ?? hcWriteTimeoutMessage;
          _messageTone = HcNoticeTone.error;
        });
      }
    } on Object catch (error) {
      if (mounted) {
        setState(() {
          _message = 'Could not submit: $error';
          _messageTone = HcNoticeTone.error;
        });
      }
    } finally {
      if (mounted) {
        setState(() => _isSubmitting = false);
      }
    }
  }
}

class _OwnerLocationRow extends StatelessWidget {
  const _OwnerLocationRow({required this.location});

  final AuracastLocation location;

  @override
  Widget build(BuildContext context) {
    final palette = context.hcPalette;
    final descriptor = HcStatusDescriptor.forLocation(location.status, palette);

    return HcListRow(
      leading: HcCategoryAvatar(category: location.category),
      title: location.name,
      subtitle: '${location.category.label} · ${location.city}',
      badges: [HcStatusBadge(descriptor: descriptor)],
    );
  }
}
