
bool shouldPreserveLocalRecord(Map<String, dynamic>? localRecord) {
  if (localRecord == null) {
    return false;
  }

  final bool isPendingSync = (localRecord['isSynced'] as bool?) == false;
  final bool isMarkedDeleted = localRecord['deletedAt'] != null;

  return isPendingSync || isMarkedDeleted;
}
