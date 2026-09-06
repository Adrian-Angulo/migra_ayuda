import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:migra_ayuda/features/users/data/models/migrant_model.dart';

class FirebaseUsersDatasource {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  Stream<List<MigrantModel>> getAll() {
    return _firestore
        .collection('users')
        .where('role', isEqualTo: 'Migrante')
        .snapshots()
        .map((snap) => snap.docs.map((doc) {
              final data = Map<String, dynamic>.from(doc.data());
              data['id'] = doc.id;
              return MigrantModel.fromMap(data);
            }).toList());
  }

  Future<MigrantModel?> getById(String id) async {
    final doc = await _firestore.collection('users').doc(id).get();
    if (!doc.exists || doc.data() == null) return null;
    final data = Map<String, dynamic>.from(doc.data()!);
    data['id'] = doc.id;
    return MigrantModel.fromMap(data);
  }

  Future<void> setWithId(String id, MigrantModel user) async {
    await _firestore.collection('users').doc(id).set(user.toMap());
  }

  Future<void> updateFields(String id, Map<String, dynamic> data) async {
    await _firestore.collection('users').doc(id).update(data);
  }

  Future<void> create(MigrantModel user) async {
    final docRef = await _firestore.collection('users').add(user.toMap());
    await docRef.update({'id': docRef.id});
  }
}

