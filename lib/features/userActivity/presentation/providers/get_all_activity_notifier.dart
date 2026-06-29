import 'dart:async';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:migra_ayuda/features/userActivity/domain/entities/user_activity_entity.dart';
import 'package:migra_ayuda/features/userActivity/presentation/providers/user_activity_providers.dart';

/// Notifier para gestionar el estado de la lista de actividades de usuario
///
/// Este notifier:
/// - Carga automáticamente las actividades al inicializar
/// - Permite refrescar la lista manualmente
/// - Maneja estados de loading, error y data
class GetAllActivityNotifier extends AsyncNotifier<List<UserActivityEntity>> {
  @override
  Future<List<UserActivityEntity>> build() async {
    // Carga inicial de actividades
    return _fetchActivities();
  }

  /// Obtiene las actividades desde el repositorio
  Future<List<UserActivityEntity>> _fetchActivities() async {
    final usecase = ref.read(getAllActivityUsecaseProvider);
    final result = await usecase();

    return result.fold(
      (failure) => throw Exception(failure.toString()),
      (activities) => activities,
    );
  }

  /// Refresca la lista de actividades
  Future<void> refresh() async {
    state = const AsyncValue.loading();
    state = await AsyncValue.guard(() => _fetchActivities());
  }
}

/// Provider del notifier
final getAllActivityNotifierProvider =
    AsyncNotifierProvider<GetAllActivityNotifier, List<UserActivityEntity>>(
  GetAllActivityNotifier.new,
);
