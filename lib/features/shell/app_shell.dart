import 'package:flutter/material.dart';

import '../admin/admin_dashboard_screen.dart';
import '../home/home_screen.dart';
import '../locations/location_list_screen.dart';
import '../map/map_screen.dart';
import '../owner/owner_dashboard_screen.dart';
import '../profile/profile_screen.dart';
import '../scan/scan_screen.dart';
import 'hc_bottom_nav.dart';

class AppShell extends StatefulWidget {
  const AppShell({super.key});

  @override
  State<AppShell> createState() => _AppShellState();
}

class _AppShellState extends State<AppShell> {
  var _selectedIndex = 0;

  void _openTab(int index) {
    setState(() => _selectedIndex = index);
  }

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;

    final screens = [
      HomeScreen(onBrowseLocations: () => _openTab(1)),
      const LocationListScreen(),
      const MapScreen(),
      const ScanScreen(),
      const OwnerDashboardScreen(),
      const AdminDashboardScreen(),
      const ProfileScreen(),
    ];

    return Scaffold(
      appBar: AppBar(
        title: const Text('HearCast Finder'),
        // A hairline instead of a shadow, matching every other surface edge.
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(1),
          child: Container(height: 1, color: scheme.outlineVariant),
        ),
      ),
      body: screens[_selectedIndex],
      bottomNavigationBar: HcBottomNav(
        selectedIndex: _selectedIndex,
        onSelected: _openTab,
        items: const [
          HcNavItem(
            icon: Icons.home_outlined,
            selectedIcon: Icons.home_rounded,
            label: 'Home',
            tooltip: 'Home',
          ),
          HcNavItem(
            icon: Icons.place_outlined,
            selectedIcon: Icons.place_rounded,
            label: 'Locations',
            tooltip: 'Locations',
          ),
          HcNavItem(
            icon: Icons.map_outlined,
            selectedIcon: Icons.map_rounded,
            label: 'Map',
            tooltip: 'Map',
          ),
          HcNavItem(
            icon: Icons.wifi_tethering_rounded,
            selectedIcon: Icons.wifi_tethering_rounded,
            label: 'Scan',
            tooltip: 'Scan for broadcasts',
          ),
          HcNavItem(
            icon: Icons.storefront_outlined,
            selectedIcon: Icons.storefront_rounded,
            label: 'Owner',
            tooltip: 'Owner dashboard',
          ),
          HcNavItem(
            icon: Icons.verified_outlined,
            selectedIcon: Icons.verified_rounded,
            label: 'Admin',
            tooltip: 'Admin review',
          ),
          HcNavItem(
            icon: Icons.person_outline,
            selectedIcon: Icons.person_rounded,
            label: 'Profile',
            tooltip: 'Profile',
          ),
        ],
      ),
    );
  }
}
