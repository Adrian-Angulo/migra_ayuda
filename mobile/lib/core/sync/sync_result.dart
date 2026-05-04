/// Resultado de la sincronización inicial
class SyncResult {
  final bool success;
  final String message;
  final int entitiesSynced;
  final int reviewsSynced;

  SyncResult({
    required this.success,
    required this.message,
    required this.entitiesSynced,
    required this.reviewsSynced,
  });

  @override
  String toString() {
    return 'SyncResult(success: $success, message: $message, entities: $entitiesSynced, reviews: $reviewsSynced)';
  }
}
