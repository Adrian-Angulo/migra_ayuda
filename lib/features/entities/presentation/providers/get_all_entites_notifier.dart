import 'dart:async';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:migra_ayuda/features/entities/domain/entities/entity_entity.dart';
import 'package:migra_ayuda/features/entities/presentation/providers/entity_providers.dart';



class GetAllEntitesNotifier extends AsyncNotifier<List<EntityEntity>> {
  @override
  FutureOr<List<EntityEntity>> build() async {
    return await _cargar();
  }

  Future<List<EntityEntity>> _cargar() async {
    final usecase = ref.read(getAllEntitiesUsecaseProvider);
    final result = await usecase();

    // Manejar el Either - si es Left (error), lanzar excepción
    return result.fold(
      (error) => throw Exception(error),
      (entities) => entities,
    );
  }

  Future<void> recargar() async {
    state = const AsyncLoading();
    state = await AsyncValue.guard(() => _cargar());
  }
}

final getAllEntitiesNotifierProvider =
    AsyncNotifierProvider<GetAllEntitesNotifier, List<EntityEntity>>(
      GetAllEntitesNotifier.new,
    );
