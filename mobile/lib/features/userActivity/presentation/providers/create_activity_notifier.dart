import 'dart:async';

import 'package:dartz/dartz.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:migra_ayuda/features/userActivity/domain/entities/user_activity_entity.dart';
import 'package:migra_ayuda/features/userActivity/presentation/providers/user_activity_providers.dart';

class CreateActivityNotifier extends AsyncNotifier<void> {
  @override
  FutureOr<void> build() {}

  Future<void> createActivity(
      {required String user, required String accion}) async {
    final usecase = ref.read(createActivityUsecaseProvider);

    state = const AsyncValue.loading();
    state = await AsyncValue.guard(() async {
      final userActivity =
          UserActivityEntity(id: "", idUser: user, accion: accion,);
      final result = await usecase(userActivity);
      result.fold(
        (failure) {
          debugPrint("error al registrar auditoria inicio de sesion");
          return AsyncValue.error(failure, StackTrace.current);
        },
        (_) {
          debugPrint("Auditoria: iniciar secion");
          return const AsyncValue.data(Right);
        },
      );
    });
  }
}

final createActivityNotifier =
    AsyncNotifierProvider<CreateActivityNotifier, void>(
        CreateActivityNotifier.new);
