import 'dart:async';
import 'dart:typed_data';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:migra_ayuda_administracion/features/entities/data/datasources/entity_remote_datasource.dart';
import 'package:migra_ayuda_administracion/features/entities/data/repositories/entity_repository_impl.dart';
import 'package:migra_ayuda_administracion/features/entities/domain/entities/entity_entity.dart';
import 'package:migra_ayuda_administracion/features/entities/domain/usecases/register_entity_usecase.dart';

final registerEntityUsecaseProvider = Provider((ref) {
  final datasource = EntityRemoteDatasource();
  final repository = EntityRepositoryImpl(datasource);
  return RegisterEntityUsecase(repository: repository);
});

class RegisterEntityNotifier extends AsyncNotifier<void> {
  @override
  FutureOr<void> build() {}

  Future<void> registrar({
    required EntityEntity entity,
    required Uint8List imagenBytes,
    required String fileName,
  }) async {
    state = const AsyncLoading();

    state = await AsyncValue.guard(() async {
      final usecase = ref.read(registerEntityUsecaseProvider);
      final result = await usecase(entity, imagenBytes, fileName);

      // Manejar el Either - si es Left (error), lanzar excepción
      result.fold((error) => throw Exception(error), (success) => null);
    });
  }
}

final registerEntityNotifierProvider =
    AsyncNotifierProvider<RegisterEntityNotifier, void>(
      RegisterEntityNotifier.new,
    );
