import 'dart:async';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_riverpod/legacy.dart';
import 'package:migra_ayuda/core/config/sembast_database.dart';
import 'package:migra_ayuda/core/network/network_provider.dart';
import 'package:migra_ayuda/features/entities/data/datasources/entity_local_datasource.dart';
import 'package:migra_ayuda/features/entities/data/datasources/entity_remote_datasource.dart';
import 'package:migra_ayuda/features/entities/data/repositories/entity_mobil_repository_impl.dart';
import 'package:migra_ayuda/features/entities/data/repositories/entity_web_repository_impl.dart';
import 'package:migra_ayuda/features/entities/domain/entities/entity_entity.dart';
import 'package:migra_ayuda/features/entities/domain/repositories/entity_repository.dart';

/// Provider para el datasource remoto (Firebase)
final entityRemoteDataSourceProvider = Provider<EntityRemoteDataSource>((ref) {
  return EntityRemoteDataSource(firestore: FirebaseFirestore.instance);
});

/// Provider para el datasource local (Sembast)
final entityLocalDataSourceProvider = Provider<EntityLocalDataSource>((ref) {
  final sembastDb = SembastDatabase.instance;
  return EntityLocalDataSource(sembastDatabase: sembastDb);
});

/// Provider del repositorio de entidades.
/// Usa la implementación web o mobile según la plataforma.
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

/// StreamProvider que emite la lista de entidades y se actualiza cada 30s.
final entities2StreamProvider = StreamProvider<List<EntityEntity>>(
  (ref) {
    final repo = ref.watch(entityRepositoryProvider);
    final res = repo.getAllEntites2();
    return res.map((either) => either.fold(
          (error) => throw Exception(error),
          (entities) => entities,
        ));
  },
);


final filterProvider = StateProvider<String>(
  (ref) => 'Todos',
);

class EntityListNotifier extends AsyncNotifier<List<EntityEntity>> {
  List<EntityEntity> _allEntities = [];

  @override
  FutureOr<List<EntityEntity>> build() {
    return _loadEntities();
  }

  Future<List<EntityEntity>> _loadEntities() async {
    state = const AsyncValue.loading();
    final result = await ref.read(entityRepositoryProvider).getAllEntities();

    return result.fold(
      (error) => throw error,
      (entities) {
        _allEntities = entities;
        return entities;
      },
    );
  }

  Future<void> refresh() async {
    state = const AsyncLoading();
    state = await AsyncValue.guard(_loadEntities);
  }

  void filter({String query = 'Todos'}) {
    ref.read(filterProvider.notifier).state = query;
    if (query == 'Todos') {
      state = AsyncValue.data(_allEntities);
      return;
    }

    final filtered = _allEntities.where((entity) {
      return entity.services.any(
        (s) => s == query,
      );
    }).toList();

    state = AsyncValue.data(filtered);
  }
}

final getAllEntitiesProvider =
    AsyncNotifierProvider<EntityListNotifier, List<EntityEntity>>(
        EntityListNotifier.new);
