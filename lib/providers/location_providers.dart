import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../models/auracast_location.dart';
import 'firebase_providers.dart';
import 'session_providers.dart';

/// Verified locations, for the public map and location list.
final verifiedLocationsProvider = StreamProvider<List<AuracastLocation>>((ref) {
  return ref.watch(locationRepositoryProvider).watchVerifiedLocations();
});

/// Candidate locations awaiting admin review.
final candidateLocationsProvider = StreamProvider<List<AuracastLocation>>((ref) {
  return ref.watch(locationRepositoryProvider).watchCandidateLocations();
});

/// The signed-in owner's own submissions, regardless of status.
final myLocationsProvider = StreamProvider<List<AuracastLocation>>((ref) {
  final user = ref.watch(currentAppUserProvider).valueOrNull;
  if (user == null) {
    return Stream.value(const []);
  }
  return ref.watch(locationRepositoryProvider).watchLocationsByOwner(user.id);
});
