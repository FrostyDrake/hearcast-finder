import 'package:fake_cloud_firestore/fake_cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:hearcast_finder/app.dart';
import 'package:hearcast_finder/features/locations/sample_locations.dart';
import 'package:hearcast_finder/models/app_user.dart';
import 'package:hearcast_finder/models/auracast_location.dart';
import 'package:hearcast_finder/models/verification_request.dart';
import 'package:hearcast_finder/providers/firebase_providers.dart';
import 'package:hearcast_finder/providers/location_providers.dart';
import 'package:hearcast_finder/providers/session_providers.dart';
import 'package:hearcast_finder/providers/verification_providers.dart';

const _testUser = AppUser(
  id: 'test-uid',
  name: 'Andrei',
  email: 'andrei@example.com',
);

/// Bypasses AuthGate by overriding the session stream directly, and backs
/// location data with static fixtures unless [extraOverrides] replaces them.
/// None of this ever touches real Firebase.
Widget _signedInApp({
  AppUser user = _testUser,
  List<Override> extraOverrides = const [],
}) {
  return ProviderScope(
    overrides: [
      currentAppUserProvider.overrideWith((ref) => Stream.value(user)),
      verifiedLocationsProvider.overrideWith((ref) => Stream.value(sampleLocations)),
      candidateLocationsProvider.overrideWith((ref) => Stream.value(const [])),
      pendingVerificationRequestsProvider.overrideWith((ref) => Stream.value(const [])),
      ...extraOverrides,
    ],
    child: const HearCastFinderApp(),
  );
}

Widget _signedOutApp() {
  return ProviderScope(
    overrides: [
      currentAppUserProvider.overrideWith((ref) => Stream.value(null)),
    ],
    child: const HearCastFinderApp(),
  );
}

void main() {
  group('AuthGate', () {
    testWidgets('shows the login screen when signed out', (tester) async {
      await tester.pumpWidget(_signedOutApp());
      await tester.pump();

      expect(find.text('Sign in to continue'), findsOneWidget);
      expect(find.widgetWithText(FilledButton, 'Login'), findsOneWidget);
      expect(find.text('Locations'), findsNothing);
    });

    testWidgets('shows the app shell when signed in', (tester) async {
      await tester.pumpWidget(_signedInApp());
      await tester.pump();

      expect(find.text('HearCast Finder'), findsOneWidget);
      expect(find.text('Find public audio locations'), findsOneWidget);
      expect(find.text('Sign in to continue'), findsNothing);
    });
  });

  testWidgets('shows the Day 1 home screen', (tester) async {
    await tester.pumpWidget(_signedInApp());
    await tester.pump();

    expect(find.text('HearCast Finder'), findsOneWidget);
    expect(find.text('Find public audio locations'), findsOneWidget);
    expect(find.text('Locations'), findsOneWidget);
  });

  testWidgets('can open the locations tab', (tester) async {
    await tester.pumpWidget(_signedInApp());
    await tester.pump();

    await tester.tap(find.text('Locations'));
    await tester.pumpAndSettle();

    expect(find.text('Verified locations'), findsOneWidget);
    expect(find.text('City Conference Hall'), findsOneWidget);
  });

  testWidgets('can search and open location details', (tester) async {
    await tester.pumpWidget(_signedInApp());
    await tester.pump();

    await tester.tap(find.text('Locations'));
    await tester.pumpAndSettle();
    await tester.enterText(
      find.widgetWithText(TextField, 'Search by name, city, category, or note'),
      'museum',
    );
    await tester.pumpAndSettle();

    expect(find.text('Museum Auditorium'), findsOneWidget);
    expect(find.text('City Conference Hall'), findsNothing);

    await tester.tap(find.text('Museum Auditorium'));
    await tester.pumpAndSettle();

    expect(find.text('Location details'), findsOneWidget);
    expect(find.text('Approximate coordinates'), findsOneWidget);
  });

  testWidgets('can favorite review and report a location', (tester) async {
    await tester.binding.setSurfaceSize(const Size(900, 1400));
    addTearDown(() => tester.binding.setSurfaceSize(null));
    await tester.pumpWidget(_signedInApp());
    await tester.pump();

    await tester.tap(find.text('Locations'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('City Conference Hall'));
    await tester.pumpAndSettle();

    await tester.tap(find.widgetWithText(FilledButton, 'Save favorite'));
    await tester.pumpAndSettle();
    expect(find.text('Saved favorite'), findsOneWidget);

    await tester.enterText(
      find.widgetWithText(TextField, 'Review note'),
      'Useful audio for the main room.',
    );
    final addReview = find.widgetWithText(FilledButton, 'Add review');
    await tester.ensureVisible(addReview);
    await tester.tap(addReview);
    await tester.pumpAndSettle();

    expect(find.text('Useful audio for the main room.'), findsOneWidget);

    final reportIssue = find.widgetWithText(OutlinedButton, 'Report issue');
    await tester.ensureVisible(reportIssue);
    await tester.tap(reportIssue);
    await tester.pumpAndSettle();

    expect(find.text('Report queued'), findsOneWidget);
  });

  testWidgets('Profile tab shows the signed-in user', (tester) async {
    await tester.pumpWidget(_signedInApp());
    await tester.pump();

    await tester.tap(find.text('Profile'));
    await tester.pumpAndSettle();

    expect(find.text('Andrei'), findsOneWidget);
    expect(find.textContaining('andrei@example.com'), findsOneWidget);
    expect(find.widgetWithText(OutlinedButton, 'Sign out'), findsOneWidget);
  });

  testWidgets('can open the map preview tab', (tester) async {
    await tester.pumpWidget(_signedInApp());
    await tester.pump();

    await tester.tap(find.text('Map'));
    await tester.pumpAndSettle();

    expect(find.byType(GoogleMap), findsOneWidget);
    expect(find.textContaining('verified location'), findsOneWidget);
  });

  testWidgets('can open the scan tab', (tester) async {
    await tester.pumpWidget(_signedInApp());
    await tester.pump();

    await tester.tap(find.text('Scan'));
    await tester.pump();

    expect(find.text('Bluetooth scan'), findsOneWidget);
    expect(find.text('Device capabilities'), findsOneWidget);
    expect(find.text('Start scan'), findsOneWidget);
  });

  testWidgets('can submit demo scan evidence locally', (tester) async {
    await tester.binding.setSurfaceSize(const Size(900, 1400));
    addTearDown(() => tester.binding.setSurfaceSize(null));

    final fakeFirestore = FakeFirebaseFirestore();
    await tester.pumpWidget(_signedInApp(
      extraOverrides: [firestoreProvider.overrideWithValue(fakeFirestore)],
    ));
    await tester.pump();

    await tester.tap(find.text('Scan'));
    await tester.pump();
    await tester.tap(find.text('Demo result'));
    await tester.pump();
    final submitEvidence = find.widgetWithText(
      OutlinedButton,
      'Submit evidence',
    );
    await tester.ensureVisible(submitEvidence);
    await tester.tap(submitEvidence);
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 300));
    final cityConferenceHall = find.text('City Conference Hall').last;
    await tester.ensureVisible(cityConferenceHall);
    await tester.tap(cityConferenceHall);
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 300));

    expect(find.textContaining('Submitted evidence'), findsOneWidget);

    final stored = await fakeFirestore.collection('verificationRequests').get();
    expect(stored.docs, hasLength(1));
    expect(stored.docs.first.data()['status'], VerificationStatus.pending.name);
    expect(stored.docs.first.data()['userId'], _testUser.id);
  });

  testWidgets('can create an owner location draft', (tester) async {
    await tester.binding.setSurfaceSize(const Size(900, 1000));
    addTearDown(() => tester.binding.setSurfaceSize(null));

    final fakeFirestore = FakeFirebaseFirestore();
    await tester.pumpWidget(_signedInApp(
      extraOverrides: [firestoreProvider.overrideWithValue(fakeFirestore)],
    ));
    await tester.pump();

    await tester.tap(find.text('Owner'));
    await tester.pumpAndSettle();
    await tester.enterText(
      find.widgetWithText(TextFormField, 'Location name'),
      'Library Hall',
    );
    await tester.enterText(
      find.widgetWithText(TextFormField, 'Address'),
      'Book Street 2',
    );
    await tester.enterText(
      find.widgetWithText(TextFormField, 'City'),
      'Odense',
    );
    final createDraft = find.widgetWithText(FilledButton, 'Create draft');
    await tester.ensureVisible(createDraft);
    await tester.tap(createDraft);
    await tester.pumpAndSettle();

    expect(find.text('Library Hall'), findsOneWidget);
    expect(find.text('No owner locations yet'), findsNothing);

    final stored = await fakeFirestore.collection('locations').get();
    expect(stored.docs, hasLength(1));
    expect(stored.docs.first.data()['ownerId'], _testUser.id);
    expect(stored.docs.first.data()['status'], LocationStatus.candidate.name);
  });

  testWidgets('admin dashboard shows pending locations and handles a failed action gracefully',
      (tester) async {
    await tester.binding.setSurfaceSize(const Size(900, 1000));
    addTearDown(() => tester.binding.setSurfaceSize(null));

    const pending = AuracastLocation(
      id: 'pending-1',
      name: 'Library Hall',
      address: 'Book Street 2',
      city: 'Odense',
      category: LocationCategory.other,
      status: LocationStatus.candidate,
      latitude: 0,
      longitude: 0,
    );

    await tester.pumpWidget(_signedInApp(
      extraOverrides: [
        candidateLocationsProvider.overrideWith((ref) => Stream.value(const [pending])),
      ],
    ));
    await tester.pump();

    await tester.tap(find.text('Admin'));
    await tester.pumpAndSettle();

    expect(find.text('Admin review'), findsOneWidget);
    expect(find.text('1 pending location'), findsOneWidget);
    expect(find.text('Library Hall'), findsOneWidget);
    expect(find.text('No verification requests pending'), findsOneWidget);

    // No Cloud Functions backend is reachable in a widget test — tapping
    // Approve must fail gracefully (a snackbar), never crash the app.
    await tester.tap(find.widgetWithText(FilledButton, 'Approve'));
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 300));

    expect(find.byType(SnackBar), findsOneWidget);
  });
}
