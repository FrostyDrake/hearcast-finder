import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/theme/hc_palette.dart';
import '../../core/utils/write_timeout.dart';
import '../../core/widgets/hc_category.dart';
import '../../core/widgets/hc_layout.dart';
import '../../core/widgets/hc_states.dart';
import '../../core/widgets/hc_status.dart';
import '../../models/app_user.dart';
import '../../models/auracast_location.dart';
import '../../models/broadcast.dart';
import '../../models/location_feedback.dart';
import '../../providers/broadcast_providers.dart';
import '../../providers/firebase_providers.dart';
import '../../providers/session_providers.dart';
import '../../repositories/location_feedback_repository.dart';

class LocationDetailsScreen extends ConsumerStatefulWidget {
  const LocationDetailsScreen({
    required this.location,
    super.key,
  });

  final AuracastLocation location;

  @override
  ConsumerState<LocationDetailsScreen> createState() =>
      _LocationDetailsScreenState();
}

class _LocationDetailsScreenState extends ConsumerState<LocationDetailsScreen> {
  final _feedbackRepository = const LocationFeedbackRepository();
  final _reviewController = TextEditingController();
  final List<LocationReview> _reviews = [];
  final List<LocationReport> _reports = [];
  FavoriteLocation? _favorite;
  var _rating = 4;

  @override
  void dispose() {
    _reviewController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final location = widget.location;

    return Scaffold(
      appBar: AppBar(title: const Text('Location details')),
      body: HcScreen(
        children: [
          _LocationHeaderCard(location: location),
          const SizedBox(height: HcSpace.lg),
          _NotesCard(notes: location.notes),
          const SizedBox(height: HcSpace.lg),
          HcCard(
            child: HcDetailRow(
              icon: Icons.explore_outlined,
              label: 'Approximate coordinates',
              value: '${location.latitude.toStringAsFixed(4)}, '
                  '${location.longitude.toStringAsFixed(4)}',
            ),
          ),
          const SizedBox(height: HcSpace.lg),
          _BroadcastProfilesCard(locationId: location.id),
          const SizedBox(height: HcSpace.lg),
          _LocationActionsCard(
            isFavorite: _favorite != null,
            hasReport: _reports.isNotEmpty,
            onFavoritePressed: _toggleFavorite,
            onReportPressed: _reportIssue,
          ),
          const SizedBox(height: HcSpace.lg),
          _ReviewCard(
            controller: _reviewController,
            rating: _rating,
            reviews: _reviews,
            onRatingChanged: (rating) => setState(() => _rating = rating),
            onSubmit: _addReview,
          ),
        ],
      ),
    );
  }

  void _toggleFavorite() {
    setState(() {
      _favorite = _favorite == null
          ? _feedbackRepository.createLocalFavorite(widget.location.id)
          : null;
    });
  }

  void _reportIssue() {
    if (_reports.isNotEmpty) {
      return;
    }

    setState(() {
      _reports.add(
        _feedbackRepository.createLocalReport(
          locationId: widget.location.id,
          reason: LocationReportReason.incorrectInfo,
        ),
      );
    });
  }

  void _addReview() {
    final comment = _reviewController.text.trim();
    if (comment.isEmpty) {
      return;
    }

    setState(() {
      _reviews.insert(
        0,
        _feedbackRepository.createLocalReview(
          locationId: widget.location.id,
          rating: _rating,
          comment: comment,
        ),
      );
      _reviewController.clear();
    });
  }
}

/// Name, address and state, in that order: the most important facts first,
/// with anything the user can *do* pushed below the fold of the card.
class _LocationHeaderCard extends StatelessWidget {
  const _LocationHeaderCard({required this.location});

  final AuracastLocation location;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final scheme = theme.colorScheme;
    final palette = context.hcPalette;
    final scaler = MediaQuery.textScalerOf(context);

    return HcCard(
      padding: const EdgeInsets.all(HcSpace.xl),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              HcCategoryAvatar(category: location.category, large: true),
              const SizedBox(width: HcSpace.lg),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Semantics(
                      header: true,
                      child: Text(
                        location.name,
                        style: theme.textTheme.headlineSmall,
                      ),
                    ),
                    const SizedBox(height: HcSpace.xs),
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        ExcludeSemantics(
                          child: Icon(
                            Icons.location_on_outlined,
                            size: scaler.scale(16),
                            color: scheme.onSurfaceVariant,
                          ),
                        ),
                        const SizedBox(width: HcSpace.xs),
                        Expanded(
                          child: Text(
                            [location.address, location.city].join(', '),
                            style: theme.textTheme.bodyMedium?.copyWith(
                              color: scheme.onSurfaceVariant,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: HcSpace.lg),
          Wrap(
            spacing: HcSpace.sm,
            runSpacing: HcSpace.sm,
            children: [
              HcStatusBadge(
                descriptor: HcStatusDescriptor.forLocation(
                  location.status,
                  palette,
                ),
              ),
              HcStatusBadge(
                semanticPrefix: 'Category',
                descriptor: HcStatusDescriptor(
                  label: location.category.label,
                  icon: location.category.icon,
                  colors: palette.neutral,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _NotesCard extends StatelessWidget {
  const _NotesCard({required this.notes});

  final String notes;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final scheme = theme.colorScheme;
    final isEmpty = notes.isEmpty;

    return HcCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Notes',
            style: theme.textTheme.bodySmall?.copyWith(
              color: scheme.onSurfaceVariant,
              fontWeight: FontWeight.w600,
              letterSpacing: 0.3,
            ),
          ),
          const SizedBox(height: HcSpace.xs),
          Text(
            isEmpty
                ? 'No notes have been added for this candidate yet.'
                : notes,
            style: theme.textTheme.bodyLarge?.copyWith(
              color: isEmpty ? scheme.onSurfaceVariant : scheme.onSurface,
            ),
          ),
        ],
      ),
    );
  }
}

class _BroadcastProfilesCard extends ConsumerWidget {
  const _BroadcastProfilesCard({required this.locationId});

  final String locationId;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final broadcastsAsync = ref.watch(
      broadcastsForLocationProvider(locationId),
    );
    final isAdmin = ref.watch(currentAppUserProvider).valueOrNull?.role ==
        AppUserRole.admin;

    return HcCard(
      padding: const EdgeInsets.fromLTRB(
        HcSpace.lg,
        HcSpace.lg,
        HcSpace.lg,
        HcSpace.sm,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          HcSectionHeader(
            title: 'Broadcast profiles',
            subtitle: 'Streams this place is known to run.',
            trailing: isAdmin
                ? IconButton(
                    onPressed: () => _showAddDialog(context, ref),
                    icon: const Icon(Icons.add_circle_outline),
                    tooltip: 'Add broadcast profile',
                  )
                : null,
          ),
          broadcastsAsync.when(
            data: (broadcasts) {
              if (broadcasts.isEmpty) {
                return Padding(
                  padding: const EdgeInsets.only(bottom: HcSpace.sm),
                  child: Text(
                    'No known broadcast profiles for this location yet.',
                    style: theme.textTheme.bodyMedium?.copyWith(
                      color: theme.colorScheme.onSurfaceVariant,
                    ),
                  ),
                );
              }
              return Column(
                children: [
                  for (final broadcast in broadcasts)
                    _BroadcastRow(
                      broadcast: broadcast,
                      onDelete: isAdmin
                          ? () => _deleteBroadcast(context, ref, broadcast)
                          : null,
                    ),
                ],
              );
            },
            loading: () => const Padding(
              padding: EdgeInsets.only(bottom: HcSpace.lg),
              child: HcLoadingState(message: 'Loading broadcast profiles…'),
            ),
            error: (error, stackTrace) => Padding(
              padding: const EdgeInsets.only(bottom: HcSpace.sm),
              child: Text(
                'Could not load broadcast profiles.\n$error',
                style: theme.textTheme.bodySmall,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Future<void> _deleteBroadcast(
    BuildContext context,
    WidgetRef ref,
    Broadcast broadcast,
  ) async {
    try {
      await ref
          .read(broadcastRepositoryProvider)
          .deleteBroadcast(locationId, broadcast.id)
          .withWriteTimeout();
    } on Object catch (error) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Could not delete: $error')),
        );
      }
    }
  }

  Future<void> _showAddDialog(BuildContext context, WidgetRef ref) async {
    final nameController = TextEditingController();
    final languageController = TextEditingController();
    final descriptionController = TextEditingController();
    var accessType = BroadcastAccessType.public;

    final shouldSave = await showDialog<bool>(
      context: context,
      builder: (dialogContext) {
        return StatefulBuilder(
          builder: (dialogContext, setDialogState) {
            return AlertDialog(
              title: const Text('Add broadcast profile'),
              content: SingleChildScrollView(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    TextField(
                      controller: nameController,
                      decoration: const InputDecoration(labelText: 'Name'),
                      autofocus: true,
                    ),
                    const SizedBox(height: HcSpace.md),
                    TextField(
                      controller: languageController,
                      decoration: const InputDecoration(labelText: 'Language'),
                    ),
                    const SizedBox(height: HcSpace.md),
                    DropdownButtonFormField<BroadcastAccessType>(
                      initialValue: accessType,
                      decoration: const InputDecoration(labelText: 'Access'),
                      items: BroadcastAccessType.values
                          .map(
                            (type) => DropdownMenuItem(
                              value: type,
                              child: Text(type.label),
                            ),
                          )
                          .toList(),
                      onChanged: (value) {
                        if (value != null) {
                          setDialogState(() => accessType = value);
                        }
                      },
                    ),
                    const SizedBox(height: HcSpace.md),
                    TextField(
                      controller: descriptionController,
                      decoration: const InputDecoration(
                        labelText: 'Description (optional)',
                      ),
                    ),
                  ],
                ),
              ),
              actions: [
                TextButton(
                  onPressed: () => Navigator.of(dialogContext).pop(false),
                  child: const Text('Cancel'),
                ),
                FilledButton(
                  onPressed: () => Navigator.of(dialogContext).pop(true),
                  child: const Text('Add'),
                ),
              ],
            );
          },
        );
      },
    );

    if (shouldSave != true || nameController.text.trim().isEmpty) {
      return;
    }

    final repository = ref.read(broadcastRepositoryProvider);
    final profile = Broadcast(
      id: repository.newBroadcastId(locationId),
      locationId: locationId,
      name: nameController.text.trim(),
      language: languageController.text.trim(),
      accessType: accessType,
      description: descriptionController.text.trim(),
    );
    try {
      await repository.saveBroadcast(profile).withWriteTimeout();
    } on TimeoutException catch (error) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(error.message ?? hcWriteTimeoutMessage)),
        );
      }
    } on Object catch (error) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Could not add broadcast profile: $error')),
        );
      }
    }
  }
}

class _BroadcastRow extends StatelessWidget {
  const _BroadcastRow({required this.broadcast, this.onDelete});

  final Broadcast broadcast;
  final VoidCallback? onDelete;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final palette = context.hcPalette;
    final meta = [
      if (broadcast.language.isNotEmpty) broadcast.language,
      if (broadcast.description.isNotEmpty) broadcast.description,
    ].join(' · ');

    return Padding(
      padding: const EdgeInsets.only(bottom: HcSpace.md),
      child: MergeSemantics(
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            ExcludeSemantics(
              child: Icon(
                Icons.graphic_eq_rounded,
                size: MediaQuery.textScalerOf(context).scale(20),
                color: theme.colorScheme.primary,
              ),
            ),
            const SizedBox(width: HcSpace.md),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(broadcast.name, style: theme.textTheme.titleMedium),
                  if (meta.isNotEmpty) ...[
                    const SizedBox(height: 2),
                    Text(
                      meta,
                      style: theme.textTheme.bodySmall?.copyWith(
                        color: theme.colorScheme.onSurfaceVariant,
                      ),
                    ),
                  ],
                  const SizedBox(height: HcSpace.sm),
                  HcStatusBadge(
                    semanticPrefix: 'Access',
                    descriptor: HcStatusDescriptor.forAccess(
                      broadcast.accessType,
                      palette,
                    ),
                  ),
                ],
              ),
            ),
            if (onDelete != null)
              IconButton(
                onPressed: onDelete,
                icon: const Icon(Icons.delete_outline),
                tooltip: 'Delete ${broadcast.name}',
              ),
          ],
        ),
      ),
    );
  }
}

class _LocationActionsCard extends StatelessWidget {
  const _LocationActionsCard({
    required this.isFavorite,
    required this.hasReport,
    required this.onFavoritePressed,
    required this.onReportPressed,
  });

  final bool isFavorite;
  final bool hasReport;
  final VoidCallback onFavoritePressed;
  final VoidCallback onReportPressed;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return HcCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          HcActionBar(
            children: [
              FilledButton.icon(
                onPressed: onFavoritePressed,
                icon: Icon(
                  isFavorite
                      ? Icons.bookmark_rounded
                      : Icons.bookmark_border_rounded,
                ),
                label: Text(isFavorite ? 'Saved favorite' : 'Save favorite'),
              ),
              OutlinedButton.icon(
                onPressed: hasReport ? null : onReportPressed,
                icon: const Icon(Icons.flag_outlined),
                label: Text(hasReport ? 'Report queued' : 'Report issue'),
              ),
            ],
          ),
          const SizedBox(height: HcSpace.md),
          Text(
            'Favourites, reviews and reports are kept on this device only.',
            style: theme.textTheme.bodySmall?.copyWith(
              color: theme.colorScheme.onSurfaceVariant,
            ),
          ),
        ],
      ),
    );
  }
}

class _ReviewCard extends StatelessWidget {
  const _ReviewCard({
    required this.controller,
    required this.rating,
    required this.reviews,
    required this.onRatingChanged,
    required this.onSubmit,
  });

  final TextEditingController controller;
  final int rating;
  final List<LocationReview> reviews;
  final ValueChanged<int> onRatingChanged;
  final VoidCallback onSubmit;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final scheme = theme.colorScheme;

    return HcCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const HcSectionHeader(title: 'Reviews'),
          Text(
            'Rating',
            style: theme.textTheme.labelLarge?.copyWith(
              color: scheme.onSurfaceVariant,
            ),
          ),
          const SizedBox(height: HcSpace.xs),
          _StarPicker(rating: rating, onChanged: onRatingChanged),
          const SizedBox(height: HcSpace.md),
          TextField(
            controller: controller,
            decoration: const InputDecoration(
              labelText: 'Review note',
              floatingLabelBehavior: FloatingLabelBehavior.always,
              hintText: 'What was the audio like?',
            ),
            maxLines: 3,
            minLines: 2,
          ),
          const SizedBox(height: HcSpace.md),
          Align(
            alignment: Alignment.centerRight,
            child: FilledButton.icon(
              onPressed: onSubmit,
              icon: const Icon(Icons.rate_review_outlined),
              label: const Text('Add review'),
            ),
          ),
          const SizedBox(height: HcSpace.lg),
          if (reviews.isEmpty)
            Text(
              'No reviews yet',
              style: theme.textTheme.bodyMedium?.copyWith(
                color: scheme.onSurfaceVariant,
              ),
            )
          else
            for (final review in reviews)
              Padding(
                padding: const EdgeInsets.only(bottom: HcSpace.md),
                child: MergeSemantics(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      _StarRow(rating: review.rating),
                      const SizedBox(height: HcSpace.xs),
                      Text(review.comment, style: theme.textTheme.bodyLarge),
                    ],
                  ),
                ),
              ),
        ],
      ),
    );
  }
}

/// Five tappable stars. Each is a full 48dp target, and the current value is
/// also announced as text so the rating never depends on counting glyphs.
class _StarPicker extends StatelessWidget {
  const _StarPicker({required this.rating, required this.onChanged});

  final int rating;
  final ValueChanged<int> onChanged;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;

    return Semantics(
      label: 'Rating: $rating of 5 stars',
      child: Wrap(
        children: [
          for (var value = 1; value <= 5; value++)
            IconButton(
              onPressed: () => onChanged(value),
              tooltip: '$value star${value == 1 ? '' : 's'}',
              icon: Icon(
                value <= rating ? Icons.star_rounded : Icons.star_outline_rounded,
                color: value <= rating
                    ? scheme.primary
                    : scheme.onSurfaceVariant,
              ),
            ),
        ],
      ),
    );
  }
}

class _StarRow extends StatelessWidget {
  const _StarRow({required this.rating});

  final int rating;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final size = MediaQuery.textScalerOf(context).scale(16);

    return Semantics(
      label: '$rating out of 5 stars',
      excludeSemantics: true,
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          for (var value = 1; value <= 5; value++)
            Icon(
              value <= rating ? Icons.star_rounded : Icons.star_outline_rounded,
              size: size,
              color: value <= rating
                  ? theme.colorScheme.primary
                  : theme.colorScheme.onSurfaceVariant,
            ),
          const SizedBox(width: HcSpace.sm),
          Text(
            '$rating stars',
            style: theme.textTheme.bodySmall?.copyWith(
              color: theme.colorScheme.onSurfaceVariant,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }
}
