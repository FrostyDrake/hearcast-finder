enum AppUserRole {
  user,
  owner,
  admin,
}

class AppUser {
  const AppUser({
    required this.id,
    required this.name,
    required this.email,
    this.role = AppUserRole.user,
  });

  final String id;
  final String name;
  final String email;
  final AppUserRole role;

  factory AppUser.fromMap(Map<String, dynamic> map) {
    return AppUser(
      id: map['id'] as String? ?? '',
      name: map['name'] as String? ?? '',
      email: map['email'] as String? ?? '',
      role: AppUserRole.values.byName(map['role'] as String? ?? 'user'),
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'name': name,
      'email': email,
      'role': role.name,
    };
  }
}
