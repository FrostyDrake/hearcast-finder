import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:hearcast_finder/app.dart';

void main() {
  testWidgets('shows the Day 1 home screen', (tester) async {
    await tester.pumpWidget(const HearCastFinderApp());

    expect(find.text('HearCast Finder'), findsOneWidget);
    expect(find.text('Find public audio locations'), findsOneWidget);
    expect(find.text('Locations'), findsOneWidget);
  });

  testWidgets('can open the locations tab', (tester) async {
    await tester.pumpWidget(const HearCastFinderApp());

    await tester.tap(find.text('Locations'));
    await tester.pumpAndSettle();

    expect(find.text('Candidate locations'), findsOneWidget);
    expect(find.text('City Conference Hall'), findsOneWidget);
  });

  testWidgets('can search and open location details', (tester) async {
    await tester.pumpWidget(const HearCastFinderApp());

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
    await tester.pumpWidget(const HearCastFinderApp());

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

  testWidgets('can register a local profile', (tester) async {
    await tester.pumpWidget(const HearCastFinderApp());

    await tester.tap(find.text('Profile'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Register'));
    await tester.pumpAndSettle();

    await tester.enterText(
      find.widgetWithText(TextFormField, 'Name'),
      'Andrei',
    );
    await tester.enterText(
      find.widgetWithText(TextFormField, 'Email'),
      'andrei@example.com',
    );
    await tester.enterText(
      find.widgetWithText(TextFormField, 'Password'),
      'password123',
    );
    await tester.tap(find.widgetWithText(FilledButton, 'Register'));
    await tester.pumpAndSettle();

    expect(find.text('Profile'), findsWidgets);
    expect(find.text('Andrei'), findsOneWidget);
    expect(find.textContaining('andrei@example.com'), findsOneWidget);
  });

  testWidgets('can open the map preview tab', (tester) async {
    await tester.pumpWidget(const HearCastFinderApp());

    await tester.tap(find.text('Map'));
    await tester.pumpAndSettle();

    expect(find.text('Map preview'), findsOneWidget);
    expect(find.text('3 map markers prepared'), findsOneWidget);
    expect(find.text('City Conference Hall'), findsOneWidget);
  });

  testWidgets('can open the scan tab', (tester) async {
    await tester.pumpWidget(const HearCastFinderApp());

    await tester.tap(find.text('Scan'));
    await tester.pump();

    expect(find.text('Bluetooth scan'), findsOneWidget);
    expect(find.text('Device capabilities'), findsOneWidget);
    expect(find.text('Start scan'), findsOneWidget);
  });

  testWidgets('can submit demo scan evidence locally', (tester) async {
    await tester.binding.setSurfaceSize(const Size(900, 1400));
    addTearDown(() => tester.binding.setSurfaceSize(null));
    await tester.pumpWidget(const HearCastFinderApp());

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

    expect(find.text('Submitted evidence'), findsOneWidget);
    expect(find.textContaining('pending'), findsOneWidget);
  });

  testWidgets('can create an owner location draft', (tester) async {
    await tester.binding.setSurfaceSize(const Size(900, 1000));
    addTearDown(() => tester.binding.setSurfaceSize(null));
    await tester.pumpWidget(const HearCastFinderApp());

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
  });

  testWidgets('can approve a local verification request as admin',
      (tester) async {
    await tester.binding.setSurfaceSize(const Size(900, 1000));
    addTearDown(() => tester.binding.setSurfaceSize(null));
    await tester.pumpWidget(const HearCastFinderApp());

    await tester.tap(find.text('Admin'));
    await tester.pumpAndSettle();

    expect(find.text('Admin review'), findsOneWidget);
    expect(find.text('1 pending verification'), findsOneWidget);

    await tester.tap(find.widgetWithText(FilledButton, 'Approve'));
    await tester.pumpAndSettle();

    expect(find.text('0 pending verification'), findsOneWidget);
    expect(find.textContaining('approved'), findsOneWidget);
  });
}
