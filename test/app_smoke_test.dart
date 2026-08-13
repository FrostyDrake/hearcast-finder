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
}
