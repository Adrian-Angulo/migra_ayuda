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

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is AuthUser &&
          runtimeType == other.runtimeType &&
          id == other.id &&
          email == other.email;

  @override
  int get hashCode => id.hashCode ^ email.hashCode;
}
