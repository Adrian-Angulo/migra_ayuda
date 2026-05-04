# Implementación: Un Usuario Solo Puede Tener Una Review Por Entidad

## 📋 Resumen

Se implementó la regla de negocio: **"Un usuario solo puede tener una review por entidad"**. Si el usuario intenta agregar otra review, se abre automáticamente la pantalla de edición de su review existente.

---

## ✅ Archivos Creados

### Domain Layer
1. **`domain/usecases/get_user_review_by_entity_usecase.dart`**
   - Caso de uso para obtener la review de un usuario específico en una entidad
   - Valida que los IDs no estén vacíos
   - Retorna `ReviewEntity?` (null si no existe)

### Presentation Layer
2. **`presentation/providers/states/edit_review_state.dart`**
   - Estado para el proceso de edición de reviews
   - Propiedades: `isLoading`, `isSuccess`, `errorMessage`

3. **`presentation/providers/edit_review_provider.dart`**
   - Notifier para manejar edición y eliminación de reviews
   - Métodos: `updateReview()`, `deleteReview()`, `reset()`
   - Invalida providers automáticamente después de operaciones

4. **`presentation/screens/place_edit_review.dart`**
   - Pantalla completa para editar reviews existentes
   - Pre-llena campos con datos existentes
   - Botón de eliminar en AppBar con confirmación
   - Banner informativo "Estás editando tu comentario existente"
   - Validaciones: 10-500 caracteres, rating 1-5
   - Feedback visual: loading, success, error con SnackBars

---

## 🔧 Archivos Modificados

### Domain Layer
5. **`domain/repositories/review_repository.dart`**
   - ✅ Agregado método: `getUserReviewByEntity(userId, entityId)`

6. **`domain/usecases/create_review_usecase.dart`**
   - ✅ Agregada validación de duplicados antes de crear
   - ✅ Verifica si el usuario ya tiene una review en la entidad
   - ✅ Retorna error: "Ya has publicado una review en esta entidad. Puedes editarla o eliminarla."

### Data Layer
7. **`data/datasources/review_local_datasource.dart`**
   - ✅ Agregado método: `getUserReviewByEntity(userId, entityId)`
   - ✅ Usa filtro compuesto: `idMigrante` + `idEntity` + `deletedAt IS NULL`
   - ✅ Excluye reviews eliminadas (soft delete)

8. **`data/datasources/review_remote_datasource.dart`**
   - ✅ Agregado método: `getUserReviewByEntity(userId, entityId)`
   - ✅ Query Firebase con `where('idMigrante')` + `where('idEntity')`
   - ✅ Limit 1 para optimización

9. **`data/repositories/review_repository_impl.dart`**
   - ✅ Implementado método: `getUserReviewByEntity(userId, entityId)`
   - ✅ Estrategia Offline-First: caché primero, luego Firebase
   - ✅ Actualiza caché con datos frescos de Firebase

### Presentation Layer
10. **`presentation/providers/review_providers.dart`**
    - ✅ Agregado import: `GetUserReviewByEntityUsecase`
    - ✅ Agregado provider: `getUserReviewByEntityUsecaseProvider`
    - ✅ Agregado provider: `userReviewByEntityProvider` (FutureProvider.family)
    - ✅ Agregado provider: `userHasReviewProvider` (Provider.family)

11. **`presentation/screens/place_details_screen.dart`**
    - ✅ Agregado import: `PlaceEditReview`
    - ✅ Agregada lógica para detectar review existente del usuario
    - ✅ Botón cambia texto: "Añadir comentario" → "Editar comentario"
    - ✅ Navegación condicional:
      - Si tiene review → `PlaceEditReview`
      - Si no tiene review → `PlaceAddReview`
    - ✅ Validación de autenticación antes de navegar
    - ✅ Manejo de estados: loading, error

---

## 🎯 Flujo de Usuario

### Caso 1: Usuario SIN review existente
1. Usuario hace clic en "Añadir comentario"
2. Sistema verifica: no tiene review
3. Navega a `PlaceAddReview`
4. Usuario crea su review
5. Sistema valida que no exista duplicado (doble verificación)
6. Review se guarda exitosamente

### Caso 2: Usuario CON review existente
1. Usuario hace clic en "Editar comentario"
2. Sistema detecta review existente
3. Navega a `PlaceEditReview` con datos pre-llenados
4. Usuario puede:
   - **Editar**: Modifica rating/comentario y guarda
   - **Eliminar**: Hace clic en ícono de eliminar → confirmación → elimina

### Caso 3: Usuario intenta crear duplicado (validación backend)
1. Usuario intenta crear review
2. `CreateReviewUsecase` verifica si ya existe
3. Si existe, retorna error: "Ya has publicado una review..."
4. UI muestra SnackBar con el error
5. Usuario debe editar su review existente

---

## 🔒 Validaciones Implementadas

### Validación en CreateReviewUsecase
```dart
// Verifica si el usuario ya tiene una review en esta entidad
final existingReviewResult = await repository.getUserReviewByEntity(
  review.idMigrante,
  review.idEntity,
);

if (existingReview != null) {
  return left('Ya has publicado una review en esta entidad. Puedes editarla o eliminarla.');
}
```

### Validación en UI (PlaceDetailsScreen)
```dart
userReviewAsync?.when(
  data: (existingReview) {
    if (existingReview != null) {
      // Navega a editar
      Navigator.push(context, MaterialPageRoute(
        builder: (context) => PlaceEditReview(...)
      ));
    } else {
      // Navega a crear
      Navigator.push(context, MaterialPageRoute(
        builder: (context) => PlaceAddReview(...)
      ));
    }
  },
  ...
);
```

---

## 📊 Providers Agregados

### `userReviewByEntityProvider`
- **Tipo**: `FutureProvider.family<ReviewEntity?, ({String userId, String entityId})>`
- **Uso**: `ref.watch(userReviewByEntityProvider((userId: 'id', entityId: 'id')))`
- **Retorna**: `ReviewEntity?` (null si no existe)

### `userHasReviewProvider`
- **Tipo**: `Provider.family<bool, ({String userId, String entityId})>`
- **Uso**: `ref.watch(userHasReviewProvider((userId: 'id', entityId: 'id')))`
- **Retorna**: `true` si el usuario tiene review, `false` si no

### `editReviewProvider`
- **Tipo**: `NotifierProvider<EditReviewNotifier, EditReviewState>`
- **Uso**: `ref.read(editReviewProvider.notifier).updateReview(...)`
- **Métodos**: `updateReview()`, `deleteReview()`, `reset()`

---

## 🎨 UI/UX Implementado

### PlaceEditReview Screen
- ✅ Banner informativo verde: "Estás editando tu comentario existente"
- ✅ Campos pre-llenados con datos existentes
- ✅ Botón de eliminar en AppBar (ícono rojo)
- ✅ Diálogo de confirmación para eliminar
- ✅ Botón principal: "Actualizar Comentario" (cambia a "Actualizando..." cuando carga)
- ✅ SnackBars de éxito/error
- ✅ Cierra automáticamente después de éxito

### PlaceDetailsScreen
- ✅ Botón dinámico: "Añadir comentario" / "Editar comentario"
- ✅ Validación de autenticación
- ✅ SnackBar de loading mientras verifica review existente
- ✅ Navegación condicional según estado

---

## 🔄 Estrategia Offline-First

### getUserReviewByEntity
1. **Caché primero**: Busca en Sembast (respuesta inmediata)
2. **Verifica conexión**: Si hay internet, consulta Firebase
3. **Actualiza caché**: Guarda datos frescos de Firebase
4. **Retorna**: Datos de Firebase si hay conexión, caché si no hay

### Filtros Implementados
- **Local (Sembast)**: `idMigrante` + `idEntity` + `deletedAt IS NULL`
- **Remoto (Firebase)**: `where('idMigrante')` + `where('idEntity')` + `limit(1)`

---

## 📝 Notas Importantes

### Índice Compuesto en Firebase (PENDIENTE)
Para optimizar las queries en Firebase, se recomienda crear un índice compuesto:
- **Colección**: `reviews`
- **Campos**: `idMigrante` (Ascending) + `idEntity` (Ascending)
- **Opcional**: Agregar `deletedAt` si se implementa soft delete en Firebase

### Sincronización
- Las reviews editadas se marcan como `isSynced: false`
- El `SyncService` las sincronizará automáticamente cuando haya conexión
- La eliminación es soft delete local, hard delete remoto

### Invalidación de Providers
Después de editar o eliminar, se invalidan automáticamente:
- `reviewsByEntityStreamProvider(entityId)` → Actualiza lista de reviews
- `userReviewByEntityProvider((userId, entityId))` → Actualiza review del usuario

---

## ✅ Testing Recomendado

### Casos de Prueba
1. ✅ Usuario sin review → Puede crear
2. ✅ Usuario con review → Puede editar
3. ✅ Usuario intenta crear duplicado → Error
4. ✅ Usuario edita review → Se actualiza correctamente
5. ✅ Usuario elimina review → Se elimina correctamente
6. ✅ Usuario sin autenticación → SnackBar de error
7. ✅ Offline: Crear/editar/eliminar → Se guarda localmente
8. ✅ Online: Sincronización automática

---

## 🚀 Próximos Pasos (Opcional)

1. **Crear índice compuesto en Firebase** (ver sección "Índice Compuesto")
2. **Testing unitario** de los nuevos use cases
3. **Testing de integración** del flujo completo
4. **Monitoreo** de errores en producción
5. **Analytics** para trackear ediciones/eliminaciones

---

## 📦 Resumen de Cambios

- **Archivos creados**: 4
- **Archivos modificados**: 7
- **Total de archivos afectados**: 11
- **Nuevos providers**: 3
- **Nuevos use cases**: 1
- **Nuevas pantallas**: 1

---

**Implementación completada exitosamente** ✅
