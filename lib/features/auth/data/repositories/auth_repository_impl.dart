import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart' as firebase_auth;
import 'package:google_sign_in/google_sign_in.dart';
import 'package:migra_ayuda/features/auth/data/models/user_model.dart';
import 'package:migra_ayuda/features/auth/domain/repositories/auth_repository.dart';

class AuthRepositoryImpl implements AuthRepository {
  final firebase_auth.FirebaseAuth _auth;
  final FirebaseFirestore _firestore;
  final GoogleSignIn googleSignIn;

  AuthRepositoryImpl({
    required firebase_auth.FirebaseAuth auth,
    required FirebaseFirestore firestore,
    required this.googleSignIn,
  })  : _auth = auth,
        _firestore = firestore;

  @override
  Future<firebase_auth.UserCredential?> authWithGoogle() async {
    final GoogleSignInAccount? googleUser = await googleSignIn.signIn();
    if (googleUser == null) return null;
    final GoogleSignInAuthentication googleAuth =
        await googleUser.authentication;

    final firebase_auth.OAuthCredential credential =
        firebase_auth.GoogleAuthProvider.credential(
      idToken: googleAuth.idToken,
      accessToken: googleAuth.accessToken,
    );

    return await firebase_auth.FirebaseAuth.instance
        .signInWithCredential(credential);
  }

  @override
  Future<void> logout() async {
    await _auth.signOut();
    await googleSignIn.signOut();
  }

  @override
  Future<void> completeProfile(
      {required String originCountry,
      required String destinationCountry,
      required int age}) async {
    await _firestore.collection('users').doc(_auth.currentUser?.uid).update({
      'originCountry': originCountry,
      'destinationCountry': destinationCountry,
      'age': age.toString(),
      'profileComplete': true,
    });
  }

  @override
  Future<UserModel> verifyOrCreateGoogleUser(
      firebase_auth.UserCredential credential) async {
    final uid = credential.user!.uid;
    final docRef = _firestore.collection('users').doc(uid);
    final doc = await docRef.get();

    if (doc.exists) {
      return UserModel.fromMap(doc);
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
      return newUser;
    }
  }

  @override
  Future<UserModel> getUserData(String uid) async {
    final doc = await _firestore.collection('users').doc(uid).get();
    return UserModel.fromMap(doc);
  }

  @override
  Future<firebase_auth.User?> login(String email, String password) async {
    final credential = await _auth.signInWithEmailAndPassword(
        email: email, password: password);
    return credential.user;
  }

  @override
  Future<void> registerUser(UserModel user) async {
    final credential = await _auth.createUserWithEmailAndPassword(
      email: user.email,
      password: user.password,
    );
    credential.user?.sendEmailVerification();
    await _firestore
        .collection('users')
        .doc(credential.user!.uid)
        .set(user.toMap());
  }

  @override
  Future<void> resetPassword(String email) async {
    await _auth.sendPasswordResetEmail(email: email);
  }

  @override
  Future<firebase_auth.User?> getAuthenticatedUser() async {
    return _auth.currentUser;
  }
}
