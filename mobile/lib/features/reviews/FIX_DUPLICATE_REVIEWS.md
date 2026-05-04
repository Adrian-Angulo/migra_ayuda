# Fix: Problema de Reviews Duplicadas

## 🐛 Problema Identificado

Cuando un usuario agregaba un comentario, aparecían **2 reviews duplicadas** en la lista.

### Causa Raíz

El flujo de creación de reviews tenía el siguiente problema:

1. Se generaba un **ID local** (UUID) para la review
2. Se guardaba en Sembast con el ID local
3. Se subía a Firebase y Firebase generaba su **propio ID**
4. Se guardaba OTRA VEZ en Sembast con el ID de Firebase
5. **❌ NO se eliminaba el registro con ID local**

**Resultado**: 2 registros en Sembast (uno con ID local, otro con ID de Firebase) → 2 reviews duplicadas en la UI.

---

## ✅ Solución Implementada

### 1. Agregado método `deleteLocalRecord()` en ReviewLocalDataSource

**Archivo**: `data/datasources/review_local_datasource.dart`

```dart
/// Elimina un registro local por ID (hard delete - para limpiar duplicados)
Future<void> deleteLocalRecord(String recordId);
```

**Implementación**:
```dart
@override
Future<void> deleteLocalRecord(String recordId) async {
  try {
    final db = await _db;
    
    // Elimina el registro físicamente (hard delete)
    await _store.record(recordId).delete(db);
  } catch (e) {
    throw CacheException('Error al eliminar registro local: $e');
  }
}
```

### 2. Actualizado método `createReview()` en ReviewRepositoryImpl

**Archivo**: `data/repositories/review_repository_impl.dart`

**Antes**:
```dart
if (isConnected) {
  try {
    // 3. Si hay internet, sube a Firebase
    final firebaseId = await remoteDataSource.createReview(modelo);

    // 4. Actualiza el ID local con el ID de Firebase
    final syncedModel = ReviewModel(id: firebaseId, ...);

    // 5. Actualiza en caché con el ID de Firebase
    await localDataSource.cacheReview(syncedModel); // ❌ Crea duplicado
  }
}
```

**Después**:
```dart
if (isConnected) {
  try {
    // 3. Si hay internet, sube a Firebase
    final firebaseId = await remoteDataSource.createReview(modelo);

    // 4. ✅ ELIMINA el registro con ID local para evitar duplicados
    await localDataSource.deleteLocalRecord(localId);

    // 5. Crea el modelo con el ID de Firebase
    final syncedModel = ReviewModel(id: firebaseId, ...);

    // 6. Guarda en caché con el ID de Firebase
    await localDataSource.cacheReview(syncedModel);
  }
}
```

### 3. Actualizado método `syncPendingReviews()` en ReviewRepositoryImpl

**Archivo**: `data/repositories/review_repository_impl.dart`

Aplicada la misma corrección para evitar duplicados durante la sincronización en background:

```dart
// Si no tiene updatedAt, es una creación
final localId = review.id; // ✅ Guarda el ID local
final firebaseId = await remoteDataSource.createReview(review);

// ✅ ELIMINA el registro con ID local para evitar duplicados
await localDataSource.deleteLocalRecord(localId);

// Crea el modelo con el ID de Firebase
final syncedModel = ReviewModel(id: firebaseId, ...);

// Guarda con el ID de Firebase
await localDataSource.cacheReview(syncedModel);
```

---

## 🔄 Flujo Corregido

### Creación de Review (Online)

1. Usuario crea review
2. Se genera ID local (UUID): `abc-123-local`
3. Se guarda en Sembast con ID local
4. Se sube a Firebase → Firebase genera ID: `firebase-xyz-456`
5. **✅ Se ELIMINA el registro con ID local de Sembast**
6. Se guarda en Sembast con ID de Firebase
7. **Resultado**: Solo 1 registro en Sembast (con ID de Firebase)

### Creación de Review (Offline → Online)

1. Usuario crea review sin internet
2. Se genera ID local: `abc-123-local`
3. Se guarda en Sembast con `isSynced: false`
4. Usuario recupera conexión
5. `SyncService` detecta review pendiente
6. Se sube a Firebase → Firebase genera ID: `firebase-xyz-456`
7. **✅ Se ELIMINA el registro con ID local de Sembast**
8. Se guarda en Sembast con ID de Firebase y `isSynced: true`
9. **Resultado**: Solo 1 registro en Sembast (con ID de Firebase)

---

## 📊 Comparación Antes vs Después

### Antes (❌ Con Duplicados)

```
Sembast Store:
├── abc-123-local (ID local)
│   ├── comment: "Excelente servicio"
│   ├── rating: 5
│   └── isSynced: false
└── firebase-xyz-456 (ID Firebase) ← DUPLICADO
    ├── comment: "Excelente servicio"
    ├── rating: 5
    └── isSynced: true

UI muestra: 2 reviews idénticas
```

### Después (✅ Sin Duplicados)

```
Sembast Store:
└── firebase-xyz-456 (ID Firebase)
    ├── comment: "Excelente servicio"
    ├── rating: 5
    └── isSynced: true

UI muestra: 1 review
```

---

## 🧪 Testing

### Casos de Prueba

1. **✅ Crear review con internet**
   - Resultado: 1 review en UI
   - Sembast: 1 registro con ID de Firebase

2. **✅ Crear review sin internet → conectar**
   - Resultado: 1 review en UI
   - Sembast: 1 registro con ID de Firebase después de sincronizar

3. **✅ Crear múltiples reviews (diferentes usuarios)**
   - Resultado: N reviews en UI (sin duplicados)
   - Sembast: N registros únicos

4. **✅ Editar review**
   - Resultado: Review actualizada (sin duplicados)
   - Sembast: 1 registro actualizado

5. **✅ Eliminar review**
   - Resultado: Review eliminada
   - Sembast: Registro marcado como eliminado (soft delete)

---

## 🔍 Cómo Verificar la Corrección

### Método 1: Inspección de Sembast (Debug)

```dart
// En review_local_datasource.dart, agregar log temporal:
@override
Future<List<ReviewModel>> getCachedReviews() async {
  final db = await _db;
  final records = await _store.find(db);
  
  print('📊 Total reviews en Sembast: ${records.length}');
  for (final record in records) {
    print('  - ID: ${record.key}, Comment: ${record.value['comment']}');
  }
  
  return records.map((r) => _fromSembastMap(r.key, r.value)).toList();
}
```

### Método 2: Verificación en UI

1. Crear una review
2. Verificar que aparezca **solo 1 vez** en la lista
3. Cerrar y reabrir la app
4. Verificar que siga apareciendo **solo 1 vez**

### Método 3: Verificación en Firebase Console

1. Ir a Firebase Console → Firestore
2. Colección `reviews`
3. Verificar que cada review tenga un ID único de Firebase
4. No debe haber reviews con IDs tipo UUID local

---

## 📝 Notas Importantes

### Hard Delete vs Soft Delete

- **`deleteLocalRecord()`**: Hard delete (elimina físicamente)
  - Usado para limpiar duplicados de IDs locales
  - No afecta la lógica de soft delete de reviews

- **`deleteReview()`**: Soft delete (marca `deletedAt`)
  - Usado cuando el usuario elimina una review
  - Mantiene el registro para sincronización

### Impacto en Sincronización

- El `SyncService` ahora limpia correctamente los IDs locales
- No afecta reviews ya sincronizadas
- Solo afecta reviews pendientes de sincronización

### Retrocompatibilidad

- Si ya existen duplicados en Sembast, se recomienda:
  1. Limpiar caché: `await localDataSource.clearCache()`
  2. Recargar desde Firebase: `await repository.getAllReviews()`

---

## ✅ Archivos Modificados

1. **`data/datasources/review_local_datasource.dart`**
   - ✅ Agregado método `deleteLocalRecord()`

2. **`data/repositories/review_repository_impl.dart`**
   - ✅ Actualizado método `createReview()`
   - ✅ Actualizado método `syncPendingReviews()`

---

**Fix aplicado exitosamente** ✅

El problema de reviews duplicadas ha sido resuelto completamente.
