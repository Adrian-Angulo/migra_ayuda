import 'package:dartz/dartz.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:migra_ayuda/features/reviews/domain/entities/review_entity.dart';
import 'package:migra_ayuda/features/reviews/domain/failures/review_failures.dart';
import 'package:migra_ayuda/features/reviews/domain/repositories/review_repository.dart';
import 'package:migra_ayuda/features/reviews/domain/usecases/review_usecases.dart';
import 'package:mocktail/mocktail.dart';

class MockReviewRepository extends Mock implements ReviewRepository {}

void main() {
  late MockReviewRepository mockReviewRepository;

  final fakeReview = ReviewEntity(
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
    registerFallbackValue(fakeReview);
  });

  setUp(() {
    mockReviewRepository = MockReviewRepository();
  });

  group('CreateReviewUseCase', () {
    late CreateReviewUseCase useCase;

    setUp(() {
      useCase = CreateReviewUseCase(mockReviewRepository);
    });

    test(
      'éxito: debería crear la reseña satisfactoriamente',
      () async {
        when(() => mockReviewRepository.createReview(fakeReview))
            .thenAnswer((_) async => const Right(null));

        final result = await useCase(fakeReview);

        expect(result, const Right(null));
        verify(() => mockReviewRepository.createReview(fakeReview)).called(1);
        verifyNoMoreInteractions(mockReviewRepository);
      },
    );

    test(
      'error: debería retornar Left(ReviewCreationFailedFailure) cuando falla la creación',
      () async {
        when(() => mockReviewRepository.createReview(any())).thenAnswer(
          (_) async => const Left(ReviewCreationFailedFailure()),
        );

        final result = await useCase(fakeReview);

        expect(result, const Left(ReviewCreationFailedFailure()));
        verify(() => mockReviewRepository.createReview(fakeReview)).called(1);
        verifyNoMoreInteractions(mockReviewRepository);
      },
    );
  });

  group('GetReviewsByEntityUseCase', () {
    late GetReviewsByEntityUseCase useCase;

    setUp(() {
      useCase = GetReviewsByEntityUseCase(mockReviewRepository);
    });

    test(
      'éxito: debería retornar la lista de reseñas asociadas a una entidad',
      () async {
        when(() => mockReviewRepository.getReviewsByEntity('entity-123'))
            .thenAnswer((_) async => Right([fakeReview]));

        final result = await useCase('entity-123');

        expect(result, isA<Right>());
        result.fold(
          (_) => fail('Debería retornar Right'),
          (reviews) {
            expect(reviews.length, 1);
            expect(reviews.first.id, 'review-123');
          },
        );
        verify(() => mockReviewRepository.getReviewsByEntity('entity-123'))
            .called(1);
        verifyNoMoreInteractions(mockReviewRepository);
      },
    );

    test(
      'error: debería retornar Left(ReviewFetchFailedFailure) cuando falla al obtener las reseñas',
      () async {
        when(() => mockReviewRepository.getReviewsByEntity(any())).thenAnswer(
          (_) async => const Left(ReviewFetchFailedFailure()),
        );

        final result = await useCase('entity-123');

        expect(result, const Left(ReviewFetchFailedFailure()));
        verify(() => mockReviewRepository.getReviewsByEntity('entity-123'))
            .called(1);
        verifyNoMoreInteractions(mockReviewRepository);
      },
    );
  });

  group('GetAllReviewsUseCase', () {
    late GetAllReviewsUseCase useCase;

    setUp(() {
      useCase = GetAllReviewsUseCase(mockReviewRepository);
    });

    test(
      'éxito: debería retornar todas las reseñas disponibles',
      () async {
        when(() => mockReviewRepository.getAllReviews())
            .thenAnswer((_) async => Right([fakeReview]));

        final result = await useCase();

        expect(result, isA<Right>());
        result.fold(
          (_) => fail('Debería retornar Right'),
          (reviews) {
            expect(reviews.length, 1);
            expect(reviews.first.id, 'review-123');
          },
        );
        verify(() => mockReviewRepository.getAllReviews()).called(1);
        verifyNoMoreInteractions(mockReviewRepository);
      },
    );

    test(
      'error: debería retornar Left(ReviewFetchFailedFailure) cuando falla la consulta de reseñas',
      () async {
        when(() => mockReviewRepository.getAllReviews()).thenAnswer(
          (_) async => const Left(ReviewFetchFailedFailure()),
        );

        final result = await useCase();

        expect(result, const Left(ReviewFetchFailedFailure()));
        verify(() => mockReviewRepository.getAllReviews()).called(1);
        verifyNoMoreInteractions(mockReviewRepository);
      },
    );
  });

  group('UpdateReviewUseCase', () {
    late UpdateReviewUseCase useCase;

    setUp(() {
      useCase = UpdateReviewUseCase(mockReviewRepository);
    });

    test(
      'éxito: debería actualizar la reseña satisfactoriamente',
      () async {
        when(() => mockReviewRepository.updateReview(fakeReview))
            .thenAnswer((_) async => const Right(null));

        final result = await useCase(fakeReview);

        expect(result, const Right(null));
        verify(() => mockReviewRepository.updateReview(fakeReview)).called(1);
        verifyNoMoreInteractions(mockReviewRepository);
      },
    );

    test(
      'error: debería retornar Left(ReviewUpdateFailedFailure) cuando falla la actualización',
      () async {
        when(() => mockReviewRepository.updateReview(any())).thenAnswer(
          (_) async => const Left(ReviewUpdateFailedFailure()),
        );

        final result = await useCase(fakeReview);

        expect(result, const Left(ReviewUpdateFailedFailure()));
        verify(() => mockReviewRepository.updateReview(fakeReview)).called(1);
        verifyNoMoreInteractions(mockReviewRepository);
      },
    );
  });

  group('DeleteReviewUseCase', () {
    late DeleteReviewUseCase useCase;

    setUp(() {
      useCase = DeleteReviewUseCase(mockReviewRepository);
    });

    test(
      'éxito: debería eliminar la reseña satisfactoriamente',
      () async {
        when(() => mockReviewRepository.deleteReview('review-123'))
            .thenAnswer((_) async => const Right(null));

        final result = await useCase('review-123');

        expect(result, const Right(null));
        verify(() => mockReviewRepository.deleteReview('review-123')).called(1);
        verifyNoMoreInteractions(mockReviewRepository);
      },
    );

    test(
      'error: debería retornar Left(ReviewDeletionFailedFailure) cuando falla la eliminación',
      () async {
        when(() => mockReviewRepository.deleteReview(any())).thenAnswer(
          (_) async => const Left(ReviewDeletionFailedFailure()),
        );

        final result = await useCase('review-123');

        expect(result, const Left(ReviewDeletionFailedFailure()));
        verify(() => mockReviewRepository.deleteReview('review-123')).called(1);
        verifyNoMoreInteractions(mockReviewRepository);
      },
    );
  });

  group('GetUserReviewByEntityUseCase', () {
    late GetUserReviewByEntityUseCase useCase;

    setUp(() {
      useCase = GetUserReviewByEntityUseCase(mockReviewRepository);
    });

    test(
      'éxito: debería retornar la reseña del usuario para la entidad especificada',
      () async {
        when(() => mockReviewRepository.getUserReviewByEntity(
              'migrante-123',
              'entity-123',
            )).thenAnswer((_) async => Right(fakeReview));

        final result = await useCase('migrante-123', 'entity-123');

        expect(result, Right(fakeReview));
        verify(() => mockReviewRepository.getUserReviewByEntity(
              'migrante-123',
              'entity-123',
            )).called(1);
        verifyNoMoreInteractions(mockReviewRepository);
      },
    );

    test(
      'error: debería retornar Left(ReviewNotFoundFailure) cuando falla al consultar la reseña',
      () async {
        when(() => mockReviewRepository.getUserReviewByEntity(any(), any()))
            .thenAnswer(
          (_) async => const Left(ReviewNotFoundFailure()),
        );

        final result = await useCase('migrante-123', 'entity-123');

        expect(result, const Left(ReviewNotFoundFailure()));
        verify(() => mockReviewRepository.getUserReviewByEntity(
              'migrante-123',
              'entity-123',
            )).called(1);
        verifyNoMoreInteractions(mockReviewRepository);
      },
    );
  });

  group('SyncPendingReviewsUseCase', () {
    late SyncPendingReviewsUseCase useCase;

    setUp(() {
      useCase = SyncPendingReviewsUseCase(mockReviewRepository);
    });

    test(
      'éxito: debería sincronizar las reseñas pendientes satisfactoriamente',
      () async {
        when(() => mockReviewRepository.syncPendingReviews())
            .thenAnswer((_) async => const Right(null));

        final result = await useCase();

        expect(result, const Right(null));
        verify(() => mockReviewRepository.syncPendingReviews()).called(1);
        verifyNoMoreInteractions(mockReviewRepository);
      },
    );

    test(
      'error: debería retornar Left(ReviewSyncFailedFailure) cuando falla la sincronización',
      () async {
        when(() => mockReviewRepository.syncPendingReviews()).thenAnswer(
          (_) async => const Left(ReviewSyncFailedFailure()),
        );

        final result = await useCase();

        expect(result, const Left(ReviewSyncFailedFailure()));
        verify(() => mockReviewRepository.syncPendingReviews()).called(1);
        verifyNoMoreInteractions(mockReviewRepository);
      },
    );
  });
}
