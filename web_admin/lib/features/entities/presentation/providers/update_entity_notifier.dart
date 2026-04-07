import 'dart:async';
import 'dart:typed_data';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:migra_ayuda_administracion/features/entities/data/datasources/entity_remote_datasource.dart';
import 'package:migra_ayuda_administracion/features/entities/data/repositories/entity_repository_impl.dart';
import 'package:migra_ayuda_administracion/features/entities/domain/entities/entity_entity.dart';
import 'package:migra_ayuda_administracion/features/entities/domain/usecases/update_entity_usecase.dart';

final updateEntityUsecaseProvider = Provider((ref) {
  final datasource = EntityRemoteDatasource();
  final repository = EntityRepositoryImpl(datasource);
  return UpdateEntityUsecase(repository: repository);
});

class UpdateEntityNotifier extends AsyncNotifier<void> {
  @override
  FutureOr<void> build() {}

  Future<void> actualizar({
    required EntityEntity entity,
    Uint8List? imagenBytes,
    String? fileName,
  }) async {
    state = const AsyncLoading();

    state = await AsyncValue.guard(() async {
      final usecase = ref.read(updateEntityUsecaseProvider);
      final result = await usecase(
        entity: entity,
        imagenBytes: imagenBytes,
        fileName: fileName,
      );

      // Manejar el Either - si es Left (error), lanzar excepción
      result.fold((error) => throw Exception(error), (success) => null);
    });
  }
}

final updateEntityNotifierProvider =
    AsyncNotifierProvider<UpdateEntityNotifier, void>(UpdateEntityNotifier.new);
