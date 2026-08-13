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
}
