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

// ---------------------------------------------------------------------------
// Providers para la tabla web de actividades
// ---------------------------------------------------------------------------

/// Texto de búsqueda ingresado en la barra de la tabla
final queryAuditProvider = StateProvider<String>((ref) => '');

/// Lista de actividades filtrada según [queryAuditProvider]
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

final auditRepositoryProvider = Provider<UserActivityRepository>(
  (ref) {
    final network = ref.read(networkInfoProvider);
    return AuditRepositoryImpl(
        remoteDataSource: AuditRemoteDataSource(),
        localDataSource: AuditLocalDataSource(),
        networkInfo: network);
  },
);
final getAllAuditProvider =
    StreamProvider((ref) => ref.read(auditRepositoryProvider).getAll());

final auditNotifierProvider =
    AsyncNotifierProvider<AuditNotifier, ActivityState>(
        AuditNotifier.new);

class AuditNotifier extends AsyncNotifier<ActivityState> {
  @override
  FutureOr<ActivityState> build() {
    return ActivityState.init;
  }

  Future<void> create({
    required String accion,
    Map<String, dynamic>? metadata,
  }) async {
    //inicializa el estado de carga
    state = const AsyncValue.loading();

    //obtiene el usuario autenticado
    final user = ref.watch(authNotifierProvider).value;

    //si no existe usuario manda un error
    if (user == null) {
      state = AsyncValue.error(
        'El usuario no está autenticado',
        StackTrace.current,
      );
      return;
    }
    //crear una accion del usuario
    final activity = AuditEntity(
        id: user.id,
        idUser: user.id,
        accion: accion,
        nombre: user.name,
        correo: user.email,
        metadata: metadata,
        pais: user.originCountry ?? 'Sin país');

    // guard. captura errores automaticamente
    state = await AsyncValue.guard(() async {
      //crear la actividad
      await ref.read(auditRepositoryProvider).createActivity(activity);

      return ActivityState.success;
    });
  }
}
