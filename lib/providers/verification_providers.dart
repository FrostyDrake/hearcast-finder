import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../models/verification_request.dart';
import 'firebase_providers.dart';

/// Scan-evidence verification requests still awaiting admin review.
final pendingVerificationRequestsProvider =
    StreamProvider<List<VerificationRequest>>((ref) {
  return ref.watch(verificationRepositoryProvider).watchPendingRequests();
});
