import 'package:migra_ayuda/features/userActivity/domain/entities/user_activity_entity.dart';

abstract class UserActivityRepository {
  Future<void> createActivity(UserActivityEntity activity);
  Stream<List<UserActivityEntity>> getAll();
  Future<void> synchronize();
}
