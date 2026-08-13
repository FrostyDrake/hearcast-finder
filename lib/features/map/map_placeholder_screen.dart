import 'package:flutter/material.dart';

class MapPlaceholderScreen extends StatelessWidget {
  const MapPlaceholderScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return const Center(
      child: Padding(
        padding: EdgeInsets.all(24),
        child: Text(
          'Map view will show candidate and verified locations after location browsing is stable.',
          textAlign: TextAlign.center,
        ),
      ),
    );
  }
}
