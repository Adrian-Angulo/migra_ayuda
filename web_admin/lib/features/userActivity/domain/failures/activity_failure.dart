/// Clase sellada para representar los diferentes tipos de fallos
/// en las operaciones de actividades de usuario
sealed class ActivityFailure {
  const ActivityFailure();
}

/// Fallo en el almacenamiento local (caché)
class CacheFailure extends ActivityFailure {
  final String message;
  const CacheFailure(this.message);

  @override
  String toString() => 'CacheFailure: $message';
}

/// Fallo de conexión a internet
class NetworkFailure extends ActivityFailure {
  const NetworkFailure();

  @override
  String toString() => 'NetworkFailure: No hay conexión a internet';
}

/// Fallo parcial en la sincronización
/// Indica cuántas actividades no se pudieron sincronizar
class SyncFailure extends ActivityFailure {
  final int failedCount;
  const SyncFailure(this.failedCount);

  @override
  String toString() =>
      'SyncFailure: $failedCount actividad(es) no se pudieron sincronizar';
}

/// Fallo del servidor remoto (Firebase)
class ServerFailure extends ActivityFailure {
  final String message;
  const ServerFailure(this.message);

  @override
  String toString() => 'ServerFailure: $message';
}
