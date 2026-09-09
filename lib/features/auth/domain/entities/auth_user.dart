class AuthUser {
  final String id;
  final String email;
  final String? displayName;
  final bool isEmailVerified;

  const AuthUser({
    required this.id,
    required this.email,
    this.displayName,
    this.isEmailVerified = false,
  });
}
