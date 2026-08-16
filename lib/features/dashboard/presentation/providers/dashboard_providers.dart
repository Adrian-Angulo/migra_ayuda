import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:migra_ayuda/features/dashboard/data/repositories/dashboard_repository_imple.dart';
import 'package:migra_ayuda/features/dashboard/domain/repositories/dashboard_repository.dart';

final dashboardRespositoryProvider = Provider<DashboardRepository>(
  (ref) => DashboardRepositoryImple(),
);

final usersCountProvider = FutureProvider<int>(
  (ref) => ref.watch(dashboardRespositoryProvider).getUsersCount(),
);
final entitiesCountProvider = FutureProvider(
  (ref) => ref.watch(dashboardRespositoryProvider).getEntitiesCount(),
);
final reviewCountProvider = FutureProvider(
  (ref) => ref.watch(dashboardRespositoryProvider).getReviewCount(),
);
final servicesCountProvider = FutureProvider(
  (ref) => ref.watch(dashboardRespositoryProvider).getServicesCount(),
);


