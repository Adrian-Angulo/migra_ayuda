# 🔧 Refactorización - UserActivity Repository

## 📋 Resumen de Cambios

Esta refactorización corrige **bugs críticos** y mejora el **manejo de errores** en la capa de datos de UserActivity.

---

## 🔴 Problemas Críticos Resueltos

### 1. ✅ Race Condition en Actualización de IDs

**Problema:**
```dart
// ❌ ANTES: Dos operaciones separadas
await localDataSource.cacheActivity(syncedModel);  // Insertar nuevo
await localDataSource.deleteLocalRecord(localId);   // Eliminar viejo
```

Si la app se cierra entre estas dos líneas, ambos registros persisten (duplicado).

**Solución:**
```dart
// ✅ AHORA: Operación atómica
await localDataSource.updateActivityId(localId, syncedModel);
```

Usa una transacción de Sembast que ejecuta ambas operaciones de forma atómica.

---

### 2. ✅ Duplicados en Firebase por Reintentos

**Problema:**
```dart
// ❌ ANTES: Siempre crea nuevo documento
final docRef = await _firestore.collection('user_activities').add({...});
```

Si Firebase recibe la actividad pero la respuesta falla, el registro queda `isSynced: false` y se vuelve a subir en el próximo sync → **duplicado en Firebase**.

**Solución:**
```dart
// ✅ AHORA: Patrón de clave de idempotencia
// 1. Verificar si ya existe
final existingQuery = await _firestore
    .collection('user_activities')
    .where('localId', isEqualTo: activity.id)
    .limit(1)
    .get();

// 2. Si existe, retornar su ID
if (existingQuery.docs.isNotEmpty) {
  return existingQuery.docs.first.id;
}

// 3. Si no existe, crear con localId
final docRef = await _firestore.collection('user_activities').add({
  'localId': activity.id, // Clave de idempotencia
  ...
});
```

El campo `localId` actúa como clave de idempotencia. Si se reintenta, se detecta el documento existente.

---

## 🟡 Mejoras Importantes

### 3. ✅ Manejo de Errores Tipados

**Antes:**
```dart
Future<Either<String, Unit>> createActivity(...)
```

Imposible distinguir tipos de error. El llamador solo recibe un `String`.

**Ahora:**
```dart
Future<Either<ActivityFailure, Unit>> createActivity(...)
```

Con clases selladas:
```dart
sealed class ActivityFailure {
  const ActivityFailure();
}

class CacheFailure extends ActivityFailure { ... }
class NetworkFailure extends ActivityFailure { ... }
class SyncFailure extends ActivityFailure { ... }
class ServerFailure extends ActivityFailure { ... }
```

**Beneficio:** El llamador puede hacer pattern matching:
```dart
result.fold(
  (failure) {
    switch (failure) {
      case NetworkFailure():
        showSnackbar('Sin conexión a internet');
      case CacheFailure(message: final msg):
        showSnackbar('Error local: $msg');
      case SyncFailure(failedCount: final count):
        showSnackbar('$count actividades no se sincronizaron');
      case ServerFailure(message: final msg):
        showSnackbar('Error del servidor: $msg');
    }
  },
  (_) => showSnackbar('Éxito'),
);
```

---

### 4. ✅ Reporte de Fallos Parciales en Sincronización

**Antes:**
```dart
for (final activity in pendingActivities) {
  try {
    // sincronizar
  } catch (e) {
    print('Error: $e');
    continue; // Continúa pero no reporta
  }
}
return right(unit); // ❌ Siempre retorna éxito
```

El llamador cree que todo se sincronizó correctamente.

**Ahora:**
```dart
int failedCount = 0;

for (final activity in pendingActivities) {
  try {
    // sincronizar
  } catch (e) {
    failedCount++;
    debugPrint('Error: $e');
    continue;
  }
}

// ✅ Reporta fallos parciales
if (failedCount > 0) {
  return left(SyncFailure(failedCount));
}

return right(unit);
```

---

### 5. ✅ Método `getAllActivity` Corregido

**Antes:**
```dart
@override
Future<Either<String, Unit>> getAllActivity() async {
  return left('Método no implementado'); // ❌ Parece error de negocio
}
```

**Ahora:**
```dart
@override
Future<Either<ActivityFailure, Unit>> getAllActivity() {
  throw UnimplementedError(
    'getAllActivity no es requerido para esta funcionalidad'
  );
}
```

Lanza excepción en desarrollo, no confunde con error de negocio.

---

## 🟢 Mejoras Menores

### 6. ✅ Reemplazo de `print()` por `debugPrint()`

**Antes:**
```dart
print('⚠️ Error al sincronizar actividad ${activity.id}: $e');
```

**Ahora:**
```dart
debugPrint('⚠️ Error al sincronizar actividad ${activity.id}: $e');
```

`debugPrint()` se elimina automáticamente en builds de release.

---

## 📊 Comparación Antes/Después

| Aspecto | Antes | Ahora |
|---------|-------|-------|
| **Race conditions** | ❌ Posibles duplicados | ✅ Operación atómica |
| **Duplicados Firebase** | ❌ Posibles en reintentos | ✅ Idempotencia |
| **Tipos de error** | ❌ String genérico | ✅ Clases selladas |
| **Fallos parciales** | ❌ No se reportan | ✅ Se reportan |
| **getAllActivity** | ❌ Retorna error falso | ✅ Lanza excepción |
| **Logging** | ❌ print() en producción | ✅ debugPrint() |

---

## 🔄 Flujo Actualizado

### Crear Actividad

```
1. Generar ID local (UUID)
2. Guardar en caché con isSynced: false
3. ¿Hay internet?
   ├─ SÍ:
   │  ├─ Subir a Firebase (con idempotencia)
   │  ├─ Obtener ID de Firebase
   │  └─ updateActivityId() atómico ✅
   └─ NO: Queda pendiente
4. Retornar Either<ActivityFailure, Unit>
```

### Sincronizar Actividades

```
1. ¿Hay internet?
   └─ NO: return left(NetworkFailure())
2. Obtener pendientes (isSynced: false)
3. ¿Hay pendientes?
   └─ NO: return right(unit)
4. Para cada actividad:
   ├─ Subir a Firebase (con idempotencia) ✅
   ├─ updateActivityId() atómico ✅
   └─ Si falla: failedCount++
5. ¿Hubo fallos?
   ├─ SÍ: return left(SyncFailure(failedCount)) ✅
   └─ NO: return right(unit)
```

---

## 🎯 Archivos Modificados

### Nuevos Archivos

1. **`domain/failures/activity_failure.dart`** ✅
   - Clases selladas para errores tipados
   - `CacheFailure`, `NetworkFailure`, `SyncFailure`, `ServerFailure`

### Archivos Modificados

2. **`domain/repositories/user_activity_repository.dart`** ✅
   - Cambio de `Either<String, Unit>` a `Either<ActivityFailure, Unit>`
   - Import de `activity_failure.dart`

3. **`data/datasources/user_activity_remote_datasource.dart`** ✅
   - Método `createActivity()` con idempotencia
   - Verifica `localId` antes de crear documento
   - Retorna ID existente si ya fue creado

4. **`data/datasources/user_activity_local_datasource.dart`** ✅
   - Nuevo método `updateActivityId()` atómico
   - Usa transacción de Sembast

5. **`data/repositories/user_activity_repository_impl.dart`** ✅
   - Usa `updateActivityId()` en lugar de insert + delete
   - Retorna `ActivityFailure` en lugar de `String`
   - Reporta fallos parciales con `SyncFailure`
   - `getAllActivity()` lanza `UnimplementedError`
   - Usa `debugPrint()` en lugar de `print()`

---

## 🧪 Testing

### Casos de Prueba Críticos

#### 1. Race Condition
```dart
test('no debe crear duplicados si la app se cierra durante sync', () async {
  // Simular cierre de app entre operaciones
  // Verificar que solo existe un registro
});
```

#### 2. Idempotencia
```dart
test('no debe crear duplicados en Firebase en reintentos', () async {
  // Simular fallo de red después de crear documento
  // Reintentar sincronización
  // Verificar que solo existe un documento en Firebase
});
```

#### 3. Fallos Parciales
```dart
test('debe reportar cantidad de fallos en sincronización', () async {
  // Simular 3 actividades pendientes
  // Hacer que 1 falle
  // Verificar que retorna SyncFailure(1)
});
```

---

## 📚 Uso Actualizado

### Crear Actividad

```dart
final result = await repository.createActivity(activity);

result.fold(
  (failure) {
    switch (failure) {
      case CacheFailure(message: final msg):
        print('Error de caché: $msg');
      case ServerFailure(message: final msg):
        print('Error del servidor: $msg');
      default:
        print('Error desconocido');
    }
  },
  (_) => print('Actividad creada'),
);
```

### Sincronizar

```dart
final result = await repository.syncPendingActivities();

result.fold(
  (failure) {
    switch (failure) {
      case NetworkFailure():
        showSnackbar('Sin conexión a internet');
      case SyncFailure(failedCount: final count):
        showSnackbar('$count actividades no se sincronizaron');
      case CacheFailure(message: final msg):
        showSnackbar('Error: $msg');
      default:
        showSnackbar('Error desconocido');
    }
  },
  (_) => showSnackbar('Sincronización exitosa'),
);
```

---

## ✅ Checklist de Refactorización

- [x] Crear `ActivityFailure` con clases selladas
- [x] Actualizar interfaz del repositorio
- [x] Agregar idempotencia en remote datasource
- [x] Agregar `updateActivityId()` atómico en local datasource
- [x] Refactorizar `createActivity()` con operación atómica
- [x] Refactorizar `syncPendingActivities()` con reporte de fallos
- [x] Corregir `getAllActivity()` con `UnimplementedError`
- [x] Reemplazar `print()` por `debugPrint()`
- [x] Actualizar documentación
- [ ] Actualizar providers de Riverpod (siguiente paso)
- [ ] Actualizar use cases (siguiente paso)
- [ ] Actualizar UI para manejar nuevos tipos de error (siguiente paso)

---

## 🚀 Próximos Pasos

1. **Actualizar Providers**
   - Manejar `ActivityFailure` en lugar de `String`
   - Mostrar mensajes específicos según el tipo de error

2. **Actualizar Use Cases**
   - Propagar `ActivityFailure` correctamente
   - Agregar lógica de negocio si es necesario

3. **Actualizar UI**
   - Pattern matching en `ActivityFailure`
   - Mostrar mensajes de error específicos
   - Mostrar badge con cantidad de fallos en sync

---

**Última actualización:** Mayo 2026  
**Versión:** 2.0.0 (Refactorizada)
