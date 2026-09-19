import 'package:flutter_test/flutter_test.dart';
import 'package:migra_ayuda/features/audit/domain/entities/audit_entity.dart';
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
            .thenAnswer((_) async {});

        await useCase(fakeAudit);

        verify(() => mockAuditRepository.createActivity(fakeAudit)).called(1);
        verifyNoMoreInteractions(mockAuditRepository);
      },
    );

    test(
      'error: debería lanzar una excepción cuando falla el registro de la actividad',
      () async {
        when(() => mockAuditRepository.createActivity(any()))
            .thenThrow(Exception('Error al registrar actividad'));

        expect(
          () async => await useCase(fakeAudit),
          throwsA(isA<Exception>()),
        );
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
        final exception = Exception('Error al obtener actividades');
        when(() => mockAuditRepository.getAll())
            .thenAnswer((_) => Stream.error(exception));

        final stream = useCase();

        await expectLater(stream, emitsError(isA<Exception>()));
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
            .thenAnswer((_) async {});

        await useCase();

        verify(() => mockAuditRepository.synchronize()).called(1);
        verifyNoMoreInteractions(mockAuditRepository);
      },
    );

    test(
      'error: debería lanzar una excepción cuando falla la sincronización de actividades',
      () async {
        when(() => mockAuditRepository.synchronize())
            .thenThrow(Exception('Error al sincronizar actividades'));

        expect(
          () async => await useCase(),
          throwsA(isA<Exception>()),
        );
        verify(() => mockAuditRepository.synchronize()).called(1);
        verifyNoMoreInteractions(mockAuditRepository);
      },
    );
  });
}
