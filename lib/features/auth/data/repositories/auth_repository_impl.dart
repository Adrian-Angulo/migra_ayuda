import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:migra_ayuda/core/models/user_model.dart';
import '../../domain/repositories/auth_repository.dart';

class AuthRepositoryImpl implements AuthRepository {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final GoogleSignIn googleSignIn = GoogleSignIn();

  // ─────────────────────────────────────────────────────────────
  // GOOGLE SIGN IN
  // Inicia sesión con Google y detecta si es usuario nuevo
  // ────────────────────────────────────────────────────────────---
  @override
  Future<UserCredential?> signInWithGoogle() async {
    final GoogleSignInAccount? googleUser = await googleSignIn.signIn();

    if (googleUser == null) return null;

    final GoogleSignInAuthentication googleAuth =
        await googleUser.authentication;

    final OAuthCredential credential = GoogleAuthProvider.credential(
      idToken: googleAuth.idToken,
      accessToken: googleAuth.accessToken,
    );

    final UserCredential userCredential =
        await FirebaseAuth.instance.signInWithCredential(credential);

    final bool isNewUser =
        userCredential.additionalUserInfo?.isNewUser ?? false;

    if (isNewUser) {
      await _createGoogleUserInFirestore(userCredential.user!);
    }

    return userCredential;
  }

  // ─────────────────────────────────────────────────────────────
  // Crea el documento base en Firestore para usuarios de Google
  // Los campos que faltan quedan null hasta que los complete
  // ─────────────────────────────────────────────────────────────
  Future<void> _createGoogleUserInFirestore(User user) async {
    await _firestore.collection('users').doc(user.uid).set({
      // ✅ Datos que Google nos da automáticamente
      'name': user.displayName?.split(' ').first ?? '',
      'lasname': user.displayName?.split(' ').skip(1).join(' ') ?? '',
      'email': user.email,
      'rol': "Migrante",
      // ⏳ Datos que el usuario debe completar después
      'originCountry': null,
      'destinationCountry': null,
      'age': null,
      'profileComplete': false,
      'createdAt': FieldValue.serverTimestamp(),
    });
  }

  // ─────────────────────────────────────────────────────────────
  // Verifica si el usuario ya completó su perfil
  // Lo usamos después del login para saber a dónde navegar
  // ─────────────────────────────────────────────────────────────
  @override
  Future<bool> isProfileComplete() async {
    final user = _auth.currentUser;
    if (user == null) return false;

    final doc = await _firestore.collection('users').doc(user.uid).get();

    if (!doc.exists) return false;

    return doc.data()?['profileComplete'] ?? false;
  }

  // ─────────────────────────────────────────────────────────────
  // Completa el perfil del usuario de Google
  // Se llama desde la pantalla CompleteProfileScreen
  // ─────────────────────────────────────────────────────────────
  @override
  Future<void> completeGoogleProfile({
    required String originCountry,
    required String destinationCountry,
    required int age,
    required bool aceptaTerminos,
  }) async {
    final user = _auth.currentUser;
    if (user == null) throw Exception('Usuario no autenticado');

    await _firestore.collection('users').doc(user.uid).update({
      'originCountry': originCountry,
      'destinationCountry': destinationCountry,
      'age': age,
      'profileComplete': true,
      'updatedAt': FieldValue.serverTimestamp(),
    });
  }

  // ─────────────────────────────────────────────────────────────
  // REGISTRO NORMAL (email/password)
  // Este ya guarda todo completo desde el inicio
  // ─────────────────────────────────────────────────────────────
  @override
  Future<void> register(
    String name,
    String lasname,
    String email,
    String password,
    String originCountry,
    String destinationCountry,
    int age,
  ) async {
    final UserCredential userCredential =
        await _auth.createUserWithEmailAndPassword(
      email: email,
      password: password,
    );

    // Registro normal siempre tiene todos los datos
    // por eso profileComplete va true desde el inicio
    await _firestore.collection('users').doc(userCredential.user?.uid).set({
      'name': name,
      'lastname': lasname,
      'originCountry': originCountry,
      'destinationCountry': destinationCountry,
      'email': email,
      'age': age,
      'profileComplete': true,
      'role': "Migrante",
      'createdAt': FieldValue.serverTimestamp(),
    });
    await userCredential.user!.sendEmailVerification();
    await userCredential.user?.updateDisplayName('$name $lasname');
  }

  // ─────────────────────────────────────────────────────────────
  // LOGIN NORMAL
  // ─────────────────────────────────────────────────────────────
  @override
  Future<UserCredential> login(String email, String password) async {
    return await _auth.signInWithEmailAndPassword(
      email: email,
      password: password,
    );
  }

  // ─────────────────────────────────────────────────────────────
  // CAMBIAR CONTRASEÑA
  // ─────────────────────────────────────────────────────────────
  @override
  Future<void> changePassword(
    String currentPassword,
    String newPassword,
  ) async {
    final user = _auth.currentUser;
    if (user == null) throw Exception('Usuario no autenticado');

    final credential = EmailAuthProvider.credential(
      email: user.email!,
      password: currentPassword,
    );

    await user.reauthenticateWithCredential(credential);
    await user.updatePassword(newPassword);
  }

  // ─────────────────────────────────────────────────────────────
  // ELIMINAR CUENTA
  // ─────────────────────────────────────────────────────────────
  @override
  Future<void> deleteAccount() async {
    final user = _auth.currentUser;
    if (user == null) throw Exception('Usuario no autenticado');

    await _firestore.collection('users').doc(user.uid).delete();
    await user.delete();
  }

  // Limpia sesión cuando el perfil quedó incompleto
  Future<void> clearIncompleteSession() async {
    try {
      final user = _auth.currentUser;

      // Opcional: eliminar el documento incompleto de Firestore
      if (user != null) {
        await _firestore.collection('users').doc(user.uid).delete();
      }

      await _auth.signOut();
      await googleSignIn.signOut();
    } catch (e) {
      // Aunque falle, lo importante es cerrar la sesión
      await _auth.signOut();
    }
  }

  // ─────────────────────────────────────────────────────────────
  // UTILIDADES
  // ─────────────────────────────────────────────────────────────
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
    try {
      await _auth.signOut();
      try {
        await googleSignIn.signOut();
      } catch (e) {
        print('Google signOut falló: $e');
      }
    } catch (e) {
      rethrow;
    }
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

  @override
  Future<UserModel?> getUsuarioActual() async {
    final uid = FirebaseAuth.instance.currentUser?.uid;
    if (uid == null) return null;

    final doc =
        await FirebaseFirestore.instance.collection('users').doc(uid).get();

    if (!doc.exists) return null;

    return UserModel.fromFirestore(doc);
  }
}
