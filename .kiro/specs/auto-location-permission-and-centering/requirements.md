# Documento de Requisitos

## Introducción

Esta funcionalidad implementa la solicitud automática de permisos de ubicación al iniciar la aplicación y el centrado automático del mapa en la ubicación del usuario cuando se muestra la pantalla ExplorarScreen. El objetivo es mejorar la experiencia del usuario eliminando pasos manuales y proporcionando acceso inmediato a funcionalidades basadas en ubicación.

## Glosario

- **App**: La aplicación móvil MigraAyuda construida con Flutter
- **Location_Permission_Manager**: Componente responsable de solicitar y verificar permisos de ubicación al inicio de la aplicación
- **ExplorarScreen**: Pantalla principal que muestra el mapa con entidades y la ubicación del usuario
- **Map_Auto_Center**: Componente responsable de centrar automáticamente el mapa en la ubicación del usuario
- **LocationService**: Servicio existente que proporciona funcionalidades de ubicación usando Geolocator
- **User_Location**: Coordenadas geográficas (latitud y longitud) del dispositivo del usuario
- **GPS**: Sistema de Posicionamiento Global del dispositivo
- **Permission_Denied**: Estado donde el usuario ha rechazado los permisos de ubicación
- **Permission_Granted**: Estado donde el usuario ha otorgado permisos de ubicación (whileInUse o always)
- **GPS_Disabled**: Estado donde el servicio de ubicación del dispositivo está desactivado

## Requisitos

### Requisito 1: Solicitud Automática de Permisos al Inicio

**Historia de Usuario:** Como usuario de la aplicación, quiero que se me soliciten los permisos de ubicación automáticamente al iniciar la app, para no tener que activarlos manualmente más tarde.

#### Criterios de Aceptación

1. WHEN THE App starts, THE Location_Permission_Manager SHALL verify if location permissions are already granted
2. WHEN location permissions are not granted, THE Location_Permission_Manager SHALL request location permissions from the user
3. IF the user denies location permissions, THEN THE App SHALL continue loading without blocking the startup process
4. WHEN location permissions are granted, THE LocationService SHALL initialize the location stream
5. THE Location_Permission_Manager SHALL complete the permission check within 5 seconds to avoid blocking app startup

### Requisito 2: Centrado Automático del Mapa al Mostrar ExplorarScreen

**Historia de Usuario:** Como usuario, quiero que el mapa se centre automáticamente en mi ubicación cuando abro la pantalla de exploración, para ver inmediatamente las entidades cercanas a mí.

#### Criterios de Aceptación

1. WHEN THE ExplorarScreen is displayed for the first time, THE Map_Auto_Center SHALL center the map on the User_Location
2. WHEN THE ExplorarScreen is displayed, THE Map_Auto_Center SHALL set the zoom level to 16.0
3. THE Map_Auto_Center SHALL center the map only once per screen display, not on every location update
4. WHILE THE ExplorarScreen is visible, THE Map_Auto_Center SHALL not re-center the map when the User_Location updates
5. WHEN THE ExplorarScreen is displayed again after navigation, THE Map_Auto_Center SHALL center the map on the current User_Location

### Requisito 3: Manejo de Permisos Denegados

**Historia de Usuario:** Como usuario que ha denegado permisos de ubicación, quiero que la aplicación siga funcionando normalmente, para poder usar otras funcionalidades sin restricciones.

#### Criterios de Aceptación

1. WHEN location permissions are denied, THE App SHALL display the map with a default center location
2. WHEN location permissions are denied, THE ExplorarScreen SHALL show entity markers without the user location marker
3. WHEN location permissions are denied, THE "Mi ubicación" button SHALL remain visible and functional
4. WHEN the user taps "Mi ubicación" button without permissions, THE App SHALL request permissions again
5. IF permissions are permanently denied, THEN THE App SHALL display a message directing the user to system settings

### Requisito 4: Manejo de GPS Desactivado

**Historia de Usuario:** Como usuario con GPS desactivado, quiero recibir una notificación clara sobre cómo activarlo, para poder usar las funcionalidades de ubicación.

#### Criterios de Aceptación

1. WHEN THE ExplorarScreen attempts to center the map, THE Map_Auto_Center SHALL verify if GPS is enabled
2. IF GPS is disabled, THEN THE App SHALL display a notification message asking the user to enable GPS
3. WHEN GPS is disabled, THE App SHALL not attempt to obtain User_Location
4. WHEN GPS is disabled, THE ExplorarScreen SHALL display the map with default center location
5. WHEN GPS is enabled after being disabled, THE LocationService SHALL automatically start providing location updates

### Requisito 5: Preservación de Funcionalidad Manual Existente

**Historia de Usuario:** Como usuario, quiero que el botón "Mi ubicación" siga funcionando como antes, para poder re-centrar el mapa manualmente cuando lo necesite.

#### Criterios de Aceptación

1. THE "Mi ubicación" button SHALL remain functional after automatic centering
2. WHEN the user taps "Mi ubicación" button, THE Map_Auto_Center SHALL center the map on the current User_Location
3. WHEN the user taps "Mi ubicación" button, THE Map_Auto_Center SHALL animate the map movement
4. THE "Mi ubicación" button SHALL show a loading indicator while obtaining User_Location
5. WHEN the user manually pans the map, THE automatic centering SHALL not interfere with user interaction

### Requisito 6: Estados de Carga y Retroalimentación

**Historia de Usuario:** Como usuario, quiero ver indicadores visuales claros cuando la aplicación está obteniendo mi ubicación, para saber que el sistema está funcionando.

#### Criterios de Aceptación

1. WHEN THE App is requesting location permissions, THE Location_Permission_Manager SHALL not display a loading indicator to avoid blocking the UI
2. WHEN THE ExplorarScreen is obtaining User_Location for automatic centering, THE Map_Auto_Center SHALL display a subtle loading state
3. WHEN automatic centering completes successfully, THE App SHALL not display a success message to avoid notification fatigue
4. WHEN automatic centering fails, THE App SHALL log the error without displaying a user-facing message
5. WHEN the "Mi ubicación" button is loading, THE button SHALL display a circular progress indicator

### Requisito 7: Integración con Arquitectura Existente

**Historia de Usuario:** Como desarrollador, quiero que la nueva funcionalidad se integre con la arquitectura Clean Architecture y Riverpod existente, para mantener la consistencia del código.

#### Criterios de Aceptación

1. THE Location_Permission_Manager SHALL use the existing LocationService interface
2. THE Map_Auto_Center SHALL use the existing centerOnUserLocationProvider from Riverpod
3. THE Location_Permission_Manager SHALL not create new location service implementations
4. THE Map_Auto_Center SHALL reuse the existing MapController from MapView widget
5. THE implementation SHALL follow Clean Architecture principles with clear separation of concerns
