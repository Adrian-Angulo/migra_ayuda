import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:migra_ayuda/core/models/user_model.dart';
import 'package:migra_ayuda/features/auth/domain/repositories/auth_repository.dart';

class AuthRepositoryImple2 implements AuthRepository {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final GoogleSignIn googleSignIn = GoogleSignIn();
  @override
  Future<UserModel?> getUsuarioActual() async {
    final uid = _auth.currentUser?.uid;
    if (uid == null) return null;
    final doc =
        await _firestore.collection('users').doc(uid).get();

    if (!doc.exists) return null;
    return UserModel.fromFirestore(doc);
  }

  @override
  Future<void> login(String email, String password) async {
    await _auth.signInWithEmailAndPassword(
      email: email,
      password: password,
    );
  }

  @override
  Future<void> logout() async {
    await _auth.signOut();
    await googleSignIn.signOut();
  }

  @override
  Future<void> register(
      String name,
      String lasname,
      String email,
      String password,
      String originCountry,
      String destinationCountry,
      int age) async {
    final UserCredential userCredential =
        await _auth.createUserWithEmailAndPassword(
      email: email,
      password: password,
    );

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

  @override
  Future<void> resetPassword(String email) async {
    await _auth.sendPasswordResetEmail(email: email);
  }

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

    return userCredential;
  }
}
