# 📍 Documentación: Ubicación del Usuario en Tiempo Real

## 🎯 Descripción

Esta funcionalidad muestra la ubicación del dispositivo del usuario en el mapa en tiempo real. El marcador de ubicación se actualiza automáticamente cuando el usuario se mueve.

### Características implementadas:

✅ **Ubicación en tiempo real** - Se actualiza automáticamente cada 10 metros  
✅ **Marcador visual distintivo** - Punto azul con efecto de radar  
✅ **Botón "Mi ubicación"** - Centra el mapa en la ubicación del usuario  
✅ **Solicitud automática de permisos** - Pide permisos al abrir el mapa  
✅ **Manejo robusto de errores** - Funciona incluso sin permisos  
✅ **Clean Architecture** - Siguiendo la arquitectura del proyecto  

---

## 🏗️ Arquitectura

### Capas implementadas:

```
┌─────────────────────────────────────────────────────────┐
│                    PRESENTACIÓN                         │
│  ┌──────────────────────────────────────────────────┐  │
│  │  MapView (ConsumerStatefulWidget)               │  │
│  │  - Muestra marcador de ubicación                │  │
│  │  - Escucha cambios en tiempo real               │  │
│  │  - Centra mapa cuando se solicita               │  │
│  └──────────────────────────────────────────────────┘  │
│  ┌──────────────────────────────────────────────────┐  │
│  │  ExplorarScreen                                  │  │
│  │  - Botón "Mi ubicación" funcional               │  │
│  └──────────────────────────────────────────────────┘  │
└────────────────────────┬────────────────────────────────┘
                         │ Riverpod Providers
                         ▼
┌─────────────────────────────────────────────────────────┐
│                      PROVIDERS                          │
│  ┌──────────────────────────────────────────────────┐  │
│  │  userLocationStreamProvider                      │  │
│  │  - StreamProvider que emite Position             │  │
│  │  - Maneja permisos automáticamente              │  │
│  │  - Actualiza en tiempo real                     │  │
│  └──────────────────────────────────────────────────┘  │
│  ┌──────────────────────────────────────────────────┐  │
│  │  centerOnUserLocationProvider                    │  │
│  │  - Notifier para centrar mapa                   │  │
│  └──────────────────────────────────────────────────┘  │
└────────────────────────┬────────────────────────────────┘
                         │ Dependency Injection
                         ▼
┌─────────────────────────────────────────────────────────┐
│                      SERVICIOS                          │
│  ┌──────────────────────────────────────────────────┐  │
│  │  LocationService (interfaz)                      │  │
│  │  - locationStream: Stream<Position>              │  │
│  │  - getCurrentLocation()                          │  │
│  │  - hasPermission()                               │  │
│  │  - requestPermission()                           │  │
│  └──────────────────────────────────────────────────┘  │
│  ┌──────────────────────────────────────────────────┐  │
│  │  LocationServiceImpl                             │  │
│  │  - Implementación con Geolocator                │  │
│  │  - Actualiza cada 10 metros                     │  │
│  └──────────────────────────────────────────────────┘  │
└────────────────────────┬────────────────────────────────┘
                         │
                         ▼
                  ┌──────────────┐
                  │  Geolocator  │
                  │   Package    │
                  └──────────────┘
```

---

## 📁 Archivos creados/modificados

### Archivos nuevos (3):

1. **`core/services/location_service.dart`**
   - Interfaz abstracta del servicio de ubicación
   - Define métodos: `locationStream`, `getCurrentLocation()`, etc.

2. **`core/services/location_service_impl.dart`**
   - Implementación usando Geolocator
   - Stream que emite ubicación cada 10 metros
   - Manejo de permisos y errores

3. **`core/providers/location_provider.dart`**
   - `locationServiceProvider` - Provider del servicio
   - `userLocationStreamProvider` - Stream de ubicación en tiempo real
   - `centerOnUserLocationProvider` - Notifier para centrar mapa

### Archivos modificados (3):

4. **`features/entities/presentation/widgets/map_view.dart`**
   - Convertido a `ConsumerStatefulWidget`
   - Agregado `MapController` para controlar el mapa
   - Método `_buildUserLocationMarker()` - Marcador azul con efecto radar
   - Escucha cambios de ubicación en tiempo real
   - Centra mapa cuando se solicita

5. **`features/entities/presentation/screens/explorar_screen.dart`**
   - Método `_centerOnUserLocation()` - Activa centrado del mapa
   - Botón "Mi ubicación" ahora funcional
   - Importado `location_provider`

6. **`ios/Runner/Info.plist`**
   - Agregados permisos de ubicación para iOS

---

## 🔄 Flujo de ejecución

### Inicio de la aplicación:

```
Usuario abre ExplorarScreen
         ↓
MapView se inicializa
         ↓
Solicita permisos de ubicación
         ↓
    ¿Permisos otorgados?
    ├─ NO → Muestra solo entidades
    │        (sin marcador de usuario)
    │
    └─ SÍ → Inicia stream de ubicación
             ↓
        Obtiene ubicación inicial
             ↓
        Muestra marcador azul en mapa
             ↓
        Escucha cambios en tiempo real
             ↓
        Usuario se mueve 10+ metros
             ↓
        Actualiza marcador automáticamente
```

### Usuario presiona "Mi ubicación":

```
Usuario presiona botón FAB
         ↓
_centerOnUserLocation()
         ↓
Activa centerOnUserLocationProvider
         ↓
MapView detecta cambio
         ↓
Centra mapa en ubicación actual
         ↓
Zoom a nivel 15
         ↓
Resetea el flag
```

---

## 🎨 Marcador de ubicación del usuario

### Diseño visual:

```
┌─────────────────────────┐
│   Círculo exterior      │  ← 60x60px, azul 20% opacidad
│   (efecto radar)        │
│                         │
│   ┌─────────────────┐   │
│   │ Círculo medio   │   │  ← 40x40px, azul 30% opacidad
│   │                 │   │
│   │   ┌─────────┐   │   │
│   │   │ Punto   │   │   │  ← 20x20px, azul sólido
│   │   │ central │   │   │     Borde blanco 3px
│   │   └─────────┘   │   │     Sombra negra
│   │                 │   │
│   └─────────────────┘   │
│                         │
└─────────────────────────┘
```

### Código del marcador:

```dart
Marker _buildUserLocationMarker(Position position) {
  return Marker(
    point: LatLng(position.latitude, position.longitude),
    width: 60,
    height: 60,
    child: Stack(
      alignment: Alignment.center,
      children: [
        // Círculo exterior (radar)
        Container(
          width: 60,
          height: 60,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: Colors.blue.withValues(alpha: 0.2),
          ),
        ),
        // Círculo medio
        Container(
          width: 40,
          height: 40,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: Colors.blue.withValues(alpha: 0.3),
          ),
        ),
        // Punto central
        Container(
          width: 20,
          height: 20,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: Colors.blue,
            border: Border.all(color: Colors.white, width: 3),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.3),
                blurRadius: 8,
                offset: const Offset(0, 2),
              ),
            ],
          ),
        ),
      ],
    ),
  );
}
```

---

## ⚙️ Configuración del servicio

### LocationSettings:

```dart
const locationSettings = LocationSettings(
  accuracy: LocationAccuracy.high,  // Precisión alta (GPS)
  distanceFilter: 10,               // Actualiza cada 10 metros
);
```

### Parámetros:

| Parámetro | Valor | Descripción |
|-----------|-------|-------------|
| `accuracy` | `LocationAccuracy.high` | Usa GPS para máxima precisión |
| `distanceFilter` | `10` metros | Solo actualiza si se movió 10+ metros |

### Ventajas de esta configuración:

✅ **Precisión alta** - Usa GPS en lugar de WiFi/Cell towers  
✅ **Ahorra batería** - No actualiza por movimientos pequeños  
✅ **Reduce ruido** - Evita actualizaciones por imprecisión del GPS  
✅ **Fluido** - 10 metros es suficiente para navegación peatonal  

---

## 🔧 Permisos configurados

### Android (`AndroidManifest.xml`):

```xml
<uses-permission android:name="android.permission.ACCESS_FINE_LOCATION" />
<uses-permission android:name="android.permission.ACCESS_COARSE_LOCATION" />
```

✅ **Ya estaban configurados**

### iOS (`Info.plist`):

```xml
<key>NSLocationWhenInUseUsageDescription</key>
<string>Necesitamos tu ubicación para mostrarte en el mapa y ayudarte a encontrar servicios cercanos</string>

<key>NSLocationAlwaysAndWhenInUseUsageDescription</key>
<string>Necesitamos tu ubicación para mostrarte en el mapa y ayudarte a encontrar servicios cercanos</string>
```

✅ **Agregados en esta implementación**

---

## 🎯 Casos de uso

### Caso 1: Usuario con permisos ✅

**Flujo:**
1. Usuario abre el mapa
2. App solicita permisos (primera vez)
3. Usuario otorga permisos
4. Aparece marcador azul en su ubicación
5. Usuario camina
6. Marcador se actualiza automáticamente

**Resultado**: Ubicación en tiempo real funcionando

---

### Caso 2: Usuario sin permisos ⚠️

**Flujo:**
1. Usuario abre el mapa
2. App solicita permisos
3. Usuario deniega permisos
4. Mapa muestra solo entidades
5. No aparece marcador de usuario

**Resultado**: App funciona normalmente sin ubicación

---

### Caso 3: Usuario presiona "Mi ubicación" 📍

**Flujo:**
1. Usuario está viendo otra zona del mapa
2. Presiona botón FAB "Mi ubicación"
3. Mapa se centra en su ubicación actual
4. Zoom a nivel 15
5. Usuario ve su ubicación claramente

**Resultado**: Navegación rápida a ubicación actual

---

### Caso 4: GPS desactivado ❌

**Flujo:**
1. Usuario tiene GPS desactivado
2. App no puede obtener ubicación
3. Mapa muestra solo entidades
4. No aparece marcador de usuario

**Resultado**: App funciona sin errores

---

## 🧪 Manejo de errores

### Errores manejados:

| Situación | Comportamiento |
|-----------|----------------|
| GPS desactivado | No muestra marcador, app funciona normal |
| Permisos denegados | No muestra marcador, app funciona normal |
| Timeout de ubicación | Usa última ubicación conocida |
| Error de Geolocator | Stream emite error, no crashea |
| Sin señal GPS | No actualiza hasta recuperar señal |

### Estrategia de manejo:

```dart
userLocationAsync.when(
  data: (position) {
    if (position == null) return const SizedBox.shrink();
    return MarkerLayer(markers: [_buildUserLocationMarker(position)]);
  },
  loading: () => const SizedBox.shrink(),
  error: (_, __) => const SizedBox.shrink(),
)
```

**Ventaja**: La app NUNCA crashea por problemas de ubicación

---

## 🚀 Ventajas de esta implementación

### 1. **Clean Architecture** ✅
- Servicio separado en Core Layer
- Providers en Presentation Layer
- Fácil de testear y mantener

### 2. **Tiempo real** ⚡
- Stream que emite cambios automáticamente
- No requiere polling manual
- Eficiente en batería

### 3. **Robusto** 🛡️
- Maneja todos los casos de error
- No crashea nunca
- Funciona con o sin permisos

### 4. **UX optimizada** 🎨
- Marcador visual distintivo
- Botón "Mi ubicación" intuitivo
- Animación suave al centrar

### 5. **Eficiente** 🔋
- Solo actualiza cada 10 metros
- Usa LocationSettings optimizados
- Limpia recursos al cerrar

### 6. **Escalable** 📈
- Fácil agregar más funcionalidades
- Servicio reutilizable
- Providers desacoplados

---

## 🔮 Posibles mejoras futuras

1. **Animación del marcador** - Animar transición entre posiciones
2. **Precisión visual** - Mostrar círculo de precisión alrededor del marcador
3. **Brújula** - Mostrar dirección hacia donde mira el usuario
4. **Modo seguimiento** - Seguir automáticamente al usuario mientras camina
5. **Historial de ruta** - Dibujar línea del recorrido del usuario
6. **Velocidad** - Mostrar velocidad actual del usuario
7. **Altitud** - Mostrar altitud si está disponible
8. **Caché de ubicación** - Guardar última ubicación para inicio más rápido

---

## 📊 Dependencias utilizadas

```yaml
dependencies:
  geolocator: ^11.0.0        # Obtener ubicación GPS
  flutter_map: ^8.3.0        # Mapa interactivo
  latlong2: ^0.9.1           # Coordenadas geográficas
  flutter_riverpod: ^3.3.1   # Estado y DI
```

**Nota**: Todas ya estaban instaladas en el proyecto

---

## 🎓 Conclusión

Esta implementación proporciona:

- 📍 **Ubicación en tiempo real** con actualización automática
- 🎨 **Marcador visual distintivo** fácil de identificar
- 🔘 **Botón "Mi ubicación"** funcional y útil
- 🛡️ **Manejo robusto de errores** sin crashes
- 🏗️ **Clean Architecture** mantenible y escalable
- ⚡ **Eficiente en batería** con configuración optimizada

El usuario siempre puede ver su ubicación en el mapa (si otorga permisos) y navegar fácilmente con el botón "Mi ubicación".

---

**Fecha de implementación**: Abril 2026  
**Versión**: 1.0.0  
**Archivos creados**: 3  
**Archivos modificados**: 3  
**Líneas de código**: ~400
