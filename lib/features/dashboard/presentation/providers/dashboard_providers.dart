import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:migra_ayuda/features/audit/domain/entities/audit_entity.dart';
import 'package:migra_ayuda/features/audit/presentation/providers/audit_providers.dart';
import 'package:migra_ayuda/features/dashboard/data/repositories/dashboard_repository_imple.dart';
import 'package:migra_ayuda/features/dashboard/domain/entities/category_data.dart';
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
