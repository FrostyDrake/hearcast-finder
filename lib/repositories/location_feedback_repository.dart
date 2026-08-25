import '../models/location_feedback.dart';

class LocationFeedbackRepository {
  const LocationFeedbackRepository();

  FavoriteLocation createLocalFavorite(
    String locationId, {
    String userId = 'local-user',
  }) {
    return FavoriteLocation.local(locationId: locationId, userId: userId);
  }

  LocationReview createLocalReview({
    required String locationId,
    required int rating,
    required String comment,
    String userId = 'local-user',
  }) {
    return LocationReview.local(
      locationId: locationId,
      rating: rating,
      comment: comment,
      userId: userId,
    );
  }

  LocationReport createLocalReport({
    required String locationId,
    required LocationReportReason reason,
    String userId = 'local-user',
  }) {
    return LocationReport.local(
      locationId: locationId,
      reason: reason,
      userId: userId,
    );
  }
}
