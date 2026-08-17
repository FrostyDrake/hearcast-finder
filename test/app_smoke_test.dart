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
}
