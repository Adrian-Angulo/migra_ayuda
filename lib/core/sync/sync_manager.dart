import 'dart:async';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:migra_ayuda/features/entities/presentation/providers/entity_providers.dart';
import 'package:migra_ayuda/features/reviews/presentation/providers/review_providers.dart';
import 'package:migra_ayuda/features/audit/presentation/providers/audit_providers.dart';

enum SyncState { init, success, error }

final syncProvider =
    AsyncNotifierProvider<SyncNotifier, SyncState>(SyncNotifier.new);

class SyncNotifier extends AsyncNotifier<SyncState> {
  @override
  FutureOr<SyncState> build() {
    return SyncState.init;
  }

  Future<void> syncAll() async {
    state = const AsyncValue.loading();
    try {
      await _syncAll();
      state = const AsyncValue.data(SyncState.success);
    } catch (e, st) {
      state = AsyncValue.error(e, st);
    }
  }

  Future<void> _syncAll() async {
    await ref.read(entityRepositoryProvider).syncAllFromFirebase();    //sincronizar entidades
    await ref.read(reviewRepositoryProvider).syncPendingReviews(); //sincronizar reseñas
    await ref.read(auditRepositoryProvider).synchronize(); //sincronizar acciones del usuario
  }
}
