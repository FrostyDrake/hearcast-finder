import 'package:flutter/material.dart';

class ScanPlaceholderScreen extends StatelessWidget {
  const ScanPlaceholderScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return const Center(
      child: Padding(
        padding: EdgeInsets.all(24),
        child: Text(
          'Bluetooth scan work is planned for a later milestone after the basic app flow is clearer.',
          textAlign: TextAlign.center,
        ),
      ),
    );
  }
}
