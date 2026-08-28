import 'package:cloud_functions/cloud_functions.dart';

import '../models/auracast_location.dart';

/// Admin-only location writes. These always go through Cloud Functions
/// rather than direct Firestore calls, because firestore.rules deliberately
/// blocks client updates/deletes on the locations collection (allow update,
/// delete: if false) — only the Admin SDK inside a Cloud Function can bypass
/// that, after checking the caller's role.
class AdminLocationService {
  AdminLocationService(this._functions);

  final FirebaseFunctions _functions;

  Future<void> createLocation({
    required String name,
    required String address,
    required String city,
    required LocationCategory category,
    required double latitude,
    required double longitude,
    String notes = '',
    LocationStatus status = LocationStatus.verified,
  }) async {
    await _call('createLocation', {
      'name': name,
      'address': address,
      'city': city,
      'category': category.name,
      'latitude': latitude,
      'longitude': longitude,
      'notes': notes,
      'status': status.name,
    });
  }

  Future<void> approveLocation(String locationId) {
    return updateLocation(locationId, {'status': LocationStatus.verified.name});
  }

  Future<void> updateLocation(String locationId, Map<String, dynamic> changes) async {
    await _call('updateLocation', {
      'locationId': locationId,
      ...changes,
    });
  }

  Future<void> deleteLocation(String locationId) async {
    await _call('deleteLocation', {'locationId': locationId});
  }

  Future<void> _call(String name, Map<String, dynamic> data) async {
    try {
      await _functions.httpsCallable(name).call(data);
    } on FirebaseFunctionsException catch (error) {
      throw AdminActionException(_messageFor(error));
    }
  }

  String _messageFor(FirebaseFunctionsException error) {
    switch (error.code) {
      case 'permission-denied':
        return 'Your account does not have admin access.';
      case 'unauthenticated':
        return 'You need to be signed in to do that.';
      case 'invalid-argument':
        return error.message ?? 'Some of the fields were invalid.';
      case 'not-found':
        return 'That location no longer exists.';
      case 'unavailable':
        return 'No internet connection. Check your network and try again.';
      default:
        return error.message ?? 'Something went wrong. Please try again.';
    }
  }
}

class AdminActionException implements Exception {
  const AdminActionException(this.message);

  final String message;

  @override
  String toString() => message;
}
