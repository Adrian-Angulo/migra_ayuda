import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:migra_ayuda/core/constants/activity_actions.dart';
import 'package:migra_ayuda/core/utils/utils.dart';
import 'package:migra_ayuda/features/dashboard/domain/entities/activity_chart_result.dart';
import 'package:migra_ayuda/features/dashboard/domain/entities/category_data.dart';
import 'package:migra_ayuda/features/dashboard/domain/entities/destination_data.dart';
import 'package:migra_ayuda/features/dashboard/domain/failures/dashboard_failures.dart';
import 'package:migra_ayuda/features/dashboard/domain/repositories/dashboard_repository.dart';

class DashboardRepositoryImple implements DashboardRepository {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  Future<int> _getCountColletion(String colletionName) async {
    try {
      final snapshot = await _firestore.collection(colletionName).count().get();
      return snapshot.count ?? 0;
    } catch (_) {
      throw const DashboardMetricsFetchFailure();
    }
  }

  @override
  Future<int> getUsersCount() async {
    try {
      final snapshot = await _firestore
          .collection('users')
          .where('role', isEqualTo: 'Migrante')
          .count()
          .get();
      return snapshot.count ?? 0;
    } catch (_) {
      throw const DashboardMetricsFetchFailure();
    }
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
    try {
      final snapshot = await _firestore
          .collection('user_activities')
          .where('accion', isEqualTo: 'Como llegar')
          .count()
          .get();
      return snapshot.count ?? 0;
    } catch (_) {
      throw const DashboardMetricsFetchFailure();
    }
  }

  @override
  Future<List<CategoryData>> getCategoryData() async {
    try {
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
    } catch (_) {
      throw const DashboardChartDataFetchFailure();
    }
  }

  @override
  Stream<List<DestinationData>> getDetinations() {
    return _firestore.collection('users').snapshots().map((snapshot) {
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

      final List<DestinationData> destinations = destinationsCount.entries
          .map((entry) =>
              DestinationData(nombre: entry.key, cantidad: entry.value))
          .toList()
        ..sort((a, b) => b.cantidad.compareTo(a.cantidad));

      return destinations.take(5).toList();
    }).handleError((_) {
      throw const DashboardDestinationsFetchFailure();
    });
  }

  @override
  Future<ActivityChartResult> getActivityData({
    DateTime? startDate,
    DateTime? endDate,
    int? days,
  }) async {
    try {
      final now = DateTime.now();
      final DateTime desde = startDate ??
          (days != null
              ? now.subtract(Duration(days: days))
              : now.subtract(const Duration(days: 15)));
      final DateTime hasta = endDate != null
          ? DateTime(endDate.year, endDate.month, endDate.day, 23, 59, 59, 999)
          : now;

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
        if (createdAt == null ||
            createdAt.isBefore(desde) ||
            createdAt.isAfter(hasta)) {
          continue;
        }

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
    } catch (_) {
      throw const DashboardChartDataFetchFailure();
    }
  }
}
