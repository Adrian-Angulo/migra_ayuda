# Documentación Técnica - Módulo de Gestión de Entidades

## Resumen Ejecutivo

El módulo de gestión de entidades implementa un CRUD completo (Crear, Leer, Actualizar, Eliminar) siguiendo los principios de Clean Architecture y el patrón de diseño Repository. Este documento describe la arquitectura, flujo de datos y componentes principales del sistema.

---

## 1. Arquitectura del Sistema

### 1.1 Clean Architecture

El proyecto sigue una arquitectura en capas que garantiza la separación de responsabilidades:

```
features/entities/
├── domain/              # Capa de dominio (lógica de negocio)
│   ├── entities/        # Entidades del dominio
│   ├── repositories/    # Interfaces de repositorios
│   └── usecases/        # Casos de uso
├── data/                # Capa de datos (implementación)
│   ├── datasources/     # Fuentes de datos (Firebase, APIs)
│   ├── models/          # Modelos de datos
│   └── repositories/    # Implementación de repositorios
└── presentation/        # Capa de presentación (UI)
    ├── providers/       # Gestión de estado (Riverpod)
    ├── screens/         # Pantallas
    └── widgets/         # Componentes reutilizables
```

### 1.2 Ventajas de esta Arquitectura

- **Independencia de frameworks**: La lógica de negocio no depende de Flutter
- **Testeable**: Cada capa puede probarse de forma independiente
- **Mantenible**: Cambios en una capa no afectan a las demás
- **Escalable**: Fácil agregar nuevas funcionalidades

---

## 2. Componentes Principales

### 2.1 Entidad del Dominio

```dart
class EntityEntity {
  final String id;
  final String name;
  final String description;
  final List<String> services;
  final String address;
  final double latitude;
  final double longitude;
  final String phone;
  final String serviceHours;
  final String imageUrl;
}
```

**Propósito**: Representa una entidad colaboradora en el dominio del negocio, independiente de la implementación técnica.

### 2.2 Repositorio (Interfaz)

```dart
abstract class EntityRepository {
  Future<Either<String, Unit>> registerEntity({...});
  Future<Either<String, Unit>> updateEntity({...});
  Future<Either<String, Unit>> deleteEntity(String entityId);
  Future<Either<String, List<EntityEntity>>> getAllEntities();
  Future<Either<String, EntityEntity>> getEntityById(String id);
}
```

**Propósito**: Define el contrato para las operaciones de datos. Usa `Either` de Dartz para manejo funcional de errores.

### 2.3 Casos de Uso

Cada operación CRUD tiene su propio caso de uso:

```dart
class RegisterEntityUsecase {
  final EntityRepository repository;
  
  Future<Either<String, Unit>> call(
    EntityEntity entity,
    Uint8List imagenBytes,
    String fileName,
  ) async {
    return await repository.registerEntity(...);
  }
}
```

**Propósito**: Encapsula la lógica de negocio específica de cada operación.

---

## 3. Operaciones CRUD

### 3.1 Registrar Entidad (Create)

#### Flujo de Datos

```
Usuario → UI (Modal) → Notifier → UseCase → Repository → DataSource → Firebase
                                                                    ↓
                                                                Cloudinary (imagen)
```

#### Componentes Clave

**1. AddEntityModal (Presentación)**
- Formulario con validación de campos
- Selector de imagen con preview
- Checklist de servicios
- Manejo de estado de carga

**2. RegisterEntityNotifier (Estado)**
```dart
class RegisterEntityNotifier extends AsyncNotifier<void> {
  Future<void> registrar({
    required EntityEntity entity,
    required Uint8List imagenBytes,
    required String fileName,
  }) async {
    state = const AsyncLoading();
    state = await AsyncValue.guard(() async {
      final usecase = ref.read(registerEntityUsecaseProvider);
      final result = await usecase(entity, imagenBytes, fileName);
      result.fold(
        (error) => throw Exception(error),
        (success) => null,
      );
    });
  }
}
```

**3. EntityRemoteDatasource (Datos)**
```dart
Future<void> registerEntity({
  required EntityModels entityModel,
  required Uint8List imageBytes,
  required String fileName,
}) async {
  // 1. Subir imagen a Cloudinary
  final imagenUrl = await _subirImagenCloudinary(...);
  
  // 2. Guardar entidad en Firestore
  await _firestore.collection('entities').add(
    entityModel.copyWith(imageUrl: imagenUrl).toMap()
  );
}
```

#### Características Técnicas

- **Validación en tiempo real**: Campos obligatorios, formato de coordenadas
- **Subida de imágenes**: Integración con Cloudinary para almacenamiento
- **Manejo de errores**: Mensajes específicos para cada tipo de error
- **Feedback visual**: Loading states, mensajes de éxito/error

---

### 3.2 Ver Detalles (Read)

#### Flujo de Datos

```
Usuario → Navegación → DetailScreen → Notifier → UseCase → Repository → Firebase
                                         ↓
                                    Renderizado UI
```

#### Componentes Clave

**1. EntityDetailScreen (Presentación)**
- SliverAppBar con imagen de fondo
- Información de contacto organizada
- Sección de comentarios
- Botones de acción (editar, eliminar, compartir)

**2. EntityDetailNotifier (Estado)**
```dart
class EntityDetailNotifier extends AsyncNotifier<EntityEntity> {
  String? _entityId;
  
  void setEntityId(String id) => _entityId = id;
  
  Future<void> recargar() async {
    if (_entityId == null) return;
    
    state = const AsyncLoading();
    state = await AsyncValue.guard(() async {
      final usecase = ref.read(getEntityByIdUsecaseProvider);
      final result = await usecase(_entityId!);
      return result.fold(
        (error) => throw Exception(error),
        (entity) => entity,
      );
    });
  }
}
```

#### Características Técnicas

- **Diseño responsive**: Adaptable a diferentes tamaños de pantalla
- **Carga optimizada**: Solo carga datos cuando es necesario
- **Estados de UI**: Loading, error, success con componentes específicos
- **Navegación fluida**: Integración con GoRouter

---

### 3.3 Editar Entidad (Update)

#### Flujo de Datos

```
Usuario → Botón Editar → Modal Precargado → Notifier → UseCase → Repository → Firebase
                                                                            ↓
                                                                    Cloudinary (si hay nueva imagen)
```

#### Componentes Clave

**1. EditEntityModal (Presentación)**
- Formulario precargado con datos actuales
- Opción de cambiar o mantener imagen existente
- Validación de cambios
- Confirmación de actualización

**2. UpdateEntityNotifier (Estado)**
```dart
class UpdateEntityNotifier extends AsyncNotifier<void> {
  Future<void> actualizar({
    required EntityEntity entity,
    Uint8List? imagenBytes,  // Opcional
    String? fileName,         // Opcional
  }) async {
    state = const AsyncLoading();
    state = await AsyncValue.guard(() async {
      final usecase = ref.read(updateEntityUsecaseProvider);
      final result = await usecase(
        entity: entity,
        imagenBytes: imagenBytes,
        fileName: fileName,
      );
      result.fold(
        (error) => throw Exception(error),
        (success) => null,
      );
    });
  }
}
```

**3. Lógica de Actualización**
```dart
Future<void> updateEntity({
  required EntityModels entityModel,
  Uint8List? imageBytes,
  String? fileName,
}) async {
  String imagenUrl = entityModel.imageUrl;
  
  // Solo subir nueva imagen si se proporcionó
  if (imageBytes != null && fileName != null) {
    imagenUrl = await _subirImagenCloudinary(...);
  }
  
  await _firestore
    .collection('entities')
    .doc(entityModel.id)
    .update(entityModel.copyWith(imageUrl: imagenUrl).toMap());
}
```

#### Características Técnicas

- **Actualización parcial**: Solo sube nueva imagen si el usuario la cambió
- **Preservación de datos**: Mantiene información no modificada
- **Recarga automática**: Actualiza la vista después de guardar
- **Validación consistente**: Mismas reglas que en registro

---

### 3.4 Eliminar Entidad (Delete)

#### Flujo de Datos

```
Usuario → Botón Eliminar → Diálogo Confirmación → Notifier → UseCase → Repository → Firebase
                                    ↓
                            Navegación/Recarga
```

#### Componentes Clave

**1. DeleteConfirmationDialog (Presentación)**
```dart
class DeleteConfirmationDialog extends StatelessWidget {
  final String entityName;
  final VoidCallback onConfirm;
  
  @override
  Widget build(BuildContext context) {
    return Dialog(
      child: Column(
        children: [
          // Icono de advertencia
          // Mensaje de confirmación con nombre de entidad
          // Botones: Cancelar / Eliminar
        ],
      ),
    );
  }
}
```

**2. DeleteEntityNotifier (Estado)**
```dart
class DeleteEntityNotifier extends AsyncNotifier<void> {
  Future<void> eliminar(String entityId) async {
    state = const AsyncLoading();
    state = await AsyncValue.guard(() async {
      final usecase = ref.read(deleteEntityUsecaseProvider);
      final result = await usecase(entityId);
      result.fold(
        (error) => throw Exception(error),
        (success) => null,
      );
    });
  }
}
```

**3. Lógica de Eliminación**
```dart
Future<void> deleteEntity(String entityId) async {
  await _firestore
    .collection('entities')
    .doc(entityId)
    .delete();
}
```

#### Características Técnicas

- **Doble confirmación**: Previene eliminaciones accidentales
- **Feedback claro**: Mensaje sobre irreversibilidad de la acción
- **Navegación automática**: Redirige al listado después de eliminar
- **Actualización de lista**: Recarga automática del listado

---

### 3.5 Buscar Entidades (Search)

#### Flujo de Datos

```
Usuario → Campo de Búsqueda → setState → Filtrado Local → Renderizado
```

#### Implementación

**1. Lógica de Filtrado**
```dart
List<EntityEntity> _filterEntities(List<EntityEntity> entities) {
  if (_searchQuery.trim().isEmpty) {
    return entities;
  }
  
  final query = _searchQuery.toLowerCase().trim();
  
  return entities.where((entity) {
    final nameMatch = entity.name.toLowerCase().contains(query);
    final addressMatch = entity.address.toLowerCase().contains(query);
    final servicesMatch = entity.services.any(
      (service) => service.toLowerCase().contains(query),
    );
    
    return nameMatch || addressMatch || servicesMatch;
  }).toList();
}
```

**2. UI de Búsqueda**
```dart
SearchBarWidget(
  hintText: 'Buscar por nombre, dirección o servicio...',
  controller: _searchController,
  onChanged: (value) {
    // Actualización automática vía listener
  },
)
```

**3. Badge de Resultados**
- Muestra cantidad de resultados encontrados
- Botón para limpiar búsqueda rápidamente
- Diseño consistente con el tema

#### Características Técnicas

- **Búsqueda en tiempo real**: Sin necesidad de presionar Enter
- **Múltiples campos**: Busca en nombre, dirección y servicios
- **Case-insensitive**: Ignora mayúsculas/minúsculas
- **Sin latencia**: Filtrado local instantáneo
- **Feedback visual**: Contador de resultados, mensaje de "sin resultados"

---

## 4. Gestión de Estado con Riverpod

### 4.1 Patrón AsyncNotifier

Todos los notifiers siguen el mismo patrón:

```dart
class OperationNotifier extends AsyncNotifier<ReturnType> {
  @override
  FutureOr<ReturnType> build() {
    // Inicialización
  }
  
  Future<void> performOperation(...) async {
    state = const AsyncLoading();
    
    state = await AsyncValue.guard(() async {
      // Lógica de la operación
    });
  }
}
```

### 4.2 Ventajas del Patrón

- **Estados automáticos**: Loading, data, error
- **Manejo de errores**: Try-catch automático con AsyncValue.guard
- **Reactividad**: UI se actualiza automáticamente
- **Testeable**: Fácil de mockear y probar

### 4.3 Listeners en UI

```dart
ref.listen<AsyncValue<void>>(operationNotifierProvider, (previous, next) {
  next.when(
    data: (_) {
      // Mostrar mensaje de éxito
      // Navegar o recargar
    },
    loading: () {
      // Opcional: mostrar loading global
    },
    error: (error, stack) {
      // Mostrar mensaje de error
    },
  );
});
```

---

## 5. Manejo de Errores

### 5.1 Either de Dartz

```dart
Future<Either<String, Unit>> operation() async {
  try {
    // Operación exitosa
    return right(unit);
  } catch (e) {
    // Error
    return left('Mensaje de error: ${e.toString()}');
  }
}
```

### 5.2 Propagación de Errores

```
DataSource → Repository → UseCase → Notifier → UI
   ↓            ↓           ↓          ↓        ↓
 throw      Either<L,R>  Either<L,R>  throw  SnackBar
```

### 5.3 Mensajes de Error en UI

```dart
ScaffoldMessenger.of(context).showSnackBar(
  SnackBar(
    content: Row(
      children: [
        Icon(Icons.error, color: Colors.white),
        SizedBox(width: 12),
        Expanded(child: Text('Error: ${error.toString()}')),
      ],
    ),
    backgroundColor: Colors.red,
    behavior: SnackBarBehavior.floating,
  ),
);
```

---

## 6. Integración con Servicios Externos

### 6.1 Firebase Firestore

**Colección**: `entities`

**Operaciones**:
- `add()`: Crear nueva entidad
- `doc(id).get()`: Obtener por ID
- `orderBy().get()`: Listar todas
- `doc(id).update()`: Actualizar
- `doc(id).delete()`: Eliminar

### 6.2 Cloudinary

**Propósito**: Almacenamiento y optimización de imágenes

**Flujo**:
1. Usuario selecciona imagen
2. Imagen se convierte a bytes (Uint8List)
3. Se sube a Cloudinary vía API REST
4. Se obtiene URL pública
5. URL se guarda en Firestore

**Ventajas**:
- Optimización automática de imágenes
- CDN global para carga rápida
- Transformaciones on-the-fly

---

## 7. Validaciones

### 7.1 Validaciones de Formulario

```dart
validator: (value) {
  if (value == null || value.isEmpty) {
    return 'El campo es requerido';
  }
  if (double.tryParse(value) == null) {
    return 'Formato inválido';
  }
  return null;
}
```

### 7.2 Validaciones de Negocio

- Nombre: Requerido, mínimo 3 caracteres
- Descripción: Opcional
- Servicios: Al menos uno seleccionado
- Dirección: Requerida
- Coordenadas: Formato numérico válido
- Teléfono: Requerido
- Horarios: Requerido
- Imagen: Requerida en registro, opcional en edición

---

## 8. Optimizaciones y Buenas Prácticas

### 8.1 Rendimiento

- **Filtrado local**: Búsqueda sin llamadas al servidor
- **Carga bajo demanda**: Solo carga detalles cuando se necesitan
- **Caché de imágenes**: Flutter maneja caché automáticamente
- **Listeners eficientes**: Solo escuchan cambios necesarios

### 8.2 UX/UI

- **Loading states**: Indicadores visuales durante operaciones
- **Mensajes claros**: Feedback específico para cada acción
- **Confirmaciones**: Diálogos para acciones destructivas
- **Diseño consistente**: Mismos patrones en todo el módulo

### 8.3 Código Limpio

- **Separación de responsabilidades**: Cada clase tiene un propósito único
- **Nombres descriptivos**: Variables y funciones autoexplicativas
- **Comentarios mínimos**: Código que se explica por sí mismo
- **Reutilización**: Widgets y funciones compartidas

---

## 9. Diagrama de Flujo General

```
┌─────────────┐
│   Usuario   │
└──────┬──────┘
       │
       ▼
┌─────────────────┐
│  Presentation   │ ← Widgets, Screens, Modals
│   (UI Layer)    │
└────────┬────────┘
         │
         ▼
┌─────────────────┐
│   Providers     │ ← Riverpod Notifiers
│ (State Mgmt)    │
└────────┬────────┘
         │
         ▼
┌─────────────────┐
│   Use Cases     │ ← Business Logic
│  (Domain)       │
└────────┬────────┘
         │
         ▼
┌─────────────────┐
│  Repository     │ ← Interface
│  (Domain)       │
└────────┬────────┘
         │
         ▼
┌─────────────────┐
│  Repository     │ ← Implementation
│  Impl (Data)    │
└────────┬────────┘
         │
         ▼
┌─────────────────┐
│  Data Source    │ ← Firebase, APIs
│   (Data)        │
└────────┬────────┘
         │
         ▼
┌─────────────────┐
│  External       │ ← Firestore, Cloudinary
│  Services       │
└─────────────────┘
```

---

## 10. Conclusiones

### 10.1 Logros Técnicos

- ✅ Arquitectura escalable y mantenible
- ✅ Separación clara de responsabilidades
- ✅ Manejo robusto de errores
- ✅ Estado reactivo con Riverpod
- ✅ Integración con servicios externos
- ✅ UI/UX profesional y consistente

### 10.2 Beneficios del Diseño

1. **Testeable**: Cada capa puede probarse independientemente
2. **Mantenible**: Cambios localizados, bajo acoplamiento
3. **Escalable**: Fácil agregar nuevas funcionalidades
4. **Reutilizable**: Componentes y patrones aplicables a otros módulos
5. **Profesional**: Código de calidad empresarial

### 10.3 Aplicabilidad

Este patrón arquitectónico se puede replicar para otros módulos del sistema:
- Gestión de usuarios
- Gestión de recursos
- Sistema de notificaciones
- Reportes y estadísticas

---

## Referencias

- **Clean Architecture**: Robert C. Martin
- **Flutter Riverpod**: https://riverpod.dev
- **Dartz (Functional Programming)**: https://pub.dev/packages/dartz
- **Firebase Firestore**: https://firebase.google.com/docs/firestore
- **Cloudinary**: https://cloudinary.com/documentation

---

*Documento generado para documentación de tesis - Módulo de Gestión de Entidades*
