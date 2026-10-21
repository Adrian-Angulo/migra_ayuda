import 'package:dartz/dartz.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:migra_ayuda/features/reviews/domain/entities/review_entity.dart';
import 'package:migra_ayuda/features/reviews/domain/failures/review_failures.dart';
import 'package:migra_ayuda/features/reviews/domain/repositories/review_repository.dart';
import 'package:migra_ayuda/features/reviews/domain/usecases/review_usecases.dart';
import 'package:mocktail/mocktail.dart';

class MockReviewRepository extends Mock implements ReviewRepository {}

void main() {
  late MockReviewRepository reviewRepositoryMock;

  final reviewExample = ReviewEntity(
    id: 'review-123',
    idMigrante: 'migrante-123',
    idEntity: 'entity-123',
    nameEntity: 'Cruz Roja',
    userName: 'Juan Perez',
    userCountry: 'Colombia',
    rating: 4.5,
    comment: 'Excelente servicio',
    isSynced: true,
  );

  setUpAll(() {
    registerFallbackValue(reviewExample);
  });

  setUp(() {
    reviewRepositoryMock = MockReviewRepository();
  });

  group('CreateReviewUseCase', () {
    late CreateReviewUseCase createReview;

    setUp(() {
      createReview = CreateReviewUseCase(reviewRepositoryMock);
    });

    test(
      'Exito: Devuelve Right(null) cuando la reseña se crea correctamente',
      () async {
        when(() => reviewRepositoryMock.createReview(reviewExample))
            .thenAnswer((_) async => const Right(null));

        final resultado = await createReview(reviewExample);

        expect(resultado, const Right(null));
        verify(() => reviewRepositoryMock.createReview(reviewExample)).called(1);
        verifyNoMoreInteractions(reviewRepositoryMock);
      },
    );

    test(
      'Error: Devuelve Left(ReviewCreationFailedFailure) cuando ocurre un fallo en la creación',
      () async {
        when(() => reviewRepositoryMock.createReview(any())).thenAnswer(
          (_) async => const Left(ReviewCreationFailedFailure()),
        );

        final resultado = await createReview(reviewExample);

        expect(resultado, const Left(ReviewCreationFailedFailure()));
        verify(() => reviewRepositoryMock.createReview(reviewExample)).called(1);
        verifyNoMoreInteractions(reviewRepositoryMock);
      },
    );
  });

  group('GetReviewsByEntityUseCase', () {
    late GetReviewsByEntityUseCase getReviewsByEntity;

    setUp(() {
      getReviewsByEntity = GetReviewsByEntityUseCase(reviewRepositoryMock);
    });

    test(
      'Exito: Devuelve una lista de reseñas asociadas a una entidad',
      () async {
        when(() => reviewRepositoryMock.getReviewsByEntity('entity-123'))
            .thenAnswer((_) async => Right([reviewExample]));

        final resultado = await getReviewsByEntity('entity-123');

        expect(resultado, isA<Right>());
        resultado.fold(
          (_) => fail('Se esperaba Right con reseñas'),
          (reviews) {
            expect(reviews.length, 1);
            expect(reviews.first.id, 'review-123');
          },
        );
        verify(() => reviewRepositoryMock.getReviewsByEntity('entity-123'))
            .called(1);
        verifyNoMoreInteractions(reviewRepositoryMock);
      },
    );

    test(
      'Error: Devuelve Left(ReviewFetchFailedFailure) cuando ocurre un fallo al obtener las reseñas',
      () async {
        when(() => reviewRepositoryMock.getReviewsByEntity(any()))
            .thenAnswer((_) async => const Left(ReviewFetchFailedFailure()));

        final resultado = await getReviewsByEntity('entity-123');

        expect(resultado, const Left(ReviewFetchFailedFailure()));
        verify(() => reviewRepositoryMock.getReviewsByEntity('entity-123'))
            .called(1);
        verifyNoMoreInteractions(reviewRepositoryMock);
      },
    );
  });

  group('GetAllReviewsUseCase', () {
    late GetAllReviewsUseCase getAllReviews;

    setUp(() {
      getAllReviews = GetAllReviewsUseCase(reviewRepositoryMock);
    });

    test(
      'Exito: Devuelve todas las reseñas disponibles',
      () async {
        when(() => reviewRepositoryMock.getAllReviews())
            .thenAnswer((_) async => Right([reviewExample]));

        final resultado = await getAllReviews();

        expect(resultado, isA<Right>());
        resultado.fold(
          (_) => fail('Se esperaba Right con las reseñas'),
          (reviews) {
            expect(reviews.length, 1);
            expect(reviews.first.id, 'review-123');
          },
        );
        verify(() => reviewRepositoryMock.getAllReviews()).called(1);
        verifyNoMoreInteractions(reviewRepositoryMock);
      },
    );

    test(
      'Error: Devuelve Left(ReviewFetchFailedFailure) cuando ocurre un fallo al consultar todas las reseñas',
      () async {
        when(() => reviewRepositoryMock.getAllReviews())
            .thenAnswer((_) async => const Left(ReviewFetchFailedFailure()));

        final resultado = await getAllReviews();

        expect(resultado, const Left(ReviewFetchFailedFailure()));
        verify(() => reviewRepositoryMock.getAllReviews()).called(1);
        verifyNoMoreInteractions(reviewRepositoryMock);
      },
    );
  });

  group('UpdateReviewUseCase', () {
    late UpdateReviewUseCase updateReview;

    setUp(() {
      updateReview = UpdateReviewUseCase(reviewRepositoryMock);
    });

    test(
      'Exito: Devuelve Right(null) cuando la reseña se actualiza correctamente',
      () async {
        when(() => reviewRepositoryMock.updateReview(reviewExample))
            .thenAnswer((_) async => const Right(null));

        final resultado = await updateReview(reviewExample);

        expect(resultado, const Right(null));
        verify(() => reviewRepositoryMock.updateReview(reviewExample)).called(1);
        verifyNoMoreInteractions(reviewRepositoryMock);
      },
    );

    test(
      'Error: Devuelve Left(ReviewUpdateFailedFailure) cuando ocurre un fallo en la actualización',
      () async {
        when(() => reviewRepositoryMock.updateReview(any()))
            .thenAnswer((_) async => const Left(ReviewUpdateFailedFailure()));

        final resultado = await updateReview(reviewExample);

        expect(resultado, const Left(ReviewUpdateFailedFailure()));
        verify(() => reviewRepositoryMock.updateReview(reviewExample)).called(1);
        verifyNoMoreInteractions(reviewRepositoryMock);
      },
    );
  });

  group('DeleteReviewUseCase', () {
    late DeleteReviewUseCase deleteReview;

    setUp(() {
      deleteReview = DeleteReviewUseCase(reviewRepositoryMock);
    });

    test(
      'Exito: Devuelve Right(null) cuando la reseña es eliminada correctamente',
      () async {
        when(() => reviewRepositoryMock.deleteReview('review-123'))
            .thenAnswer((_) async => const Right(null));

        final resultado = await deleteReview('review-123');

        expect(resultado, const Right(null));
        verify(() => reviewRepositoryMock.deleteReview('review-123')).called(1);
        verifyNoMoreInteractions(reviewRepositoryMock);
      },
    );

    test(
      'Error: Devuelve Left(ReviewDeletionFailedFailure) cuando ocurre un error al eliminar la reseña',
      () async {
        when(() => reviewRepositoryMock.deleteReview(any()))
            .thenAnswer((_) async => const Left(ReviewDeletionFailedFailure()));

        final resultado = await deleteReview('review-123');

        expect(resultado, const Left(ReviewDeletionFailedFailure()));
        verify(() => reviewRepositoryMock.deleteReview('review-123')).called(1);
        verifyNoMoreInteractions(reviewRepositoryMock);
      },
    );
  });

  group('SyncPendingReviewsUseCase', () {
    late SyncPendingReviewsUseCase syncPendingReviews;

    setUp(() {
      syncPendingReviews = SyncPendingReviewsUseCase(reviewRepositoryMock);
    });

    test(
      'Exito: Devuelve Right(null) cuando las reseñas pendientes se sincronizan exitosamente',
      () async {
        when(() => reviewRepositoryMock.syncPendingReviews())
            .thenAnswer((_) async => const Right(null));

        final resultado = await syncPendingReviews();

        expect(resultado, const Right(null));
        verify(() => reviewRepositoryMock.syncPendingReviews()).called(1);
        verifyNoMoreInteractions(reviewRepositoryMock);
      },
    );

    test(
      'Error: Devuelve Left(ReviewSyncFailedFailure) cuando ocurre un error de sincronización',
      () async {
        when(() => reviewRepositoryMock.syncPendingReviews())
            .thenAnswer((_) async => const Left(ReviewSyncFailedFailure()));

        final resultado = await syncPendingReviews();

        expect(resultado, const Left(ReviewSyncFailedFailure()));
        verify(() => reviewRepositoryMock.syncPendingReviews()).called(1);
        verifyNoMoreInteractions(reviewRepositoryMock);
      },
    );
  });
}
