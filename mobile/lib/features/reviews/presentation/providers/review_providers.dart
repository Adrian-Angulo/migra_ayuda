import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:migra_ayuda/core/database/sembast_database.dart';
import 'package:migra_ayuda/core/network/network_provider.dart';
import 'package:migra_ayuda/features/reviews/data/datasources/review_local_datasource.dart';
import 'package:migra_ayuda/features/reviews/data/datasources/review_remote_datasource.dart';
import 'package:migra_ayuda/features/reviews/data/repositories/review_repository_impl.dart';
import 'package:migra_ayuda/features/reviews/domain/entities/review_entity.dart';
import 'package:migra_ayuda/features/reviews/domain/repositories/review_repository.dart';
import 'package:migra_ayuda/features/reviews/domain/usecases/create_review_usecase.dart';
import 'package:migra_ayuda/features/reviews/domain/usecases/delete_review_usecase.dart';
import 'package:migra_ayuda/features/reviews/domain/usecases/get_all_reviews_usecase.dart';
import 'package:migra_ayuda/features/reviews/domain/usecases/get_reviews_by_entity_usecase.dart';
import 'package:migra_ayuda/features/reviews/domain/usecases/update_review_usecase.dart';

// ============================================================================
// DATASOURCES PROVIDERS
// ============================================================================

/// Provider para el datasource remoto (Firebase)
final reviewRemoteDataSourceProvider = Provider<ReviewRemoteDataSource>((ref) {
  return ReviewRemoteDataSourceImpl(firestore: FirebaseFirestore.instance);
});

/// Provider para el datasource local (Sembast)
final reviewLocalDataSourceProvider = Provider<ReviewLocalDataSource>((ref) {
  final sembastDb = SembastDatabase.instance;
  return ReviewLocalDataSourceImpl(sembastDatabase: sembastDb);
});

// ============================================================================
// REPOSITORY PROVIDER
// ============================================================================

/// Provider para el repositorio de reviews con estrategia offline-first
final reviewRepositoryProvider = Provider<ReviewRepository>((ref) {
  final remoteDataSource = ref.watch(reviewRemoteDataSourceProvider);
  final localDataSource = ref.watch(reviewLocalDataSourceProvider);
  final networkInfo = ref.watch(networkInfoProvider);

  return ReviewRepositoryImpl(
    remoteDataSource: remoteDataSource,
    localDataSource: localDataSource,
    networkInfo: networkInfo,
  );
});

// ============================================================================
// USECASES PROVIDERS
// ============================================================================

/// Provider para el caso de uso: Crear review
final createReviewUsecaseProvider = Provider<CreateReviewUsecase>((ref) {
  final repository = ref.watch(reviewRepositoryProvider);
  return CreateReviewUsecase(repository: repository);
});

/// Provider para el caso de uso: Obtener reviews por entidad
final getReviewsByEntityUsecaseProvider =
    Provider<GetReviewsByEntityUsecase>((ref) {
  final repository = ref.watch(reviewRepositoryProvider);
  return GetReviewsByEntityUsecase(repository: repository);
});

/// Provider para el caso de uso: Obtener todas las reviews
final getAllReviewsUsecaseProvider = Provider<GetAllReviewsUsecase>((ref) {
  final repository = ref.watch(reviewRepositoryProvider);
  return GetAllReviewsUsecase(repository: repository);
});

/// Provider para el caso de uso: Actualizar review
final updateReviewUsecaseProvider = Provider<UpdateReviewUsecase>((ref) {
  final repository = ref.watch(reviewRepositoryProvider);
  return UpdateReviewUsecase(repository: repository);
});

/// Provider para el caso de uso: Eliminar review
final deleteReviewUsecaseProvider = Provider<DeleteReviewUsecase>((ref) {
  final repository = ref.watch(reviewRepositoryProvider);
  return DeleteReviewUsecase(repository: repository);
});

// ============================================================================
// STREAM PROVIDERS
// ============================================================================

/// StreamProvider que emite las reviews de una entidad específica
/// Se actualiza automáticamente cada 30 segundos
///
/// Uso: ref.watch(reviewsByEntityStreamProvider('entity-id'))
final reviewsByEntityStreamProvider =
    StreamProvider.family<List<ReviewEntity>, String>((ref, entityId) async* {
  final usecase = ref.watch(getReviewsByEntityUsecaseProvider);

  // Carga inicial
  final result = await usecase.call(entityId);
  yield result.fold(
    (error) => <ReviewEntity>[],
    (reviews) => reviews,
  );

  // Actualización periódica cada 30 segundos
  await for (final _ in Stream.periodic(const Duration(seconds: 30))) {
    final newResult = await usecase.call(entityId);
    yield newResult.fold(
      (error) => <ReviewEntity>[],
      (reviews) => reviews,
    );
  }
});

/// StreamProvider que emite todas las reviews del sistema
/// Se actualiza automáticamente cada 30 segundos
/// Útil para administración o estadísticas
final allReviewsStreamProvider =
    StreamProvider<List<ReviewEntity>>((ref) async* {
  final usecase = ref.watch(getAllReviewsUsecaseProvider);

  // Carga inicial
  final result = await usecase.call();
  yield result.fold(
    (error) => <ReviewEntity>[],
    (reviews) => reviews,
  );

  // Actualización periódica cada 30 segundos
  await for (final _ in Stream.periodic(const Duration(seconds: 30))) {
    final newResult = await usecase.call();
    yield newResult.fold(
      (error) => <ReviewEntity>[],
      (reviews) => reviews,
    );
  }
});

// ============================================================================
// STATE PROVIDERS
// ============================================================================

/// Provider para calcular el rating promedio de una entidad
///
/// Uso: ref.watch(averageRatingProvider('entity-id'))
final averageRatingProvider = Provider.family<double, String>((ref, entityId) {
  final reviewsAsync = ref.watch(reviewsByEntityStreamProvider(entityId));

  return reviewsAsync.when(
    data: (reviews) {
      if (reviews.isEmpty) return 0.0;

      final totalRating = reviews.fold<double>(
        0.0,
        (sum, review) => sum + review.rating,
      );

      return totalRating / reviews.length;
    },
    loading: () => 0.0,
    error: (_, __) => 0.0,
  );
});

/// Provider para contar el número de reviews de una entidad
///
/// Uso: ref.watch(reviewCountProvider('entity-id'))
final reviewCountProvider = Provider.family<int, String>((ref, entityId) {
  final reviewsAsync = ref.watch(reviewsByEntityStreamProvider(entityId));

  return reviewsAsync.when(
    data: (reviews) => reviews.length,
    loading: () => 0,
    error: (_, __) => 0,
  );
});

/// Provider para obtener la distribución de ratings de una entidad
/// Retorna un Map con el conteo de cada rating (1-5)
///
/// Uso: ref.watch(ratingDistributionProvider('entity-id'))
final ratingDistributionProvider =
    Provider.family<Map<int, int>, String>((ref, entityId) {
  final reviewsAsync = ref.watch(reviewsByEntityStreamProvider(entityId));

  return reviewsAsync.when(
    data: (reviews) {
      final distribution = <int, int>{
        1: 0,
        2: 0,
        3: 0,
        4: 0,
        5: 0,
      };

      for (final review in reviews) {
        final rating = review.rating.round();
        distribution[rating] = (distribution[rating] ?? 0) + 1;
      }

      return distribution;
    },
    loading: () => {1: 0, 2: 0, 3: 0, 4: 0, 5: 0},
    error: (_, __) => {1: 0, 2: 0, 3: 0, 4: 0, 5: 0},
  );
});
