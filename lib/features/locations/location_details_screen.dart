import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

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
  ConsumerState<LocationDetailsScreen> createState() => _LocationDetailsScreenState();
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
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          Text(
            location.name,
            style: Theme.of(context).textTheme.headlineSmall,
          ),
          const SizedBox(height: 8),
          Text(
            [location.address, location.city].join(', '),
            style: Theme.of(context).textTheme.bodyLarge,
          ),
          const SizedBox(height: 16),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: [
              Chip(
                avatar: const Icon(Icons.category_outlined),
                label: Text(location.category.label),
              ),
              Chip(
                avatar: const Icon(Icons.info_outline),
                label: Text(location.status.label),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Card(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Text(
                location.notes.isEmpty
                    ? 'No notes have been added for this candidate yet.'
                    : location.notes,
              ),
            ),
          ),
          const SizedBox(height: 16),
          Card(
            child: ListTile(
              leading: const Icon(Icons.location_on_outlined),
              title: const Text('Approximate coordinates'),
              subtitle: Text(
                '${location.latitude.toStringAsFixed(4)}, '
                '${location.longitude.toStringAsFixed(4)}',
              ),
            ),
          ),
          const SizedBox(height: 16),
          _BroadcastProfilesCard(locationId: location.id),
          const SizedBox(height: 16),
          _LocationActionsCard(
            isFavorite: _favorite != null,
            hasReport: _reports.isNotEmpty,
            onFavoritePressed: _toggleFavorite,
            onReportPressed: _reportIssue,
          ),
          const SizedBox(height: 16),
          _ReviewCard(
            controller: _reviewController,
            rating: _rating,
            reviews: _reviews,
            onRatingChanged: (rating) {
              if (rating != null) {
                setState(() => _rating = rating);
              }
            },
            onSubmit: _addReview,
          ),
          const SizedBox(height: 24),
          OutlinedButton.icon(
            onPressed: () => Navigator.of(context).pop(),
            icon: const Icon(Icons.arrow_back),
            label: const Text('Back to list'),
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

class _BroadcastProfilesCard extends ConsumerWidget {
  const _BroadcastProfilesCard({required this.locationId});

  final String locationId;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final broadcastsAsync = ref.watch(broadcastsForLocationProvider(locationId));
    final isAdmin =
        ref.watch(currentAppUserProvider).valueOrNull?.role == AppUserRole.admin;

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Expanded(
                  child: Text(
                    'Broadcast profiles',
                    style: Theme.of(context).textTheme.titleMedium,
                  ),
                ),
                if (isAdmin)
                  IconButton(
                    onPressed: () => _showAddDialog(context, ref),
                    icon: const Icon(Icons.add_circle_outline),
                    tooltip: 'Add broadcast profile',
                  ),
              ],
            ),
            const SizedBox(height: 4),
            broadcastsAsync.when(
              data: (broadcasts) {
                if (broadcasts.isEmpty) {
                  return const Text(
                    'No known broadcast profiles for this location yet.',
                  );
                }
                return Column(
                  children: [
                    for (final broadcast in broadcasts)
                      ListTile(
                        contentPadding: EdgeInsets.zero,
                        leading: const Icon(Icons.podcasts_outlined),
                        title: Text(broadcast.name),
                        subtitle: Text(
                          [
                            if (broadcast.language.isNotEmpty) broadcast.language,
                            broadcast.accessType.label,
                            if (broadcast.description.isNotEmpty)
                              broadcast.description,
                          ].join(' · '),
                        ),
                        trailing: isAdmin
                            ? IconButton(
                                onPressed: () =>
                                    _deleteBroadcast(context, ref, broadcast),
                                icon: const Icon(Icons.delete_outline),
                                tooltip: 'Delete',
                              )
                            : null,
                      ),
                  ],
                );
              },
              loading: () => const Padding(
                padding: EdgeInsets.symmetric(vertical: 8),
                child: Center(child: CircularProgressIndicator()),
              ),
              error: (error, stackTrace) =>
                  Text('Could not load broadcast profiles.\n$error'),
            ),
          ],
        ),
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
          .deleteBroadcast(locationId, broadcast.id);
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
                    TextField(
                      controller: languageController,
                      decoration: const InputDecoration(labelText: 'Language'),
                    ),
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
    try {
      await repository.saveBroadcast(
        Broadcast(
          id: repository.newBroadcastId(locationId),
          locationId: locationId,
          name: nameController.text.trim(),
          language: languageController.text.trim(),
          accessType: accessType,
          description: descriptionController.text.trim(),
        ),
      );
    } on Object catch (error) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Could not add broadcast profile: $error')),
        );
      }
    }
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
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Wrap(
          spacing: 8,
          runSpacing: 8,
          children: [
            FilledButton.icon(
              onPressed: onFavoritePressed,
              icon: Icon(
                isFavorite ? Icons.bookmark : Icons.bookmark_border_outlined,
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
  final ValueChanged<int?> onRatingChanged;
  final VoidCallback onSubmit;

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Reviews',
              style: Theme.of(context).textTheme.titleMedium,
            ),
            const SizedBox(height: 12),
            DropdownButtonFormField<int>(
              initialValue: rating,
              decoration: const InputDecoration(
                labelText: 'Rating',
                border: OutlineInputBorder(),
              ),
              items: [
                for (var value = 1; value <= 5; value++)
                  DropdownMenuItem(
                    value: value,
                    child: Text('$value stars'),
                  ),
              ],
              onChanged: onRatingChanged,
            ),
            const SizedBox(height: 12),
            TextField(
              controller: controller,
              decoration: const InputDecoration(
                labelText: 'Review note',
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 12),
            Align(
              alignment: Alignment.centerRight,
              child: FilledButton.icon(
                onPressed: onSubmit,
                icon: const Icon(Icons.rate_review_outlined),
                label: const Text('Add review'),
              ),
            ),
            const SizedBox(height: 12),
            if (reviews.isEmpty)
              const Text('No reviews yet')
            else
              for (final review in reviews)
                ListTile(
                  contentPadding: EdgeInsets.zero,
                  leading: const Icon(Icons.star_outline),
                  title: Text('${review.rating} stars'),
                  subtitle: Text(review.comment),
                ),
          ],
        ),
      ),
    );
  }
}
