# ✅ PASO 2 COMPLETADO: DATA LAYER

## 📦 Archivos Creados

### 1. Local DataSource (Sembast)
**Archivo:** `data/datasources/review_local_datasource.dart`

**Métodos implementados:**
- ✅ `getCachedReviews()` - Obtiene todas las reviews del caché
- ✅ `getReviewsByEntity(entityId)` - Filtra reviews por entidad
- ✅ `cacheReview(review)` - Guarda/actualiza una review
- ✅ `cacheReviews(reviews)` - Guarda múltiples reviews
- ✅ `deleteReview(id)` - Soft delete (marca deletedAt)
- ✅ `getPendingReviews()` - Obtiene reviews con isSynced=false
- ✅ `markAsSynced(id)` - Marca review como sincronizada
- ✅ `clearCache()` - Limpia todo el caché

**Store Sembast:** `'reviews'`

**Estructura de datos en Sembast:**
```dart
{
  'idMigrante': String,
  'idEntity': String,
  'userName': String,
  'userCountry': String,
  'rating': double,
  'comment': String,
  'createdAt': int (milliseconds),
  'updatedAt': int? (milliseconds),
  'deletedAt': int? (milliseconds),
  'isSynced': bool,
  'cached_at': int (milliseconds)
}
```

**Características:**
- ✅ Soft delete (marca deletedAt en lugar de eliminar)
- ✅ Ordenamiento por fecha (más recientes primero)
- ✅ Filtrado por entidad
- ✅ Trackeo de sincronización (isSynced)
- ✅ Timestamp de caché (cached_at)

---

### 2. Remote DataSource (Firebase)
**Archivo:** `data/datasources/review_remote_datasource.dart`

**Métodos implementados:**
- ✅ `createReview(review)` - Crea en Firestore
- ✅ `getAllReviews()` - Obtiene todas las reviews
- ✅ `getReviewsByEntity(entityId)` - Filtra por entidad
- ✅ `updateReview(review)` - Actualiza en Firestore
- ✅ `deleteReview(id)` - Elimina de Firestore (hard delete)

**Colección Firebase:** `'reviews'`

**Estructura de datos en Firestore:**
```dart
{
  'idMigrante': String,
  'idEntity': String,
  'userName': String,
  'userCountry': String,
  'rating': double,
  'comment': String,
  'createdAt': String (ISO8601),
  'updatedAt': String? (ISO8601),
  'deletedAt': String? (ISO8601),
  'isSynced': bool
}
```

**Características:**
- ✅ Hard delete en Firebase (elimina físicamente)
- ✅ Ordenamiento por fecha (más recientes primero)
- ✅ Filtrado por entidad con índice
- ✅ Conversión automática de timestamps
- ✅ Manejo de errores con ServerException

---

### 3. Repository Implementation (Offline-First)
**Archivo:** `data/repositories/review_repository_impl.dart`

**Estrategia Offline-First implementada:**

#### CREATE REVIEW
```
1. Genera ID único local (UUID)
2. Guarda en Sembast con isSynced=false
3. ¿Hay internet?
   ├─ SÍ → Sube a Firebase → Obtiene ID de Firebase
   │        → Actualiza caché con ID de Firebase
   │        → Marca isSynced=true
   └─ NO → Queda pendiente de sincronización
4. Retorna éxito al usuario
```

#### READ REVIEWS
```
1. Lee de Sembast (respuesta inmediata)
2. ¿Hay internet?
   ├─ SÍ → Obtiene de Firebase → Actualiza Sembast
   │        → Retorna datos frescos
   └─ NO → Retorna datos del caché
3. Si no hay caché ni internet → Error
```

#### UPDATE REVIEW
```
1. Actualiza en Sembast con isSynced=false
2. Actualiza timestamp updatedAt
3. ¿Hay internet?
   ├─ SÍ → Actualiza en Firebase
   │        → Marca isSynced=true en caché
   └─ NO → Queda pendiente de sincronización
4. Retorna éxito al usuario
```

#### DELETE REVIEW
```
1. Marca deletedAt en Sembast (soft delete)
2. Marca isSynced=false
3. ¿Hay internet?
   ├─ SÍ → Elimina de Firebase (hard delete)
   └─ NO → Queda pendiente de sincronización
4. Retorna éxito al usuario
```

#### SYNC PENDING REVIEWS
```
1. Verifica conexión a internet
2. Obtiene reviews con isSynced=false
3. Para cada review pendiente:
   ├─ Si deletedAt != null → Elimina de Firebase
   ├─ Si updatedAt != null → Actualiza en Firebase
   └─ Si es nueva → Crea en Firebase
4. Marca como sincronizadas
5. Retorna éxito
```

**Características:**
- ✅ Respuesta inmediata al usuario (caché primero)
- ✅ Sincronización en background
- ✅ Funciona sin internet
- ✅ Manejo robusto de errores
- ✅ Generación de IDs únicos con UUID
- ✅ Actualización automática de timestamps

---

## 🔄 FLUJO COMPLETO DE DATOS

### Ejemplo: Usuario crea review sin internet

```
Usuario escribe review
    ↓
CreateReviewUsecase valida datos
    ↓
Repository genera ID local (UUID)
    ↓
LocalDataSource guarda en Sembast
    isSynced = false
    ↓
NetworkInfo detecta sin internet
    ↓
Repository retorna éxito
    ↓
Usuario ve "Review guardada localmente"
    ↓
[Tiempo después...]
    ↓
NetworkInfo detecta internet
    ↓
SyncService llama syncPendingReviews()
    ↓
Repository obtiene reviews pendientes
    ↓
RemoteDataSource sube a Firebase
    ↓
Firebase retorna ID
    ↓
LocalDataSource actualiza con ID de Firebase
    isSynced = true
    ↓
Sincronización completa
```

---

## 📊 Resumen

| Componente | Archivos | Métodos | Estado |
|------------|----------|---------|--------|
| Local DataSource | 1 | 8 | ✅ Completado |
| Remote DataSource | 1 | 5 | ✅ Completado |
| Repository Impl | 1 | 6 | ✅ Completado |
| **Total** | **3 archivos** | **19 métodos** | ✅ **100% Completado** |

---

## ✅ Verificación

- ✅ Sin errores de compilación
- ✅ Estrategia Offline-First implementada
- ✅ Soft delete en local, hard delete en remoto
- ✅ Sincronización automática
- ✅ Generación de IDs únicos
- ✅ Manejo robusto de errores
- ✅ Conversión de timestamps
- ✅ Filtrado y ordenamiento

---

## 🚀 Siguiente Paso

**PASO 3: PRESENTATION LAYER**
- Implementar `review_providers.dart` (Riverpod providers)
- Implementar `review_sync_provider.dart` (Sincronización automática)
- Integrar con `main.dart`

---

## 📝 Notas Técnicas

### Generación de IDs
Se usa el paquete `uuid` para generar IDs únicos locales:
```dart
final localId = const Uuid().v4();
```

Cuando se sincroniza con Firebase, el ID local se reemplaza con el ID de Firebase.

### Soft Delete vs Hard Delete
- **Local (Sembast):** Soft delete - marca `deletedAt`
- **Remote (Firebase):** Hard delete - elimina físicamente

Esto permite:
- Recuperar reviews eliminadas localmente
- Sincronización correcta con Firebase
- Auditoría de eliminaciones

### Timestamps
- **Sembast:** Almacena como `int` (milliseconds)
- **Firebase:** Almacena como `String` (ISO8601)
- Conversión automática en ambas direcciones

### Índices Firebase Necesarios
Para optimizar las consultas, crear estos índices en Firestore:

```
Collection: reviews
- idEntity (Ascending) + createdAt (Descending)
- idMigrante (Ascending) + createdAt (Descending)
- isSynced (Ascending) + createdAt (Descending)
```

### Dependencias Necesarias
Asegúrate de tener en `pubspec.yaml`:
```yaml
dependencies:
  uuid: ^4.0.0  # Para generar IDs únicos
  sembast: ^3.0.0  # Base de datos local
  cloud_firestore: ^4.0.0  # Firebase Firestore
  dartz: ^0.10.0  # Either para manejo de errores
```

---

**Tiempo de implementación:** ~1 hora
**Estado:** ✅ COMPLETADO SIN ERRORES
