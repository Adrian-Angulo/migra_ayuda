import 'package:dartz/dartz.dart';
import 'package:migra_ayuda/features/userActivity/domain/entities/user_activity_entity.dart';
import 'package:migra_ayuda/features/userActivity/domain/failures/activity_failure.dart';
import 'package:migra_ayuda/features/userActivity/domain/repositories/user_activity_repository.dart';

class CreateActivityUsecase {
  final UserActivityRepository repository;

  CreateActivityUsecase({required this.repository});

  Future<Either<ActivityFailure, Unit>> call(UserActivityEntity activity) async {
    return repository.createActivity(activity);
  }
}
