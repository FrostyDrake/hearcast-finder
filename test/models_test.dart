import 'package:flutter_test/flutter_test.dart';
import 'package:hearcast_finder/models/app_user.dart';
import 'package:hearcast_finder/models/auracast_location.dart';
import 'package:hearcast_finder/models/scan_result.dart';

void main() {
  test('location category labels are readable', () {
    expect(LocationCategory.conference.label, 'Conference');
    expect(LocationCategory.transport.label, 'Transport');
  });

  test('locations can match simple search queries', () {
    const location = AuracastLocation(
      id: 'museum-auditorium',
      name: 'Museum Auditorium',
      address: 'Gallery Road 4',
      city: 'Aarhus',
      category: LocationCategory.museum,
      status: LocationStatus.unknown,
      latitude: 56.1629,
      longitude: 10.2039,
      notes: 'Guided tours and auditorium talks.',
    );

    expect(location.matchesQuery('aarhus'), isTrue);
    expect(location.matchesQuery('guided'), isTrue);
    expect(location.matchesQuery('airport'), isFalse);
  });

  test('locations can be serialized for Firestore', () {
    const location = AuracastLocation(
      id: 'central-station',
      name: 'Central Station',
      address: 'Station Road',
      city: 'Copenhagen',
      category: LocationCategory.transport,
      status: LocationStatus.candidate,
      latitude: 55.6728,
      longitude: 12.5656,
      notes: 'Platform announcements.',
    );

    final parsed = AuracastLocation.fromMap(location.id, location.toMap());

    expect(parsed.id, location.id);
    expect(parsed.category, LocationCategory.transport);
    expect(parsed.notes, 'Platform announcements.');
  });

  test('users can be serialized for Firestore', () {
    const user = AppUser(
      id: 'user-1',
      name: 'Andrei',
      email: 'andrei@example.com',
      role: AppUserRole.owner,
    );

    final parsed = AppUser.fromMap(user.toMap());

    expect(parsed.id, 'user-1');
    expect(parsed.role, AppUserRole.owner);
  });

  test('scan results start as local-only by default', () {
    final result = ScanResult(
      id: 'scan-1',
      broadcastName: 'Main Hall Audio',
      rssi: -62,
      detectedAt: DateTime.utc(2026, 8, 12),
    );

    expect(result.status, ScanResultStatus.localOnly);
  });
}
