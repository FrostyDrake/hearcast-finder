import 'package:flutter/material.dart';

import '../../models/auracast_location.dart';
import '../theme/hc_palette.dart';

/// One glyph per category, defined once and reused by the list row, the
/// detail header, the category filter and the map legend. Repeating the same
/// glyph in every context is what makes a place recognisable across tabs -
/// today every row shows the same generic ear icon, which carries no
/// information at all.
///
/// Categories are deliberately **not** colour-coded. Hue is reserved for
/// status, so a church and a cinema share the same teal container and differ
/// only by glyph. That keeps the four status hues unambiguous.
extension LocationCategoryGlyph on LocationCategory {
  IconData get icon {
    return switch (this) {
      LocationCategory.cinema => Icons.local_movies_rounded,
      LocationCategory.church => Icons.church_rounded,
      LocationCategory.museum => Icons.museum_rounded,
      LocationCategory.school => Icons.school_rounded,
      LocationCategory.conference => Icons.groups_rounded,
      LocationCategory.transport => Icons.train_rounded,
      LocationCategory.hospital => Icons.local_hospital_rounded,
      LocationCategory.other => Icons.place_rounded,
    };
  }
}

/// A squircle - not a circle: it costs less width and reads more
/// institutional - carrying the category glyph.
class HcCategoryAvatar extends StatelessWidget {
  const HcCategoryAvatar({
    required this.category,
    this.large = false,
    super.key,
  });

  final LocationCategory category;
  final bool large;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    // Scales with the system font setting so the avatar keeps its optical
    // relationship to the title at 200% text.
    final scaler = MediaQuery.textScalerOf(context);
    final box = scaler.scale(large ? 56 : 44);
    final glyph = scaler.scale(large ? 28 : 22);

    return ExcludeSemantics(
      child: Container(
        width: box,
        height: box,
        decoration: ShapeDecoration(
          color: scheme.primaryContainer,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(
              large ? HcRadius.card : HcRadius.avatar,
            ),
          ),
        ),
        child: Icon(
          category.icon,
          size: glyph,
          color: scheme.onPrimaryContainer,
        ),
      ),
    );
  }
}
