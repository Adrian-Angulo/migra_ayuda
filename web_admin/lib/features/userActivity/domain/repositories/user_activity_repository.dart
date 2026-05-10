import 'package:dartz/dartz.dart';
import 'package:migra_ayuda_administracion/features/userActivity/domain/entities/user_activity_entity.dart';
import 'package:migra_ayuda_administracion/features/userActivity/domain/failures/activity_failure.dart';

abstract class UserActivityRepository {
  /// Obtiene todas las actividades de usuario
  Future<Either<ActivityFailure, List<UserActivityEntity>>> getAllActivity();
}
