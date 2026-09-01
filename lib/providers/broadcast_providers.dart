import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../models/broadcast.dart';
import 'firebase_providers.dart';

/// Known broadcast profiles for a single location.
final broadcastsForLocationProvider =
    StreamProvider.family<List<Broadcast>, String>((ref, locationId) {
  return ref.watch(broadcastRepositoryProvider).watchBroadcasts(locationId);
});
