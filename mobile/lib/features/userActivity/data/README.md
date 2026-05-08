# 📚 Documentación - Capa de Datos de UserActivity

## 🎯 Objetivo

Esta capa implementa la funcionalidad de **crear** y **sincronizar** actividades de usuario con una estrategia **Offline-First**, permitiendo que la aplicación funcione sin conexión a internet.

---

## 📁 Estructura de Archivos

```
data/
├── datasources/
│   ├── user_activity_local_datasource.dart   # Caché local (Sembast)
│   └── user_activity_remote_datasource.dart  # Firebase Firestore
├── models/
│   └── user_activity_model.dart              # Modelo de datos
├── repositories/
│   └── user_activity_repository_impl.dart    # Implementación del repositorio
└── README.md                                  # Esta documentación
```

---

## 🔄 Flujo de Datos - Estrategia Offline-First

### 1️⃣ Crear Actividad (`createActivity`)

```
┌─────────────────────────────────────────────────────────────┐
│ 1. Usuario crea actividad                                   │
└─────────────────────────────────────────────────────────────┘
                          ↓
┌─────────────────────────────────────────────────────────────┐
│ 2. Generar ID único local (UUID)                            │
│    Ejemplo: "a1b2c3d4-e5f6-7890-abcd-ef1234567890"         │
└─────────────────────────────────────────────────────────────┘
                          ↓
┌─────────────────────────────────────────────────────────────┐
│ 3. Guardar en caché local (Sembast)                         │
│    - isSynced: false                                        │
│    - Respuesta INMEDIATA al usuario ✅                      │
└─────────────────────────────────────────────────────────────┘
                          ↓
┌─────────────────────────────────────────────────────────────┐
│ 4. ¿Hay conexión a internet?                                │
└─────────────────────────────────────────────────────────────┘
         ↓ SÍ                              ↓ NO
┌──────────────────────┐      ┌──────────────────────────────┐
│ 5. Subir a Firebase  │      │ Queda pendiente              │
│    Obtener ID real   │      │ Se sincronizará después      │
└──────────────────────┘      └──────────────────────────────┘
         ↓
┌──────────────────────┐
│ 6. Actualizar caché  │
│    - ID: Firebase ID │
│    - isSynced: true  │
└──────────────────────┘
         ↓
┌──────────────────────┐
│ 7. Eliminar registro │
│    con ID local      │
└──────────────────────┘
```

---

### 2️⃣ Sincronizar Actividades Pendientes (`syncPendingActivities`)

```
┌─────────────────────────────────────────────────────────────┐
│ 1. Usuario solicita sincronización (o automática)           │
└─────────────────────────────────────────────────────────────┘
                          ↓
┌─────────────────────────────────────────────────────────────┐
│ 2. ¿Hay conexión a internet?                                │
└─────────────────────────────────────────────────────────────┘
         ↓ NO                               ↓ SÍ
┌──────────────────────┐      ┌──────────────────────────────┐
│ Retornar error       │      │ 3. Obtener actividades       │
│ "Sin conexión"       │      │    pendientes (isSynced=false)│
└──────────────────────┘      └──────────────────────────────┘
                                           ↓
                              ┌──────────────────────────────┐
                              │ 4. ¿Hay actividades          │
                              │    pendientes?               │
                              └──────────────────────────────┘
                                  ↓ NO          ↓ SÍ
                         ┌──────────────┐  ┌─────────────────┐
                         │ Retornar OK  │  │ 5. PARA CADA    │
                         │ (nada que    │  │    actividad:   │
                         │  sincronizar)│  └─────────────────┘
                         └──────────────┘           ↓
                                           ┌─────────────────┐
                                           │ - Subir a       │
                                           │   Firebase      │
                                           │ - Obtener ID    │
                                           │ - Actualizar    │
                                           │   caché         │
                                           │ - Eliminar ID   │
                                           │   local         │
                                           └─────────────────┘
                                                    ↓
                                           ┌─────────────────┐
                                           │ 6. Retornar OK  │
                                           └─────────────────┘
```

---

## 📦 Componentes Detallados

### 1. **UserActivityModel** (`models/user_activity_model.dart`)

**Propósito:** Modelo de datos que extiende la entidad del dominio.

**Campos:**
```dart
- id: String           // ID único (local o Firebase)
- idUser: String       // ID del usuario que realizó la acción
- accion: String       // Descripción de la acción
- createdAt: DateTime  // Fecha y hora de creación
- isSynced: bool       // ¿Está sincronizada con Firebase?
```

**Métodos:**
- `fromMap()` - Deserializa desde Map
- `toMap()` - Serializa a Map
- `copyWith()` - Crea copia con campos actualizados

---

### 2. **UserActivityRemoteDataSource** (`datasources/user_activity_remote_datasource.dart`)

**Propósito:** Comunicación con Firebase Firestore.

**Métodos:**
```dart
createActivity(UserActivityModel) → Future<String>
```

**Colección Firebase:** `user_activities`

**Estructura del documento:**
```json
{
  "idUser": "user123",
  "accion": "Inició sesión",
  "createdAt": "2026-05-04T10:30:00.000Z",
  "isSynced": true
}
```

---

### 3. **UserActivityLocalDataSource** (`datasources/user_activity_local_datasource.dart`)

**Propósito:** Almacenamiento local con Sembast (caché offline).

**Métodos:**
```dart
cacheActivity(UserActivityModel) → Future<void>
  // Guarda/actualiza una actividad en caché

getPendingActivities() → Future<List<UserActivityModel>>
  // Obtiene actividades con isSynced = false

markAsSynced(String activityId) → Future<void>
  // Marca una actividad como sincronizada

deleteLocalRecord(String recordId) → Future<void>
  // Elimina físicamente un registro (limpia duplicados)
```

**Store Sembast:** `user_activities`

---

### 4. **UserActivityRepositoryImpl** (`repositories/user_activity_repository_impl.dart`)

**Propósito:** Orquesta los datasources local y remoto.

**Métodos:**
```dart
createActivity(UserActivityEntity) → Future<Either<String, Unit>>
  // Crea actividad con estrategia Offline-First

syncPendingActivities() → Future<Either<String, Unit>>
  // Sincroniza actividades pendientes con Firebase
```

---

## 🚀 Cómo Usar

### Ejemplo 1: Crear una Actividad

```dart
// En tu caso de uso o provider
final result = await repository.createActivity(
  UserActivityEntity(
    id: '', // Se genera automáticamente
    idUser: 'user123',
    accion: 'Inició sesión',
    createdAt: DateTime.now(),
  ),
);

result.fold(
  (error) => print('Error: $error'),
  (_) => print('Actividad creada exitosamente'),
);
```

**Resultado:**
- ✅ Se guarda localmente de inmediato
- ✅ Si hay internet, se sincroniza automáticamente
- ✅ Si no hay internet, queda pendiente

---

### Ejemplo 2: Sincronizar Actividades Pendientes

```dart
// Llamar manualmente o en un timer periódico
final result = await repository.syncPendingActivities();

result.fold(
  (error) => print('Error al sincronizar: $error'),
  (_) => print('Sincronización exitosa'),
);
```

**Cuándo llamar:**
- Al iniciar la app (si hay conexión)
- Cuando se detecta conexión a internet
- Periódicamente (cada X minutos)
- Manualmente por el usuario

---

## ⚠️ Manejo de Errores

### Tipos de Errores

1. **CacheException** - Error en el almacenamiento local
   ```dart
   'Error de caché: [mensaje]'
   ```

2. **ServerException** - Error en Firebase
   ```dart
   'Error del servidor: [mensaje]'
   ```

3. **Sin conexión**
   ```dart
   'No hay conexión a internet para sincronizar'
   ```

### Estrategia de Recuperación

- Si falla Firebase pero se guardó localmente → **Éxito parcial**
- Si falla el caché → **Error crítico**
- Si no hay internet → **Éxito** (se sincronizará después)

---

## 🔍 Debugging

### Ver actividades pendientes en Sembast

```dart
final pending = await localDataSource.getPendingActivities();
print('Actividades pendientes: ${pending.length}');
for (final activity in pending) {
  print('- ${activity.accion} (${activity.id})');
}
```

### Verificar sincronización

```dart
// Antes de sincronizar
final beforeSync = await localDataSource.getPendingActivities();
print('Pendientes antes: ${beforeSync.length}');

// Sincronizar
await repository.syncPendingActivities();

// Después de sincronizar
final afterSync = await localDataSource.getPendingActivities();
print('Pendientes después: ${afterSync.length}');
```

---

## 📊 Flujo de IDs

### Ciclo de vida de un ID

```
1. Creación Offline:
   ID Local: "a1b2c3d4-e5f6-7890-abcd-ef1234567890"
   isSynced: false
   
2. Sincronización:
   ID Firebase: "xYz123AbC456"
   isSynced: true
   
3. Limpieza:
   Se elimina el registro con ID local
   Solo queda el registro con ID de Firebase
```

---

## ✅ Checklist de Implementación

- [x] Modelo de datos creado
- [x] Remote datasource implementado
- [x] Local datasource implementado
- [x] Repository implementado
- [x] Manejo de errores con Either
- [x] Estrategia Offline-First
- [x] Sincronización de pendientes
- [x] Limpieza de duplicados
- [ ] Providers de Riverpod (siguiente paso)
- [ ] Use cases del dominio (siguiente paso)
- [ ] Integración en la UI (siguiente paso)

---

## 🎓 Conceptos Clave

### Offline-First
La app funciona sin internet. Los datos se guardan localmente primero y se sincronizan cuando hay conexión.

### isSynced
Flag booleano que indica si una actividad está sincronizada con Firebase.
- `false` = Pendiente de sincronización
- `true` = Ya está en Firebase

### UUID
Identificador único universal generado localmente. Se reemplaza por el ID de Firebase después de sincronizar.

### Either<L, R>
Tipo funcional de `dartz` que representa un resultado que puede ser:
- `Left(error)` = Error
- `Right(value)` = Éxito

---

## 📞 Soporte

Si tienes dudas sobre la implementación:
1. Revisa los comentarios en el código
2. Consulta esta documentación
3. Revisa los ejemplos de uso
4. Verifica el flujo de datos

---

**Última actualización:** Mayo 2026
**Versión:** 1.0.0
