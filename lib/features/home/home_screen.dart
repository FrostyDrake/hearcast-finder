import 'package:flutter/material.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

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
      ],
    );
  }
}
