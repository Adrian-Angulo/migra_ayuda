import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:migra_ayuda/features/dashboard/domain/repositories/dashboard_repository.dart';

class DashboardRepositoryImple implements DashboardRepository {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  Future<int> _getCountColletion(String colletionName) async {
    final snapshot = await _firestore.collection(colletionName).count().get();
    return snapshot.count ?? 0;
  }

  @override
  Future<int> getUsersCount() async {
    return await _getCountColletion('users');
  }

  @override
  Future<int> getEntitiesCount() async {
    return await _getCountColletion('entities');
  }

  @override
  Future<int> getReviewCount() async {
    return await _getCountColletion('reviews');
  }

  @override
  Future<int> getServicesCount() async {
    final snapshot = await _firestore
        .collection('user_activities')
        .where('accion', isEqualTo: 'Filtrar')
        .count()
        .get();
    return snapshot.count ?? 0;
  }
}
