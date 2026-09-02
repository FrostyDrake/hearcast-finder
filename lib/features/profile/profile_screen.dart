import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/theme/hc_palette.dart';
import '../../core/widgets/hc_layout.dart';
import '../../core/widgets/hc_states.dart';
import '../../core/widgets/hc_status.dart';
import '../../models/app_user.dart';
import '../../providers/session_providers.dart';

class ProfileScreen extends ConsumerWidget {
  const ProfileScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final session = ref.watch(currentAppUserProvider);

    return session.when(
      data: (user) {
        if (user == null) {
          return const Center(child: CircularProgressIndicator());
        }
        return HcScreen(
          children: [
            const HcPageHeader(
              title: 'Your account',
              subtitle: 'What this app knows about you, and what your role '
                  'lets you do.',
            ),
            _IdentityCard(user: user),
            const SizedBox(height: HcSpace.lg),
            _RoleCard(role: user.role),
            const SizedBox(height: HcSpace.xxl),
            OutlinedButton.icon(
              onPressed: () => ref.read(authControllerProvider).signOut(),
              icon: const Icon(Icons.logout_rounded),
              label: const Text('Sign out'),
            ),
          ],
        );
      },
      loading: () => const Center(child: CircularProgressIndicator()),
      error: (error, stackTrace) => Padding(
        padding: const EdgeInsets.all(HcSpace.xxl),
        child: HcErrorState(
          title: 'Could not load your profile',
          error: error,
        ),
      ),
    );
  }
}

class _IdentityCard extends StatelessWidget {
  const _IdentityCard({required this.user});

  final AppUser user;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final scheme = theme.colorScheme;
    final scaler = MediaQuery.textScalerOf(context);
    final displayName = user.name.isEmpty ? user.email : user.name;
    final initial = displayName.trim().isEmpty
        ? '?'
        : displayName.trim().substring(0, 1).toUpperCase();

    return HcCard(
      padding: const EdgeInsets.all(HcSpace.xl),
      child: MergeSemantics(
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            ExcludeSemantics(
              child: Container(
                width: scaler.scale(56),
                height: scaler.scale(56),
                alignment: Alignment.center,
                decoration: ShapeDecoration(
                  color: scheme.primaryContainer,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(HcRadius.card),
                  ),
                ),
                child: Text(
                  initial,
                  style: theme.textTheme.headlineSmall?.copyWith(
                    color: scheme.onPrimaryContainer,
                  ),
                ),
              ),
            ),
            const SizedBox(width: HcSpace.lg),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(displayName, style: theme.textTheme.titleLarge),
                  const SizedBox(height: HcSpace.xs),
                  Text(
                    user.email,
                    style: theme.textTheme.bodyMedium?.copyWith(
                      color: scheme.onSurfaceVariant,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// Says what the role *means*, not just what it is called. "admin" on its own
/// tells a user nothing about what they can do.
class _RoleCard extends StatelessWidget {
  const _RoleCard({required this.role});

  final AppUserRole role;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final palette = context.hcPalette;

    final (label, icon, description) = switch (role) {
      AppUserRole.admin => (
          'Administrator',
          Icons.verified_user_rounded,
          'You can approve or reject submitted locations and scan evidence, '
              'and manage broadcast profiles.',
        ),
      AppUserRole.owner => (
          'Location owner',
          Icons.storefront_rounded,
          'You can submit locations you run and follow their review status.',
        ),
      AppUserRole.user => (
          'Standard user',
          Icons.person_rounded,
          'You can browse verified places, run scans and submit what you '
              'find as evidence.',
        ),
    };

    return HcCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const HcSectionHeader(title: 'Role'),
          HcStatusBadge(
            semanticPrefix: 'Role',
            descriptor: HcStatusDescriptor(
              label: label,
              icon: icon,
              colors: role == AppUserRole.admin
                  ? palette.verified
                  : palette.neutral,
            ),
          ),
          const SizedBox(height: HcSpace.md),
          Text(
            description,
            style: theme.textTheme.bodyMedium?.copyWith(
              color: theme.colorScheme.onSurfaceVariant,
            ),
          ),
        ],
      ),
    );
  }
}
