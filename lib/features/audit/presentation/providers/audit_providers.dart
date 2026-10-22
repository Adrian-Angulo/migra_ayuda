import 'package:migra_ayuda/features/audit/domain/usecases/audit_usecases.dart';
import 'dart:async';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_riverpod/legacy.dart';
import 'package:migra_ayuda/core/enum/enums.dart';
import 'package:migra_ayuda/core/network/network_provider.dart';
import 'package:migra_ayuda/features/auth/presentation/providers/auth_notifier.dart';
import 'package:migra_ayuda/features/audit/data/datasources/audit_local_datasource.dart';
import 'package:migra_ayuda/features/audit/data/datasources/audit_remote_datasource.dart';
import 'package:migra_ayuda/features/audit/data/repositories/audit_repository_impl.dart';
import 'package:migra_ayuda/features/audit/domain/entities/audit_entity.dart';
import 'package:migra_ayuda/features/audit/domain/repositories/audit_repository.dart';

final queryAuditProvider = StateProvider<String>((ref) => '');


final auditFilterProvider =
    StateProvider.autoDispose<AsyncValue<List<AuditEntity>>>((ref) {
  final query = ref.watch(queryAuditProvider);
  final stream = ref.watch(getAllAuditProvider);

  return stream.when(
      data: (originList) {
        List<AuditEntity> filterList = originList;
        if (query.isNotEmpty) {
          filterList = originList
              .where((a) =>
                  a.nombre.toLowerCase().contains(query) ||
                  a.correo.toLowerCase().contains(query) ||
                  a.accion.toLowerCase().contains(query) ||
                  a.pais.toLowerCase().contains(query))
              .toList();
        }

        return AsyncValue.data(filterList);
      },
      error: (error, stackTrace) => AsyncValue.error(error, stackTrace),
      loading: () => const AsyncValue.loading());
});

final auditRepositoryProvider = Provider<AuditRepository>(
  (ref) {
    final network = ref.read(networkInfoProvider);
    return AuditRepositoryImpl(
        remoteDataSource: AuditRemoteDataSource(),
        localDataSource: AuditLocalDataSource(),
        networkInfo: network);
  },
);

final registerActivityUseCaseProvider = Provider<RegisterActivityUsecase>(
  (ref) => RegisterActivityUsecase(ref.watch(auditRepositoryProvider)),
);

final getAllActivitiesUseCaseProvider = Provider<GetAllActitiesUsecase>(
  (ref) => GetAllActitiesUsecase(ref.watch(auditRepositoryProvider)),
);

final synchronizeAuditUseCaseProvider = Provider<SyncronizeUsecase>(
  (ref) => SyncronizeUsecase(ref.watch(auditRepositoryProvider)),
);

final getAllAuditProvider =
    StreamProvider((ref) => ref.read(getAllActivitiesUseCaseProvider).call());

final auditNotifierProvider =
    AsyncNotifierProvider<AuditNotifier, ActivityState>(AuditNotifier.new);

class AuditNotifier extends AsyncNotifier<ActivityState> {
  @override
  FutureOr<ActivityState> build() => ActivityState.init;

  Future<void> create({
    required String accion,
    Map<String, dynamic>? metadata,
  }) async {
    state = const AsyncValue.loading();

    final user = ref.read(authNotifierProvider).value;
    if (user == null) {
      state = AsyncValue.error(
        'El usuario no está autenticado',
        StackTrace.current,
      );
      return;
    }

    final activity = _buildAuditEntity(user, accion, metadata);

    state = await AsyncValue.guard(() async {
      final result = await ref.read(registerActivityUseCaseProvider).call(activity);
      return result.fold(
        (failure) => throw failure,
        (_) => ActivityState.success,
      );
    });
  }

  AuditEntity _buildAuditEntity(
    dynamic user,
    String accion,
    Map<String, dynamic>? metadata,
  ) {
    return AuditEntity(
      id: user.id,
      idUser: user.id,
      accion: accion,
      nombre: user.name,
      correo: user.email,
      metadata: metadata,
      pais: user.originCountry,
    );
  }
}
