import 'package:dartz/dartz.dart';
import 'package:migra_ayuda/features/userActivity/domain/entities/user_activity_entity.dart';
import 'package:migra_ayuda/features/userActivity/domain/failures/activity_failure.dart';
import 'package:migra_ayuda/features/userActivity/domain/repositories/user_activity_repository.dart';

/// Use case para obtener todas las actividades de usuario desde Firebase
///
/// Este use case se encarga de:
/// 1. Verificar si hay conexión a internet
/// 2. Obtener todas las actividades desde Firebase
/// 3. Retornar la lista ordenada por fecha (más recientes primero)
class GetAllActivityUsecase {
  final UserActivityRepository repository;

  GetAllActivityUsecase({required this.repository});

  /// Ejecuta la consulta de todas las actividades
  ///
  /// Retorna:
  /// - Right(List<UserActivityEntity>): Lista de actividades
  /// - Left(NetworkFailure): Sin conexión a internet
  /// - Left(ServerFailure): Error del servidor
  Future<Either<ActivityFailure, List<UserActivityEntity>>> call() async {
    return repository.getAllActivity();
  }
}
