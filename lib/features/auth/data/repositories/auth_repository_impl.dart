import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:migra_ayuda/core/errors/failures.dart';

import 'package:migra_ayuda/features/auth/data/models/user_model.dart';
import 'package:migra_ayuda/features/auth/domain/repositories/auth_repository.dart';

class AuthRepositoryImpl implements AuthRepository {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final GoogleSignIn googleSignIn = GoogleSignIn();

  AuthRepositoryImpl();

  @override
  Future<UserCredential> authWithGoogle() async {
    try {
      final googleUser = await googleSignIn.signIn();

      if (googleUser == null) {
        throw const OperationCancelledFailure();
      }
      final googleAuth = await googleUser.authentication;
      final idToken = googleAuth.idToken;
      final accessToken = googleAuth.accessToken;
      if (idToken == null) {
        throw const UnexpectedFailure();
      }
      final oauthCredential = GoogleAuthProvider.credential(
        idToken: idToken,
        accessToken: accessToken,
      );
      final userCredential = await _auth.signInWithCredential(oauthCredential);
      final user = userCredential.user;
      if (user == null) {
        throw const UserNotFoundFailure();
      }

      final providers =
          user.providerData.map((info) => info.providerId).toList();

      if (providers.contains('password')) {
        await user.unlink('password');
      }

      return userCredential;
    } on OperationCancelledFailure {
      rethrow;
    } on UnexpectedFailure {
      rethrow;
    } on UserNotFoundFailure {
      rethrow;
    } on FirebaseAuthException catch (e) {
      throw AuthFailure(e.message ?? 'Error de autenticación con Google');
    } catch (e) {
      throw const UnexpectedFailure();
    }
  }

  @override
  Future<void> logout() async {
    try {
      await _auth.signOut();
      await googleSignIn.signOut();
    } on FirebaseAuthException catch (e) {
      throw AuthFailure(e.message ?? 'Error al cerrar sesión');
    } catch (e) {
      throw const UnexpectedFailure();
    }
  }

  @override
  Future<void> completeProfile({
    required String originCountry,
    required String destinationCountry,
    required int age,
  }) async {
    try {
      final uid = _auth.currentUser?.uid;

      if (uid == null) {
        throw const UserNotFoundFailure();
      }

      await _firestore.collection('users').doc(uid).update({
        'originCountry': originCountry,
        'destinationCountry': destinationCountry,
        'age': age.toString(),
        'profileComplete': true,
      });
    } on UserNotFoundFailure {
      rethrow;
    } on FirebaseException catch (e) {
      throw AuthFailure(e.message ?? 'Error al completar el perfil');
    } catch (e) {
      throw const UnexpectedFailure();
    }
  }

  @override
  Future<UserModel> verifyOrCreateGoogleUser(UserCredential credential) async {
    try {
      final uid = credential.user?.uid;

      if (uid == null) {
        throw const UserNotFoundFailure();
      }

      final docRef = _firestore.collection('users').doc(uid);
      final doc = await docRef.get();

      if (doc.exists) {
        return UserModel.fromMap(doc);
      } else {
        final newUser = UserModel(
          id: uid,
          name: credential.user!.displayName ?? 'Usuario',
          email: credential.user!.email ?? '',
          password: '',
          role: 'Migrante', // Asignar rol por defecto
          profileComplete: false,
        );

        await docRef.set(newUser.toMap());

        return newUser;
      }
    } on UserNotFoundFailure {
      rethrow;
    } on FirebaseException catch (e) {
      throw AuthFailure(e.message ?? 'Error al verificar o crear usuario');
    } catch (e) {
      throw const UnexpectedFailure();
    }
  }

  @override
  Future<UserModel> getUserData(String uid) async {
    try {
      final doc = await _firestore.collection('users').doc(uid).get();
      if (!doc.exists) {
        throw const UserDataNotFoundFailure();
      }
      final userData = UserModel.fromMap(doc);
      return userData;
    } on UserDataNotFoundFailure {
      rethrow;
    } on FirebaseException catch (e) {
      throw AuthFailure(e.message ?? 'Error al obtener datos del usuario');
    } catch (e) {
      throw const UnexpectedFailure();
    }
  }

  Future<bool> emailExists(String email) async {
    try {
      final snapshot = await _firestore
          .collection('users')
          .where('email', isEqualTo: email)
          .limit(1)
          .get();
      return snapshot.docs.isNotEmpty;
    } on FirebaseException catch (e) {
      throw AuthFailure(e.message ?? 'Error al verificar el correo');
    } catch (e) {
      throw const UnexpectedFailure();
    }
  }

  @override
  Future<User> login(String email, String password) async {
    try {
      final credential = await _auth.signInWithEmailAndPassword(
        email: email,
        password: password,
      );

      if (credential.user == null) {
        throw const UserNotFoundFailure();
      }

      if (!credential.user!.emailVerified) {
        throw const EmailNotVerifiedFailure();
      }

      return credential.user!;
    } on UserNotFoundFailure {
      rethrow;
    } on EmailNotVerifiedFailure {
      rethrow;
    } on FirebaseAuthException catch (e) {
      throw AuthFailure(e.message ?? 'Error al iniciar sesión');
    } catch (e) {
      throw const UnexpectedFailure();
    }
  }

  @override
  Future<void> registerUser(UserModel user) async {
    try {
      final existingMethods = await emailExists(user.email);

      if (existingMethods == true) {
        throw const EmailAlreadyInUseFailure();
      }
      final credential = await _auth.createUserWithEmailAndPassword(
        email: user.email,
        password: user.password,
      );

      await credential.user?.sendEmailVerification();

      await _firestore
          .collection('users')
          .doc(credential.user!.uid)
          .set(user.toMap());

      if (user.role == 'Migrante') {
        await _auth.signOut();
      }
    } on EmailAlreadyInUseFailure {
      rethrow;
    } on FirebaseAuthException catch (e) {
      throw AuthFailure(e.message ?? 'Error al registrar usuario');
    } on FirebaseException catch (e) {
      throw AuthFailure(e.message ?? 'Error al guardar datos del usuario');
    } catch (e) {
      throw const UnexpectedFailure();
    }
  }

  @override
  Future<void> resetPassword(String email) async {
    try {
      await _auth.sendPasswordResetEmail(email: email);
    } on FirebaseAuthException catch (e) {
      throw AuthFailure(
          e.message ?? 'Error al enviar correo de restablecimiento');
    } catch (e) {
      throw const UnexpectedFailure();
    }
  }

  @override
  Stream<UserModel?> authStateChanges() {
    return _auth.authStateChanges().asyncMap((usu) async {
      if (usu == null) return null;
      try {
        final doc = await _firestore.collection('users').doc(usu.uid).get();
        if (!doc.exists || doc.data() == null) return null;
        return UserModel.fromMap(doc);
      } on FirebaseException catch (_) {
        return null;
      } catch (_) {
        return null;
      }
    });
  }

  @override
  Future<List<UserModel>> getAllUsers() async {
    try {
      final snapshot = await _firestore.collection('users').get();
      final users = snapshot.docs.map((doc) => UserModel.fromMap(doc)).toList();
      return users;
    } on FirebaseException catch (e) {
      throw AuthFailure(e.message ?? 'Error al obtener usuarios');
    } catch (e) {
      throw const UnexpectedFailure();
    }
  }

  @override
  Future<User?> getAuthenticatedUser() async {
    try {
      return _auth.currentUser;
    } catch (e) {
      throw const UnexpectedFailure();
    }
  }
}
