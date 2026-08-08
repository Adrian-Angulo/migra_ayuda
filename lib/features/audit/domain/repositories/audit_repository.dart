import 'package:migra_ayuda/features/audit/domain/entities/audit_entity.dart';

abstract class UserActivityRepository {
  Future<void> createActivity(AuditEntity activity);
  Stream<List<AuditEntity>> getAll();
  Future<void> synchronize();
}
