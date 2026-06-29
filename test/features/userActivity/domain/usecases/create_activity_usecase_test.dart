import 'package:dartz/dartz.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:migra_ayuda/core/constants/activity_actions.dart';
import 'package:migra_ayuda/features/userActivity/domain/entities/user_activity_entity.dart';
import 'package:migra_ayuda/features/userActivity/domain/failures/activity_failure.dart';
import 'package:migra_ayuda/features/userActivity/domain/repositories/user_activity_repository.dart';
import 'package:migra_ayuda/features/userActivity/domain/usecase/create_activity_usecase.dart';
import 'package:mocktail/mocktail.dart';

class MockUserActivityRepository extends Mock
    implements UserActivityRepository {}

void main() {
  late MockUserActivityRepository repository;
  late CreateActivityUsecase createActivity;
  setUp(
    () {
      repository = MockUserActivityRepository();
      createActivity = CreateActivityUsecase(repository: repository);
    },
  );

  UserActivityEntity activity = UserActivityEntity(
      id: '',
      idUser: 'rweds',
      accion: ActivityActions.login(),
      nombre: "Adrian",
      correo: "email@gamil.com",
      pais: "Venezuela");

  
  test('deberia retornar Right cuando se crea una actividad exitosamente',
      () async {
    when(() => repository.createActivity(activity))
        .thenAnswer((_) async => const Right(unit));
    final result = await createActivity.call(activity);
    expect(result, const Right(unit));
    verify(() => repository.createActivity(activity)).called(1);
    verifyNoMoreInteractions(repository);
  });

  test('deberia retornar Left(CacheFailure) cuando falla el caché local',
      () async {
    when(() => repository.createActivity(activity)).thenAnswer(
        (_) async => const Left(CacheFailure('Error al guardar en caché')));
    final result = await createActivity.call(activity);
    expect(result, const Left(CacheFailure('Error al guardar en caché')));
    verify(() => repository.createActivity(activity)).called(1);
    verifyNoMoreInteractions(repository);
  });

  test('deberia retornar Left(CacheFailure) cuando ocurre un error inesperado',
      () async {
    when(() => repository.createActivity(activity)).thenAnswer(
        (_) async => const Left(CacheFailure('Error inesperado: excepción')));
    final result = await createActivity.call(activity);
    expect(result, const Left(CacheFailure('Error inesperado: excepción')));
    verify(() => repository.createActivity(activity)).called(1);
    verifyNoMoreInteractions(repository);
  });
}
