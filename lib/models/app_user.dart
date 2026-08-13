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
}
