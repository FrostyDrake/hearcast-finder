import 'package:flutter_test/flutter_test.dart';
import 'package:hearcast_finder/services/firebase_setup_status.dart';

void main() {
  test('Day 4 Firebase setup is not ready for app connection yet', () {
    expect(day4FirebaseSetupStatus.completedStepCount, 3);
    expect(day4FirebaseSetupStatus.canConnectFromApp, isFalse);
  });
}
