# 📖 Ejemplos de Uso - UserActivity Data Layer

## 🎯 Casos de Uso Prácticos

---

## 1️⃣ Registrar Inicio de Sesión

```dart
// Cuando un usuario inicia sesión
Future<void> logUserLogin(String userId) async {
  final activity = UserActivityEntity(
    id: '', // Se genera automáticamente
    idUser: userId,
    accion: 'Inició sesión',
    createdAt: DateTime.now(),
  );

  final result = await userActivityRepository.createActivity(activity);

  result.fold(
    (error) {
      // Manejar error (raro, porque se guarda localmente)
      print('Error al registrar login: $error');
    },
    (_) {
      // Éxito - La actividad se guardó
      print('Login registrado exitosamente');
    },
  );
}
```

---

## 2️⃣ Registrar Cierre de Sesión

```dart
Future<void> logUserLogout(String userId) async {
  final activity = UserActivityEntity(
    id: '',
    idUser: userId,
    accion: 'Cerró sesión',
    createdAt: DateTime.now(),
  );

  await userActivityRepository.createActivity(activity);
}
```

---

## 3️⃣ Registrar Acción Personalizada

```dart
Future<void> logCustomAction(String userId, String action) async {
  final activity = UserActivityEntity(
    id: '',
    idUser: userId,
    accion: action,
    createdAt: DateTime.now(),
  );

  await userActivityRepository.createActivity(activity);
}

// Ejemplos de uso:
await logCustomAction('user123', 'Actualizó perfil');
await logCustomAction('user123', 'Creó nueva entidad');
await logCustomAction('user123', 'Eliminó servicio');
await logCustomAction('user123', 'Modificó configuración');
```

---

## 4️⃣ Sincronización Automática al Iniciar la App

```dart
class AppStartupService {
  final UserActivityRepository _repository;

  AppStartupService(this._repository);

  Future<void> onAppStart() async {
    // Verificar si hay conexión
    final hasConnection = await checkInternetConnection();

    if (hasConnection) {
      // Sincronizar actividades pendientes
      final result = await _repository.syncPendingActivities();

      result.fold(
        (error) => print('No se pudo sincronizar: $error'),
        (_) => print('Actividades sincronizadas exitosamente'),
      );
    }
  }
}
```

---

## 5️⃣ Sincronización Periódica con Timer

```dart
import 'dart:async';

class ActivitySyncService {
  final UserActivityRepository _repository;
  Timer? _syncTimer;

  ActivitySyncService(this._repository);

  // Iniciar sincronización cada 5 minutos
  void startPeriodicSync() {
    _syncTimer = Timer.periodic(
      const Duration(minutes: 5),
      (_) => _syncPendingActivities(),
    );
  }

  // Detener sincronización periódica
  void stopPeriodicSync() {
    _syncTimer?.cancel();
    _syncTimer = null;
  }

  Future<void> _syncPendingActivities() async {
    final result = await _repository.syncPendingActivities();

    result.fold(
      (error) => print('Sync failed: $error'),
      (_) => print('Sync successful'),
    );
  }
}
```

---

## 6️⃣ Sincronización al Detectar Conexión

```dart
import 'package:connectivity_plus/connectivity_plus.dart';

class ConnectivitySyncService {
  final UserActivityRepository _repository;
  StreamSubscription? _connectivitySubscription;

  ConnectivitySyncService(this._repository);

  void startListening() {
    _connectivitySubscription = Connectivity()
        .onConnectivityChanged
        .listen((ConnectivityResult result) {
      if (result != ConnectivityResult.none) {
        // Hay conexión, sincronizar
        _syncPendingActivities();
      }
    });
  }

  void stopListening() {
    _connectivitySubscription?.cancel();
  }

  Future<void> _syncPendingActivities() async {
    await _repository.syncPendingActivities();
  }
}
```

---

## 7️⃣ Botón Manual de Sincronización en la UI

```dart
class SyncButton extends ConsumerWidget {
  const SyncButton({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return ElevatedButton.icon(
      onPressed: () async {
        // Mostrar loading
        showDialog(
          context: context,
          barrierDismissible: false,
          builder: (_) => const Center(
            child: CircularProgressIndicator(),
          ),
        );

        // Sincronizar
        final repository = ref.read(userActivityRepositoryProvider);
        final result = await repository.syncPendingActivities();

        // Cerrar loading
        Navigator.of(context).pop();

        // Mostrar resultado
        result.fold(
          (error) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(content: Text('Error: $error')),
            );
          },
          (_) {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(content: Text('Sincronización exitosa')),
            );
          },
        );
      },
      icon: const Icon(Icons.sync),
      label: const Text('Sincronizar'),
    );
  }
}
```

---

## 8️⃣ Middleware para Registrar Todas las Acciones

```dart
class ActivityLogger {
  final UserActivityRepository _repository;
  final String _userId;

  ActivityLogger(this._repository, this._userId);

  // Wrapper para registrar cualquier acción
  Future<T> logAction<T>(
    String actionName,
    Future<T> Function() action,
  ) async {
    // Ejecutar la acción
    final result = await action();

    // Registrar la actividad
    await _repository.createActivity(
      UserActivityEntity(
        id: '',
        idUser: _userId,
        accion: actionName,
        createdAt: DateTime.now(),
      ),
    );

    return result;
  }
}

// Uso:
final logger = ActivityLogger(repository, 'user123');

// Registrar automáticamente
await logger.logAction('Actualizó perfil', () async {
  return await updateUserProfile(newData);
});

await logger.logAction('Creó entidad', () async {
  return await createEntity(entityData);
});
```

---

## 9️⃣ Provider de Riverpod (Ejemplo de Integración)

```dart
import 'package:flutter_riverpod/flutter_riverpod.dart';

// Provider del repository
final userActivityRepositoryProvider = Provider<UserActivityRepository>((ref) {
  return UserActivityRepositoryImpl(
    remoteDataSource: ref.read(userActivityRemoteDataSourceProvider),
    localDataSource: ref.read(userActivityLocalDataSourceProvider),
    networkInfo: ref.read(networkInfoProvider),
  );
});

// Provider para crear actividad
final createActivityProvider = FutureProvider.family<void, UserActivityEntity>(
  (ref, activity) async {
    final repository = ref.read(userActivityRepositoryProvider);
    final result = await repository.createActivity(activity);

    result.fold(
      (error) => throw Exception(error),
      (_) => null,
    );
  },
);

// Provider para sincronizar
final syncActivitiesProvider = FutureProvider<void>((ref) async {
  final repository = ref.read(userActivityRepositoryProvider);
  final result = await repository.syncPendingActivities();

  result.fold(
    (error) => throw Exception(error),
    (_) => null,
  );
});
```

---

## 🔟 Testing - Ejemplo de Test Unitario

```dart
import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/mockito.dart';

void main() {
  late UserActivityRepositoryImpl repository;
  late MockRemoteDataSource mockRemoteDataSource;
  late MockLocalDataSource mockLocalDataSource;
  late MockNetworkInfo mockNetworkInfo;

  setUp(() {
    mockRemoteDataSource = MockRemoteDataSource();
    mockLocalDataSource = MockLocalDataSource();
    mockNetworkInfo = MockNetworkInfo();

    repository = UserActivityRepositoryImpl(
      remoteDataSource: mockRemoteDataSource,
      localDataSource: mockLocalDataSource,
      networkInfo: mockNetworkInfo,
    );
  });

  group('createActivity', () {
    test('should save locally and sync when online', () async {
      // Arrange
      when(mockNetworkInfo.isConnected).thenAnswer((_) async => true);
      when(mockRemoteDataSource.createActivity(any))
          .thenAnswer((_) async => 'firebase-id-123');

      final activity = UserActivityEntity(
        id: '',
        idUser: 'user123',
        accion: 'Test action',
        createdAt: DateTime.now(),
      );

      // Act
      final result = await repository.createActivity(activity);

      // Assert
      expect(result.isRight(), true);
      verify(mockLocalDataSource.cacheActivity(any)).called(2);
      verify(mockRemoteDataSource.createActivity(any)).called(1);
      verify(mockLocalDataSource.deleteLocalRecord(any)).called(1);
    });

    test('should save locally when offline', () async {
      // Arrange
      when(mockNetworkInfo.isConnected).thenAnswer((_) async => false);

      final activity = UserActivityEntity(
        id: '',
        idUser: 'user123',
        accion: 'Test action',
        createdAt: DateTime.now(),
      );

      // Act
      final result = await repository.createActivity(activity);

      // Assert
      expect(result.isRight(), true);
      verify(mockLocalDataSource.cacheActivity(any)).called(1);
      verifyNever(mockRemoteDataSource.createActivity(any));
    });
  });
}
```

---

## 📊 Monitoreo de Actividades Pendientes

```dart
class ActivityMonitor {
  final UserActivityLocalDataSource _localDataSource;

  ActivityMonitor(this._localDataSource);

  // Obtener cantidad de actividades pendientes
  Future<int> getPendingCount() async {
    final pending = await _localDataSource.getPendingActivities();
    return pending.length;
  }

  // Mostrar badge con cantidad pendiente
  Widget buildPendingBadge() {
    return FutureBuilder<int>(
      future: getPendingCount(),
      builder: (context, snapshot) {
        if (!snapshot.hasData || snapshot.data == 0) {
          return const SizedBox.shrink();
        }

        return Badge(
          label: Text('${snapshot.data}'),
          child: const Icon(Icons.sync),
        );
      },
    );
  }
}
```

---

## 🎓 Mejores Prácticas

### ✅ DO (Hacer)

1. **Registrar actividades importantes**
   ```dart
   await logAction('Inició sesión');
   await logAction('Actualizó perfil');
   await logAction('Creó entidad');
   ```

2. **Sincronizar periódicamente**
   ```dart
   Timer.periodic(Duration(minutes: 5), (_) => sync());
   ```

3. **Sincronizar al detectar conexión**
   ```dart
   onConnectivityChanged.listen((result) {
     if (result != ConnectivityResult.none) sync();
   });
   ```

4. **Manejar errores gracefully**
   ```dart
   result.fold(
     (error) => print('Error: $error'),
     (_) => print('Success'),
   );
   ```

### ❌ DON'T (No hacer)

1. **No registrar actividades triviales**
   ```dart
   // ❌ Evitar
   await logAction('Scrolled down');
   await logAction('Tapped button');
   ```

2. **No sincronizar en cada acción**
   ```dart
   // ❌ Evitar
   await createActivity(activity);
   await syncPendingActivities(); // Innecesario
   ```

3. **No bloquear la UI esperando sincronización**
   ```dart
   // ❌ Evitar
   await syncPendingActivities(); // Puede tardar
   navigateToNextScreen();
   
   // ✅ Mejor
   syncPendingActivities(); // Fire and forget
   navigateToNextScreen();
   ```

---

## 🚀 Integración Completa - Ejemplo Real

```dart
class UserActivityService {
  final UserActivityRepository _repository;
  final String _userId;
  Timer? _syncTimer;

  UserActivityService(this._repository, this._userId) {
    _startPeriodicSync();
  }

  // Registrar acción
  Future<void> log(String action) async {
    await _repository.createActivity(
      UserActivityEntity(
        id: '',
        idUser: _userId,
        accion: action,
        createdAt: DateTime.now(),
      ),
    );
  }

  // Sincronización periódica
  void _startPeriodicSync() {
    _syncTimer = Timer.periodic(
      const Duration(minutes: 5),
      (_) => _repository.syncPendingActivities(),
    );
  }

  // Limpiar recursos
  void dispose() {
    _syncTimer?.cancel();
  }
}

// Uso en la app:
final activityService = UserActivityService(repository, currentUserId);

// Registrar acciones
await activityService.log('Inició sesión');
await activityService.log('Actualizó perfil');

// Al cerrar la app
activityService.dispose();
```

---

**¡Listo para usar!** 🎉
