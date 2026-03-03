abstract class AuthRepository {
  Future<void> register(
    String email,
    String password,
    String nombre,
    String apellido,
    String paisOrigen,
    String paisDestino,
    int edad,
    bool aceptaTerminos,
  );
  Future<void> login(String email, String password);
  Future<void> logout();
  Future<bool> isLoggedIn();
  Future<String?> getCurrentUserId();
  Future<void> resetPassword(String email);
  Future<void> changePassword(String currentPassword, String newPassword);
  Future<void> deleteAccount();
  Future<void> refreshToken();
}
