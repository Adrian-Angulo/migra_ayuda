import 'package:dartz/dartz.dart';
import 'package:migra_ayuda/core/errors/failure.dart';
import 'package:migra_ayuda/features/audit/domain/entities/audit_entity.dart';

abstract class AuditRepository {
  Future<Either<Failure, void>> createActivity(AuditEntity activity);
  Stream<List<AuditEntity>> getAll();
  Future<Either<Failure, void>> synchronize();
}
