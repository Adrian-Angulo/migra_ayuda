import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:migra_ayuda/data/repositories/auth_repository.dart';

class AuthProvider extends ChangeNotifier {
  final AuthRepository repository;
  bool _isSeleted = true;
  String? error;
  bool isLoading = false;
  UserCredential? userCredential;
  User? _currentUser;

  AuthProvider(this.repository) {
    _initializeAuthState();
  }

  User? get currentUser => _currentUser;

  // Inicializar el estado de autenticación
  void _initializeAuthState() {
    _currentUser = FirebaseAuth.instance.currentUser;

    // Escuchar cambios en el estado de autenticación
    FirebaseAuth.instance.authStateChanges().listen((User? user) {
      _currentUser = user;
      notifyListeners();
    });
  }

  void _clearError() {
    error = null;
  }

  // Verificar si hay una sesión activa
  Future<bool> checkActiveSession() async {
    try {
      final user = FirebaseAuth.instance.currentUser;
      if (user != null) {
        // Recargar el usuario para obtener información actualizada
        await user.reload();
        _currentUser = FirebaseAuth.instance.currentUser;
        return _currentUser != null;
      }
      return false;
    } catch (e) {
      error = e.toString();
      return false;
    }
  }

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
    _clearError();
    notifyListeners();

    try {
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
    } catch (e) {
      if (e.toString().contains('email-already-in-use')) {
        error = 'Este correo electrónico ya está registrado';
      } else if (e.toString().contains('network-request-failed')) {
        error = 'Sin conexión a internet. Verifica tu conexión';
      } else {
        error = e.toString();
      }
    }

    isLoading = false;
    notifyListeners();
  }

  bool get isSelected => _isSeleted;

  set isSelected(bool value) {
    _isSeleted = value;
    notifyListeners();
  }

  Future<bool?> handleGoogleLogin() async {
    _clearError();
    isLoading = true;
    notifyListeners();

    try {
      final result = await repository.signInWithGoogle();
      if (result == null) {
        error = 'Error al iniciar sesión con Google';
        return null;
      }

      final bool profileComplete = await repository.isProfileComplete();
      return profileComplete;
    } catch (e) {
      if (e.toString().contains('network-request-failed')) {
        error = 'Sin conexión a internet. Verifica tu conexión';
      } else {
        error = e.toString();
        return null;
      }
    } finally {
      isLoading = false;
      notifyListeners();
    }
    return null;
  }

  Future<void> completedPerfil({
    required String paisOrigen,
    required String paisDestino,
    required int edad,
    required bool aceptaTerminos,
  }) async {
    isLoading = true;
    _clearError();
    notifyListeners();

    try {
      await repository.completeGoogleProfile(
          paisOrigen: paisOrigen,
          paisDestino: paisDestino,
          edad: edad,
          aceptaTerminos: aceptaTerminos);
    } catch (e) {
      error = e.toString();
    } finally {
      isLoading = false;
      notifyListeners();
    }
  }

  Future<void> login(String email, String password) async {
    isLoading = true;
    _clearError();
    notifyListeners();

    try {
      final userCredential = await repository.login(email, password);
      final user = userCredential.user;

      // ✅ Verifica si el correo está confirmado
      if (user != null && !user.emailVerified) {
        error =
            'Debes verificar tu correo antes de ingresar. Revisa tu bandeja spam.';
        isLoading = false;
        notifyListeners();
        return;
      }
    } on FirebaseAuthException catch (e) {
      // ✅ Mensajes amigables según el error
      if (e.code == 'user-not-found') {
        error = 'No existe una cuenta con este correo';
      } else if (e.toString().contains('wrong-password')) {
        error = 'Contraseña incorrecta';
      } else if (e.toString().contains('invalid-email')) {
        error = 'El correo no es válido';
      } else if (e.toString().contains('user-disabled')) {
        error = 'Esta cuenta fue deshabilitada';
      } else if (e.toString().contains('too-many-requests')) {
        error = 'Demasiados intentos, espera un momento';
      } else if (e.toString().contains('invalid-credential')) {
        error = 'Correo y/o contraseña invalidas';
      } else if (e.toString().contains('invalid-credential')) {
        error = 'Correo y/o contraseña invalidas';
      } else if (e.toString().contains('network-request-failed')) {
        error = 'Sin conexión a internet. Verifica tu conexión';
      } else {
        error = e.toString();
      }
    } finally {
      // ✅ Siempre se ejecuta, haya error o no
      isLoading = false;
      notifyListeners();
    }
  }

  Future<void> logout() async {
    isLoading = true;
    _clearError();
    notifyListeners();

    try {
      await repository.logout();
      _currentUser = null;
    } catch (e) {
      error = e.toString();
    }
    isLoading = false;
    notifyListeners();
  }

  Future<void> isLoggedIn() async {
    try {
      await repository.isLoggedIn();
    } catch (e) {
      error = e.toString();
    }
  }

  Future<void> resetPassword(String email) async {
    isLoading = true;
    _clearError();
    notifyListeners();

    try {
      await repository.resetPassword(email);
    } catch (e) {
      error = e.toString();
    }

    isLoading = false;
    notifyListeners();
  }

  Future<void> deleteAccount() async {
    isLoading = true;
    _clearError();
    notifyListeners();

    try {
      await repository.deleteAccount();
      _currentUser = null;
    } catch (e) {
      error = e.toString();
    }

    isLoading = false;
    notifyListeners();
  }
}
