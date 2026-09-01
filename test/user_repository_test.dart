import 'package:fake_cloud_firestore/fake_cloud_firestore.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:hearcast_finder/models/app_user.dart';
import 'package:hearcast_finder/repositories/user_repository.dart';

void main() {
  test('ensureUserProfile creates a new profile with the default user role', () async {
    final repository = UserRepository(FakeFirebaseFirestore());

    final user = await repository.ensureUserProfile(
      uid: 'uid-1',
      email: 'andrei@example.com',
      name: 'Andrei',
    );

    expect(user.id, 'uid-1');
    expect(user.name, 'Andrei');
    expect(user.role, AppUserRole.user);
  });

  test('ensureUserProfile falls back to the email when no name is given', () async {
    final repository = UserRepository(FakeFirebaseFirestore());

    final user = await repository.ensureUserProfile(
      uid: 'uid-1',
      email: 'andrei@example.com',
    );

    expect(user.name, 'andrei@example.com');
  });

  test('ensureUserProfile never overwrites an existing role, e.g. an admin promotion', () async {
    final firestore = FakeFirebaseFirestore();
    final repository = UserRepository(firestore);

    await repository.saveUser(
      const AppUser(
        id: 'uid-1',
        name: 'Andrei',
        email: 'andrei@example.com',
        role: AppUserRole.admin,
      ),
    );

    final user = await repository.ensureUserProfile(
      uid: 'uid-1',
      email: 'andrei@example.com',
      name: 'Andrei',
    );

    expect(user.role, AppUserRole.admin);
  });

  test('watchUser streams the saved profile', () async {
    final firestore = FakeFirebaseFirestore();
    final repository = UserRepository(firestore);

    await repository.saveUser(
      const AppUser(id: 'uid-1', name: 'Andrei', email: 'andrei@example.com'),
    );

    final user = await repository.watchUser('uid-1').first;

    expect(user?.name, 'Andrei');
  });

  test('watchUser emits null for a profile that does not exist', () async {
    final repository = UserRepository(FakeFirebaseFirestore());

    final user = await repository.watchUser('missing-uid').first;

    expect(user, isNull);
  });
}
