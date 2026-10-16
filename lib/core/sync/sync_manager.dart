import 'dart:async';
import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:migra_ayuda/core/network/network_provider.dart';
import 'package:migra_ayuda/features/entities/presentation/providers/entity_providers.dart';
import 'package:migra_ayuda/features/reviews/presentation/providers/review_providers.dart';
import 'package:migra_ayuda/features/audit/presentation/providers/audit_providers.dart';

enum SyncState { init, success, error }

final syncProvider =
    AsyncNotifierProvider<SyncNotifier, SyncState>(SyncNotifier.new);

class SyncNotifier extends AsyncNotifier<SyncState> {
  Timer? _periodicTimer;
  StreamSubscription<bool>? _connectivitySub;

  /// Intervalo periódico de sincronización (ejemplo: 5 minutos)
  static const Duration _syncInterval = Duration(minutes: 5);

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
    _connectivitySub = networkInfo.onConnectivityChanged.listen((hasConnection) async {
      if (hasConnection) {
       
        await syncAll();
      }
    });
  }

 
  Future<void> syncAll() async {
 
    if (state.isLoading) {
     
      return;
    }


    final networkInfo = ref.read(networkInfoProvider);
    final isConnected = await networkInfo.isConnected;
    if (!isConnected) {
      
      return;
    }

    state = const AsyncValue.loading();

    try {
      await _syncAll();
      state = const AsyncValue.data(SyncState.success);
      
    } catch (e, st) {
     
      state = AsyncValue.error(e, st);
    }
  }

  Future<void> _syncAll() async {
    try {
      await ref.read(entityMobilRepositoryProvider).syncAllFromFirebase();
    } catch (e) {
      debugPrint("Error al sincronizar entidades: $e");
    }
    try {
      await ref.read(reviewRepositoryProvider).syncPendingReviews();
    } catch (e) {
      debugPrint("Error al sincronizar reviews: $e");
    }
    try {
      await ref.read(auditRepositoryProvider).synchronize();
    } catch (e) {
      debugPrint("Error al sincronizar auditoría: $e");
    }
  }
}