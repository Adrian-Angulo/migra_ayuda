import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:migra_ayuda/core/errors/auth_failures.dart';
import 'package:migra_ayuda/features/auth/data/models/user_model.dart';
import 'package:migra_ayuda/features/auth/domain/repositories/auth_repository.dart';

class AuthRepositoryImpl implements AuthRepository {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final GoogleSignIn googleSignIn = GoogleSignIn();

  AuthRepositoryImpl();

  @override
  Future<UserCredential> authWithGoogle() async {
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

    final providers = user.providerData.map((info) => info.providerId).toList();

    if (providers.contains('password')) {
      await user.unlink('password');
    }

    return userCredential;
  }

  @override
  Future<void> logout() async {
    await _auth.signOut();
    await googleSignIn.signOut();
  }

  @override
  Future<void> completeProfile({
    required String originCountry,
    required String destinationCountry,
    required int age,
  }) async {
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
  }

  @override
  Future<UserModel> verifyOrCreateGoogleUser(UserCredential credential) async {
    final uid = credential.user?.uid;

    if (uid == null) {
      throw const UserNotFoundFailure();
    }

    final docRef = _firestore.collection('users').doc(uid);
    final doc = await docRef.get();

    if (doc.exists) {
      print('✅ Usuario existente encontrado');
      return UserModel.fromMap(doc);
    } else {
      print('🆕 Creando nuevo usuario con Google');
      final newUser = UserModel(
        id: uid,
        name: credential.user!.displayName ?? 'Usuario',

        email: credential.user!.email ?? '',
        password: '',
        role: 'Migrante', // Asignar rol por defecto
        profileComplete: false,
      );

      await docRef.set(newUser.toMap());
      print('✅ Usuario creado: ${newUser.toMap()}');
      return newUser;
    }
  }

  @override
  Future<UserModel> getUserData(String uid) async {
    final doc = await _firestore.collection('users').doc(uid).get();
    if (!doc.exists) {
      throw const UserDataNotFoundFailure();
    }
    final userData = UserModel.fromMap(doc);
    return userData;
  }

  Future<bool> emailExists(String email) async {
    final snapshot = await _firestore
        .collection('users')
        .where('email', isEqualTo: email)
        .limit(1)
        .get();
    return snapshot.docs.isNotEmpty;
  }

  @override
  Future<User> login(String email, String password) async {
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
  }

  @override
  Future<void> registerUser(UserModel user) async {
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

    await _auth.signOut();
  }

  @override
  Future<void> resetPassword(String email) async {
    await _auth.sendPasswordResetEmail(email: email);
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
  Future<List<UserModel>> getAllUsers() async {
    final snapshot = await _firestore.collection('users').get();
    final users = snapshot.docs.map((doc) => UserModel.fromMap(doc)).toList();
    return users;
  }

  @override
  Future<User?> getAuthenticatedUser() async {
    return _auth.currentUser;
  }
}
