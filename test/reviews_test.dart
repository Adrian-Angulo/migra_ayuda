import 'package:flutter_test/flutter_test.dart';
import 'package:migra_ayuda/features/reviews/domain/entities/review_entity.dart';
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
            .thenAnswer((_) async {});

        await useCase(fakeReview);

        verify(() => mockReviewRepository.createReview(fakeReview)).called(1);
        verifyNoMoreInteractions(mockReviewRepository);
      },
    );

    test(
      'error: debería lanzar una excepción cuando falla la creación de la reseña',
      () async {
        when(() => mockReviewRepository.createReview(any()))
            .thenThrow(Exception('Error al crear reseña'));

        expect(
          () async => await useCase(fakeReview),
          throwsA(isA<Exception>()),
        );
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
            .thenAnswer((_) async => [fakeReview]);

        final result = await useCase('entity-123');

        expect(result, isA<List<ReviewEntity>>());
        expect(result.length, 1);
        expect(result.first.id, 'review-123');
        verify(() => mockReviewRepository.getReviewsByEntity('entity-123'))
            .called(1);
        verifyNoMoreInteractions(mockReviewRepository);
      },
    );

    test(
      'error: debería lanzar una excepción cuando falla al obtener las reseñas de la entidad',
      () async {
        when(() => mockReviewRepository.getReviewsByEntity(any()))
            .thenThrow(Exception('Error al obtener reseñas'));

        expect(
          () async => await useCase('entity-123'),
          throwsA(isA<Exception>()),
        );
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
            .thenAnswer((_) async => [fakeReview]);

        final result = await useCase();

        expect(result, isA<List<ReviewEntity>>());
        expect(result.length, 1);
        expect(result.first.id, 'review-123');
        verify(() => mockReviewRepository.getAllReviews()).called(1);
        verifyNoMoreInteractions(mockReviewRepository);
      },
    );

    test(
      'error: debería lanzar una excepción cuando falla la consulta de todas las reseñas',
      () async {
        when(() => mockReviewRepository.getAllReviews())
            .thenThrow(Exception('Error al obtener todas las reseñas'));

        expect(
          () async => await useCase(),
          throwsA(isA<Exception>()),
        );
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
            .thenAnswer((_) async {});

        await useCase(fakeReview);

        verify(() => mockReviewRepository.updateReview(fakeReview)).called(1);
        verifyNoMoreInteractions(mockReviewRepository);
      },
    );

    test(
      'error: debería lanzar una excepción cuando falla la actualización de la reseña',
      () async {
        when(() => mockReviewRepository.updateReview(any()))
            .thenThrow(Exception('Error al actualizar reseña'));

        expect(
          () async => await useCase(fakeReview),
          throwsA(isA<Exception>()),
        );
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
            .thenAnswer((_) async {});

        await useCase('review-123');

        verify(() => mockReviewRepository.deleteReview('review-123')).called(1);
        verifyNoMoreInteractions(mockReviewRepository);
      },
    );

    test(
      'error: debería lanzar una excepción cuando falla la eliminación de la reseña',
      () async {
        when(() => mockReviewRepository.deleteReview(any()))
            .thenThrow(Exception('Error al eliminar reseña'));

        expect(
          () async => await useCase('review-123'),
          throwsA(isA<Exception>()),
        );
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
            )).thenAnswer((_) async => fakeReview);

        final result = await useCase('migrante-123', 'entity-123');

        expect(result, fakeReview);
        verify(() => mockReviewRepository.getUserReviewByEntity(
              'migrante-123',
              'entity-123',
            )).called(1);
        verifyNoMoreInteractions(mockReviewRepository);
      },
    );

    test(
      'error: debería lanzar una excepción cuando falla al consultar la reseña del usuario para una entidad',
      () async {
        when(() => mockReviewRepository.getUserReviewByEntity(any(), any()))
            .thenThrow(Exception('Error al consultar reseña de usuario'));

        expect(
          () async => await useCase('migrante-123', 'entity-123'),
          throwsA(isA<Exception>()),
        );
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
            .thenAnswer((_) async {});

        await useCase();

        verify(() => mockReviewRepository.syncPendingReviews()).called(1);
        verifyNoMoreInteractions(mockReviewRepository);
      },
    );

    test(
      'error: debería lanzar una excepción cuando falla la sincronización de reseñas',
      () async {
        when(() => mockReviewRepository.syncPendingReviews())
            .thenThrow(Exception('Error al sincronizar reseñas'));

        expect(
          () async => await useCase(),
          throwsA(isA<Exception>()),
        );
        verify(() => mockReviewRepository.syncPendingReviews()).called(1);
        verifyNoMoreInteractions(mockReviewRepository);
      },
    );
  });
}
