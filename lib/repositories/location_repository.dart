import 'package:cloud_firestore/cloud_firestore.dart';

import '../models/auracast_location.dart';

class LocationRepository {
  const LocationRepository(this._firestore);

  final FirebaseFirestore _firestore;

  CollectionReference<Map<String, dynamic>> get _locations {
    return _firestore.collection('locations');
  }

  Stream<List<AuracastLocation>> watchLocations() {
    return _locations.snapshots().map(_mapDocs);
  }

  /// Locations a normal user is allowed to browse on the map and list.
  Stream<List<AuracastLocation>> watchVerifiedLocations() {
    return _locations
        .where('status', isEqualTo: LocationStatus.verified.name)
        .snapshots()
        .map(_mapDocs);
  }

  /// Candidate locations awaiting admin review.
  Stream<List<AuracastLocation>> watchCandidateLocations() {
    return _locations
        .where('status', isEqualTo: LocationStatus.candidate.name)
        .snapshots()
        .map(_mapDocs);
  }

  /// A single owner's own submissions, regardless of status.
  Stream<List<AuracastLocation>> watchLocationsByOwner(String ownerId) {
    return _locations
        .where('ownerId', isEqualTo: ownerId)
        .snapshots()
        .map(_mapDocs);
  }

  Future<void> saveCandidateLocation(AuracastLocation location) {
    return _locations.doc(location.id).set(location.toMap());
  }

  /// A fresh Firestore-generated document id, so two owners submitting a
  /// location with the same name never collide on the same document.
  String newLocationId() => _locations.doc().id;

  List<AuracastLocation> _mapDocs(QuerySnapshot<Map<String, dynamic>> snapshot) {
    return snapshot.docs
        .map((doc) => AuracastLocation.fromMap(doc.id, doc.data()))
        .toList();
  }
}
