import 'package:dartz/dartz.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:migra_ayuda/features/audit/domain/entities/audit_entity.dart';
import 'package:migra_ayuda/features/audit/domain/failures/audit_failures.dart';
import 'package:migra_ayuda/features/audit/domain/repositories/audit_repository.dart';
import 'package:migra_ayuda/features/audit/domain/usecases/audit_usecases.dart';
import 'package:mocktail/mocktail.dart';

class MockAuditRepository extends Mock implements AuditRepository {}

void main() {
  late MockAuditRepository mockAuditRepository;

  final fakeAudit = AuditEntity(
    id: 'audit-123',
    idUser: 'user-123',
    accion: 'login',
    nombre: 'Juan Perez',
    correo: 'juan@example.com',
    pais: 'Colombia',
  );

  setUpAll(() {
    registerFallbackValue(fakeAudit);
  });

  setUp(() {
    mockAuditRepository = MockAuditRepository();
  });

  group('RegisterActivityUsecase', () {
    late RegisterActivityUsecase useCase;

    setUp(() {
      useCase = RegisterActivityUsecase(mockAuditRepository);
    });

    test(
      'éxito: debería registrar la actividad satisfactoriamente',
      () async {
        when(() => mockAuditRepository.createActivity(fakeAudit))
            .thenAnswer((_) async => const Right(null));

        final result = await useCase(fakeAudit);

        expect(result, const Right(null));
        verify(() => mockAuditRepository.createActivity(fakeAudit)).called(1);
        verifyNoMoreInteractions(mockAuditRepository);
      },
    );

    test(
      'error: debería retornar Left(AuditActivityCreationFailedFailure) cuando falla el registro',
      () async {
        when(() => mockAuditRepository.createActivity(any())).thenAnswer(
          (_) async => const Left(AuditActivityCreationFailedFailure()),
        );

        final result = await useCase(fakeAudit);

        expect(result, const Left(AuditActivityCreationFailedFailure()));
        verify(() => mockAuditRepository.createActivity(fakeAudit)).called(1);
        verifyNoMoreInteractions(mockAuditRepository);
      },
    );
  });

  group('GetAllActitiesUsecase', () {
    late GetAllActitiesUsecase useCase;

    setUp(() {
      useCase = GetAllActitiesUsecase(mockAuditRepository);
    });

    test(
      'éxito: debería emitir la lista de actividades desde el stream',
      () async {
        final activitiesList = [fakeAudit];
        when(() => mockAuditRepository.getAll())
            .thenAnswer((_) => Stream.value(activitiesList));

        final stream = useCase();

        await expectLater(stream, emits(activitiesList));
        verify(() => mockAuditRepository.getAll()).called(1);
        verifyNoMoreInteractions(mockAuditRepository);
      },
    );

    test(
      'error: debería emitir un error cuando el stream del repositorio falla',
      () async {
        final failure = const AuditFetchFailedFailure();
        when(() => mockAuditRepository.getAll())
            .thenAnswer((_) => Stream.error(failure));

        final stream = useCase();

        await expectLater(stream, emitsError(isA<AuditFetchFailedFailure>()));
        verify(() => mockAuditRepository.getAll()).called(1);
        verifyNoMoreInteractions(mockAuditRepository);
      },
    );
  });

  group('SyncronizeUsecase', () {
    late SyncronizeUsecase useCase;

    setUp(() {
      useCase = SyncronizeUsecase(mockAuditRepository);
    });

    test(
      'éxito: debería sincronizar las actividades satisfactoriamente',
      () async {
        when(() => mockAuditRepository.synchronize())
            .thenAnswer((_) async => const Right(null));

        final result = await useCase();

        expect(result, const Right(null));
        verify(() => mockAuditRepository.synchronize()).called(1);
        verifyNoMoreInteractions(mockAuditRepository);
      },
    );

    test(
      'error: debería retornar Left(AuditSyncFailedFailure) cuando falla la sincronización',
      () async {
        when(() => mockAuditRepository.synchronize()).thenAnswer(
          (_) async => const Left(AuditSyncFailedFailure()),
        );

        final result = await useCase();

        expect(result, const Left(AuditSyncFailedFailure()));
        verify(() => mockAuditRepository.synchronize()).called(1);
        verifyNoMoreInteractions(mockAuditRepository);
      },
    );
  });
}
