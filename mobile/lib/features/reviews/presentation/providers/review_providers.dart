import 'dart:async';

import 'package:dartz/dartz.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:migra_ayuda/core/database/sembast_database.dart';
import 'package:migra_ayuda/core/network/network_provider.dart';
import 'package:migra_ayuda/features/reviews/data/datasources/review_local_datasource.dart';
import 'package:migra_ayuda/features/reviews/domain/entities/review_entity.dart';
import 'package:migra_ayuda/features/reviews/domain/repositories/review_repository.dart';
import '../../data/datasources/review_remote_datasource.dart';
import '../../data/repositories/review_repository_impl.dart';

final reviewLocaldatabase = Provider(
  (ref) => ReviewLocalDataSourceImpl(sembastDatabase: SembastDatabase.instance),
);

final reviewRepositoryProvider = Provider<ReviewRepository>((ref) {
  final remoteDatasource = ReviewRemoteDataSourceImpl();
  final localDatasource = ref.watch(reviewLocaldatabase);
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
    final result = await repo.getReviewsByEntity(entityId);

    return result.fold(
      (error) => throw error,
      (reviews) => reviews,
    );
  },
);

final reviewNotifierProvider =
    AsyncNotifierProvider<ReviewsNotifier, void>(ReviewsNotifier.new);

class ReviewsNotifier extends AsyncNotifier<void> {
  @override
  FutureOr<void> build() {}

  Future<void> createReview(ReviewEntity review) async {
    state = const AsyncValue.loading();
    final repo = ref.read(reviewRepositoryProvider);
    final result = await repo.createReview(review);
    result.fold(
      (failure) {
        state = AsyncValue.error(failure, StackTrace.current);
      },
      (createdReview) {
        state = const AsyncValue.data(null);
        ref.invalidate(getReviewsByEntity);
      },
    );
  }

  Future<void> updateReview(ReviewEntity review) async {
    state = const AsyncValue.loading();
    final repo = ref.read(reviewRepositoryProvider);
    final result = await repo.updateReview(review);
    result.fold(
      (failure) {
        state = AsyncValue.error(failure, StackTrace.current);
      },
      (updatedReview) {
        state = const AsyncValue.data(null);
      },
    );
  }

  Future<void> deleteReview(String reviewId) async {
    state = const AsyncValue.loading();
    final repo = ref.read(reviewRepositoryProvider);
    final result = await repo.deleteReview(reviewId);
    result.fold(
      (failure) {
        state = AsyncValue.error(failure, StackTrace.current);
      },
      (_) {
        state = const AsyncValue.data(null);
      },
    );
  }
}
