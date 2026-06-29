import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:migra_ayuda/core/database/sembast_database.dart';
import 'package:migra_ayuda/core/network/network_provider.dart';
import 'package:migra_ayuda/features/entities/data/datasources/entity_local_datasource.dart';
import 'package:migra_ayuda/features/entities/data/datasources/entity_remote_datasource.dart';
import 'package:migra_ayuda/features/entities/data/repositories/entity_mobil_repository_impl.dart';
import 'package:migra_ayuda/features/entities/data/repositories/entity_web_repository_impl.dart';
import 'package:migra_ayuda/features/entities/domain/entities/entity_entity.dart';
import 'package:migra_ayuda/features/entities/domain/repositories/entity_repository.dart';
import 'package:migra_ayuda/features/entities/domain/usecases/delete_entity_usecase.dart';
import 'package:migra_ayuda/features/entities/domain/usecases/get_all_entities_usecase.dart';
import 'package:migra_ayuda/features/entities/domain/usecases/get_entity_by_id_usecase.dart';
import 'package:migra_ayuda/features/entities/domain/usecases/register_entity_usecase.dart';
import 'package:migra_ayuda/features/entities/domain/usecases/sync_all_entities_usecase.dart';
import 'package:migra_ayuda/features/entities/domain/usecases/update_entity_usecase.dart';

// ============================================================================
// DATASOURCES PROVIDERS
// ============================================================================

/// Provider para el datasource remoto (Firebase)
final entityRemoteDataSourceProvider = Provider<EntityRemoteDataSource>((ref) {
  return EntityRemoteDataSource(firestore: FirebaseFirestore.instance);
});

/// Provider para el datasource local (Sembast)
final entityLocalDataSourceProvider = Provider<EntityLocalDataSource>((ref) {
  final sembastDb = SembastDatabase.instance;
  return EntityLocalDataSource(sembastDatabase: sembastDb);
});

// ============================================================================
// REPOSITORY PROVIDER
// ============================================================================

/// Provider para el repositorio de entidades con estrategia offline-first
final entityRepositoryProvider = Provider<EntityRepository>((ref) {
  final remoteDataSource = ref.watch(entityRemoteDataSourceProvider);
  final localDataSource = ref.watch(entityLocalDataSourceProvider);
  final networkInfo = ref.watch(networkInfoProvider);

  if (kIsWeb) {
    return EntityWebRepositoryImpl(remoteDataSource: remoteDataSource);
  }
  return EntityMobilRepositoryImpl(
    remoteDataSource: remoteDataSource,
    localDataSource: localDataSource,
    networkInfo: networkInfo,
  );
});

// ============================================================================
// USECASES PROVIDERS
// ============================================================================

/// Provider para el caso de uso: Obtener todas las entidades
final getAllEntitiesUsecaseProvider = Provider<GetAllEntitiesUsecase>((ref) {
  final repository = ref.watch(entityRepositoryProvider);
  return GetAllEntitiesUsecase(repository: repository);
});

/// Provider para el caso de uso: Obtener entidad por ID
final getEntityByIdUsecaseProvider = Provider<GetEntityByIdUsecase>((ref) {
  final repository = ref.watch(entityRepositoryProvider);
  return GetEntityByIdUsecase(repository: repository);
});

/// Provider para el caso de uso: Registrar nueva entidad
final registerEntityUsecaseProvider = Provider<RegisterEntityUsecase>((ref) {
  final repository = ref.watch(entityRepositoryProvider);
  return RegisterEntityUsecase(repository: repository);
});

/// Provider para el caso de uso: Actualizar entidad
final updateEntityUsecaseProvider = Provider<UpdateEntityUsecase>((ref) {
  final repository = ref.watch(entityRepositoryProvider);
  return UpdateEntityUsecase(repository: repository);
});

/// Provider para el caso de uso: Eliminar entidad
final deleteEntityUsecaseProvider = Provider<DeleteEntityUsecase>((ref) {
  final repository = ref.watch(entityRepositoryProvider);
  return DeleteEntityUsecase(repository: repository);
});

/// Provider para el caso de uso: Sincronizar todas las entidades desde Firebase
final syncAllEntitiesUsecaseProvider = Provider<SyncAllEntitiesUsecase>((ref) {
  final repository = ref.watch(entityRepositoryProvider);
  return SyncAllEntitiesUsecase(repository: repository);
});


// ============================================================================
// STREAM PROVIDERS
// ============================================================================

/// StreamProvider que emite las entidades y se actualiza automáticamente
/// Se actualiza cada 30 segundos para obtener nuevos datos de Firebase
final entitiesStreamProvider = StreamProvider<List<EntityEntity>>((ref) async* {
  final usecase = ref.watch(getAllEntitiesUsecaseProvider);

  // Carga inicial
  final result = await usecase.call();
  yield result.fold(
    (error) => <EntityEntity>[],
    (entities) => entities,
  );

  // Actualización periódica cada 30 segundos
  await for (final _ in Stream.periodic(const Duration(seconds: 30))) {
    final newResult = await usecase.call();
    yield newResult.fold(
      (error) => <EntityEntity>[],
      (entities) => entities,
    );
  }
});
