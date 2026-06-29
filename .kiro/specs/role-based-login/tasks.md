# Plan de Implementación: Inicio de Sesión Basado en Roles

## Visión General

Este plan implementa un sistema de navegación basada en roles que redirige automáticamente a los usuarios a diferentes pantallas según su rol (Migrante o Administrador) después de una autenticación exitosa. La implementación se integra con la arquitectura existente de Flutter usando Riverpod, manteniendo la separación de responsabilidades.

## Tareas

- [x] 1. Crear NavigationService para lógica de navegación basada en roles
  - Crear archivo `lib/core/services/navigation_service.dart`
  - Implementar método `navigateByRole()` que recibe BuildContext y UserModel
  - Implementar método privado `_normalizeRole()` para validar y normalizar roles
  - Agregar verificación de `context.mounted` antes de navegar
  - Agregar manejo de errores con fallback a LoginScreen
  - _Requisitos: 1.2, 1.3, 2.3, 2.4, 3.3, 3.4, 4.2, 5.2_

- [ ]* 1.1 Escribir property test para normalización de roles
  - **Propiedad 3: Normalización de Roles Inválidos**
  - **Valida: Requisitos 1.4, 2.5, 4.2**

- [x] 2. Crear pantallas administrativas
  - [x] 2.1 Crear AdminHomeScreen con navegación inferior
    - Crear archivo `lib/features/auth/presentation/pages/AdminHomeScreen/admin_home_screen.dart`
    - Implementar estructura con BottomNavigationBar
    - Configurar 3 secciones: Dashboard, Usuarios, Perfil
    - Usar color temático `0xFF64999A` para elementos seleccionados
    - _Requisitos: 1.3, 2.4, 3.4_

  - [x] 2.2 Crear pantallas placeholder para secciones administrativas
    - Crear `lib/features/auth/presentation/pages/AdminHomeScreen/admin_dashboard_screen.dart`
    - Crear `lib/features/auth/presentation/pages/AdminHomeScreen/admin_users_screen.dart`
    - Crear `lib/features/auth/presentation/pages/AdminHomeScreen/admin_profile_screen.dart`
    - Implementar UI básica con título y mensaje placeholder
    - _Requisitos: 1.3, 2.4, 3.4_

- [x] 3. Modificar LoginScreen para usar NavigationService
  - Actualizar el listener de `authProvider` en `login_screen.dart`
  - Reemplazar navegación directa a HomeScreen con `NavigationService.navigateByRole()`
  - Mantener manejo de errores existente con SnackBar
  - Verificar `context.mounted` antes de navegar
  - _Requisitos: 1.1, 1.2, 1.3, 1.5, 6.4, 6.5_

- [ ]* 3.1 Escribir property test para navegación basada en roles
  - **Propiedad 2: Navegación Basada en Role**
  - **Valida: Requisitos 1.2, 1.3, 2.3, 2.4, 3.3, 3.4, 6.5**

- [x] 4. Modificar ButtonGoogleWidget para navegación basada en roles
  - Actualizar lógica en `button_google_widget.dart`
  - Mantener navegación a CompleteInfoScreen cuando `isFirstTime == true`
  - Para usuarios existentes (`isFirstTime == false`), usar `NavigationService.navigateByRole()`
  - Leer el usuario desde `ref.read(authProvider).value`
  - Mantener manejo de errores existente
  - _Requisitos: 2.1, 2.2, 2.3, 2.4, 2.5_

- [ ]* 4.1 Escribir unit tests para ButtonGoogleWidget
  - Test: Primera vez con Google redirige a CompleteInfoScreen
  - Test: Usuario existente navega según rol
  - Test: Manejo de errores muestra SnackBar
  - _Requisitos: 2.1, 2.2, 2.3, 2.4_

- [x] 5. Modificar CompleteInfoScreen para navegación basada en roles
  - Agregar listener de `authProvider` en `complete_info_screen.dart`
  - Detectar cuando `user.profileComplete == true`
  - Usar `NavigationService.navigateByRole()` para navegar según rol
  - Verificar `context.mounted` antes de navegar
  - _Requisitos: 7.1, 7.2, 7.3, 7.4, 7.5_

- [ ]* 5.1 Escribir property test para role predeterminado en completar perfil
  - **Propiedad 7: Role Predeterminado en Completar Perfil Google**
  - **Valida: Requisitos 4.4, 7.1, 7.2**

- [ ] 6. Checkpoint - Verificar navegación manual
  - Probar login con email/contraseña para usuario Migrante
  - Probar login con email/contraseña para usuario Administrador
  - Probar Google Sign-In primera vez
  - Probar Google Sign-In usuario existente
  - Verificar que roles inválidos se normalizan a Migrante
  - Preguntar al usuario si hay problemas o dudas

- [x] 7. Actualizar main.dart para verificación de sesión persistente
  - Modificar `MainApp` para verificar estado de autenticación al inicio
  - Implementar método `_getHomeScreenByRole()` para determinar pantalla inicial
  - Usar `authProvider.when()` para manejar estados: data, loading, error
  - Mostrar CircularProgressIndicator durante carga
  - Navegar a AuthPage si no hay usuario autenticado
  - Navegar según rol si hay usuario autenticado
  - _Requisitos: 3.1, 3.2, 3.3, 3.4, 3.5_

- [ ]* 7.1 Escribir property test para persistencia de sesión
  - **Propiedad 9: Persistencia de Sesión con Role**
  - **Valida: Requisitos 3.1, 3.2, 3.3, 3.4**

- [-] 8. Agregar logging de errores relacionados con roles
  - Agregar `debugPrint` en NavigationService para errores de navegación
  - Agregar `debugPrint` en NavigationService para roles inválidos detectados
  - Agregar `debugPrint` en AuthNotifier para errores de autenticación
  - Agregar `debugPrint` para context no montado
  - _Requisitos: 5.5_

- [ ]* 8.1 Escribir property test para manejo de errores de autenticación
  - **Propiedad 4: Manejo de Errores de Autenticación**
  - **Valida: Requisitos 1.5, 5.1, 5.3, 5.4**

- [ ]* 8.2 Escribir unit tests para manejo de errores
  - Test: Context no montado no causa crash
  - Test: Error en Firestore se maneja correctamente
  - Test: Error de navegación redirige a LoginScreen
  - _Requisitos: 5.2, 5.3, 5.4_

- [ ] 9. Checkpoint final - Pruebas de integración
  - Ejecutar todos los tests: `flutter test`
  - Verificar cobertura de código
  - Probar flujo completo de login con ambos roles
  - Probar persistencia de sesión cerrando y reabriendo app
  - Probar manejo de errores con credenciales inválidas
  - Asegurar que todos los tests pasan
  - Preguntar al usuario si hay problemas o dudas

## Notas

- Las tareas marcadas con `*` son opcionales y pueden omitirse para un MVP más rápido
- Cada tarea referencia requisitos específicos para trazabilidad
- Los checkpoints aseguran validación incremental
- Los property tests validan propiedades universales de corrección
- Los unit tests validan casos específicos y edge cases
- El campo `role` ya existe en UserModel, no requiere modificaciones
- La arquitectura de Riverpod existente se mantiene sin cambios estructurales
