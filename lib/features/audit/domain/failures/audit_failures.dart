import 'package:migra_ayuda/core/errors/failure.dart';

abstract class AuditFailure extends Failure {
  const AuditFailure({required super.message, super.code});
}

class AuditActivityCreationFailedFailure extends AuditFailure {
  const AuditActivityCreationFailedFailure({
    super.message = 'Error al registrar la actividad de auditoría',
    super.code = 'audit-creation-failed',
  });
}

class AuditFetchFailedFailure extends AuditFailure {
  const AuditFetchFailedFailure({
    super.message = 'Error al consultar los registros de auditoría',
    super.code = 'audit-fetch-failed',
  });
}

class AuditSyncFailedFailure extends AuditFailure {
  const AuditSyncFailedFailure({
    super.message = 'Error al sincronizar los registros de auditoría',
    super.code = 'audit-sync-failed',
  });
}

class GenericAuditFailure extends AuditFailure {
  const GenericAuditFailure({
    required super.message,
    super.code,
  });
}
