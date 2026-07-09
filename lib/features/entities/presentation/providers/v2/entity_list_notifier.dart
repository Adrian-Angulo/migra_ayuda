import 'dart:async';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:migra_ayuda/features/entities/domain/entities/entity_entity.dart';
import 'package:migra_ayuda/features/entities/presentation/providers/entity_providers.dart';

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
    if (query == 'Todos') {
      state = AsyncValue.data(_allEntities);
      return;
    }

    final lowerQuery = query.toLowerCase();
    final filtered = _allEntities.where((entity) {
      return entity.services.any(
        (s) => s == lowerQuery,
      );
    }).toList();

    state = AsyncValue.data(filtered);
  }
}

final getAllEntitiesProvider =
    AsyncNotifierProvider<EntityListNotifier, List<EntityEntity>>(
        EntityListNotifier.new);
