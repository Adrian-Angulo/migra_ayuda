import 'dart:async';

import 'package:flutter/rendering.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:migra_ayuda/core/enum/enums.dart';
import 'package:migra_ayuda/core/network/network_provider.dart';
import 'package:migra_ayuda/features/auth/data/models/user_model.dart';
import 'package:migra_ayuda/features/userActivity/data/datasources/user_activity_local_datasource.dart';
import 'package:migra_ayuda/features/userActivity/data/datasources/user_activity_remote_datasource.dart';
import 'package:migra_ayuda/features/userActivity/data/repositories/user_activity_repository_impl.dart';
import 'package:migra_ayuda/features/userActivity/domain/entities/user_activity_entity.dart';
import 'package:migra_ayuda/features/userActivity/domain/repositories/user_activity_repository.dart';

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
    state = const AsyncValue.loading();
    final repo = ref.read(activityRepositoryP);
    final userFake = UserModel(
      id: 'ad',
        name: 'Camilo',
        email: 'ejemplo@gmail.com',
        password: '',
        originCountry: 'Venezuela',
        role: 'Migrante');
    final activity = UserActivityEntity(
        id: userFake.id,
        idUser: userFake.id,
        accion: accion,
        nombre: userFake.name,
        correo: userFake.email,
        pais: userFake.originCountry!);

    state = await AsyncValue.guard(() async {
      await repo.createActivity(activity);
      debugPrint('Se creo una actvidad $accion');
      return ActivityState.success;
    });
  }
}
