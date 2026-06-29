# Documento de Diseño: Inicio de Sesión Basado en Roles

## Visión General

Este diseño implementa un sistema de navegación basado en roles que redirige automáticamente a los usuarios a diferentes pantallas según su rol (Migrante o Administrador) después de una autenticación exitosa. La solución se integra con la arquitectura existente de Flutter usando Riverpod con AsyncNotifier, manteniendo la separación de responsabilidades y siguiendo los patrones establecidos en el proyecto.

El sistema aprovecha el campo `role` ya existente en `UserModel` y extiende la funcionalidad del `AuthNotifier` actual para incluir lógica de navegación basada en roles sin modificar la estructura fundamental de la autenticación.

## Arquitectura

### Componentes Principales

```
┌─────────────────────────────────────────────────────────────┐
│                        Presentation Layer                    │
├─────────────────────────────────────────────────────────────┤
│  LoginScreen / ButtonGoogleWidget                           │
│         │                                                     │
│         ├──► AuthNotifier (AsyncNotifier<UserModel?>)       │
│         │         │                                          │
│         │         └──► NavigationService                     │
│         │                   │                                │
│         │                   ├──► HomeScreen (Migrante)      │
│         │                   └──► AdminHomeScreen (Admin)    │
└─────────────────────────────────────────────────────────────┘
         │
         ▼
┌─────────────────────────────────────────────────────────────┐
│                        Domain Layer                          │
├─────────────────────────────────────────────────────────────┤
│  Use Cases:                                                  │
│    - LoginUser                                               │
│    - AuthWithGoogle                                          │
│    - CompleteGoogleProfile                                   │
└─────────────────────────────────────────────────────────────┘
         │
         ▼
┌─────────────────────────────────────────────────────────────┐
│                         Data Layer                           │
├─────────────────────────────────────────────────────────────┤
│  AuthRepositoryImple2                                        │
│    - Firebase Auth                                           │
│    - Firestore (users collection)                           │
└─────────────────────────────────────────────────────────────┘
```

### Flujo de Autenticación y Navegación

**Flujo 1: Login con Email/Contraseña**
```
Usuario ingresa credenciales
    │
    ▼
AuthNotifier.login()
    │
    ▼
LoginUser use case
    │
    ▼
AuthRepository.login()
    │
    ▼
Firebase Auth
    │
    ▼
AuthRepository.getUsuarioActual()
    │
    ▼
Firestore recupera UserModel con role
    │
    ▼
AuthNotifier actualiza estado
    │
    ▼
LoginScreen escucha cambio de estado
    │
    ▼
NavigationService.navigateByRole()
    │
    ├──► role == "Migrante" → HomeScreen
    └──► role == "Administrador" → AdminHomeScreen
```

**Flujo 2: Login con Google (Primera vez)**
```
Usuario presiona botón Google
    │
    ▼
AuthNotifier.authWithGoogle()
    │
    ▼
AuthWithGoogle use case
    │
    ▼
AuthRepository.signInWithGoogle()
    │
    ▼
Google Sign-In + Firebase Auth
    │
    ▼
Firestore crea documento con role: "Migrante", profileComplete: false
    │
    ▼
Retorna GoogleSignInResult(isFirstTime: true)
    │
    ▼
ButtonGoogleWidget detecta isFirstTime
    │
    ▼
Navega a CompleteInfoScreen (sin verificar role)
```

**Flujo 3: Login con Google (Usuario existente)**
```
Usuario presiona botón Google
    │
    ▼
AuthNotifier.authWithGoogle()
    │
    ▼
AuthWithGoogle use case
    │
    ▼
AuthRepository.signInWithGoogle()
    │
    ▼
Google Sign-In + Firebase Auth
    │
    ▼
Firestore encuentra documento existente
    │
    ▼
Retorna GoogleSignInResult(isFirstTime: false)
    │
    ▼
AuthNotifier actualiza estado con UserModel
    │
    ▼
ButtonGoogleWidget detecta isFirstTime == false
    │
    ▼
NavigationService.navigateByRole()
    │
    ├──► role == "Migrante" → HomeScreen
    └──► role == "Administrador" → AdminHomeScreen
```

**Flujo 4: Completar Perfil de Google**
```
Usuario completa información en CompleteInfoScreen
    │
    ▼
AuthNotifier.completeGoogleProfile()
    │
    ▼
CompleteGoogleProfile use case
    │
    ▼
AuthRepository.completeGoogleProfile()
    │
    ▼
Firestore actualiza profileComplete: true
    │
    ▼
AuthNotifier actualiza estado con UserModel
    │
    ▼
CompleteInfoScreen escucha cambio de estado
    │
    ▼
NavigationService.navigateByRole()
    │
    ├──► role == "Migrante" → HomeScreen
    └──► role == "Administrador" → AdminHomeScreen
```

## Componentes e Interfaces

### 1. NavigationService

Servicio responsable de la lógica de navegación basada en roles.

```dart
class NavigationService {
  static void navigateByRole(BuildContext context, UserModel user) {
    final role = _normalizeRole(user.role);
    
    Widget destination;
    switch (role) {
      case 'Administrador':
        destination = const AdminHomeScreen();
        break;
      case 'Migrante':
      default:
        destination = const HomeScreen();
        break;
    }
    
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(builder: (context) => destination),
    );
  }
  
  static String _normalizeRole(String role) {
    final validRoles = ['Migrante', 'Administrador'];
    return validRoles.contains(role) ? role : 'Migrante';
  }
}
```

**Ubicación:** `lib/core/services/navigation_service.dart`

**Responsabilidades:**
- Determinar la pantalla de destino según el rol del usuario
- Normalizar roles inválidos al valor predeterminado "Migrante"
- Ejecutar la navegación usando Navigator

### 2. AdminHomeScreen

Nueva pantalla para usuarios con rol "Administrador".

```dart
class AdminHomeScreen extends StatefulWidget {
  const AdminHomeScreen({super.key});

  @override
  State<AdminHomeScreen> createState() => _AdminHomeScreenState();
}

class _AdminHomeScreenState extends State<AdminHomeScreen> {
  int _selectedIndex = 0;

  final List<Widget> _screens = [
    const AdminDashboardScreen(),
    const AdminUsersScreen(),
    const AdminProfileScreen(),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: _screens[_selectedIndex],
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _selectedIndex,
        onTap: (index) => setState(() => _selectedIndex = index),
        selectedItemColor: const Color(0xFF64999A),
        items: const [
          BottomNavigationBarItem(
            icon: Icon(Icons.dashboard_outlined),
            activeIcon: Icon(Icons.dashboard),
            label: 'Dashboard',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.people_outline),
            activeIcon: Icon(Icons.people),
            label: 'Usuarios',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.person_outline),
            activeIcon: Icon(Icons.person),
            label: 'Perfil',
          ),
        ],
      ),
    );
  }
}
```

**Ubicación:** `lib/features/auth/presentation/pages/AdminHomeScreen/admin_home_screen.dart`

**Responsabilidades:**
- Proporcionar interfaz específica para administradores
- Gestionar navegación entre secciones administrativas
- Mantener estructura similar a HomeScreen para consistencia

### 3. Modificaciones en LoginScreen

Actualizar el listener de `authProvider` para usar `NavigationService`:

```dart
ref.listen(
  authProvider,
  (previous, next) {
    next.whenOrNull(
      data: (user) {
        if (user != null) {
          NavigationService.navigateByRole(context, user);
        }
      },
      error: (error, stackTrace) {
        ScaffoldMessenger.of(context)
          ..clearSnackBars()
          ..showSnackBar(SnackBar(content: Text("$error")));
      },
    );
  },
);
```

### 4. Modificaciones en ButtonGoogleWidget

Actualizar la lógica de navegación después del login con Google:

```dart
@override
Widget build(BuildContext context, WidgetRef ref) {
  return ElevatedButton.icon(
    onPressed: () async {
      try {
        final isFirstTime =
            await ref.read(authProvider.notifier).authWithGoogle();

        if (!context.mounted) return;

        if (isFirstTime) {
          // Primera vez - ir a completar información
          Navigator.pushReplacement(
            context,
            MaterialPageRoute(
              builder: (context) => const CompleteInfoScreen(),
            ),
          );
        } else {
          // Usuario existente - navegar según rol
          final user = ref.read(authProvider).value;
          if (user != null) {
            NavigationService.navigateByRole(context, user);
          }
        }
      } catch (e) {
        if (!context.mounted) return;
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    },
    // ... resto del widget
  );
}
```

### 5. Modificaciones en CompleteInfoScreen

Agregar listener para navegar según rol después de completar el perfil:

```dart
ref.listen(
  authProvider,
  (previous, next) {
    next.whenOrNull(
      data: (user) {
        if (user != null && user.profileComplete) {
          NavigationService.navigateByRole(context, user);
        }
      },
      error: (error, stackTrace) {
        ScaffoldMessenger.of(context)
          ..clearSnackBars()
          ..showSnackBar(SnackBar(content: Text("$error")));
      },
    );
  },
);
```

### 6. Verificación de Sesión en Main

Agregar verificación de sesión persistente en el inicio de la aplicación:

```dart
class MainApp extends ConsumerWidget {
  const MainApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final authState = ref.watch(authProvider);

    return MaterialApp(
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.teal),
        visualDensity: VisualDensity.adaptivePlatformDensity,
        fontFamily: 'Inter',
      ),
      home: authState.when(
        data: (user) {
          if (user == null) {
            return const AuthPage();
          }
          // Usuario autenticado - navegar según rol
          return _getHomeScreenByRole(user.role);
        },
        loading: () => const Scaffold(
          body: Center(child: CircularProgressIndicator()),
        ),
        error: (_, __) => const AuthPage(),
      ),
    );
  }

  Widget _getHomeScreenByRole(String role) {
    final normalizedRole = ['Migrante', 'Administrador'].contains(role) 
        ? role 
        : 'Migrante';
    
    return normalizedRole == 'Administrador'
        ? const AdminHomeScreen()
        : const HomeScreen();
  }
}
```

## Modelos de Datos

### UserModel (Ya existente)

El modelo `UserModel` ya contiene el campo `role` con valor predeterminado "Migrante":

```dart
class UserModel {
  final String id;
  final String name;
  final String lastname;
  final String originCountry;
  final String destinationCountry;
  final String email;
  final int age;
  final String password;
  final String role;  // ← Campo existente
  final bool profileComplete;
  final DateTime createdAt;
  
  // ... constructor y métodos
}
```

**Valores válidos para `role`:**
- `"Migrante"` (predeterminado)
- `"Administrador"`

### GoogleSignInResult (Ya existente)

```dart
class GoogleSignInResult {
  final bool isFirstTime;
  final String userId;

  GoogleSignInResult({
    required this.isFirstTime,
    required this.userId,
  });
}
```

## Propiedades de Corrección

*Una propiedad es una característica o comportamiento que debe ser verdadero en todas las ejecuciones válidas de un sistema, esencialmente, una declaración formal sobre lo que el sistema debe hacer. Las propiedades sirven como puente entre las especificaciones legibles por humanos y las garantías de corrección verificables por máquinas.*


### Reflexión sobre Propiedades

Después de analizar todos los criterios de aceptación, he identificado las siguientes redundancias:

**Propiedades Redundantes Identificadas:**
- Los criterios 1.1, 2.2, 3.2, 6.2, 6.3 todos verifican que el sistema recupera el User completo con su Role → Se consolidan en una sola propiedad
- Los criterios 1.2, 2.3, 3.3, 7.4 todos verifican navegación a HomeScreen para rol "Migrante" → Se consolidan en una sola propiedad
- Los criterios 1.3, 2.4, 3.4, 7.5 todos verifican navegación a AdminHomeScreen para rol "Administrador" → Se consolidan en una sola propiedad
- Los criterios 1.4, 2.5, 4.2 todos verifican normalización de roles inválidos → Se consolidan en una sola propiedad
- Los criterios 4.4 y 7.1 son idénticos sobre asignación de rol en completar perfil Google → Se consolidan en una sola propiedad

**Propiedades que se Combinan:**
- Las propiedades de navegación (1.2 y 1.3) pueden combinarse en una sola propiedad más general que verifica que la navegación es correcta para cualquier rol válido

### Propiedad 1: Recuperación Completa del Usuario con Role

*Para cualquier* usuario autenticado exitosamente (ya sea por email/contraseña o Google Sign-In), el sistema debe recuperar el UserModel completo que incluye la propiedad `role` con un valor válido.

**Valida: Requisitos 1.1, 2.2, 3.2, 6.2, 6.3**

### Propiedad 2: Navegación Basada en Role

*Para cualquier* usuario autenticado con un role válido ("Migrante" o "Administrador"), el NavigationService debe redirigir a la pantalla correspondiente: HomeScreen para "Migrante" y AdminHomeScreen para "Administrador".

**Valida: Requisitos 1.2, 1.3, 2.3, 2.4, 3.3, 3.4, 6.5, 7.4, 7.5**

### Propiedad 3: Normalización de Roles Inválidos

*Para cualquier* UserModel con un valor de `role` que no sea "Migrante" o "Administrador" (incluyendo null, vacío, o cualquier otro valor), el sistema debe normalizar el role a "Migrante" como valor predeterminado.

**Valida: Requisitos 1.4, 2.5, 4.2**

### Propiedad 4: Manejo de Errores de Autenticación

*Para cualquier* intento de autenticación que falle, el sistema debe mantener al usuario en LoginScreen, mostrar un mensaje de error descriptivo, y limpiar el estado de carga, permitiendo nuevos intentos de login.

**Valida: Requisitos 1.5, 5.1, 5.3, 5.4**

### Propiedad 5: Valores Válidos de Role

*Para cualquier* operación del sistema que involucre el campo `role`, el sistema debe reconocer únicamente dos valores válidos: "Migrante" y "Administrador", rechazando o normalizando cualquier otro valor.

**Valida: Requisitos 4.1**

### Propiedad 6: Role Predeterminado en Registro

*Para cualquier* nuevo usuario creado mediante el proceso de registro (email/contraseña), el sistema debe asignar automáticamente "Migrante" como valor del campo `role`.

**Valida: Requisitos 4.3**

### Propiedad 7: Role Predeterminado en Completar Perfil Google

*Para cualquier* usuario que completa su perfil después del primer inicio de sesión con Google, el sistema debe asignar "Migrante" como valor del campo `role` y actualizar `profileComplete` a true.

**Valida: Requisitos 4.4, 7.1, 7.2**

### Propiedad 8: Manejo de Errores de Navegación

*Para cualquier* error que ocurra durante el proceso de navegación basada en roles, el NavigationService debe registrar el error en los logs y redirigir de forma segura a LoginScreen.

**Valida: Requisitos 5.2, 5.5**

### Propiedad 9: Persistencia de Sesión con Role

*Para cualquier* usuario con sesión persistente al iniciar la aplicación, el sistema debe verificar la autenticación, recuperar el role del usuario, y navegar a la pantalla correspondiente según el role.

**Valida: Requisitos 3.1, 3.2, 3.3, 3.4**

## Manejo de Errores

### Estrategia General

El sistema implementa un manejo de errores en múltiples capas:

1. **Capa de Repositorio:** Captura errores de Firebase Auth y Firestore
2. **Capa de Use Cases:** Propaga errores con contexto adicional
3. **Capa de Presentación:** Muestra errores al usuario y mantiene estado consistente

### Escenarios de Error

#### 1. Error de Autenticación

**Causa:** Credenciales inválidas, usuario no existe, problemas de red

**Manejo:**
```dart
// En AuthNotifier
state = await AsyncValue.guard(() async {
  await loginUser(email, password);
  return _repository.getUsuarioActual();
});

// En LoginScreen
ref.listen(authProvider, (previous, next) {
  next.whenOrNull(
    error: (error, stackTrace) {
      ScaffoldMessenger.of(context)
        ..clearSnackBars()
        ..showSnackBar(SnackBar(content: Text("$error")));
    },
  );
});
```

**Resultado:**
- Usuario permanece en LoginScreen
- Se muestra mensaje de error descriptivo
- Estado de carga se limpia automáticamente
- Usuario puede intentar nuevamente

#### 2. Error al Recuperar Usuario

**Causa:** Documento de Firestore no existe, permisos insuficientes, problemas de red

**Manejo:**
```dart
// En AuthRepositoryImple2
Future<UserModel?> getUsuarioActual() async {
  try {
    final uid = _auth.currentUser?.uid;
    if (uid == null) return null;
    
    final doc = await _firestore.collection('users').doc(uid).get();
    if (!doc.exists) {
      throw Exception('Usuario no encontrado en la base de datos');
    }
    
    return UserModel.fromFirestore(doc);
  } catch (e) {
    // Log del error
    debugPrint('Error al recuperar usuario: $e');
    rethrow;
  }
}
```

**Resultado:**
- Error se propaga a través de AsyncValue
- Usuario ve mensaje de error
- Sistema redirige a LoginScreen

#### 3. Error de Navegación

**Causa:** Context inválido, widget desmontado, error en construcción de pantalla

**Manejo:**
```dart
// En NavigationService
static void navigateByRole(BuildContext context, UserModel user) {
  try {
    final role = _normalizeRole(user.role);
    
    Widget destination;
    switch (role) {
      case 'Administrador':
        destination = const AdminHomeScreen();
        break;
      case 'Migrante':
      default:
        destination = const HomeScreen();
        break;
    }
    
    if (!context.mounted) {
      debugPrint('Error: Context no montado, no se puede navegar');
      return;
    }
    
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(builder: (context) => destination),
    );
  } catch (e) {
    debugPrint('Error en navegación basada en roles: $e');
    // Fallback seguro a LoginScreen
    if (context.mounted) {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) => const AuthPage()),
      );
    }
  }
}
```

**Resultado:**
- Error se registra en logs
- Sistema intenta navegación segura a LoginScreen
- Usuario puede intentar login nuevamente

#### 4. Role Inválido o Faltante

**Causa:** Datos corruptos en Firestore, migración incompleta, error de sincronización

**Manejo:**
```dart
// En NavigationService
static String _normalizeRole(String role) {
  final validRoles = ['Migrante', 'Administrador'];
  if (!validRoles.contains(role)) {
    debugPrint('Role inválido detectado: $role. Normalizando a Migrante');
    return 'Migrante';
  }
  return role;
}
```

**Resultado:**
- Role se normaliza automáticamente a "Migrante"
- Usuario puede continuar usando la aplicación
- Error se registra para investigación

#### 5. Error en Google Sign-In

**Causa:** Usuario cancela, permisos denegados, problemas de red, configuración incorrecta

**Manejo:**
```dart
// En AuthRepositoryImple2
Future<GoogleSignInResult> signInWithGoogle() async {
  try {
    final GoogleSignInAccount? googleUser = await googleSignIn.signIn();
    if (googleUser == null) {
      throw Exception('Inicio de sesión cancelado');
    }
    // ... resto del código
  } on FirebaseAuthException catch (e) {
    debugPrint('Error de Firebase Auth: ${e.code} - ${e.message}');
    throw Exception('Error de autenticación: ${e.message}');
  } catch (e) {
    debugPrint('Error en Google Sign-In: $e');
    rethrow;
  }
}

// En ButtonGoogleWidget
try {
  final isFirstTime = await ref.read(authProvider.notifier).authWithGoogle();
  // ... navegación
} catch (e) {
  if (!context.mounted) return;
  ScaffoldMessenger.of(context).showSnackBar(
    SnackBar(
      content: Text('Error: $e'),
      backgroundColor: Colors.red,
    ),
  );
}
```

**Resultado:**
- Usuario ve mensaje de error específico
- Usuario permanece en LoginScreen
- Puede intentar con otro método de autenticación

### Logging de Errores

Todos los errores relacionados con roles y navegación se registran usando `debugPrint` para facilitar la depuración:

```dart
// Ejemplos de logging
debugPrint('Error al recuperar usuario: $e');
debugPrint('Role inválido detectado: $role. Normalizando a Migrante');
debugPrint('Error en navegación basada en roles: $e');
debugPrint('Error: Context no montado, no se puede navegar');
```

En producción, estos logs pueden ser reemplazados por un servicio de logging más robusto (Firebase Crashlytics, Sentry, etc.).

## Estrategia de Testing

### Enfoque Dual de Testing

Este proyecto implementa un enfoque dual que combina:

1. **Unit Tests:** Para casos específicos, ejemplos concretos y casos edge
2. **Property-Based Tests:** Para propiedades universales que deben cumplirse con cualquier entrada

Ambos tipos de tests son complementarios y necesarios para una cobertura completa.

### Property-Based Testing

**Biblioteca:** `fake` para generación de datos aleatorios en Dart/Flutter

**Configuración:** Mínimo 100 iteraciones por test de propiedad

**Formato de Tags:**
```dart
// Feature: role-based-login, Property 1: Recuperación Completa del Usuario con Role
test('property: authenticated user always has valid role', () {
  // ... test implementation
});
```

#### Tests de Propiedades

**Test 1: Recuperación Completa del Usuario con Role**
```dart
// Feature: role-based-login, Property 1: Recuperación Completa del Usuario con Role
test('property: authenticated user always has valid role', () async {
  final faker = Faker();
  
  for (int i = 0; i < 100; i++) {
    // Generar usuario aleatorio
    final email = faker.internet.email();
    final password = faker.internet.password();
    final role = faker.randomGenerator.element(['Migrante', 'Administrador']);
    
    // Crear usuario en Firestore con role
    await createTestUser(email: email, password: password, role: role);
    
    // Autenticar
    await authRepository.login(email, password);
    
    // Verificar que getUsuarioActual retorna UserModel con role
    final user = await authRepository.getUsuarioActual();
    
    expect(user, isNotNull);
    expect(user!.role, isNotEmpty);
    expect(['Migrante', 'Administrador'].contains(user.role), isTrue);
  }
});
```

**Test 2: Navegación Basada en Role**
```dart
// Feature: role-based-login, Property 2: Navegación Basada en Role
test('property: navigation matches user role', () {
  final faker = Faker();
  
  for (int i = 0; i < 100; i++) {
    // Generar usuario aleatorio con role válido
    final role = faker.randomGenerator.element(['Migrante', 'Administrador']);
    final user = createMockUser(role: role);
    
    // Determinar pantalla esperada
    final expectedScreen = role == 'Administrador' 
        ? AdminHomeScreen 
        : HomeScreen;
    
    // Verificar que getHomeScreenByRole retorna la pantalla correcta
    final screen = getHomeScreenByRole(user.role);
    
    expect(screen.runtimeType, expectedScreen);
  }
});
```

**Test 3: Normalización de Roles Inválidos**
```dart
// Feature: role-based-login, Property 3: Normalización de Roles Inválidos
test('property: invalid roles normalize to Migrante', () {
  final faker = Faker();
  
  for (int i = 0; i < 100; i++) {
    // Generar roles inválidos aleatorios
    final invalidRole = faker.randomGenerator.element([
      '',
      'admin',
      'user',
      'ADMINISTRADOR',
      'migrante',
      faker.lorem.word(),
      '123',
      null,
    ]);
    
    // Normalizar role
    final normalized = NavigationService._normalizeRole(invalidRole ?? '');
    
    // Verificar que siempre normaliza a Migrante
    expect(normalized, equals('Migrante'));
  }
});
```

**Test 4: Manejo de Errores de Autenticación**
```dart
// Feature: role-based-login, Property 4: Manejo de Errores de Autenticación
test('property: failed auth maintains consistent state', () async {
  final faker = Faker();
  
  for (int i = 0; i < 100; i++) {
    // Generar credenciales inválidas aleatorias
    final email = faker.internet.email();
    final password = faker.internet.password(length: 3); // Muy corta
    
    // Intentar autenticar
    final container = ProviderContainer();
    final notifier = container.read(authProvider.notifier);
    
    await notifier.login(email, password);
    
    // Verificar estado de error
    final state = container.read(authProvider);
    
    expect(state.hasError, isTrue);
    expect(state.isLoading, isFalse);
    expect(state.value, isNull);
  }
});
```

**Test 5: Role Predeterminado en Registro**
```dart
// Feature: role-based-login, Property 6: Role Predeterminado en Registro
test('property: new registrations default to Migrante role', () async {
  final faker = Faker();
  
  for (int i = 0; i < 100; i++) {
    // Generar datos de registro aleatorios
    final name = faker.person.firstName();
    final lastname = faker.person.lastName();
    final email = faker.internet.email();
    final password = faker.internet.password();
    final age = faker.randomGenerator.integer(100, min: 18);
    final originCountry = faker.address.country();
    final destinationCountry = faker.address.country();
    
    // Registrar usuario
    await authRepository.register(
      name,
      lastname,
      email,
      password,
      originCountry,
      destinationCountry,
      age,
    );
    
    // Verificar que el role es Migrante
    final user = await authRepository.getUsuarioActual();
    
    expect(user, isNotNull);
    expect(user!.role, equals('Migrante'));
  }
});
```

**Test 6: Role Predeterminado en Completar Perfil Google**
```dart
// Feature: role-based-login, Property 7: Role Predeterminado en Completar Perfil Google
test('property: completed Google profiles default to Migrante role', () async {
  final faker = Faker();
  
  for (int i = 0; i < 100; i++) {
    // Crear usuario de Google sin perfil completo
    final userId = faker.guid.guid();
    await createIncompleteGoogleUser(userId);
    
    // Generar datos de perfil aleatorios
    final age = faker.randomGenerator.integer(100, min: 18);
    final originCountry = faker.address.country();
    final destinationCountry = faker.address.country();
    
    // Completar perfil
    await authRepository.completeGoogleProfile(
      userId: userId,
      originCountry: originCountry,
      destinationCountry: destinationCountry,
      age: age,
    );
    
    // Verificar role y profileComplete
    final doc = await firestore.collection('users').doc(userId).get();
    final data = doc.data()!;
    
    expect(data['role'], equals('Migrante'));
    expect(data['profileComplete'], isTrue);
  }
});
```

### Unit Testing

Los unit tests se enfocan en casos específicos, ejemplos concretos y casos edge:

#### Tests de Ejemplos Específicos

**Test: Primera vez con Google redirige a CompleteInfoScreen**
```dart
test('first time Google sign-in redirects to CompleteInfoScreen', () async {
  // Simular primer inicio de sesión con Google
  when(mockAuthRepository.signInWithGoogle())
      .thenAnswer((_) async => GoogleSignInResult(
            isFirstTime: true,
            userId: 'test-user-id',
          ));
  
  final container = ProviderContainer(
    overrides: [
      authRepositoryProvider.overrideWithValue(mockAuthRepository),
    ],
  );
  
  final isFirstTime = await container.read(authProvider.notifier).authWithGoogle();
  
  expect(isFirstTime, isTrue);
  // En el widget, esto debe navegar a CompleteInfoScreen
});
```

**Test: Usuario sin autenticación muestra LoginScreen**
```dart
test('unauthenticated user shows LoginScreen', () async {
  when(mockAuthRepository.getUsuarioActual())
      .thenAnswer((_) async => null);
  
  final container = ProviderContainer(
    overrides: [
      authRepositoryProvider.overrideWithValue(mockAuthRepository),
    ],
  );
  
  final user = await container.read(authProvider.future);
  
  expect(user, isNull);
  // En MainApp, esto debe mostrar AuthPage
});
```

**Test: Listener de authProvider detecta cambios**
```dart
testWidgets('authProvider listener triggers navigation', (tester) async {
  final mockUser = UserModel(
    id: 'test-id',
    name: 'Test',
    lastname: 'User',
    email: 'test@example.com',
    role: 'Migrante',
    profileComplete: true,
    // ... otros campos
  );
  
  await tester.pumpWidget(
    ProviderScope(
      overrides: [
        authProvider.overrideWith((ref) => mockUser),
      ],
      child: MaterialApp(home: LoginScreen()),
    ),
  );
  
  // Simular login exitoso
  // Verificar que se navega a HomeScreen
  await tester.pumpAndSettle();
  
  expect(find.byType(HomeScreen), findsOneWidget);
});
```

#### Tests de Casos Edge

**Test: Role null se normaliza**
```dart
test('null role normalizes to Migrante', () {
  final normalized = NavigationService._normalizeRole(null ?? '');
  expect(normalized, equals('Migrante'));
});
```

**Test: Role vacío se normaliza**
```dart
test('empty role normalizes to Migrante', () {
  final normalized = NavigationService._normalizeRole('');
  expect(normalized, equals('Migrante'));
});
```

**Test: Context no montado no causa crash**
```dart
testWidgets('navigation with unmounted context does not crash', (tester) async {
  final context = MockBuildContext();
  when(context.mounted).thenReturn(false);
  
  final user = createMockUser(role: 'Migrante');
  
  // No debe lanzar excepción
  expect(
    () => NavigationService.navigateByRole(context, user),
    returnsNormally,
  );
});
```

**Test: Error en Firestore se maneja correctamente**
```dart
test('Firestore error is handled gracefully', () async {
  when(mockAuthRepository.getUsuarioActual())
      .thenThrow(FirebaseException(
        plugin: 'cloud_firestore',
        message: 'Network error',
      ));
  
  final container = ProviderContainer(
    overrides: [
      authRepositoryProvider.overrideWithValue(mockAuthRepository),
    ],
  );
  
  final state = await container.read(authProvider.future).catchError((_) => null);
  
  expect(state, isNull);
  expect(container.read(authProvider).hasError, isTrue);
});
```

### Estructura de Archivos de Test

```
test/
├── features/
│   └── auth/
│       ├── domain/
│       │   └── usecases/
│       │       ├── login_user_test.dart
│       │       └── auth_with_google_test.dart
│       ├── data/
│       │   └── repositories/
│       │       └── auth_repository_impl_test.dart
│       └── presentation/
│           ├── providers/
│           │   └── auth_notifier_test.dart
│           ├── screens/
│           │   ├── login_screen_test.dart
│           │   └── complete_info_screen_test.dart
│           └── widgets/
│               └── button_google_widget_test.dart
├── core/
│   └── services/
│       └── navigation_service_test.dart
└── property_tests/
    └── role_based_login_properties_test.dart
```

### Cobertura de Testing

**Objetivo:** Mínimo 80% de cobertura de código

**Áreas Críticas (100% de cobertura):**
- NavigationService
- AuthNotifier
- Normalización de roles
- Manejo de errores

**Comando para ejecutar tests:**
```bash
# Todos los tests
flutter test

# Solo property tests
flutter test test/property_tests/

# Con cobertura
flutter test --coverage
genhtml coverage/lcov.info -o coverage/html
```

### Integración Continua

Los tests deben ejecutarse automáticamente en CI/CD:

```yaml
# .github/workflows/test.yml
name: Tests
on: [push, pull_request]
jobs:
  test:
    runs-on: ubuntu-latest
    steps:
      - uses: actions/checkout@v2
      - uses: subosito/flutter-action@v2
      - run: flutter pub get
      - run: flutter test --coverage
      - run: flutter test test/property_tests/ --reporter expanded
```

## Conclusión

Este diseño proporciona una solución completa para implementar navegación basada en roles en la aplicación MigraAyuda, integrándose perfectamente con la arquitectura existente de Riverpod y manteniendo la separación de responsabilidades. La solución es robusta, testeable y extensible para futuros roles adicionales si es necesario.
