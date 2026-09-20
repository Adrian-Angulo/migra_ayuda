import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_riverpod/legacy.dart';
import 'package:migra_ayuda/features/audit/domain/entities/audit_entity.dart';
import 'package:migra_ayuda/features/audit/presentation/providers/audit_providers.dart';
import 'package:migra_ayuda/features/dashboard/data/repositories/dashboard_repository_imple.dart';
import 'package:migra_ayuda/features/dashboard/domain/entities/activity_chart_result.dart';
import 'package:migra_ayuda/features/dashboard/domain/entities/category_data.dart';
import 'package:migra_ayuda/features/dashboard/domain/entities/destination_data.dart';
import 'package:migra_ayuda/features/dashboard/domain/repositories/dashboard_repository.dart';

final dashboardRespositoryProvider = Provider<DashboardRepository>(
  (ref) => DashboardRepositoryImple(),
);

final usersCountProvider = FutureProvider.autoDispose<int>(
  (ref) => ref.watch(dashboardRespositoryProvider).getUsersCount(),
);
final entitiesCountProvider = FutureProvider.autoDispose(
  (ref) => ref.watch(dashboardRespositoryProvider).getEntitiesCount(),
);
final reviewCountProvider = FutureProvider.autoDispose(
  (ref) => ref.watch(dashboardRespositoryProvider).getReviewCount(),
);
final servicesCountProvider = FutureProvider.autoDispose(
  (ref) => ref.watch(dashboardRespositoryProvider).getServicesCount(),
);

final recentActivityProvider = StreamProvider<List<AuditEntity>>((ref) {
  return ref.read(auditRepositoryProvider).getAll().map((audits) {
    final sortedAudits = [...audits];
    sortedAudits.sort((a, b) => b.createdAt.compareTo(a.createdAt));
    return sortedAudits.take(10).toList();
  });
});

final getCategoryDataProvider = FutureProvider.autoDispose<List<CategoryData>>(
  (ref) {
    return ref.read(dashboardRespositoryProvider).getCategoryData();
  },
);

final getDestinationsProvider =
    StreamProvider.autoDispose<List<DestinationData>>((ref) {
  return ref.watch(dashboardRespositoryProvider).getDetinations();
});

final getUserLength = Provider.autoDispose<int>(
  (ref) {
    final usersCountState = ref.watch(usersCountProvider);
    return usersCountState.when(
      data: (data) => data,
      error: (error, stackTrace) {
        debugPrint('ha ocurrido un error ${error.toString()}');
        return 0;
      },
      loading: () => 0,
    );
  },
);

final activityDateRangeProvider =
    StateProvider.autoDispose<DateTimeRange>((ref) {
  final now = DateTime.now();
  return DateTimeRange(
    start: now.subtract(const Duration(days: 15)),
    end: now,
  );
});

final activityChartProvider =
    FutureProvider.autoDispose<ActivityChartResult>((ref) async {
  final range = ref.watch(activityDateRangeProvider);
  final service = ref.read(dashboardRespositoryProvider);
  return service.getActivityData(
    startDate: range.start,
    endDate: range.end,
  );
});
