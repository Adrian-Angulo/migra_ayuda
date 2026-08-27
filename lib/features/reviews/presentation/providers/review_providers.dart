import 'dart:async';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_riverpod/legacy.dart';
import 'package:migra_ayuda/core/constants/activity_actions.dart';
import 'package:migra_ayuda/core/config/sembast_database.dart';
import 'package:migra_ayuda/core/network/network_provider.dart';
import 'package:migra_ayuda/features/entities/presentation/providers/entity_crud_providers.dart';
import 'package:migra_ayuda/features/reviews/data/datasources/review_local_datasource.dart';
import 'package:migra_ayuda/features/reviews/domain/entities/review_entity.dart';
import 'package:migra_ayuda/features/reviews/domain/repositories/review_repository.dart';
import 'package:migra_ayuda/features/audit/presentation/providers/audit_providers.dart';
import '../../data/datasources/review_remote_datasource.dart';
import '../../data/repositories/review_repository_impl.dart';

final reviewRepositoryProvider = Provider<ReviewRepository>((ref) {
  final remoteDatasource = ReviewRemoteDataSource();
  final localDatasource =
      ReviewLocalDataSource(sembastDatabase: SembastDatabase.instance);
  final networkInfo = ref.watch(networkInfoProvider);

  return ReviewRepositoryImpl(
      remoteDataSource: remoteDatasource,
      localDataSource: localDatasource,
      networkInfo: networkInfo);
});

/// Provider que obtiene la lista de reviews asociadas a una entidad específica.
/// Utiliza FutureProvider.autoDispose.family para recibir el ID de la entidad como parámetro (entityId).
/// Los resultados se ordenan de más reciente a más antiguo según el campo 'createdAt'.
final getReviewsByEntity =
    FutureProvider.autoDispose.family<List<ReviewEntity>, String>(
  (ref, entityId) async {
    // Se obtiene el repositorio de reviews usando Riverpod
    final repo = ref.watch(reviewRepositoryProvider);

    // Se obtienen las reviews asociadas a la entidad cuyo id es 'entityId'
    final reviews = await repo.getReviewsByEntity(entityId);

    // Se devuelve la lista ordenada por fecha de creación descendente (más reciente primero)
    return reviews.toList()..sort((a, b) => b.createdAt.compareTo(a.createdAt));
  },
);

// Provider que calcula el promedio ('mean') y la cantidad ('count') de reviews de una entidad específica.
// Utiliza el provider 'getReviewsByEntity' para obtener la lista de reviews de la entidad.
final meanReviewByEntity =
    FutureProvider.autoDispose.family<Map<String, dynamic>, String>(
  (ref, idEntity) async {
    // Espera a que se carguen las reviews de la entidad
    final reviews = await ref.watch(getReviewsByEntity(idEntity).future);

    // Si no hay reviews, retorna promedio 0.0 y cantidad 0
    if (reviews.isEmpty) return {'mean': 0.0, 'count': 0.0};
    
    // Calcula la sumatoria del rating de todas las reviews
    final total = reviews.fold<double>(0.0, (sum, r) => sum + r.rating);
    
    // Retorna un mapa con el promedio y el conteo de reviews
    return {
      // El promedio es el total dividido entre la cantidad de reviews, con un decimal
      'mean': (total / reviews.length).toDouble().toStringAsFixed(1),
      'count': reviews.length
    };
  },
);

enum ReviewState {
  initial,
  creating,
  updating,
  deleting,
}

final reviewNotifierProvider =
    AsyncNotifierProvider<ReviewsNotifier, ReviewState>(ReviewsNotifier.new);

class ReviewsNotifier extends AsyncNotifier<ReviewState> {
  @override
  FutureOr<ReviewState> build() {
    return ReviewState.initial;
  }

  Future<void> createReview(ReviewEntity review) async {
    state = const AsyncValue.loading();
    state = await AsyncValue.guard(() async {
      await ref.read(reviewRepositoryProvider).createReview(review);
      await ref.read(entitiesCrudProvider.notifier).actualizarTotalYPromedioEntidad(review.id);
      await ref
          .read(auditNotifierProvider.notifier)
          .create(accion: ActivityActions.addComment());
      
      ref.invalidate(getReviewsByEntity(review.idEntity));
      return ReviewState.creating;
    });
  }

  Future<void> updateReview(ReviewEntity review) async {
    state = const AsyncValue.loading();
    state = await AsyncValue.guard(() async {
      await ref.read(reviewRepositoryProvider).updateReview(review);
      await ref
          .read(auditNotifierProvider.notifier)
          .create(accion: ActivityActions.updateComment());
      ref.invalidate(getReviewsByEntity(review.idEntity));
      return ReviewState.updating;
    });
  }

  Future<void> deleteReview(ReviewEntity review) async {
    state = const AsyncValue.loading();
    state = await AsyncValue.guard(() async {
      await ref.read(reviewRepositoryProvider).deleteReview(review.id);
      await ref
          .read(auditNotifierProvider.notifier)
          .create(accion: ActivityActions.deleteComment());
      ref.invalidate(getReviewsByEntity(review.idEntity));
      return ReviewState.deleting;
    });
  }
}

// ---------------------------------------------------------------------------
// Providers para la tabla web de reseñas
// ---------------------------------------------------------------------------

/// Texto de búsqueda ingresado en la barra de la tabla
final queryReviewProvider = StateProvider<String>((ref) => '');

/// Todas las reseñas sin filtro de entidad (para la vista web admin)
final getAllReviewsProvider =
    FutureProvider.autoDispose<List<ReviewEntity>>((ref) {
  return ref.watch(reviewRepositoryProvider).getAllReviews();
});

/// Lista de reseñas filtrada según [queryReviewProvider]
/// Provider para obtener la lista filtrada de reseñas según el texto de búsqueda.
/// Utiliza el valor de [queryReviewProvider] para filtrar la lista traida por [getAllReviewsProvider].
final reviewsFilterProvider =
    StateProvider.autoDispose<AsyncValue<List<ReviewEntity>>>((ref) {
  // Obtiene el texto de búsqueda actual
  final query = ref.watch(queryReviewProvider);
  // Obtiene el estado (cargando, error o datos) de la lista de todas las reseñas
  final reviews = ref.watch(getAllReviewsProvider);

  // Maneja los diferentes estados del proveedor de reseñas
  return reviews.when(
    data: (reviewsList) {
      // Por defecto todas las reseñas
      List<ReviewEntity> filteredReviews = reviewsList;
      // Si hay texto de búsqueda, filtra la lista
      if (query.isNotEmpty) {
        filteredReviews = reviewsList
            .where((r) =>
                // Filtra por nombre de usuario
                r.userName.toLowerCase().contains(query.toLowerCase()) ||
                // Filtra por nombre de la entidad
                r.nameEntity.toLowerCase().contains(query.toLowerCase()) ||
                // Filtra por país del usuario
                r.userCountry.toLowerCase().contains(query.toLowerCase()))
            .toList();
      }
      // Retorna la lista filtrada envuelta en un AsyncValue.data
      return AsyncValue.data(filteredReviews);
    },
    // Si hay error al cargar las reseñas
    error: (error, stackTrace) => AsyncValue.error(error, stackTrace),
    // Si las reseñas están cargando
    loading: () => const AsyncValue.loading(),
  );
});
