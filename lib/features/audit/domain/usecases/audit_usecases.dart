import 'package:dartz/dartz.dart';
import 'package:migra_ayuda/core/errors/failure.dart';
import 'package:migra_ayuda/features/audit/domain/entities/audit_entity.dart';
import 'package:migra_ayuda/features/audit/domain/repositories/audit_repository.dart';

class RegisterActivityUsecase {
  final AuditRepository repository;

  RegisterActivityUsecase(this.repository);

  Future<Either<Failure, void>> call(AuditEntity audit) {
    return repository.createActivity(audit);
  }
}

class GetAllActitiesUsecase {
  final AuditRepository repository;

  GetAllActitiesUsecase(this.repository);

  Stream<List<AuditEntity>> call() {
    return repository.getAll();
  }
}

class SyncronizeUsecase {
  final AuditRepository repository;

  SyncronizeUsecase(this.repository);

  Future<Either<Failure, void>> call() {
    return repository.synchronize();
  }
}
