import 'package:flutter/material.dart';

import 'core/theme/app_theme.dart';
import 'features/auth/auth_gate.dart';

class HearCastFinderApp extends StatelessWidget {
  const HearCastFinderApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'HearCast Finder',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.light(),
      darkTheme: AppTheme.dark(),
      // The audience skews older and low-vision, and a dark-mode phone
      // showing a hard white page is exactly the glare that group turns dark
      // mode on to avoid. Both themes are contrast-verified, so following the
      // system setting costs nothing.
      themeMode: ThemeMode.system,
      home: const AuthGate(),
    );
  }
}
