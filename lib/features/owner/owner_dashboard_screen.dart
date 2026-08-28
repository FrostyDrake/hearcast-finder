import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/utils/validators.dart';
import '../../models/auracast_location.dart';
import '../../providers/firebase_providers.dart';
import '../../providers/location_providers.dart';
import '../../providers/session_providers.dart';

class OwnerDashboardScreen extends ConsumerStatefulWidget {
  const OwnerDashboardScreen({super.key});

  @override
  ConsumerState<OwnerDashboardScreen> createState() => _OwnerDashboardScreenState();
}

class _OwnerDashboardScreenState extends ConsumerState<OwnerDashboardScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _addressController = TextEditingController();
  final _cityController = TextEditingController();
  LocationCategory _category = LocationCategory.conference;
  var _isSubmitting = false;
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
    final myLocationsAsync = ref.watch(myLocationsProvider);

    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        Text(
          'Owner dashboard',
          style: Theme.of(context).textTheme.headlineSmall,
        ),
        const SizedBox(height: 8),
        const Text(
          'Submit a candidate Auracast location for an admin to review.',
        ),
        const SizedBox(height: 16),
        _buildLocationForm(context),
        const SizedBox(height: 24),
        Text(
          'Submitted locations',
          style: Theme.of(context).textTheme.titleMedium,
        ),
        const SizedBox(height: 8),
        myLocationsAsync.when(
          data: (locations) {
            if (locations.isEmpty) {
              return const Card(
                child: ListTile(
                  leading: Icon(Icons.add_location_alt_outlined),
                  title: Text('No owner locations yet'),
                  subtitle: Text('Create a draft above.'),
                ),
              );
            }

            return Column(
              children: [
                for (final location in locations)
                  Card(
                    child: ListTile(
                      leading: const Icon(Icons.place_outlined),
                      title: Text(location.name),
                      subtitle: Text(
                        '${location.category.label} • ${location.city}\n'
                        '${location.status.label}',
                      ),
                      isThreeLine: true,
                    ),
                  ),
              ],
            );
          },
          loading: () => const Padding(
            padding: EdgeInsets.symmetric(vertical: 16),
            child: Center(child: CircularProgressIndicator()),
          ),
          error: (error, stackTrace) => Card(
            child: ListTile(
              leading: const Icon(Icons.error_outline),
              title: const Text('Could not load your locations'),
              subtitle: Text('$error'),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildLocationForm(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Create location draft',
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
                onPressed: _isSubmitting ? null : _submitLocation,
                icon: _isSubmitting
                    ? const SizedBox.square(
                        dimension: 18,
                        child: CircularProgressIndicator(strokeWidth: 2),
                      )
                    : const Icon(Icons.add_location_alt_outlined),
                label: const Text('Create draft'),
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

  Future<void> _submitLocation() async {
    if (!(_formKey.currentState?.validate() ?? false)) {
      return;
    }

    final owner = ref.read(currentAppUserProvider).valueOrNull;
    if (owner == null) {
      setState(() => _message = 'You need to be signed in to submit a location.');
      return;
    }

    setState(() {
      _isSubmitting = true;
      _message = null;
    });

    final repository = ref.read(locationRepositoryProvider);

    try {
      await repository.saveCandidateLocation(
        AuracastLocation(
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
        ),
      );

      if (!mounted) {
        return;
      }
      _nameController.clear();
      _addressController.clear();
      _cityController.clear();
      setState(() => _message = 'Submitted for admin review.');
    } on Object catch (error) {
      if (mounted) {
        setState(() => _message = 'Could not submit: $error');
      }
    } finally {
      if (mounted) {
        setState(() => _isSubmitting = false);
      }
    }
  }
}
