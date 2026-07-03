# Feature: Auth (Autenticación)

## 📂 Estructura del Feature

```
auth/
├── data/
│   ├── models/
│   │   └── user_model.dart          # Modelo de datos del usuario
│   └── repositories/
│       └── auth_repository_impl.dart # Implementación del repositorio
├── domain/
│   └── repositories/
│       └── auth_repository.dart      # Interfaz del repositorio
└── presentation/
    ├── providers/
    │   ├── auth_notifier.dart        # Gestión del estado de autenticación
    │   ├── register_notifier.dart    # Gestión del registro
    │   ├── reset_password_notifier.dart # Gestión de reset de contraseña
    │   └── providers.dart            # Exportación de providers
    ├── screens/                      # Pantallas de UI
    └── widgets/                      # Widgets reutilizables
```

---

## 🏗️ Arquitectura

Este feature sigue **Clean Architecture** simplificada:

- **Domain**: Define el contrato del repositorio (interfaces)
- **Data**: Implementa el repositorio usando Firebase Auth + Firestore
- **Presentation**: Maneja el estado con Riverpod y la UI con Flutter

---

## 🔧 Providers Disponibles

### 1. `repositoryProvider`
**Tipo**: `Provider<AuthRepository>`

Proporciona acceso directo al repositorio de autenticación.

```dart
final repository = ref.read(repositoryProvider);
```

### 2. `authNotifierProvider`
**Tipo**: `AsyncNotifierProvider<AuthNotifier, UserModel?>`

Gestiona el estado del usuario autenticado.

**Métodos disponibles:**
- `login(String email, String password)` - Iniciar sesión
- `logout()` - Cerrar sesión
- `authWithGoogle()` - Autenticación con Google
- `completeProfile({...})` - Completar perfil del usuario

**Uso en la UI:**
```dart
// Leer el estado
final userAsync = ref.watch(authNotifierProvider);

// Ejecutar acciones
await ref.read(authNotifierProvider.notifier).login(email, password);
await ref.read(authNotifierProvider.notifier).logout();
await ref.read(authNotifierProvider.notifier).authWithGoogle();
```

### 3. `registerProvider`
**Tipo**: `AsyncNotifierProvider<RegisterNotifier, void>`

Gestiona el registro de nuevos usuarios.

**Métodos disponibles:**
- `registerUser(UserModel user)` - Registrar nuevo usuario

**Uso en la UI:**
```dart
// Observar el estado del registro
final registerState = ref.watch(registerProvider);

// Ejecutar registro
await ref.read(registerProvider.notifier).registerUser(user);

// Manejar estados
registerState.when(
  data: (_) => print('✅ Registro exitoso'),
  loading: () => CircularProgressIndicator(),
  error: (error, stack) => Text('Error: $error'),
);
```

### 4. `resetPasswordProvider`
**Tipo**: `AsyncNotifierProvider<ResetPasswordNotifier, void>`

Gestiona el reseteo de contraseñas.

**Métodos disponibles:**
- `resetPassword(String email)` - Enviar correo de recuperación

**Uso en la UI:**
```dart
// Observar el estado
final resetState = ref.watch(resetPasswordProvider);

// Ejecutar reset
await ref.read(resetPasswordProvider.notifier).resetPassword(email);
```

### 5. `authStateProvider`
**Tipo**: `StreamProvider<UserModel?>`

Stream en tiempo real de los cambios de autenticación.

**Uso:**
```dart
final authStream = ref.watch(authStateProvider);

authStream.when(
  data: (user) => user != null ? HomeScreen() : LoginScreen(),
  loading: () => CircularProgressIndicator(),
  error: (e, s) => Text('Error: $e'),
);
```

---

## 📝 Manejo de Errores

Todos los notifiers incluyen **manejo de errores amigables** con mensajes en español:

| Código Firebase | Mensaje Usuario |
|----------------|-----------------|
| `user-not-found` | No existe un usuario con este correo |
| `wrong-password` | Contraseña incorrecta |
| `invalid-email` | Correo electrónico inválido |
| `email-already-in-use` | Este correo ya está registrado |
| `weak-password` | La contraseña debe tener al menos 6 caracteres |
| `network-request-failed` | Error de conexión. Verifica tu internet |

---

## 🚀 Flujo de Autenticación

```
1. Usuario abre la app
   ↓
2. AppStartupProvider verifica sesión
   ↓
3. authNotifierProvider.build() se ejecuta
   ↓
4. Si hay usuario → carga datos desde Firestore
   Si no hay usuario → retorna null
   ↓
5. Router decide navegación basado en el estado
```

---

## ✨ Características

- ✅ **Autenticación con Email/Password**
- ✅ **Autenticación con Google**
- ✅ **Reset de Contraseña**
- ✅ **Registro de Usuarios**
- ✅ **Completar Perfil**
- ✅ **Stream de cambios de autenticación en tiempo real**
- ✅ **Manejo de errores con mensajes amigables**
- ✅ **Logs detallados para debugging**
- ✅ **Sin uso de casos de uso innecesarios (acceso directo al repositorio)**

---

## 🔄 Migración desde la Arquitectura Anterior

### Antes (con UseCases):
```dart
ref.read(loginProvider).call(email, password)
ref.read(getAuthenticatedUserProvider).call()
```

### Ahora (acceso directo al repositorio):
```dart
final repository = ref.read(repositoryProvider);
repository.login(email, password)
repository.getAuthenticatedUser()
```

O mejor aún, usa los notifiers:
```dart
ref.read(authNotifierProvider.notifier).login(email, password)
```

---

## 🧪 Testing

Para testear este feature, puedes mockear el `repositoryProvider`:

```dart
final mockRepository = MockAuthRepository();

final container = ProviderContainer(
  overrides: [
    repositoryProvider.overrideWithValue(mockRepository),
  ],
);
```

---

## 📚 Recursos

- [Firebase Auth Documentation](https://firebase.google.com/docs/auth)
- [Riverpod Documentation](https://riverpod.dev)
- [Flutter Documentation](https://flutter.dev)
