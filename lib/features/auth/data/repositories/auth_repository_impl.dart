import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:migra_ayuda/features/auth/data/models/user_model.dart';
import 'package:migra_ayuda/features/auth/domain/repositories/auth_repository.dart';

class AuthRepositoryImpl implements AuthRepository {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final GoogleSignIn googleSignIn = GoogleSignIn();

  @override
  Future<UserCredential?> authConGoogle() async {
    final GoogleSignInAccount? googleUser = await googleSignIn.signIn();
    if (googleUser == null) return null;
    final GoogleSignInAuthentication googleAuth =
        await googleUser.authentication;

    final OAuthCredential credential = GoogleAuthProvider.credential(
      idToken: googleAuth.idToken,
      accessToken: googleAuth.accessToken,
    );

    return await FirebaseAuth.instance.signInWithCredential(credential);
  }

  @override
  Future<void> cerrarSesion() async {
    await _auth.signOut();
    await googleSignIn.signOut();
  }

  @override
  Future<void> completarPerfil(
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
  Future<Usuario> verificarOCrearUsuarioGoogle(
      UserCredential credential) async {
    final uid = credential.user!.uid;
    final docRef = _firestore.collection('users').doc(uid);
    final doc = await docRef.get();

    if (doc.exists) {
      // Usuario ya existe, retornar sus datos
      return Usuario.fromMap(doc);
    } else {
      // Usuario nuevo, crear en Firestore
      final nuevoUsuario = Usuario(
        id: uid,
        name: credential.user!.displayName ?? 'Usuario',
        lastname: '',
        email: credential.user!.email ?? '',
        password: '',
        profileComplete: false,
      );

      await docRef.set(nuevoUsuario.toMap());
      return nuevoUsuario;
    }
  }

  @override
  Future<Usuario> datosDeUsuario(String uid) async {
    final doc = await _firestore.collection('users').doc(uid).get();
    return Usuario.fromMap(doc);
  }

  @override
  Future<User?> iniciarSesion(String email, String password) async {
    final credential = await _auth.signInWithEmailAndPassword(
        email: email, password: password);
    return credential.user;
  }

  @override
  Future<void> registrarUsuario(Usuario user) async {
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
  Future<void> restablecerContrasena(String email) {
    // TODO: implement restablecerContrasena
    throw UnimplementedError();
  }

  @override
  Future<User?> usuarioAutenticado() async {
    return _auth.currentUser;
  }
}
