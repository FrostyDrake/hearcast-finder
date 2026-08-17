import 'package:cloud_firestore/cloud_firestore.dart';

import '../models/auracast_location.dart';

class LocationRepository {
  const LocationRepository(this._firestore);

  final FirebaseFirestore _firestore;

  CollectionReference<Map<String, dynamic>> get _locations {
    return _firestore.collection('locations');
  }

  Stream<List<AuracastLocation>> watchLocations() {
    return _locations.snapshots().map((snapshot) {
      return snapshot.docs
          .map((doc) => AuracastLocation.fromMap(doc.id, doc.data()))
          .toList();
    });
  }

  Future<void> saveCandidateLocation(AuracastLocation location) {
    return _locations.doc(location.id).set(location.toMap());
  }
}
