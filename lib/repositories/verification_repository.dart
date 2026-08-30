import 'package:cloud_firestore/cloud_firestore.dart';

import '../models/auracast_location.dart';
import '../models/scan_result.dart';
import '../models/verification_request.dart';

class VerificationRepository {
  const VerificationRepository(this._firestore);

  final FirebaseFirestore _firestore;

  CollectionReference<Map<String, dynamic>> get _requests {
    return _firestore.collection('verificationRequests');
  }

  VerificationRequest createLocalRequest({
    required ScanResult scanResult,
    required AuracastLocation location,
    required String userId,
  }) {
    return VerificationRequest.local(
      scanResult: scanResult,
      location: location,
      userId: userId,
    );
  }

  Future<void> submitRequest(VerificationRequest request) async {
    await _requests.add(request.toMap());
  }

  /// All requests still awaiting admin review, for the admin dashboard.
  Stream<List<VerificationRequest>> watchPendingRequests() {
    return _requests
        .where('status', isEqualTo: VerificationStatus.pending.name)
        .snapshots()
        .map((snapshot) {
      return snapshot.docs
          .map((doc) => VerificationRequest.fromMap(doc.id, doc.data()))
          .toList();
    });
  }

  Future<void> setStatus(String requestId, VerificationStatus status) {
    return _requests.doc(requestId).update({'status': status.name});
  }
}
