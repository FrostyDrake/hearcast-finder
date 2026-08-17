import 'package:flutter_test/flutter_test.dart';
import 'package:hearcast_finder/core/utils/validators.dart';

void main() {
  test('validates email and password input', () {
    expect(Validators.email('person@example.com'), isNull);
    expect(Validators.email('bad-email'), isNotNull);
    expect(Validators.password('password123'), isNull);
    expect(Validators.password('short'), isNotNull);
  });
}
