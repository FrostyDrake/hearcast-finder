import 'package:flutter/material.dart';

import '../../models/auracast_location.dart';
import '../../models/location_feedback.dart';
import '../../repositories/location_feedback_repository.dart';

class LocationDetailsScreen extends StatefulWidget {
  const LocationDetailsScreen({
    required this.location,
    super.key,
  });

  final AuracastLocation location;

  @override
  State<LocationDetailsScreen> createState() => _LocationDetailsScreenState();
}

class _LocationDetailsScreenState extends State<LocationDetailsScreen> {
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
