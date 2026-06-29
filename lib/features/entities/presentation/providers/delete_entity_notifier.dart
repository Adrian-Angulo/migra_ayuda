import 'dart:async';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:migra_ayuda/features/entities/presentation/providers/entity_providers.dart';




class DeleteEntityNotifier extends AsyncNotifier<void> {
  @override
  FutureOr<void> build() {}

  Future<void> eliminar(String entityId) async {
    state = const AsyncLoading();

    state = await AsyncValue.guard(() async {
      final usecase = ref.read(deleteEntityUsecaseProvider);
      final result = await usecase(entityId);

      // Manejar el Either - si es Left (error), lanzar excepción
      result.fold((error) => throw Exception(error), (success) => null);
    });
  }
}

final deleteEntityNotifierProvider =
    AsyncNotifierProvider<DeleteEntityNotifier, void>(DeleteEntityNotifier.new);
