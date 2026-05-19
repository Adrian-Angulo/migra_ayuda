import 'package:dartz/dartz.dart';
import 'package:migra_ayuda/features/userActivity/domain/entities/user_activity_entity.dart';
import 'package:migra_ayuda/features/userActivity/domain/failures/activity_failure.dart';

abstract class UserActivityRepository {
  Future<Either<ActivityFailure, Unit>> createActivity(
      UserActivityEntity activity);

  /// Sincroniza las actividades pendientes con Firebase
  Future<Either<ActivityFailure, Unit>> syncPendingActivities();

  /// Obtiene todas las actividades (no implementado)
  Future<Either<ActivityFailure, List<UserActivityEntity>>> getAllActivity();
}
