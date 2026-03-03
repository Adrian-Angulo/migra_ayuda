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

    await repository.register(email, password, nombre, apellido, paisOrigen, paisDestino, edad, aceptaTerminos);

    isLoading = false;
    notifyListeners();
  }

  bool get isSelected => _isSeleted;

  set isSelected(bool value) {
    _isSeleted = value;
    notifyListeners();
  }
}
