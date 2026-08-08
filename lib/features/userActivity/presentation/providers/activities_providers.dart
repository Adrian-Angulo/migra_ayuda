import 'dart:async';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_riverpod/legacy.dart';
import 'package:migra_ayuda/core/enum/enums.dart';
import 'package:migra_ayuda/core/network/network_provider.dart';
import 'package:migra_ayuda/features/auth/presentation/providers/auth_notifier.dart';
import 'package:migra_ayuda/features/userActivity/data/datasources/user_activity_local_datasource.dart';
import 'package:migra_ayuda/features/userActivity/data/datasources/user_activity_remote_datasource.dart';
import 'package:migra_ayuda/features/userActivity/data/repositories/user_activity_repository_impl.dart';
import 'package:migra_ayuda/features/userActivity/domain/entities/user_activity.dart';
import 'package:migra_ayuda/features/userActivity/domain/repositories/user_activity_repository.dart';

// ---------------------------------------------------------------------------
// Providers para la tabla web de actividades
// ---------------------------------------------------------------------------

/// Texto de búsqueda ingresado en la barra de la tabla
final queryActivityProvider = StateProvider<String>((ref) => '');

/// Lista de actividades filtrada según [queryActivityProvider]
final activitiesFilterProvider =
    StateProvider.autoDispose<AsyncValue<List<UserActivity>>>((ref) {
  final query = ref.watch(queryActivityProvider);
  final stream = ref.watch(getAllActivityP);

  return stream.when(
      data: (originList) {
        List<UserActivity> filterList = originList;
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

/*   if (query.isEmpty) return stream;

  return stream.map((list) => list
      .where((a) =>
          a.nombre.toLowerCase().contains(query) ||
          a.correo.toLowerCase().contains(query) ||
          a.accion.toLowerCase().contains(query) ||
          a.pais.toLowerCase().contains(query))
      .toList()); */
});

final activityRepositoryP = Provider<UserActivityRepository>(
  (ref) {
    final network = ref.read(networkInfoProvider);
    return UserActivityRepositoryImpl(
        remoteDataSource: UserActivityRemoteDataSource(),
        localDataSource: UserActivityLocalDataSource(),
        networkInfo: network);
  },
);
final getAllActivityP =
    StreamProvider((ref) => ref.read(activityRepositoryP).getAll());

final activityProvider = AsyncNotifierProvider<ActivityNotifier, ActivityState>(
    ActivityNotifier.new);

class ActivityNotifier extends AsyncNotifier<ActivityState> {
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
    final activity = UserActivity(
        id: user.id,
        idUser: user.id,
        accion: accion,
        nombre: user.name,
        correo: user.email,
        metadata: metadata,
        pais: user.originCountry!);

    // guard. captura errores automaticamente
    state = await AsyncValue.guard(() async {
      //crear la actividad
      await ref.read(activityRepositoryP).createActivity(activity);

      return ActivityState.success;
    });
  }
}
