import 'package:cloud_firestore/cloud_firestore.dart';

import '../models/app_user.dart';

class UserRepository {
  const UserRepository(this._firestore);

  final FirebaseFirestore _firestore;

  CollectionReference<Map<String, dynamic>> get _users {
    return _firestore.collection('users');
  }

  Stream<AppUser?> watchUser(String userId) {
    return _users.doc(userId).snapshots().map((snapshot) {
      final data = snapshot.data();
      if (data == null) {
        return null;
      }
      return AppUser.fromMap(data);
    });
  }

  Future<void> saveUser(AppUser user) {
    return _users.doc(user.id).set(user.toMap());
  }

  /// Returns the existing profile for [uid], or creates one with the
  /// default 'user' role if this is the account's first sign-in. Never
  /// overwrites an existing role (e.g. an admin promotion).
  Future<AppUser> ensureUserProfile({
    required String uid,
    required String email,
    String? name,
  }) async {
    final doc = _users.doc(uid);
    final snapshot = await doc.get();
    final existing = snapshot.data();
    if (existing != null) {
      return AppUser.fromMap(existing);
    }

    final trimmedName = name?.trim() ?? '';
    final user = AppUser(
      id: uid,
      name: trimmedName.isNotEmpty ? trimmedName : email,
      email: email,
    );
    await doc.set(user.toMap());
    return user;
  }
}
