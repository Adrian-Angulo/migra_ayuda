import 'dart:async';
import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:migra_ayuda/core/network/network_provider.dart';
import 'package:migra_ayuda/features/entities/presentation/providers/entity_providers.dart';
import 'package:migra_ayuda/features/reviews/presentation/providers/review_providers.dart';
import 'package:migra_ayuda/features/audit/presentation/providers/audit_providers.dart';

enum SyncState { init, success, error }

enum SyncResult { success, noConnection, alreadySyncing, error }

final syncProvider =
    AsyncNotifierProvider<SyncNotifier, SyncState>(SyncNotifier.new);

class SyncNotifier extends AsyncNotifier<SyncState> {
  Timer? _periodicTimer;
  StreamSubscription<bool>? _connectivitySub;

  static const Duration _syncInterval = Duration(minutes: 10);

  @override
  FutureOr<SyncState> build() {
    _startPeriodicSync();
    _listenConnectivity();

    ref.onDispose(() {
      _periodicTimer?.cancel();
      _connectivitySub?.cancel();
    });

    return SyncState.init;
  }

  void _startPeriodicSync() {
    _periodicTimer?.cancel();
    _periodicTimer = Timer.periodic(_syncInterval, (_) async {
      await syncAll();
    });
  }

  void _listenConnectivity() {
    final networkInfo = ref.read(networkInfoProvider);
    _connectivitySub =
        networkInfo.onConnectivityChanged.listen((hasConnection) async {
      if (hasConnection) {
        await syncAll();
      }
    });
  }

  Future<SyncResult> syncAll() async {
    if (state.isLoading) {
      return SyncResult.alreadySyncing;
    }

    final networkInfo = ref.read(networkInfoProvider);
    final isConnected = await networkInfo.isConnected;
    if (!isConnected) {
      return SyncResult.noConnection;
    }

    state = const AsyncValue.loading();

    try {
      await _syncAll();
      state = const AsyncValue.data(SyncState.success);
      return SyncResult.success;
    } catch (e, st) {
      state = AsyncValue.error(e, st);
      return SyncResult.error;
    }
  }

  Future<void> _syncAll() async {
    try {
      await ref.read(entityMobilRepositoryProvider).syncAllFromFirebase();
      await ref.read(getAllEntitiesProvider.notifier).refresh();
    } catch (e) {
      debugPrint("Error al sincronizar entidades: $e");
    }
    try {
      await ref.read(syncPendingReviewsUseCaseProvider).call();
    } catch (e) {
      debugPrint("Error al sincronizar reviews: $e");
    }
    try {
      await ref.read(synchronizeAuditUseCaseProvider).call();
    } catch (e) {
      debugPrint("Error al sincronizar auditoría: $e");
    }
  }
}
