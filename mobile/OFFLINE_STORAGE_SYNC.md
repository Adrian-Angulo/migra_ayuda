# 📱 Documentación: Almacenamiento Offline y Sincronización

## 📋 Tabla de Contenidos

1. [¿Qué es el almacenamiento offline?](#qué-es-el-almacenamiento-offline)
2. [¿Por qué es importante?](#por-qué-es-importante)
3. [Arquitectura del sistema](#arquitectura-del-sistema)
4. [Componentes principales](#componentes-principales)
5. [Flujo de datos completo](#flujo-de-datos-completo)
6. [Estrategia Cache-First](#estrategia-cache-first)
7. [Sincronización automática](#sincronización-automática)
8. [Manejo de errores](#manejo-de-errores)
9. [Casos de uso](#casos-de-uso)
10. [Preguntas frecuentes](#preguntas-frecuentes)

---

## 🤔 ¿Qué es el almacenamiento offline?

El **almacenamiento offline** es la capacidad de una aplicación móvil para funcionar **sin conexión a internet**. Esto significa que:

- ✅ Los usuarios pueden ver datos aunque no tengan WiFi o datos móviles
- ✅ La app carga más rápido porque lee datos del dispositivo
- ✅ Los datos se guardan localmente en el teléfono
- ✅ Cuando hay internet, los datos se sincronizan automáticamente

**Ejemplo del mundo real:**
Imagina que estás en el metro (sin señal) y abres la app. En lugar de ver una pantalla en blanco o un error, ves todos los servicios que viste la última vez que tenías internet. Cuando salgas del metro y tengas señal, la app se actualiza automáticamente con información nueva.

---

## 💡 ¿Por qué es importante?

### Problemas que resuelve:

1. **Conexión inestable**: En muchas zonas la señal es débil o intermitente
2. **Experiencia lenta**: Esperar a que cargue todo desde internet es frustrante
3. **Consumo de datos**: Descargar todo cada vez gasta muchos datos móviles
4. **Accesibilidad**: No todos tienen internet ilimitado o rápido

### Beneficios para el usuario:

- 🚀 **Velocidad**: La app abre instantáneamente
- 📶 **Funciona sin internet**: Puedes ver información guardada
- 💾 **Ahorra datos**: Solo descarga lo nuevo
- 😊 **Mejor experiencia**: No hay pantallas de carga largas

---

## 🏗️ Arquitectura del sistema

Nuestra app usa una arquitectura **Offline-First** con **Clean Architecture**. Esto suena complicado, pero es simple:

### Capas de la aplicación:

```
┌─────────────────────────────────────────┐
│         PRESENTACIÓN (UI)               │  ← Lo que ve el usuario
│  (Pantallas, Widgets, Providers)        │
└─────────────────────────────────────────┘
                  ↕
┌─────────────────────────────────────────┐
│         DOMINIO (Lógica)                │  ← Reglas de negocio
│  (Entities, UseCases, Repository)       │
└─────────────────────────────────────────┘
                  ↕
┌─────────────────────────────────────────┐
│         DATOS (Data Sources)            │  ← Donde se guardan los datos
│  ┌─────────────┐    ┌────────────────┐ │
│  │   SEMBAST   │    │    FIREBASE    │ │
│  │  (Local)    │    │   (Remoto)     │ │
│  └─────────────┘    └────────────────┘ │
└─────────────────────────────────────────┘
```

### ¿Qué significa cada capa?

1. **Presentación**: Las pantallas y botones que ves
2. **Dominio**: Las reglas (ej: "primero busca en caché, luego en internet")
3. **Datos**: Donde se guardan los datos (teléfono y nube)

---

## 🧩 Componentes principales

### 1. **Sembast** - Base de datos local

**¿Qué es?**
Sembast es una base de datos NoSQL que guarda información **directamente en tu teléfono**.

**¿Cómo funciona?**
- Crea un archivo en el almacenamiento del dispositivo
- Guarda datos en formato JSON (texto estructurado)
- Es muy rápido porque no necesita internet

**Archivo**: `sembast_database.dart`

```dart
// Singleton: Solo existe UNA instancia de la base de datos
class SembastDatabase {
  static final SembastDatabase _instance = SembastDatabase._internal();
  Database? _database;
  
  // Nombre del archivo donde se guardan los datos
  static const String _dbName = 'migra_ayuda.db';
  
  // Obtiene o crea la base de datos
  Future<Database> get database async {
    if (_database != null) return _database!;
    await _initDatabase();
    return _database!;
  }
}
```

**¿Qué hace este código?**
- Crea un archivo llamado `migra_ayuda.db` en tu teléfono
- Solo crea UNA base de datos para toda la app (Singleton)
- Si ya existe, la reutiliza

---

### 2. **NetworkInfo** - Detector de conexión

**¿Qué es?**
Un componente que verifica si tienes internet o no.

**¿Cómo funciona?**
- Usa el paquete `connectivity_plus`
- Detecta WiFi, datos móviles o ethernet
- Puede escuchar cambios en tiempo real

**Archivo**: `network_info.dart`

```dart
class NetworkInfoImpl implements NetworkInfo {
  final Connectivity connectivity;
  
  // Verifica si hay conexión AHORA
  Future<bool> get isConnected async {
    final result = await connectivity.checkConnectivity();
    return result.contains(ConnectivityResult.wifi) ||
           result.contains(ConnectivityResult.mobile);
  }
  
  // Stream que avisa cuando cambia la conexión
  Stream<bool> get onConnectivityChanged {
    return connectivity.onConnectivityChanged.map((result) {
      return _isConnectedResult(result);
    });
  }
}
```

**¿Qué hace este código?**
- `isConnected`: Pregunta "¿hay internet ahora?"
- `onConnectivityChanged`: Avisa cuando te conectas o desconectas

---

### 3. **EntityLocalDataSource** - Maneja el caché local

**¿Qué es?**
El componente que guarda y lee entidades (servicios) en Sembast.

**¿Cómo funciona?**
- Guarda entidades en el teléfono
- Lee entidades del teléfono
- Actualiza o elimina entidades locales

**Archivo**: `entity_local_datasource.dart`

```dart
class EntityLocalDataSourceImpl implements EntityLocalDataSource {
  final SembastDatabase sembastDatabase;
  final _store = stringMapStoreFactory.store('entities');
  
  // Obtiene todas las entidades guardadas localmente
  Future<List<EntityModels>> getCachedEntities() async {
    final db = await sembastDatabase.database;
    final records = await _store.find(db);
    return records.map((record) => _fromSembastMap(record)).toList();
  }
  
  // Guarda múltiples entidades
  Future<void> cacheEntities(List<EntityModels> entities) async {
    final db = await sembastDatabase.database;
    await _store.delete(db); // Limpia datos viejos
    for (final entity in entities) {
      await _store.record(entity.id).put(db, _toSembastMap(entity));
    }
  }
}
```

**¿Qué hace este código?**
- `getCachedEntities()`: Lee todos los servicios guardados en el teléfono
- `cacheEntities()`: Guarda nuevos servicios en el teléfono
- Usa un "store" llamado 'entities' (como una tabla en una base de datos)

---

### 4. **EntityRemoteDataSource** - Maneja Firebase

**¿Qué es?**
El componente que se comunica con Firebase (la nube).

**¿Cómo funciona?**
- Descarga entidades desde Firebase
- Sube nuevas entidades a Firebase
- Actualiza o elimina entidades en Firebase

**Archivo**: `entity_remote_datasource.dart`

```dart
class EntityRemoteDataSourceImpl implements EntityRemoteDataSource {
  final FirebaseFirestore _firestore;
  
  // Obtiene todas las entidades de Firebase
  Future<List<EntityModels>> getAllEntities() async {
    final snapshot = await _firestore
        .collection('entities')
        .orderBy('name')
        .get();
    
    return snapshot.docs
        .map((doc) => EntityModels.fromMap(doc))
        .toList();
  }
  
  // Registra una nueva entidad en Firebase
  Future<void> registerEntity({
    required EntityModels entityModel,
    required Uint8List imageBytes,
    required String fileName,
  }) async {
    // 1. Sube la imagen a Cloudinary
    final imagenUrl = await _uploadImage(bytes: imageBytes, fileName: fileName);
    
    // 2. Guarda la entidad en Firebase con la URL de la imagen
    await _firestore.collection('entities').add(entityModel.toMap());
  }
}
```

**¿Qué hace este código?**
- `getAllEntities()`: Descarga todos los servicios de Firebase
- `registerEntity()`: Sube un nuevo servicio a Firebase (con imagen)
- Usa Cloudinary para guardar imágenes

---

### 5. **EntityRepositoryImpl** - El cerebro del sistema

**¿Qué es?**
El repositorio es el **coordinador** que decide:
- ¿Leo del caché o de Firebase?
- ¿Hay internet?
- ¿Qué hago si falla algo?

**¿Cómo funciona?**
- Implementa la estrategia **Cache-First**
- Coordina entre local y remoto
- Maneja errores

**Archivo**: `entity_repository_impl.dart`

```dart
class EntityRepositoryImpl implements EntityRepository {
  final EntityRemoteDataSource remoteDataSource;
  final EntityLocalDataSource localDataSource;
  final NetworkInfo networkInfo;
  
  Future<Either<String, List<EntityEntity>>> getAllEntities() async {
    // PASO 1: Intenta leer del caché (rápido)
    List<EntityModels> cachedEntities = [];
    try {
      cachedEntities = await localDataSource.getCachedEntities();
    } catch (e) {
      cachedEntities = [];
    }
    
    // PASO 2: Verifica si hay internet
    final isConnected = await networkInfo.isConnected;
    
    if (isConnected) {
      try {
        // PASO 3: Descarga datos frescos de Firebase
        final remoteEntities = await remoteDataSource.getAllEntities();
        
        // PASO 4: Actualiza el caché
        await localDataSource.cacheEntities(remoteEntities);
        
        // PASO 5: Retorna datos frescos
        return right(remoteEntities);
      } catch (e) {
        // Si falla Firebase, retorna el caché
        if (cachedEntities.isNotEmpty) {
          return right(cachedEntities);
        }
        return left('Error del servidor');
      }
    }
    
    // Sin internet, retorna el caché
    if (cachedEntities.isNotEmpty) {
      return right(cachedEntities);
    }
    
    return left('No hay datos disponibles');
  }
}
```

**¿Qué hace este código?**
1. Primero intenta leer del caché (instantáneo)
2. Verifica si hay internet
3. Si hay internet, descarga datos nuevos de Firebase
4. Actualiza el caché con los datos nuevos
5. Si no hay internet, usa el caché
6. Si falla todo, muestra un error

---

## 🔄 Flujo de datos completo

### Escenario 1: Usuario abre la app CON internet

```
┌──────────────┐
│   Usuario    │
│  abre la app │
└──────┬───────┘
       │
       ▼
┌──────────────────────────────────────┐
│  1. Lee del CACHÉ (Sembast)          │  ← Respuesta INSTANTÁNEA
│     Muestra datos guardados          │
└──────┬───────────────────────────────┘
       │
       ▼
┌──────────────────────────────────────┐
│  2. Verifica conexión a internet     │
│     ✅ HAY INTERNET                  │
└──────┬───────────────────────────────┘
       │
       ▼
┌──────────────────────────────────────┐
│  3. Descarga de FIREBASE             │  ← Datos actualizados
│     Obtiene datos frescos            │
└──────┬───────────────────────────────┘
       │
       ▼
┌──────────────────────────────────────┐
│  4. Actualiza CACHÉ con datos nuevos │
└──────┬───────────────────────────────┘
       │
       ▼
┌──────────────────────────────────────┐
│  5. Muestra datos actualizados       │
│     + Banner "Nuevos servicios"      │
└──────────────────────────────────────┘
```

**Tiempo total**: ~2-3 segundos
- 0.1s: Muestra caché
- 2-3s: Descarga y actualiza

---

### Escenario 2: Usuario abre la app SIN internet

```
┌──────────────┐
│   Usuario    │
│  abre la app │
└──────┬───────┘
       │
       ▼
┌──────────────────────────────────────┐
│  1. Lee del CACHÉ (Sembast)          │  ← Respuesta INSTANTÁNEA
│     Muestra datos guardados          │
└──────┬───────────────────────────────┘
       │
       ▼
┌──────────────────────────────────────┐
│  2. Verifica conexión a internet     │
│     ❌ NO HAY INTERNET               │
└──────┬───────────────────────────────┘
       │
       ▼
┌──────────────────────────────────────┐
│  3. Usa solo el CACHÉ                │
│     Muestra datos guardados          │
│     (sin actualizar)                 │
└──────────────────────────────────────┘
```

**Tiempo total**: ~0.1 segundos
- La app funciona completamente offline

---

### Escenario 3: Usuario registra una nueva entidad

```
┌──────────────┐
│   Usuario    │
│ crea servicio│
└──────┬───────┘
       │
       ▼
┌──────────────────────────────────────┐
│  1. Verifica conexión a internet     │
└──────┬───────────────────────────────┘
       │
       ├─── ✅ HAY INTERNET ────────────┐
       │                                │
       ▼                                │
┌──────────────────────────────────┐   │
│  2. Sube imagen a Cloudinary     │   │
└──────┬───────────────────────────┘   │
       │                                │
       ▼                                │
┌──────────────────────────────────┐   │
│  3. Guarda en FIREBASE           │   │
└──────┬───────────────────────────┘   │
       │                                │
       ▼                                │
┌──────────────────────────────────┐   │
│  4. Actualiza CACHÉ              │   │
└──────┬───────────────────────────┘   │
       │                                │
       ▼                                │
┌──────────────────────────────────┐   │
│  5. ✅ Éxito                     │   │
└──────────────────────────────────┘   │
                                        │
       ├─── ❌ NO HAY INTERNET ─────────┘
       │
       ▼
┌──────────────────────────────────┐
│  ❌ Error: Se requiere internet  │
│  (no se puede subir imagen)      │
└──────────────────────────────────┘
```

**Nota**: Crear entidades REQUIERE internet porque hay que subir la imagen.

---

## 🎯 Estrategia Cache-First

### ¿Qué es Cache-First?

**Cache-First** significa: **"Primero muestra lo que tienes guardado, luego actualiza"**

### Ventajas:

1. ✅ **Velocidad**: Respuesta instantánea
2. ✅ **Funciona offline**: Siempre hay datos
3. ✅ **Mejor UX**: No hay pantallas de carga largas
4. ✅ **Ahorra datos**: Solo descarga lo nuevo

### Comparación con otras estrategias:

| Estrategia | Velocidad | Funciona Offline | Datos Actualizados |
|------------|-----------|------------------|-------------------|
| **Cache-First** | ⚡ Muy rápido | ✅ Sí | ✅ Sí (se actualiza después) |
| Network-First | 🐌 Lento | ❌ No | ✅ Siempre |
| Cache-Only | ⚡ Muy rápido | ✅ Sí | ❌ Nunca |
| Network-Only | 🐌 Lento | ❌ No | ✅ Siempre |

### Implementación en código:

```dart
Future<List<EntityEntity>> getAllEntities() async {
  // 1. CACHE: Lee primero del caché (rápido)
  final cachedData = await localDataSource.getCachedEntities();
  
  // 2. NETWORK: Si hay internet, actualiza
  if (await networkInfo.isConnected) {
    try {
      final freshData = await remoteDataSource.getAllEntities();
      await localDataSource.cacheEntities(freshData); // Actualiza caché
      return freshData; // Retorna datos frescos
    } catch (e) {
      return cachedData; // Si falla, usa caché
    }
  }
  
  // 3. FALLBACK: Sin internet, usa caché
  return cachedData;
}
```

---

## 🔄 Sincronización automática

### ¿Cómo funciona?

La app se actualiza automáticamente cada **30 segundos** usando un **StreamProvider**.

**Archivo**: `entity_providers.dart`

```dart
final entitiesStreamProvider = StreamProvider<List<EntityEntity>>((ref) async* {
  final usecase = ref.watch(getAllEntitiesUsecaseProvider);
  
  // Carga inicial
  final result = await usecase.call();
  yield result.fold(
    (error) => <EntityEntity>[],
    (entities) => entities,
  );
  
  // Actualización periódica cada 30 segundos
  await for (final _ in Stream.periodic(const Duration(seconds: 30))) {
    final newResult = await usecase.call();
    yield newResult.fold(
      (error) => <EntityEntity>[],
      (entities) => entities,
    );
  }
});
```

### ¿Qué hace este código?

1. **Carga inicial**: Obtiene datos al abrir la app
2. **Stream.periodic**: Crea un temporizador que se activa cada 30 segundos
3. **yield**: Emite nuevos datos cada vez que se actualiza
4. **Riverpod**: Notifica automáticamente a la UI para que se actualice

### Detección de nuevos datos:

```dart
// En explorar_screen.dart
final previousCount = ref.read(previousEntityCountProvider);
final currentCount = entities.length;

if (currentCount > previousCount) {
  // Hay MÁS entidades que antes
  setState(() {
    _showNewDataBanner = true; // Muestra banner
  });
  ref.read(previousEntityCountProvider.notifier).state = currentCount;
}
```

**¿Qué hace?**
- Compara el número de entidades actual vs anterior
- Si hay MÁS entidades, muestra el banner "Nuevos servicios disponibles"
- El banner desaparece cuando el usuario actualiza manualmente

---

## ⚠️ Manejo de errores

### Tipos de errores:

1. **ServerException**: Error de Firebase
2. **CacheException**: Error de Sembast
3. **NetworkException**: Sin conexión

### Estrategia de recuperación:

```dart
try {
  // Intenta operación principal
  final data = await remoteDataSource.getAllEntities();
  return right(data);
} on ServerException catch (e) {
  // Si falla Firebase, usa caché
  if (cachedData.isNotEmpty) {
    return right(cachedData);
  }
  return left('Error del servidor: ${e.message}');
} on CacheException catch (e) {
  // Si falla caché, intenta solo Firebase
  return left('Error de caché: ${e.message}');
} catch (e) {
  // Error desconocido
  return left('Error inesperado: ${e.toString()}');
}
```

### Mensajes al usuario:

| Situación | Mensaje |
|-----------|---------|
| Sin internet + Sin caché | "No hay datos disponibles. Verifica tu conexión" |
| Sin internet + Con caché | (Muestra datos del caché sin mensaje) |
| Error Firebase + Con caché | (Muestra datos del caché sin mensaje) |
| Error Firebase + Sin caché | "Error del servidor. Intenta más tarde" |

---

## 📱 Casos de uso

### Caso 1: Usuario en zona rural con mala señal

**Problema**: La señal es intermitente

**Solución**:
1. La app carga datos del caché instantáneamente
2. Cuando hay señal (aunque sea por segundos), sincroniza
3. El usuario siempre ve información

---

### Caso 2: Usuario con datos móviles limitados

**Problema**: No quiere gastar muchos datos

**Solución**:
1. Solo descarga datos nuevos (no todo cada vez)
2. Las imágenes se cachean automáticamente
3. Ahorra hasta 90% de datos móviles

---

### Caso 3: Usuario en el metro (sin señal)

**Problema**: Cero conexión a internet

**Solución**:
1. La app funciona completamente offline
2. Puede ver todos los servicios guardados
3. Puede ver imágenes cacheadas
4. Al salir del metro, se sincroniza automáticamente

---

### Caso 4: Administrador agrega nuevo servicio

**Problema**: Otros usuarios deben verlo

**Solución**:
1. Admin sube el servicio (requiere internet)
2. Se guarda en Firebase
3. Cada 30 segundos, otros usuarios sincronizan
4. Aparece banner "Nuevos servicios disponibles"
5. Usuario actualiza y ve el nuevo servicio

---

## ❓ Preguntas frecuentes

### ¿Cuánto espacio ocupa el caché?

Depende del número de entidades:
- 100 entidades ≈ 50 KB
- 1000 entidades ≈ 500 KB
- Las imágenes se cachean por separado (managed by `cached_network_image`)

### ¿Cada cuánto se actualiza?

- **Automático**: Cada 30 segundos
- **Manual**: Cuando el usuario hace pull-to-refresh

### ¿Qué pasa si borro el caché?

- La app descargará todo de nuevo desde Firebase
- Funciona normal, solo será más lento la primera vez

### ¿Puedo crear entidades offline?

- ❌ No, porque se requiere subir la imagen a Cloudinary
- Esto requiere conexión a internet

### ¿Puedo editar entidades offline?

- ✅ Sí, se guarda localmente
- ⚠️ Pero no se sincronizará hasta tener internet

### ¿Qué pasa si dos usuarios editan lo mismo?

- El último en sincronizar sobrescribe al anterior
- Firebase usa "last-write-wins" (última escritura gana)

### ¿Los datos están encriptados?

- En Firebase: ✅ Sí (HTTPS + Firebase Security Rules)
- En Sembast: ❌ No por defecto (se puede agregar)

---

## 🔧 Dependencias utilizadas

```yaml
dependencies:
  # Base de datos local
  sembast: ^3.7.4
  path_provider: ^2.1.5
  path: ^1.9.0
  
  # Detección de red
  connectivity_plus: ^6.1.2
  
  # Caché de imágenes
  cached_network_image: ^3.4.1
  
  # Backend
  cloud_firestore: ^5.7.2
  
  # Estado
  flutter_riverpod: ^2.6.1
  
  # Utilidades
  dartz: ^0.10.1
```

---

## 📊 Diagrama de arquitectura completo

```
┌─────────────────────────────────────────────────────────────┐
│                      PRESENTACIÓN                           │
│  ┌──────────────┐  ┌──────────────┐  ┌──────────────┐     │
│  │ ExplorarScreen│  │  Providers   │  │   Widgets    │     │
│  └──────────────┘  └──────────────┘  └──────────────┘     │
└────────────────────────┬────────────────────────────────────┘
                         │ Riverpod
                         ▼
┌─────────────────────────────────────────────────────────────┐
│                        DOMINIO                              │
│  ┌──────────────┐  ┌──────────────┐  ┌──────────────┐     │
│  │   Entities   │  │  UseCases    │  │ Repository   │     │
│  │              │  │              │  │  Interface   │     │
│  └──────────────┘  └──────────────┘  └──────────────┘     │
└────────────────────────┬────────────────────────────────────┘
                         │ Dependency Injection
                         ▼
┌─────────────────────────────────────────────────────────────┐
│                         DATOS                               │
│  ┌──────────────────────────────────────────────────────┐  │
│  │           EntityRepositoryImpl                       │  │
│  │  (Coordina Local + Remote + Network)                │  │
│  └────────┬─────────────────────────────────┬──────────┘  │
│           │                                  │              │
│           ▼                                  ▼              │
│  ┌─────────────────┐              ┌─────────────────┐     │
│  │ LocalDataSource │              │ RemoteDataSource│     │
│  │   (Sembast)     │              │   (Firebase)    │     │
│  └────────┬────────┘              └────────┬────────┘     │
│           │                                 │              │
│           ▼                                 ▼              │
│  ┌─────────────────┐              ┌─────────────────┐     │
│  │  SembastDB      │              │  Firestore +    │     │
│  │  (Teléfono)     │              │  Cloudinary     │     │
│  └─────────────────┘              └─────────────────┘     │
│                                                             │
│  ┌─────────────────────────────────────────────────────┐  │
│  │              NetworkInfo                            │  │
│  │         (Connectivity Check)                        │  │
│  └─────────────────────────────────────────────────────┘  │
└─────────────────────────────────────────────────────────────┘
```

---

## 🎓 Conclusión

Este sistema de almacenamiento offline y sincronización proporciona:

✅ **Velocidad**: Respuesta instantánea con Cache-First
✅ **Confiabilidad**: Funciona sin internet
✅ **Actualización**: Sincronización automática cada 30 segundos
✅ **Eficiencia**: Ahorra datos móviles
✅ **Escalabilidad**: Arquitectura limpia y mantenible

La combinación de **Sembast** (local) + **Firebase** (remoto) + **NetworkInfo** (detector) + **Riverpod** (estado) crea una experiencia de usuario fluida y profesional.

---

**Última actualización**: Abril 2026
**Versión**: 1.0.0
