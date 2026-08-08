import 'package:migra_ayuda/features/userActivity/domain/entities/user_activity.dart';

abstract class UserActivityRepository {
  Future<void> createActivity(UserActivity activity);
  Stream<List<UserActivity>> getAll();
  Future<void> synchronize();
}
