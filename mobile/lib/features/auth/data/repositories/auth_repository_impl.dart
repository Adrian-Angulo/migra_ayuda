import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:dartz/dartz.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:migra_ayuda/core/errors/auth_failures.dart';
import 'package:migra_ayuda/core/errors/failures.dart';
import 'package:migra_ayuda/features/auth/data/models/user_model.dart';
import 'package:migra_ayuda/features/auth/domain/repositories/auth_repository.dart';

class AuthRepositoryImpl implements AuthRepository {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final GoogleSignIn googleSignIn = GoogleSignIn();

  AuthRepositoryImpl() ;

  @override
  Future<Either<Failure, UserCredential>> authWithGoogle() async {
    try {
      final GoogleSignInAccount? googleUser = await googleSignIn.signIn();

      if (googleUser == null) {
        return const Left(OperationCancelledFailure());
      }

      final GoogleSignInAuthentication googleAuth =
          await googleUser.authentication;

      final credential = GoogleAuthProvider.credential(
        idToken: googleAuth.idToken,
        accessToken: googleAuth.accessToken,
      );

      final userCredential =
          await FirebaseAuth.instance.signInWithCredential(credential);

      return Right(userCredential);
    } on FirebaseAuthException catch (e) {
      return Left(_mapFirebaseAuthError(e.code));
    } on FirebaseException catch (e) {
      return Left(ServerFailure(e.message ?? 'Error del servidor'));
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
        return Right(UserModel.fromMap(doc));
      } else {
        final newUser = UserModel(
          id: uid,
          name: credential.user!.displayName ?? 'Usuario',
          lastname: '',
          email: credential.user!.email ?? '',
          password: '',
          profileComplete: false,
        );

        await docRef.set(newUser.toMap());
        return Right(newUser);
      }
    } on FirebaseException catch (e) {
      return Left(ServerFailure(e.message ?? 'Error al crear usuario'));
    } catch (e) {
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

      return Right(UserModel.fromMap(doc));
    } on FirebaseException catch (e) {
      return Left(ServerFailure(e.message ?? 'Error al obtener datos'));
    } catch (e) {
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
