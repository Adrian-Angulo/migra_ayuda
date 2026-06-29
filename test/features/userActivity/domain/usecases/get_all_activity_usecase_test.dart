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

  final List<UserActivityEntity> activitiesList = [activity];
  test(
      'debe retornar una lista de actividades cuando el repositorio tiene éxito',
      () async {
    when(() => repository.getAllActivity())
        .thenAnswer((_) async => right(activitiesList));

    final result = await repository.getAllActivity();

    expect(result, right(activitiesList));
    verify(() => repository.getAllActivity()).called(1);
  });

  test('debe retornar un ActivityFailure cuando el repositorio falla',
      () async {
    when(() => repository.getAllActivity()).thenAnswer(
        (_) async => left(const ServerFailure('Error del servidor')));

    final result = await repository.getAllActivity();

    expect(result, left(const ServerFailure('Error del servidor')));
    verify(() => repository.getAllActivity()).called(1);
  });
}
