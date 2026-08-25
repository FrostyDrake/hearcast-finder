import 'package:flutter/material.dart';

import '../../core/utils/validators.dart';
import '../../models/auracast_location.dart';

class OwnerDashboardScreen extends StatefulWidget {
  const OwnerDashboardScreen({super.key});

  @override
  State<OwnerDashboardScreen> createState() => _OwnerDashboardScreenState();
}

class _OwnerDashboardScreenState extends State<OwnerDashboardScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _addressController = TextEditingController();
  final _cityController = TextEditingController();
  LocationCategory _category = LocationCategory.conference;
  final List<AuracastLocation> _ownerLocations = [];

  @override
  void dispose() {
    _nameController.dispose();
    _addressController.dispose();
    _cityController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        Text(
          'Owner dashboard',
          style: Theme.of(context).textTheme.headlineSmall,
        ),
        const SizedBox(height: 8),
        const Text(
          'Local owner workflow for drafting new Auracast candidate locations before Firestore persistence.',
        ),
        const SizedBox(height: 16),
        _buildLocationForm(context),
        const SizedBox(height: 24),
        Text(
          'Submitted locations',
          style: Theme.of(context).textTheme.titleMedium,
        ),
        const SizedBox(height: 8),
        if (_ownerLocations.isEmpty)
          const Card(
            child: ListTile(
              leading: Icon(Icons.add_location_alt_outlined),
              title: Text('No owner locations yet'),
              subtitle: Text('Create a local draft above.'),
            ),
          )
        else
          for (final location in _ownerLocations)
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
                onPressed: _submitLocation,
                icon: const Icon(Icons.add_location_alt_outlined),
                label: const Text('Create draft'),
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _submitLocation() {
    if (!(_formKey.currentState?.validate() ?? false)) {
      return;
    }

    final id = _nameController.text
        .trim()
        .toLowerCase()
        .replaceAll(RegExp(r'[^a-z0-9]+'), '-');

    setState(() {
      _ownerLocations.insert(
        0,
        AuracastLocation(
          id: id,
          name: _nameController.text.trim(),
          address: _addressController.text.trim(),
          city: _cityController.text.trim(),
          category: _category,
          status: LocationStatus.candidate,
          latitude: 0,
          longitude: 0,
          notes: 'Owner submitted local draft.',
        ),
      );
      _nameController.clear();
      _addressController.clear();
      _cityController.clear();
    });
  }
}
