import 'package:flutter/material.dart';

import 'features/auth/auth_gate.dart';

class HearCastFinderApp extends StatelessWidget {
  const HearCastFinderApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'HearCast Finder',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: const Color(0xFF146C63)),
        useMaterial3: true,
      ),
      home: const AuthGate(),
    );
  }
}
