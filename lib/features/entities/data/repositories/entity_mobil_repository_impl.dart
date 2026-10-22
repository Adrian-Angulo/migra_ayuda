import 'package:fpdart/fpdart.dart';
import 'package:migra_ayuda/core/errors/failure.dart';
import 'package:migra_ayuda/core/network/network_info.dart';
import 'package:migra_ayuda/features/entities/data/datasources/entity_local_datasource.dart';
import 'package:migra_ayuda/features/entities/data/datasources/entity_remote_datasource.dart';
import 'package:migra_ayuda/features/entities/data/mappers/entity_mappers.dart';
import 'package:migra_ayuda/features/entities/domain/entities/entity_entity.dart';
import 'package:migra_ayuda/features/entities/domain/failures/entity_failures.dart';
import 'package:migra_ayuda/features/entities/domain/repositories/entity_mobile_repository.dart';

class EntityMobilRepositoryImpl implements EntityMobileRepository {
  final EntityRemoteDataSource remoteDataSource;
  final EntityLocalDataSource localDataSource;
  final NetworkInfo networkInfo;

  EntityMobilRepositoryImpl({
    required this.remoteDataSource,
    required this.localDataSource,
    required this.networkInfo,
  });

  @override
  Future<Either<Failure, List<EntityEntity>>> getAllEntities() async {
    try {
      final cachedEntities = await localDataSource.getCachedEntities();
      if (cachedEntities.isNotEmpty) {
        final entityList =
            cachedEntities.map((model) => EntityMappers.toEntity(model)).toList();
        return Right(entityList);
      }

      // Si la base de datos local está vacía (primer inicio), consultar Firebase
      final isConnected = await networkInfo.isConnected;
      if (isConnected) {
        final remoteEntities = await remoteDataSource.getAllEntities();
        await localDataSource.cacheEntities(remoteEntities);
        final entityList =
            remoteEntities.map((model) => EntityMappers.toEntity(model)).toList();
        return Right(entityList);
      }

      return const Right([]);
    } catch (_) {
      return const Left(EntityFetchFailedFailure());
    }
  }

  @override
  Future<Either<Failure, void>> syncAllFromFirebase() async {
    final isConnected = await networkInfo.isConnected;
    if (!isConnected) {
      return const Left(NetworkFailure());
    }
    try {
      final remoteEntities = await remoteDataSource.getAllEntities();
      await localDataSource.clearCache();
      await localDataSource.cacheEntities(remoteEntities);
      return const Right(null);
    } catch (_) {
      return const Left(EntityFetchFailedFailure());
    }
  }
}
