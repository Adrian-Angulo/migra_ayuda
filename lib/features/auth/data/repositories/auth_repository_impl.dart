import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:migra_ayuda/features/auth/data/models/user_model.dart';
import 'package:migra_ayuda/features/auth/domain/entities/google_signin_result.dart';
import 'package:migra_ayuda/features/auth/domain/repositories/auth_repository.dart';

class AuthRepositoryImpl implements AuthRepository {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  @override
  Future<GoogleSignInResult> authConGoogle() {
    // TODO: implement authConGoogle
    throw UnimplementedError();
  }

  @override
  Future<void> cerrarSesion() async {
    await _auth.signOut();
  }

  @override
  Future<void> completarPerfil(
      {required String userId,
      required String originCountry,
      required String destinationCountry,
      required int age}) {
    // TODO: implement completarPerfil
    throw UnimplementedError();
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
    /* if (id == null) return null;
    return await datosDeUsuario(id); */
  }
}
