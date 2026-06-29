# 🌐 Guía - EntityWebRepositoryImpl

## 📋 Resumen

Implementación del repositorio de entidades **específica para aplicaciones WEB**. Esta versión se comunica directamente con Firebase sin usar caché local (Sembast).

---

## ✅ Implementación Completada

### Métodos Implementados

| Método | Estado | Descripción |
|--------|--------|-------------|
| `registerEntity()` | ✅ | Registra nueva entidad con imagen |
| `updateEntity()` | ✅ | Actualiza entidad existente |
| `deleteEntity()` | ✅ | Elimina entidad de Firebase |
| `getAllEntities()` | ✅ | Obtiene todas las entidades |
| `getEntityById()` | ✅ | Obtiene entidad específica por ID |
| `syncAllFromFirebase()` | ⚠️ | No implementado (lanza UnimplementedError) |

---

## 🔄 Flujo de Datos

### Arquitectura Web (Online-Only)

```
┌─────────────────────────────────────────────────────────────┐
│                    APLICACIÓN WEB                            │
└─────────────────────────────────────────────────────────────┘
                          ↓
┌─────────────────────────────────────────────────────────────┐
│              EntityWebRepositoryImpl                         │
│  - Sin caché local                                          │
│  - Sin verificación de conexión                             │
│  - Comunicación directa con Firebase                        │
└─────────────────────────────────────────────────────────────┘
                          ↓
┌─────────────────────────────────────────────────────────────┐
│           EntityRemoteDataSource                             │
│  - Sube imágenes a Cloudinary                               │
│  - Lee/Escribe en Firebase Firestore                        │
└─────────────────────────────────────────────────────────────┘
                          ↓
┌─────────────────────────────────────────────────────────────┐
│                  FIREBASE + CLOUDINARY                       │
└─────────────────────────────────────────────────────────────┘
```

---

## 📦 Diferencias con Mobile

| Aspecto | Mobile (Offline-First) | Web (Online-Only) |
|---------|------------------------|-------------------|
| **Caché local** | ✅ Sembast | ❌ No usa |
| **NetworkInfo** | ✅ Verifica conexión | ❌ No necesita |
| **Estrategia** | Cache-First | Remote-Only |
| **Respuesta** | Instantánea (caché) | Depende de Firebase |
| **Offline** | ✅ Funciona | ❌ Requiere internet |
| **Sincronización** | ✅ Bidireccional | ❌ No aplica |
| **Complejidad** | Alta | Baja |

---

## 🎯 Métodos Detallados

### 1. registerEntity()

**Propósito:** Registrar una nueva entidad con imagen

**Flujo:**
```
1. Convertir EntityEntity → EntityModels
2. Llamar a remoteDataSource.registerEntity()
   ├─ Sube imagen a Cloudinary
   └─ Guarda entidad en Firebase con URL de imagen
3. Retornar Right(unit) si éxito
4. Retornar Left(error) si falla
```

**Ejemplo de uso:**
```dart
final result = await repository.registerEntity(
  entity: EntityEntity(
    id: '',
    name: 'Hospital General',
    description: 'Hospital público',
    services: ['Emergencias', 'Consulta'],
    address: 'Calle 123',
    localitation: GeoPoint(40.7128, -74.0060),
    phone: '555-1234',
    serviceHours: '24/7',
    imageUrl: '',
  ),
  imagenBytes: imageBytes,
  fileName: 'hospital.jpg',
);

result.fold(
  (error) => print('Error: $error'),
  (_) => print('Entidad registrada exitosamente'),
);
```

---

### 2. updateEntity()

**Propósito:** Actualizar una entidad existente

**Flujo:**
```
1. Convertir EntityEntity → EntityModels
2. Llamar a remoteDataSource.updateEntity()
   ├─ Si hay nueva imagen, la sube a Cloudinary
   └─ Actualiza entidad en Firebase
3. Retornar Right(unit) si éxito
4. Retornar Left(error) si falla
```

**Ejemplo de uso:**
```dart
// Actualizar sin cambiar imagen
final result = await repository.updateEntity(
  entity: updatedEntity,
);

// Actualizar con nueva imagen
final result = await repository.updateEntity(
  entity: updatedEntity,
  imagenBytes: newImageBytes,
  fileName: 'new_image.jpg',
);
```

---

### 3. deleteEntity()

**Propósito:** Eliminar una entidad

**Flujo:**
```
1. Llamar a remoteDataSource.deleteEntity(entityId)
2. Retornar Right(unit) si éxito
3. Retornar Left(error) si falla
```

**Ejemplo de uso:**
```dart
final result = await repository.deleteEntity('entity123');

result.fold(
  (error) => print('Error: $error'),
  (_) => print('Entidad eliminada'),
);
```

---

### 4. getAllEntities()

**Propósito:** Obtener todas las entidades

**Flujo:**
```
1. Llamar a remoteDataSource.getAllEntities()
2. Retornar Right(List<EntityEntity>) si éxito
3. Retornar Left(error) si falla
```

**Características:**
- ✅ Siempre retorna datos frescos de Firebase
- ❌ No usa caché (más lento que mobile)
- ⚠️ Requiere conexión a internet

**Ejemplo de uso:**
```dart
final result = await repository.getAllEntities();

result.fold(
  (error) => print('Error: $error'),
  (entities) => print('${entities.length} entidades obtenidas'),
);
```

---

### 5. getEntityById()

**Propósito:** Obtener una entidad específica

**Flujo:**
```
1. Llamar a remoteDataSource.getEntityById(id)
2. Retornar Right(EntityEntity) si éxito
3. Retornar Left(error) si falla
```

**Ejemplo de uso:**
```dart
final result = await repository.getEntityById('entity123');

result.fold(
  (error) => print('Error: $error'),
  (entity) => print('Entidad: ${entity.name}'),
);
```

---

### 6. syncAllFromFirebase() ⚠️

**Estado:** No implementado

**Razón:**
- En web no hay caché local que sincronizar
- Cada llamada ya obtiene datos frescos de Firebase
- Este método es específico para la estrategia offline-first de mobile

**Comportamiento:**
```dart
throw UnimplementedError(
  'syncAllFromFirebase no está disponible en la versión web. '
  'En web, cada llamada a getAllEntities() ya obtiene datos frescos de Firebase.',
);
```

---

## ⚠️ Manejo de Errores

### Tipos de Errores

1. **ServerException**
   ```dart
   'Error del servidor: [mensaje]'
   ```
   - Error de Firebase
   - Error de Cloudinary
   - Error de red

2. **Exception Genérica**
   ```dart
   'Error al [acción]: [mensaje]'
   ```
   - Cualquier otro error no esperado

### Estrategia de Manejo

```dart
try {
  // Operación con Firebase
  await remoteDataSource.someMethod();
  return right(unit);
} on ServerException catch (e) {
  return left('Error del servidor: ${e.message}');
} catch (e) {
  return left('Error al realizar operación: ${e.toString()}');
}
```

---

## 🚀 Cómo Usar

### Paso 1: Crear el Provider

```dart
// En entity_providers.dart (para web)
final entityWebRepositoryProvider = Provider<EntityRepository>((ref) {
  final remoteDataSource = EntityRemoteDataSource();
  
  return EntityWebRepositoryImpl(
    remoteDataSource: remoteDataSource,
  );
});
```

### Paso 2: Usar en Use Cases

```dart
// Use case para web
class GetAllEntitiesUseCase {
  final EntityRepository repository;
  
  GetAllEntitiesUseCase(this.repository);
  
  Future<Either<String, List<EntityEntity>>> call() {
    return repository.getAllEntities();
  }
}
```

### Paso 3: Usar en la UI

```dart
// En un widget
final result = await ref.read(getAllEntitiesUseCaseProvider).call();

result.fold(
  (error) {
    // Mostrar error al usuario
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(error)),
    );
  },
  (entities) {
    // Mostrar entidades
    setState(() {
      _entities = entities;
    });
  },
);
```

---

## 💡 Ventajas de la Implementación Web

1. **Simplicidad**
   - Menos código que mobile
   - Sin lógica de caché
   - Sin verificación de conexión

2. **Datos Frescos**
   - Siempre obtiene datos actualizados de Firebase
   - No hay riesgo de datos desactualizados

3. **Menos Dependencias**
   - Solo necesita `EntityRemoteDataSource`
   - No necesita `NetworkInfo`
   - No necesita `EntityLocalDataSource`

4. **Mantenimiento**
   - Más fácil de mantener
   - Menos casos edge
   - Menos bugs potenciales

---

## ⚠️ Desventajas

1. **Requiere Internet**
   - No funciona sin conexión
   - Cada operación depende de Firebase

2. **Más Lento**
   - No hay respuesta instantánea del caché
   - Depende de la latencia de red

3. **Más Costoso**
   - Más lecturas de Firebase
   - Más ancho de banda

4. **Sin Soporte Offline**
   - No se pueden ver datos sin internet
   - No se pueden hacer operaciones offline

---

## 🔍 Debugging

### Ver Errores de Firebase

```dart
final result = await repository.getAllEntities();

result.fold(
  (error) {
    print('❌ Error: $error');
    // Analizar el tipo de error
    if (error.contains('servidor')) {
      print('Error de Firebase o Cloudinary');
    } else {
      print('Error desconocido');
    }
  },
  (entities) {
    print('✅ ${entities.length} entidades obtenidas');
  },
);
```

### Verificar Conexión a Firebase

```dart
try {
  final result = await repository.getAllEntities();
  print('✅ Conexión a Firebase OK');
} catch (e) {
  print('❌ Sin conexión a Firebase: $e');
}
```

---

## 📊 Comparación de Rendimiento

| Operación | Mobile (Cache-First) | Web (Remote-Only) |
|-----------|---------------------|-------------------|
| **Primera carga** | ~500ms (Firebase) | ~500ms (Firebase) |
| **Cargas siguientes** | ~10ms (Caché) | ~500ms (Firebase) |
| **Sin internet** | ✅ Funciona | ❌ Falla |
| **Datos actualizados** | Depende de sync | Siempre frescos |

---

## ✅ Checklist de Implementación

- [x] Importar `EntityModels` para conversión
- [x] Implementar `registerEntity()` - Remote only
- [x] Implementar `updateEntity()` - Remote only
- [x] Implementar `deleteEntity()` - Remote only
- [x] Implementar `getAllEntities()` - Remote only
- [x] Implementar `getEntityById()` - Remote only
- [x] Implementar `syncAllFromFirebase()` - UnimplementedError
- [x] Agregar comentarios explicativos
- [x] Verificar manejo de errores consistente
- [x] Crear documentación

---

## 🎓 Conceptos Clave

### Remote-Only
La app se comunica directamente con Firebase sin caché local. Requiere internet para funcionar.

### Online-Only
La aplicación solo funciona con conexión a internet. No hay soporte offline.

### Datos Frescos
Cada llamada obtiene los datos más recientes de Firebase, sin usar caché.

### Either<L, R>
Tipo funcional de `dartz` que representa un resultado:
- `Left(error)` = Error
- `Right(value)` = Éxito

---

## 📞 Soporte

Si tienes dudas:
1. Revisa los comentarios en el código
2. Consulta esta documentación
3. Compara con `entity_mobil_repository_impl.dart`
4. Revisa la documentación de Firebase

---

**Última actualización:** Mayo 2026  
**Versión:** 1.0.0
