import 'package:flutter/material.dart';
import 'package:migra_ayuda/features/domain/auth_repository.dart';

class AuthProvider extends ChangeNotifier {
  final AuthRepository repository;
  bool _isSeleted = false;

  AuthProvider(this.repository);

  bool isLoading = false;

  Future<void> register(
    String email,
    String password,
    String nombre,
    String apellido,
    String paisOrigen,
    String paisDestino,
    int edad,
    bool aceptaTerminos,
  ) async {
    isLoading = true;
    notifyListeners();

    await repository.register(
      email,
      password,
      nombre,
      apellido,
      paisOrigen,
      paisDestino,
      edad,
      aceptaTerminos,
    );

    isLoading = false;
    notifyListeners();
  }

  bool get isSelected => _isSeleted;

  set isSelected(bool value) {
    _isSeleted = value;
    notifyListeners();
  }

  Future<void> login(String email, String password) async {
    isLoading = true;
    notifyListeners();

    await repository.login(email, password);

    isLoading = false;
    notifyListeners();
  }

  Future<void> logout() async {
    isLoading = true;
    notifyListeners();

    await repository.logout();

    isLoading = false;
    notifyListeners();
  }

  Future<bool> isLoggedIn() async {
    return await repository.isLoggedIn();
  }

  Future<void> resetPassword(String email) async {
    isLoading = true;
    notifyListeners();

    await repository.resetPassword(email);

    isLoading = false;
    notifyListeners();
  }

  /* Future<void> updateProfile(
    String nombre,
    String apellido,
    String paisOrigen,
    String paisDestino,
    int edad,
  ) async {
    isLoading = true;
    notifyListeners();

    await repository.updateProfile(
      nombre,
      apellido,
      paisOrigen,
      paisDestino,
      edad,
    );

    isLoading = false;
    notifyListeners();
  } */

  Future<void> deleteAccount() async {
    isLoading = true;
    notifyListeners();

    await repository.deleteAccount();

    isLoading = false;
    notifyListeners();
  }
}
