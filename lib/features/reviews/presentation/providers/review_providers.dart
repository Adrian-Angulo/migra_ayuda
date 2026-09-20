import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_riverpod/legacy.dart';
import 'package:migra_ayuda/core/constants/activity_actions.dart';
import 'package:migra_ayuda/core/config/sembast_database.dart';
import 'package:migra_ayuda/core/network/network_provider.dart';
import 'package:migra_ayuda/features/entities/presentation/providers/entity_crud_providers.dart';
import 'package:migra_ayuda/features/entities/presentation/providers/entity_providers.dart';
import 'package:migra_ayuda/features/reviews/data/datasources/review_local_datasource.dart';
import 'package:migra_ayuda/features/reviews/domain/entities/review_entity.dart';
import 'package:migra_ayuda/features/reviews/domain/repositories/review_repository.dart';
import 'package:migra_ayuda/features/audit/presentation/providers/audit_providers.dart';
import '../../data/datasources/review_remote_datasource.dart';
import '../../data/repositories/review_repository_impl.dart';
import 'package:migra_ayuda/features/reviews/domain/usecases/review_usecases.dart';

enum ReviewState {
  initial,
  creating,
  updating,
  deleting,
}


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

// Use Case Providers
final createReviewUseCaseProvider = Provider<CreateReviewUseCase>(
  (ref) => CreateReviewUseCase(ref.watch(reviewRepositoryProvider)),
);

final getReviewsByEntityUseCaseProvider = Provider<GetReviewsByEntityUseCase>(
  (ref) => GetReviewsByEntityUseCase(ref.watch(reviewRepositoryProvider)),
);

final getAllReviewsUseCaseProvider = Provider<GetAllReviewsUseCase>(
  (ref) => GetAllReviewsUseCase(ref.watch(reviewRepositoryProvider)),
);

final updateReviewUseCaseProvider = Provider<UpdateReviewUseCase>(
  (ref) => UpdateReviewUseCase(ref.watch(reviewRepositoryProvider)),
);

final deleteReviewUseCaseProvider = Provider<DeleteReviewUseCase>(
  (ref) => DeleteReviewUseCase(ref.watch(reviewRepositoryProvider)),
);

final getUserReviewByEntityUseCaseProvider =
    Provider<GetUserReviewByEntityUseCase>(
  (ref) => GetUserReviewByEntityUseCase(ref.watch(reviewRepositoryProvider)),
);

final syncPendingReviewsUseCaseProvider = Provider<SyncPendingReviewsUseCase>(
  (ref) => SyncPendingReviewsUseCase(ref.watch(reviewRepositoryProvider)),
);

// FutureProvider para reviews de una entidad usando usecase provider
final getReviewsByEntity =
    FutureProvider.autoDispose.family<List<ReviewEntity>, String>(
  (ref, entityId) async {
    final useCase = ref.watch(getReviewsByEntityUseCaseProvider);
    final result = await useCase(entityId);
    return result.fold(
      (failure) => throw failure,
      (reviews) =>
          reviews.toList()..sort((a, b) => b.createdAt.compareTo(a.createdAt)),
    );
  },
);

final meanReviewByEntity =
    FutureProvider.autoDispose.family<Map<String, dynamic>, String>(
  (ref, idEntity) async {
    final reviews = await ref.watch(getReviewsByEntity(idEntity).future);

    if (reviews.isEmpty) return {'mean': 0.0, 'count': 0.0};

    final total = reviews.fold<double>(0.0, (sum, r) => sum + r.rating);
    return {
      'mean': (total / reviews.length).toDouble().toStringAsFixed(1),
      'count': reviews.length
    };
  },
);

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
      final createReview = ref.read(createReviewUseCaseProvider);
      final result = await createReview(review);
      return result.fold(
        (failure) => throw failure,
        (_) async {
          try {
            await ref
                .read(entitiesCrudProvider.notifier)
                .actualizarTotalYPromedioEntidad(review.idEntity);
          } catch (e) {
            debugPrint('⚠️ Error actualizando total y promedio de entidad: $e');
          }
          try {
            await ref
                .read(auditNotifierProvider.notifier)
                .create(accion: ActivityActions.addComment());
          } catch (e) {
            debugPrint('⚠️ Error creando registro de auditoría: $e');
          }
          ref.invalidate(getReviewsByEntity(review.idEntity));
          ref.invalidate(getAllEntitiesProvider);
          return ReviewState.creating;
        },
      );
    });
  }

  Future<void> updateReview(ReviewEntity review) async {
    state = const AsyncValue.loading();
    state = await AsyncValue.guard(() async {
      final updateReview = ref.read(updateReviewUseCaseProvider);
      final result = await updateReview(review);
      return result.fold(
        (failure) => throw failure,
        (_) async {
          try {
            await ref
                .read(entitiesCrudProvider.notifier)
                .actualizarTotalYPromedioEntidad(review.idEntity);
          } catch (e) {
            debugPrint('⚠️ Error actualizando total y promedio de entidad: $e');
          }

          try {
            await ref
                .read(auditNotifierProvider.notifier)
                .create(accion: ActivityActions.updateComment());
          } catch (e) {
            debugPrint('⚠️ Error creando registro de auditoría: $e');
          }

          ref.invalidate(getReviewsByEntity(review.idEntity));
          ref.invalidate(getAllEntitiesProvider);
          return ReviewState.updating;
        },
      );
    });
  }

  Future<void> deleteReview(ReviewEntity review) async {
    state = const AsyncValue.loading();
    state = await AsyncValue.guard(() async {
      final deleteReview = ref.read(deleteReviewUseCaseProvider);
      final result = await deleteReview(review.id);
      return result.fold(
        (failure) => throw failure,
        (_) async {
          try {
            await ref
                .read(entitiesCrudProvider.notifier)
                .actualizarTotalYPromedioEntidad(review.idEntity);
          } catch (e) {
            debugPrint('⚠️ Error actualizando total y promedio de entidad: $e');
          }

          try {
            await ref
                .read(auditNotifierProvider.notifier)
                .create(accion: ActivityActions.deleteComment());
          } catch (e) {
            debugPrint('⚠️ Error creando registro de auditoría: $e');
          }

          ref.invalidate(getReviewsByEntity(review.idEntity));
          ref.invalidate(getAllEntitiesProvider);
          return ReviewState.deleting;
        },
      );
    });
  }
}


final queryReviewProvider = StateProvider<String>((ref) => '');

final getAllReviewsProvider =
    FutureProvider.autoDispose<List<ReviewEntity>>((ref) async {
  final useCase = ref.watch(getAllReviewsUseCaseProvider);
  final result = await useCase();
  return result.fold(
    (failure) => throw failure,
    (reviews) => reviews,
  );
});

final reviewsFilterProvider =
    StateProvider.autoDispose<AsyncValue<List<ReviewEntity>>>((ref) {
  final query = ref.watch(queryReviewProvider);
  final reviews = ref.watch(getAllReviewsProvider);

  return reviews.when(
    data: (reviewsList) {
      List<ReviewEntity> filteredReviews = reviewsList;
      if (query.isNotEmpty) {
        filteredReviews = reviewsList
            .where((r) =>
                r.userName.toLowerCase().contains(query.toLowerCase()) ||
                r.nameEntity.toLowerCase().contains(query.toLowerCase()) ||
                r.userCountry.toLowerCase().contains(query.toLowerCase()))
            .toList();
      }
      return AsyncValue.data(filteredReviews);
    },
    error: (error, stackTrace) => AsyncValue.error(error, stackTrace),
    loading: () => const AsyncValue.loading(),
  );
});
