import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:migra_ayuda/data/models/user_model.dart';
import 'package:migra_ayuda/data/repositories/auth_repository.dart';

class AuthProvider extends ChangeNotifier {
  final AuthRepository repository;
  bool _isSeleted = true;
  String? error;
  bool isLoading = false;
  UserCredential? userCredential;
  User? _currentUser;
  bool _isRegistering = false;
  UserModel? _userModel;

  AuthProvider(this.repository) {
    _initializeAuthState();
  }

  User? get currentUser => _currentUser;
  UserModel? get user => _userModel;
  String? get rol => _userModel?.role;
  // Inicializar el estado de autenticación
  void _initializeAuthState() {
    _currentUser = FirebaseAuth.instance.currentUser;

    // Escuchar cambios en el estado de autenticación
    FirebaseAuth.instance.authStateChanges().listen((User? user) {
      if (_isRegistering) return;

      _currentUser = user;
      notifyListeners();
    });
  }

  void _clearError() {
    error = null;
  }

  Future<bool> checkActiveSession() async {
    try {
      final user = FirebaseAuth.instance.currentUser;
      if (user != null) {
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

  Future<void> resetPassword(String email) async {
    isLoading = true;
    _clearError();
    notifyListeners();

    try {
      await repository.resetPassword(email);
    } catch (e) {
      if (e.toString().contains('user-not-found')) {
        error = 'No existe una cuenta con este correo';
      } else if (e.toString().contains('invalid-email')) {
        error = 'El correo no es válido';
      } else if (e.toString().contains('network-request-failed')) {
        error = 'Sin conexión a internet. Verifica tu conexión';
      } else {
        error = e.toString();
      }
    }

    isLoading = false;
    notifyListeners();
  }

  Future<void> register(
    String name,
    String lastname,
    String email,
    String password,
    String originCountry,
    String destinationCountry,
    int age,
  ) async {
    isLoading = true;
    _isRegistering = true;
    _clearError();
    notifyListeners();

    try {
      await repository.register(name, lastname, email, password, originCountry,
          destinationCountry, age);
      await FirebaseAuth.instance.signOut();
    } catch (e) {
      if (e.toString().contains('email-already-in-use')) {
        error = 'Este correo electrónico ya está registrado';
      } else if (e.toString().contains('network-request-failed')) {
        error = 'Sin conexión a internet. Verifica tu conexión';
      } else {
        error = e.toString();
      }
    }
    _isRegistering = false;
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
      _userModel = await repository.getUsuarioActual();

      if (_userModel?.role == "Admin") {
        return true;
      }

      return await repository.isProfileComplete();
    } catch (e) {
      _handleGoogleLoginError(e);
      return null;
    } finally {
      isLoading = false;
      notifyListeners();
    }
  }

  void _handleGoogleLoginError(dynamic e) {
    if (e.toString().contains('network-request-failed')) {
      error = 'Sin conexión a internet. Verifica tu conexión';
    } else {
      error = e.toString();
    }
  }

  Future<void> completedPerfil({
    required String originCountry,
    required String destinationCountry,
    required int age,
    required bool aceptaTerminos,
  }) async {
    isLoading = true;
    _clearError();
    notifyListeners();

    try {
      await repository.completeGoogleProfile(
          originCountry: originCountry,
          destinationCountry: destinationCountry,
          age: age,
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

      if (user != null) {
        _userModel = await repository.getUsuarioActual();
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
    _userModel = null;
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
