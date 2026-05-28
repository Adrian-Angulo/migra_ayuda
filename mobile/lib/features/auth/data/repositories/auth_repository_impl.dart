import 'dart:io';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:dartz/dartz.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/services.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:migra_ayuda/core/errors/auth_failures.dart';
import 'package:migra_ayuda/core/errors/failures.dart';
import 'package:migra_ayuda/features/auth/data/models/user_model.dart';
import 'package:migra_ayuda/features/auth/domain/repositories/auth_repository.dart';

class AuthRepositoryImpl implements AuthRepository {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final GoogleSignIn googleSignIn = GoogleSignIn();

  AuthRepositoryImpl();

  @override
  Future<Either<Failure, UserCredential>> authWithGoogle() async {
    try {
      final googleUser = await googleSignIn.signIn();

      if (googleUser == null) {
        return const Left(OperationCancelledFailure());
      }

      final googleAuth = await googleUser.authentication;

      final idToken = googleAuth.idToken;
      final accessToken = googleAuth.accessToken;

      if (idToken == null) {
        return const Left(UnexpectedFailure());
      }

      final oauthCredential = GoogleAuthProvider.credential(
        idToken: idToken,
        accessToken: accessToken,
      );

      final userCredential = await _auth.signInWithCredential(oauthCredential);

      final user = userCredential.user;
      if (user == null) {
        return const Left(UserNotFoundFailure());
      }

      final providers =
          user.providerData.map((info) => info.providerId).toList();

      if (providers.contains('password')) {
        await user.unlink('password');
      }

      return Right(userCredential);
    } on FirebaseAuthException catch (e) {
      print("Error: $e");
      return Left(_mapFirebaseAuthError(e.code));
    } on FirebaseException catch (e) {
      return Left(ServerFailure(e.message ?? 'Error del servidor'));
    } on PlatformException catch (e) {
      return const Left(NetworkFailureAuth());
    } catch (e) {
      return const Left(UnexpectedFailure());
    }
  }

  @override
  Future<Either<Failure, Unit>> logout() async {
    try {
      await _auth.signOut();
      await googleSignIn.signOut();
      return const Right(unit);
    } catch (e) {
      return const Left(UnexpectedFailure());
    }
  }

  @override
  Future<Either<Failure, Unit>> completeProfile({
    required String originCountry,
    required String destinationCountry,
    required int age,
  }) async {
    try {
      final uid = _auth.currentUser?.uid;

      if (uid == null) {
        return const Left(UserNotFoundFailure());
      }

      await _firestore.collection('users').doc(uid).update({
        'originCountry': originCountry,
        'destinationCountry': destinationCountry,
        'age': age.toString(),
        'profileComplete': true,
      });

      return const Right(unit);
    } on FirebaseException catch (e) {
      return Left(ServerFailure(e.message ?? 'Error al actualizar perfil'));
    } catch (e) {
      return const Left(UnexpectedFailure());
    }
  }

  @override
  Future<Either<Failure, UserModel>> verifyOrCreateGoogleUser(
      UserCredential credential) async {
    try {
      final uid = credential.user?.uid;

      if (uid == null) {
        return const Left(UserNotFoundFailure());
      }

      final docRef = _firestore.collection('users').doc(uid);
      final doc = await docRef.get();

      if (doc.exists) {
        print('✅ Usuario existente encontrado');
        return Right(UserModel.fromMap(doc));
      } else {
        print('🆕 Creando nuevo usuario con Google');
        final newUser = UserModel(
          id: uid,
          name: credential.user!.displayName ?? 'Usuario',
          lastname: '',
          email: credential.user!.email ?? '',
          password: '',
          role: 'Migrante', // Asignar rol por defecto
          profileComplete: false,
        );

        await docRef.set(newUser.toMap());
        print('✅ Usuario creado: ${newUser.toMap()}');
        return Right(newUser);
      }
    } on FirebaseException catch (e) {
      print('❌ Error de Firebase: ${e.message}');
      return Left(ServerFailure(e.message ?? 'Error al crear usuario'));
    } catch (e) {
      print('❌ Error inesperado: $e');
      return const Left(UnexpectedFailure());
    }
  }

  @override
  Future<Either<Failure, UserModel>> getUserData(String uid) async {
    try {
      final doc = await _firestore.collection('users').doc(uid).get();

      if (!doc.exists) {
        return const Left(UserDataNotFoundFailure());
      }

      final userData = UserModel.fromMap(doc);
      print('📊 Datos del usuario obtenidos: ${userData.toMap()}');

      return Right(userData);
    } on FirebaseException catch (e) {
      return Left(ServerFailure(e.message ?? 'Error al obtener datos'));
    } catch (e) {
      print('❌ Error inesperado en getUserData: $e');
      return const Left(UnexpectedFailure());
    }
  }

  @override
  Future<Either<Failure, User>> login(String email, String password) async {
    try {
      final credential = await _auth.signInWithEmailAndPassword(
        email: email,
        password: password,
      );

      if (credential.user == null) {
        return const Left(UserNotFoundFailure());
      }

      if (!credential.user!.emailVerified) {
        return const Left(EmailNotVerifiedFailure());
      }

      return Right(credential.user!);
    } on FirebaseAuthException catch (e) {
      return Left(_mapFirebaseAuthError(e.code));
    } catch (e) {
      return const Left(UnexpectedFailure());
    }
  }

  @override
  Future<Either<Failure, Unit>> registerUser(UserModel user) async {
    try {
      final credential = await _auth.createUserWithEmailAndPassword(
        email: user.email,
        password: user.password,
      );

      await credential.user?.sendEmailVerification();

      await _firestore
          .collection('users')
          .doc(credential.user!.uid)
          .set(user.toMap());

      await _auth.signOut();
      return const Right(unit);
    } on FirebaseAuthException catch (e) {
      return Left(_mapFirebaseAuthError(e.code));
    } on FirebaseException catch (e) {
      return Left(ServerFailure(e.message ?? 'Error al registrar usuario'));
    } catch (e) {
      return const Left(UnexpectedFailure());
    }
  }

  @override
  Future<Either<Failure, Unit>> resetPassword(String email) async {
    try {
      await _auth.sendPasswordResetEmail(email: email);
      return const Right(unit);
    } on FirebaseAuthException catch (e) {
      return Left(_mapFirebaseAuthError(e.code));
    } catch (e) {
      return const Left(UnexpectedFailure());
    }
  }

  @override
  Future<Either<Failure, User>> getAuthenticatedUser() async {
    try {
      final user = _auth.currentUser;
      if (user == null) {
        return const Left(UserNotFoundFailure());
      }

      return Right(user);
    } catch (e) {
      return const Left(UnexpectedFailure());
    }
  }

  @override
  Stream<UserModel?> authStateChanges() {
    return _auth.authStateChanges().asyncMap((usu) async {
      if (usu == null) return null;
      final doc = await _firestore.collection('users').doc(usu.uid).get();
      if (!doc.exists || doc.data() == null) return null;
      return UserModel.fromMap(doc);
    });
  }

  @override
  Future<Either<Failure, List<UserModel>>> getAllUsers() async {
    try {
      final snapshot = await _firestore.collection('users').get();
      final users = snapshot.docs.map((doc) => UserModel.fromMap(doc)).toList();
      return Right(users);
    } on FirebaseException catch (e) {
      return Left(ServerFailure(e.message ?? 'Error al obtener usuarios'));
    } catch (e) {
      return const Left(UnexpectedFailure());
    }
  }

  // Helper method para mapear errores de Firebase
  Failure _mapFirebaseAuthError(String code) {
    switch (code) {
      case 'email-already-in-use':
        return const EmailAlreadyInUseFailure();
      case 'invalid-credential':
        return const InvalidCredentialFailure();
      case 'invalid-email':
        return const InvalidEmailFailure();
      case 'weak-password':
        return const WeakPasswordFailure();
      case 'operation-not-allowed':
        return const OperationNotAllowedFailure();
      case 'network-request-failed':
        return const NetworkFailureAuth();
      case 'user-not-found':
        return const UserNotFoundFailure();
      default:
        return const UnexpectedFailure();
    }
  }
}
