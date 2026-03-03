import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../domain/auth_repository.dart';

class AuthRepositoryImpl implements AuthRepository {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  @override
  Future<void> register(
    String email,
    String password,
    String nombre,
    String apellido,
    String paisOrigen,
    String paisDestino,
    int edad,
    bool aceptaTerminos,
  ) async {
    if (!aceptaTerminos) {
      throw Exception('Debe aceptar los términos y condiciones');
    }
    UserCredential userCredential = await _auth.createUserWithEmailAndPassword(
      email: email,
      password: password,
    );

    // Actualizar el perfil del usuario con información adicional
    await userCredential.user?.updateDisplayName('$nombre $apellido');

    // Aquí podrías guardar información adicional en Firestore
    await _firestore.collection('users').doc(userCredential.user?.uid).set({
      'nombre': nombre,
      'apellido': apellido,
      'paisOrigen': paisOrigen,
      'paisDestino': paisDestino,
      'edad': edad,
      'email': email,
    });
  }

  @override
  Future<void> login(String email, String password) async {
    await _auth.signInWithEmailAndPassword(email: email, password: password);
  }
}
