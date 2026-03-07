import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import './auth_repository.dart';

class AuthRepositoryImpl implements AuthRepository {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  @override
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
    
    UserCredential userCredential = await _auth.createUserWithEmailAndPassword(
      email: email,
      password: password,
    );
    // ✅ Envía el email de verificación automáticamente
    await userCredential.user!.sendEmailVerification();
    
    // Actualizar el perfil del usuario con información adicional
    await userCredential.user?.updateDisplayName('$nombre $apellido');

    // Aquí podrías guardar información adicional en Firestore
    await _firestore.collection('users').doc(userCredential.user?.uid).set({
      'nombre': nombre,
      'apellido': apellido,
      'paisOrigen': paisOrigen,
      'paisDestino': paisDestino,
      'edad': edad,
      'email': email,
    });
  }

  @override
  Future<UserCredential> login(String email, String password) async {
    return await _auth.signInWithEmailAndPassword(email: email, password: password);
  }

  @override
  Future<void> changePassword(
    String currentPassword,
    String newPassword,
  ) async {
    final user = _auth.currentUser;
    if (user == null) {
      throw Exception('Usuario no autenticado');
    }

    // Re-autenticar al usuario con la contraseña actual
    final credential = EmailAuthProvider.credential(
      email: user.email!,
      password: currentPassword,
    );

    await user.reauthenticateWithCredential(credential);

    // Cambiar la contraseña
    await user.updatePassword(newPassword);
  }

  @override
  Future<void> deleteAccount() async {
    final user = _auth.currentUser;
    if (user == null) {
      throw Exception('Usuario no autenticado');
    }

    // Eliminar datos del usuario de Firestore
    await _firestore.collection('users').doc(user.uid).delete();

    // Eliminar la cuenta de Firebase Auth
    await user.delete();
  }

  @override
  Future<String?> getCurrentUserId() async {
    return _auth.currentUser?.uid;
  }

  @override
  Future<bool> isLoggedIn() async {
    return _auth.currentUser != null;
  }

  @override
  Future<void> logout() async {
    await _auth.signOut();
  }

  @override
  Future<void> refreshToken() async {
    final user = _auth.currentUser;
    if (user != null) {
      await user.reload();
    }
  }

  @override
  Future<void> resetPassword(String email) async {
    await _auth.sendPasswordResetEmail(email: email);
  }

  
}
