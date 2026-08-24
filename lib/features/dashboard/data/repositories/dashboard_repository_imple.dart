
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:migra_ayuda/core/constants/activity_actions.dart';
import 'package:migra_ayuda/core/utils/utils.dart';
import 'package:migra_ayuda/features/dashboard/domain/entities/activity_chart_result.dart';
import 'package:migra_ayuda/features/dashboard/domain/entities/category_data.dart';
import 'package:migra_ayuda/features/dashboard/domain/entities/destination_data.dart';
import 'package:migra_ayuda/features/dashboard/domain/repositories/dashboard_repository.dart';

class DashboardRepositoryImple implements DashboardRepository {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  Future<int> _getCountColletion(String colletionName) async {
    final snapshot = await _firestore.collection(colletionName).count().get();
    return snapshot.count ?? 0;
  }

  @override
  Future<int> getUsersCount() async {
    final snapshot = await _firestore
        .collection('users')
        .where('role', isEqualTo: 'Migrante')
        .count()
        .get();
    return snapshot.count ?? 0;
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
        .where('accion', isEqualTo: 'Como llegar')
        .count()
        .get();
    return snapshot.count ?? 0;
  }

  @override
  Future<List<CategoryData>> getCategoryData() async {
    final snapshot = await _firestore.collection('entities').get();
    Map<String, int> serviceCount = {};

    for (var doc in snapshot.docs) {
      for (var service in doc['services']) {
        serviceCount[service] = (serviceCount[service] ?? 0) + 1;
      }
    }

    return serviceCount.entries
        .map((entry) => CategoryData(name: entry.key, value: entry.value))
        .toList();
  }

  @override
  Stream<List<DestinationData>> getDetinations() {
    return _firestore.collection('users').snapshots().map((snapshot) {
      // Contar la cantidad por país de destino
      final Map<String, int> destinationsCount = {};

      for (var doc in snapshot.docs) {
        final nombreDestino = doc.data()['destinationCountry'];
        if (nombreDestino != null &&
            nombreDestino is String &&
            nombreDestino.isNotEmpty) {
          destinationsCount[nombreDestino] =
              (destinationsCount[nombreDestino] ?? 0) + 1;
        }
      }

      // Crear la lista de DestinationData ordenada de mayor a menor cantidad y tomar solo los 5 mayores
      final List<DestinationData> destinations = destinationsCount.entries
          .map((entry) =>
              DestinationData(nombre: entry.key, cantidad: entry.value))
          .toList()
        ..sort((a, b) => b.cantidad.compareTo(a.cantidad));

      return destinations.take(5).toList();
    });
  }






  @override
  Future<ActivityChartResult> getActivityData({int days = 31}) async {
    final desde = DateTime.now().subtract(Duration(days: days));

    // createdAt se guarda como ISO-8601 (String), no como Timestamp.
    final snapshot = await _firestore
        .collection('user_activities')
        .where(
          'createdAt',
          isGreaterThanOrEqualTo: desde.toUtc().toIso8601String(),
        )
        .orderBy('createdAt')
        .get();

    final Map<String, Map<String, int>> agrupado = {};

    for (final doc in snapshot.docs) {
      final data = doc.data();
      final createdAt = Utils.parseCreatedAt(data['createdAt']);
      if (createdAt == null || createdAt.isBefore(desde)) continue;

      final diaLabel = Utils.formatDia(createdAt);
      final tipo = data['accion'] as String? ?? '';

      agrupado.putIfAbsent(
        diaLabel,
        () => {for (final t in ActivityActions.types()) t: 0},
      );
      if (agrupado[diaLabel]!.containsKey(tipo)) {
        agrupado[diaLabel]![tipo] = agrupado[diaLabel]![tipo]! + 1;
      }
    }

    final dias = agrupado.keys.toList();

    return ActivityChartResult(
      loginData: Utils.serie(dias, agrupado, ActivityActions.login()),
      entityData: Utils.serie(dias, agrupado, ActivityActions.entityViewed()),
      routeData: Utils.serie(dias, agrupado, ActivityActions.routeRequested()),
      filterData: Utils.serie(dias, agrupado, ActivityActions.filter()),
      googleMapData:
          Utils.serie(dias, agrupado, ActivityActions.navigationMaps()),
    );
  }


}
