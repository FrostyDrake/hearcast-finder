import 'package:flutter/material.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({
    required this.onBrowseLocations,
    super.key,
  });

  final VoidCallback onBrowseLocations;

  @override
  Widget build(BuildContext context) {
    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        Text(
          'Find public audio locations',
          style: Theme.of(context).textTheme.headlineSmall,
        ),
        const SizedBox(height: 8),
        const Text(
          'A simple Android app prototype for finding places that may support Auracast or Bluetooth LE Audio broadcasts.',
        ),
        const SizedBox(height: 24),
        const Card(
          child: ListTile(
            leading: Icon(Icons.route_outlined),
            title: Text('Development focus'),
            subtitle: Text(
              'Navigation and first data models are in place. Live maps, accounts, and scanning will come later.',
            ),
          ),
        ),
        const SizedBox(height: 16),
        FilledButton.icon(
          onPressed: onBrowseLocations,
          icon: const Icon(Icons.place_outlined),
          label: const Text('Browse candidate locations'),
        ),
      ],
    );
  }
}
