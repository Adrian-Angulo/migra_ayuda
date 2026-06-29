import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:migra_ayuda/core/network/network_provider.dart';
import 'package:migra_ayuda/features/userActivity/data/datasources/user_activity_local_datasource.dart';
import 'package:migra_ayuda/features/userActivity/data/datasources/user_activity_remote_datasource.dart';
import 'package:migra_ayuda/features/userActivity/data/repositories/user_activity_repository_impl.dart';
import 'package:migra_ayuda/features/userActivity/domain/repositories/user_activity_repository.dart';
import 'package:migra_ayuda/features/userActivity/domain/usecase/create_activity_usecase.dart';
import 'package:migra_ayuda/features/userActivity/domain/usecase/get_all_activity_usecase.dart';

// ============================================================================
// REPOSITORY PROVIDER
// ============================================================================

final userActivityRProvider = Provider<UserActivityRepository>(
  (ref) {
    final remoteDataSource = UserActivityRemoteDataSource();
    final localDataSource = UserActivityLocalDataSource();
    final networkInfo = ref.watch(networkInfoProvider);

    return UserActivityRepositoryImpl(
        remoteDataSource: remoteDataSource,
        localDataSource: localDataSource,
        networkInfo: networkInfo);
  },
);

// ============================================================================
// USECASES PROVIDERS
// ============================================================================

final createActivityUsecaseProvider = Provider<CreateActivityUsecase>(
  (ref) {
    final repository = ref.watch(userActivityRProvider);
    return CreateActivityUsecase(repository: repository);
  },
);

final getAllActivityUsecaseProvider = Provider<GetAllActivityUsecase>(
  (ref) {
    final rep = ref.watch(userActivityRProvider);
    return GetAllActivityUsecase(repository: rep);
  },
);
