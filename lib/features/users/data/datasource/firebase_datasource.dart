import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:migra_ayuda/features/users/data/models/migrant_model.dart';

class FirebaseUsersDatasource {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  Stream<List<MigrantModel>> getAll() {
    return _firestore
        .collection('users')
        .where('role', isEqualTo: 'Migrante')
        .snapshots()
        .map((snap) =>
            snap.docs.map((doc) => MigrantModel.fromMap(doc.data())).toList());
  }

  Future<void> create(MigrantModel user) async {
    final docRef = await _firestore.collection('users').add(user.toMap());
    await docRef.update({'id': docRef.id});
  }
}
