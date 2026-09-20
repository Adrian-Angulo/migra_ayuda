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

final entityRemoteDataSourceProvider = Provider<EntityRemoteDataSource>((ref) {
  return EntityRemoteDataSource(firestore: FirebaseFirestore.instance);
});


final entityLocalDataSourceProvider = Provider<EntityLocalDataSource>((ref) {
  final sembastDb = SembastDatabase.instance;
  return EntityLocalDataSource(sembastDatabase: sembastDb);
});

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


final entities2StreamProvider = StreamProvider<List<EntityEntity>>(
  (ref) {
    final repo = ref.watch(entityRepositoryProvider);
    return repo.getAllEntites2();
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
      (failure) => throw failure,
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
      state = AsyncValue.data(List<EntityEntity>.from(_allEntities));
      return;
    }

    final cleanQuery = query.trim().toLowerCase();
    final filtered = _allEntities.where((entity) {
      return entity.services.any(
        (s) => s.trim().toLowerCase() == cleanQuery,
      );
    }).toList();

    state = AsyncValue.data(filtered);
  }
}

final getAllEntitiesProvider =
    AsyncNotifierProvider<EntityListNotifier, List<EntityEntity>>(
        EntityListNotifier.new);
