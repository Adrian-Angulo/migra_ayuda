# 🌍 MigraAyuda

**MigraAyuda** es una plataforma multiplataforma (Móvil y Web) desarrollada en **Flutter** diseñada para brindar asistencia, orientación y localización de servicios esenciales (salud, albergue, asesoría legal, alimentación) a la población migrante, junto con un panel administrativo web para la gestión de entidades y métricas.

---

## 🚀 Características Principales

### 📱 Aplicación Móvil (Migrantes)
* **Autenticación:** Registro/Inicio de sesión con Correo/Contraseña y Google Sign-In.
* **Onboarding Interactivo:** Guía introductoria para nuevos usuarios.
* **Directorio de Entidades:** Catálogo de organizaciones y puntos de ayuda clasificados por servicios.
* **Mapas y Geolocalización:** Visualización interactiva de puntos de interés y cálculo de rutas con Mapbox y OpenStreetMap.
* **Reseñas y Calificaciones:** Valoraciones y comentarios de la comunidad sobre la atención recibida en cada entidad.
* **Modo Offline-First:** Almacenamiento local cifrado con Sembast para consultar información y crear reseñas incluso sin conexión a internet, sincronizándose automáticamente al recuperar conectividad.

### 💻 Panel Web Administrativo (Gestión y Control)
* **Dashboard y Métricas:** Visualización en tiempo real de estadísticas de uso, usuarios registrados y entidades activas.
* **Gráficos Dinámicos:** Análisis de actividades diarias con selector de rangos predefinidos (7, 15, 30 días) y selector de fechas personalizado.
* **CRUD de Entidades:** Registro, edición y eliminación de organizaciones de ayuda con subida de imágenes y georreferenciación.
* **Gestión de Reseñas y Auditoría:** Supervisión de comentarios y trazabilidad de eventos de los usuarios.
* **Exportación de Datos:** Descarga de tablas y reportes en formato CSV.

---

## 🏗️ Arquitectura del Proyecto

El proyecto implementa **Clean Architecture (Arquitectura Limpia)** combinada con **Package by Feature** y principios **SOLID**:

```text
lib/
├── core/                       # Núcleo transversal y agnóstico a las features
│   ├── config/                 # Configuración de Firebase, base de datos Sembast y tokens
│   ├── constants/              # Constantes, nombres de rutas y tipos de acciones
│   ├── errors/                 # Clase base Failure y fallas globales (Network, Server)
│   ├── network/                # Detección de conectividad (NetworkInfo)
│   ├── router/                 # Enrutamiento con GoRouter (Móvil y Web)
│   ├── services/               # Servicios de exportación, almacenamiento y mapas
│   ├── sync/                   # Notificador de sincronización de datos
│   ├── utils/                  # Utilidades y formateadores
│   └── widgets/                # Componentes visuales reutilizables (tablas, alertas, etc.)
│
└── features/                   # Módulos de funcionalidad independientes
    ├── audit/                  # Registro y trazabilidad de actividades
    ├── auth/                   # Autenticación y gestión de sesiones
    ├── dashboard/              # Métricas, estadísticas y gráficos
    ├── entities/               # Directorio y gestión de entidades de ayuda
    ├── onboarding/             # Flujo de bienvenida inicial
    ├── reviews/                # Reseñas y calificaciones
    └── users/                  # Perfiles de usuario y gestión de roles
```

### 🔹 Estructura Interna de Cada Feature:
Cada módulo se divide en tres capas bien definidas:
1. **Domain (Dominio):** Entidades puras, contratos de repositorio (`Repository`), casos de uso (`UseCases`) y clases de error específicas (`Failures`). No depende de librerías externas.
2. **Data (Datos):** Modelos (`Models`), fuentes de datos locales y remotas (`DataSources`), y la implementación de repositorios con manejo de errores mediante `Either<Failure, T>` (Dartz).
3. **Presentation (Presentación):** Pantallas (`Screens`), widgets de interfaz y gestión de estado reactiva con **Riverpod** (`AsyncNotifier`, `FutureProvider`, `StreamProvider`).

---

## 🛠️ Tecnologías y Librerías

| Categoría | Tecnología / Paquete |
| :--- | :--- |
| **Framework** | [Flutter](https://flutter.dev) (SDK ^3.1.0) |
| **Backend & BaaS** | [Firebase](https://firebase.google.com) (Firestore, Auth, Storage) |
| **Estado** | [Flutter Riverpod](https://riverpod.dev) |
| **Base de Datos Local** | [Sembast](https://pub.dev/packages/sembast) (con codec de cifrado local) |
| **Navegación** | [GoRouter](https://pub.dev/packages/go_router) |
| **Mapas y Rutas** | [Mapbox Maps](https://pub.dev/packages/mapbox_maps_flutter) / [Flutter Map](https://pub.dev/packages/flutter_map) |
| **Gráficos** | [Syncfusion Flutter Charts](https://pub.dev/packages/syncfusion_flutter_charts) / [FL Chart](https://pub.dev/packages/fl_chart) |
| **Programación Funcional**| [Dartz](https://pub.dev/packages/dartz) (`Either<Failure, T>`) |
| **Testing & Mocks** | `flutter_test`, [Mocktail](https://pub.dev/packages/mocktail) |

---

## 🔒 Seguridad Implementada

* **Reglas de Seguridad en Firestore (`firestore.rules`):**
  * Prevención contra escalada de privilegios (los usuarios no pueden modificar su propio rol a `Admin`).
  * Validación estricta de esquemas, tipos y rangos de datos (ratings entre 1.0 y 5.0, límite de longitud en comentarios).
  * Inmutabilidad y trazabilidad en registros de auditoría por UID.
* **Cifrado Local:** Base de datos Sembast protegida con códec de cifrado para evitar lecturas de datos en texto plano en dispositivos rooteados.
* **Manejo Seguro de Errores:** Dominio estructurado con `Failures` amigables en español, evitando la exposición de mensajes crudos o stack traces técnicos al usuario.

---

## ⚙️ Configuración e Instalación

### 1. Prerrequisitos
* [Flutter SDK](https://docs.flutter.dev/get-started/install) instalado (versión 3.19.0 o superior recomendada).
* [Git](https://git-scm.com/) instalado.

### 2. Clonar el repositorio
```bash
git clone https://github.com/Adrian-Angulo/migra_ayuda.git
cd migra_ayuda
```

### 3. Instalar dependencias
```bash
flutter pub get
```

### 4. Variables de Entorno
Crea un archivo `.env` en la raíz del proyecto basado en `.env.example`:
```env
MAPBOX_ACCESS_TOKEN=tu_token_de_mapbox_aqui
```

### 5. Configurar Firebase
Asegúrate de contar con la configuración de Firebase generada en `lib/core/config/firebase_options.dart` mediante FlutterFire CLI:
```bash
flutterfire configure
```

---

## ▶️ Ejecución del Proyecto

### Móvil (Android / iOS):
```bash
# Iniciar en emulador o dispositivo conectado
flutter run
```

### Web (Panel Administrativo):
```bash
# Iniciar en Chrome
flutter run -d chrome
```

---

## 🧪 Pruebas Unitarias

El proyecto cuenta con una suite completa de pruebas unitarias para todos los casos de uso del dominio:

```bash
# Ejecutar todas las pruebas unitarias
flutter test
```

Para ver la cobertura de código:
```bash
flutter test --coverage
```

---

## 📄 Licencia

Este proyecto es privado y desarrollado para fines humanitarios y de asistencia social.
