import 'dart:async';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:migra_ayuda/core/constants/activity_actions.dart';
import 'package:migra_ayuda/core/config/sembast_database.dart';
import 'package:migra_ayuda/core/network/network_provider.dart';
import 'package:migra_ayuda/features/reviews/data/datasources/review_local_datasource.dart';
import 'package:migra_ayuda/features/reviews/domain/entities/review_entity.dart';
import 'package:migra_ayuda/features/reviews/domain/repositories/review_repository.dart';
import 'package:migra_ayuda/features/userActivity/presentation/providers/activities_providers.dart';
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

final getReviewsByEntity =
    FutureProvider.autoDispose.family<List<ReviewEntity>, String>(
  (ref, entityId) async {
    final repo = ref.watch(reviewRepositoryProvider);
    final reviews = await repo.getReviewsByEntity(entityId);

    return reviews.toList()..sort((a, b) => b.createdAt.compareTo(a.createdAt));
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
      await ref
          .read(activityProvider.notifier)
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
          .read(activityProvider.notifier)
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
          .read(activityProvider.notifier)
          .create(accion: ActivityActions.deleteComment());
      ref.invalidate(getReviewsByEntity(review.idEntity));
      return ReviewState.deleting;
    });
  }
}
