import 'package:flutter/material.dart';

class ProfilePlaceholderScreen extends StatelessWidget {
  const ProfilePlaceholderScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return const Center(
      child: Padding(
        padding: EdgeInsets.all(24),
        child: Text(
          'Profile and account features will be added once Firebase Auth is introduced.',
          textAlign: TextAlign.center,
        ),
      ),
    );
  }
}
