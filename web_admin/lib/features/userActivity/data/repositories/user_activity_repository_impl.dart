import 'package:dartz/dartz.dart';
import 'package:migra_ayuda_administracion/features/userActivity/data/datasources/user_activity_remote_datasource.dart';
import 'package:migra_ayuda_administracion/features/userActivity/domain/entities/user_activity_entity.dart';
import 'package:migra_ayuda_administracion/features/userActivity/domain/failures/activity_failure.dart';
import 'package:migra_ayuda_administracion/features/userActivity/domain/repositories/user_activity_repository.dart';

class UserActivityRepositoryImpl implements UserActivityRepository {
  final UserActivityRemoteDataSource remoteDataSource;

  UserActivityRepositoryImpl({required this.remoteDataSource});

  @override
  Future<Either<ActivityFailure, List<UserActivityEntity>>>
  getAllActivity() async {
    try {
      final activities = await remoteDataSource.getActivities();
      return Right(activities);
    } catch (e) {
      return Left(ServerFailure('Error al obtener actividades: $e'));
    }
  }
}
