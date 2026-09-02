import 'package:flutter/material.dart';

import '../../models/auracast_location.dart';
import '../../models/broadcast.dart';
import '../../models/verification_request.dart';
import '../theme/hc_palette.dart';

/// A status rendered three ways at once - colour, icon and text - so meaning
/// never depends on colour alone (WCAG 2.1 SC 1.4.1). This is the single
/// place any status in the app is described, so the icon and wording for
/// "verified" cannot drift between the list, the map and the admin queue.
@immutable
class HcStatusDescriptor {
  const HcStatusDescriptor({
    required this.label,
    required this.icon,
    required this.colors,
  });

  final String label;
  final IconData icon;
  final HcStatusColors colors;

  static HcStatusDescriptor forLocation(
    LocationStatus status,
    HcPalette palette,
  ) {
    return switch (status) {
      LocationStatus.verified => HcStatusDescriptor(
          label: 'Verified',
          icon: Icons.verified_rounded,
          colors: palette.verified,
        ),
      LocationStatus.candidate => HcStatusDescriptor(
          label: 'Candidate',
          icon: Icons.schedule_rounded,
          colors: palette.candidate,
        ),
      LocationStatus.unknown => HcStatusDescriptor(
          label: 'Unknown',
          icon: Icons.help_outline_rounded,
          colors: palette.neutral,
        ),
    };
  }

  static HcStatusDescriptor forVerification(
    VerificationStatus status,
    HcPalette palette,
  ) {
    return switch (status) {
      VerificationStatus.approved => HcStatusDescriptor(
          label: 'Approved',
          icon: Icons.check_circle_rounded,
          colors: palette.verified,
        ),
      VerificationStatus.pending => HcStatusDescriptor(
          label: 'Pending',
          icon: Icons.schedule_rounded,
          colors: palette.candidate,
        ),
      VerificationStatus.rejected => HcStatusDescriptor(
          label: 'Rejected',
          icon: Icons.cancel_rounded,
          colors: palette.danger,
        ),
    };
  }

  static HcStatusDescriptor forAccess(
    BroadcastAccessType type,
    HcPalette palette,
  ) {
    return switch (type) {
      BroadcastAccessType.public => HcStatusDescriptor(
          label: 'Public',
          icon: Icons.public_rounded,
          colors: palette.verified,
        ),
      BroadcastAccessType.private => HcStatusDescriptor(
          label: 'Private',
          icon: Icons.lock_outline_rounded,
          colors: palette.neutral,
        ),
      BroadcastAccessType.unknown => HcStatusDescriptor(
          label: 'Unknown access',
          icon: Icons.help_outline_rounded,
          colors: palette.neutral,
        ),
    };
  }
}

/// A stadium pill carrying a status. The stadium shape is reserved for
/// status throughout the app, so a pill always means "this is a state, not a
/// button".
///
/// The tinted fill is only ~1.25:1 against the page, so the 1dp outline is
/// what actually satisfies SC 1.4.11 - it is structural, not decoration.
class HcStatusBadge extends StatelessWidget {
  const HcStatusBadge({
    required this.descriptor,
    this.semanticPrefix = 'Status',
    super.key,
  });

  HcStatusBadge.location(
    LocationStatus status,
    HcPalette palette, {
    super.key,
  })  : descriptor = HcStatusDescriptor.forLocation(status, palette),
        semanticPrefix = 'Status';

  HcStatusBadge.verification(
    VerificationStatus status,
    HcPalette palette, {
    super.key,
  })  : descriptor = HcStatusDescriptor.forVerification(status, palette),
        semanticPrefix = 'Review status';

  final HcStatusDescriptor descriptor;
  final String semanticPrefix;

  @override
  Widget build(BuildContext context) {
    final colors = descriptor.colors;
    // The icon tracks the text size so the pill stays balanced when the user
    // turns system text up to 200%.
    final iconSize = MediaQuery.textScalerOf(context).scale(15);

    return Semantics(
      label: '$semanticPrefix: ${descriptor.label}',
      excludeSemantics: true,
      child: Container(
        padding: const EdgeInsets.symmetric(
          horizontal: HcSpace.md,
          vertical: 6,
        ),
        decoration: ShapeDecoration(
          color: colors.fill,
          shape: StadiumBorder(side: BorderSide(color: colors.outline)),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Icon(descriptor.icon, size: iconSize, color: colors.onFill),
            const SizedBox(width: 6),
            Flexible(
              child: Text(
                descriptor.label,
                style: Theme.of(context).textTheme.labelMedium?.copyWith(
                      color: colors.onFill,
                      fontWeight: FontWeight.w700,
                    ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// A device-capability readout on the Scan screen: available or not, said
/// with colour, icon and words at once, and announced to a screen reader as
/// a complete sentence rather than a bare label.
class HcCapabilityChip extends StatelessWidget {
  const HcCapabilityChip({
    required this.label,
    required this.enabled,
    super.key,
  });

  final String label;
  final bool enabled;

  @override
  Widget build(BuildContext context) {
    final palette = context.hcPalette;
    final colors = enabled ? palette.verified : palette.danger;
    final iconSize = MediaQuery.textScalerOf(context).scale(16);

    return Semantics(
      label: '$label: ${enabled ? 'available' : 'unavailable'}',
      excludeSemantics: true,
      child: Container(
        padding: const EdgeInsets.symmetric(
          horizontal: HcSpace.md,
          vertical: HcSpace.sm,
        ),
        decoration: ShapeDecoration(
          color: colors.fill,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(HcRadius.control),
            side: BorderSide(color: colors.outline),
          ),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              enabled ? Icons.check_circle_rounded : Icons.cancel_rounded,
              size: iconSize,
              color: colors.onFill,
            ),
            const SizedBox(width: 6),
            Flexible(
              child: Text(
                label,
                style: Theme.of(context).textTheme.labelMedium?.copyWith(
                      color: colors.onFill,
                      fontWeight: FontWeight.w600,
                    ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
