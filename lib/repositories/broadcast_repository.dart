import 'package:cloud_firestore/cloud_firestore.dart';

import '../models/broadcast.dart';

class BroadcastRepository {
  const BroadcastRepository(this._firestore);

  final FirebaseFirestore _firestore;

  CollectionReference<Map<String, dynamic>> _broadcasts(String locationId) {
    return _firestore
        .collection('locations')
        .doc(locationId)
        .collection('broadcasts');
  }

  Stream<List<Broadcast>> watchBroadcasts(String locationId) {
    return _broadcasts(locationId).snapshots().map((snapshot) {
      return snapshot.docs
          .map((doc) => Broadcast.fromMap(doc.id, locationId, doc.data()))
          .toList();
    });
  }

  String newBroadcastId(String locationId) => _broadcasts(locationId).doc().id;

  /// Admin-only in practice - firestore.rules rejects this write from
  /// anyone whose users/{uid}.role isn't 'admin'.
  Future<void> saveBroadcast(Broadcast broadcast) {
    return _broadcasts(broadcast.locationId)
        .doc(broadcast.id)
        .set(broadcast.toMap());
  }

  Future<void> deleteBroadcast(String locationId, String broadcastId) {
    return _broadcasts(locationId).doc(broadcastId).delete();
  }
}
