import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:migra_ayuda/core/models/user_model.dart';
import 'package:migra_ayuda/features/auth/domain/entities/google_signin_result.dart';
import 'package:migra_ayuda/features/auth/domain/repositories/auth_repository.dart';

class AuthRepositoryImple2 implements AuthRepository {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final GoogleSignIn googleSignIn = GoogleSignIn();
  @override
  Future<UserModel?> getUsuarioActual() async {
    final uid = _auth.currentUser?.uid;
    if (uid == null) return null;
    final doc = await _firestore.collection('users').doc(uid).get();

    if (!doc.exists) return null;
    return UserModel.fromFirestore(doc);
  }

  @override
  Future<User?> login(String email, String password) async {
    final userCredential = await _auth.signInWithEmailAndPassword(
      email: email,
      password: password,
    );
    final user = userCredential.user;
    return user;
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
    try {
      await _auth.sendPasswordResetEmail(email: email);
    } on FirebaseAuthException catch (e) {
      throw FirebaseAuthException(code: e.code);
    } catch (e) {
      throw Exception('Error desconocido al enviar el correo');
    }
  }

  @override
  Future<GoogleSignInResult> signInWithGoogle() async {
    final GoogleSignInAccount? googleUser = await googleSignIn.signIn();
    if (googleUser == null) {
      throw Exception('Inicio de sesión cancelado');
    }

    final GoogleSignInAuthentication googleAuth =
        await googleUser.authentication;

    final OAuthCredential credential = GoogleAuthProvider.credential(
      idToken: googleAuth.idToken,
      accessToken: googleAuth.accessToken,
    );

    final UserCredential userCredential =
        await FirebaseAuth.instance.signInWithCredential(credential);

    final user = userCredential.user;
    if (user == null) {
      throw Exception('Error al obtener usuario');
    }

    // Verificar si es primera vez
    final userDoc = await _firestore.collection('users').doc(user.uid).get();
    final isFirstTime = !userDoc.exists;

    if (isFirstTime) {
      // Crear documento con profileComplete: false
      await _firestore.collection('users').doc(user.uid).set({
        'name': user.displayName?.split(' ').first ?? '',
        'lastname': user.displayName?.split(' ').skip(1).join(' ') ?? '',
        'email': user.email ?? '',
        'originCountry': '',
        'destinationCountry': '',
        'age': 0,
        'profileComplete': false,
        'role': 'Migrante',
        'createdAt': FieldValue.serverTimestamp(),
      });
    }

    return GoogleSignInResult(
      isFirstTime: isFirstTime,
      userId: user.uid,
    );
  }

  @override
  Future<void> completeGoogleProfile({
    required String userId,
    required String originCountry,
    required String destinationCountry,
    required int age,
  }) async {
    await _firestore.collection('users').doc(userId).update({
      'originCountry': originCountry,
      'destinationCountry': destinationCountry,
      'age': age,
      'profileComplete': true,
    });
  }
}
