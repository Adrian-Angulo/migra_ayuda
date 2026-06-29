# Documento de Requisitos: Inicio de Sesión Basado en Roles

## Introducción

Este documento define los requisitos para implementar un sistema de inicio de sesión basado en roles en la aplicación Flutter MigraAyuda. El sistema debe redirigir automáticamente a los usuarios a diferentes pantallas según su rol (Migrante o Administrador) después de una autenticación exitosa, ya sea mediante email/contraseña o Google Sign-In.

## Glosario

- **Auth_System**: Sistema de autenticación que gestiona el inicio de sesión y verificación de usuarios
- **User**: Entidad que representa a un usuario autenticado con propiedades como email, nombre y rol
- **Role**: Propiedad del usuario que determina sus privilegios y pantalla de destino (valores: "Migrante" o "Administrador")
- **Login_Screen**: Pantalla de inicio de sesión donde el usuario ingresa credenciales
- **Home_Screen**: Pantalla principal para usuarios con rol "Migrante"
- **Admin_Home_Screen**: Pantalla principal para usuarios con rol "Administrador"
- **Auth_Notifier**: Provider de Riverpod que gestiona el estado de autenticación
- **Navigation_Service**: Servicio responsable de redirigir usuarios a la pantalla correspondiente

## Requisitos

### Requisito 1: Verificación de Rol Después del Login con Email/Contraseña

**User Story:** Como usuario de la aplicación, quiero ser redirigido automáticamente a la pantalla correcta según mi rol después de iniciar sesión con email y contraseña, para acceder directamente a las funcionalidades que me corresponden.

#### Criterios de Aceptación

1. WHEN el usuario inicia sesión exitosamente con email y contraseña, THE Auth_System SHALL recuperar el User completo incluyendo la propiedad Role
2. WHEN el User tiene Role igual a "Migrante", THE Navigation_Service SHALL redirigir a Home_Screen
3. WHEN el User tiene Role igual a "Administrador", THE Navigation_Service SHALL redirigir a Admin_Home_Screen
4. IF el User no tiene la propiedad Role definida, THEN THE Auth_System SHALL asignar "Migrante" como valor predeterminado
5. WHEN la autenticación falla, THE Auth_System SHALL mostrar un mensaje de error y permanecer en Login_Screen

### Requisito 2: Verificación de Rol Después del Login con Google

**User Story:** Como usuario de la aplicación, quiero ser redirigido automáticamente a la pantalla correcta según mi rol después de iniciar sesión con Google, para acceder directamente a las funcionalidades que me corresponden.

#### Criterios de Aceptación

1. WHEN el usuario inicia sesión exitosamente con Google y es primera vez (isFirstTime es true), THE Auth_System SHALL redirigir a Complete_Info_Screen sin verificar el rol
2. WHEN el usuario inicia sesión exitosamente con Google y NO es primera vez (isFirstTime es false), THE Auth_System SHALL recuperar el User completo incluyendo la propiedad Role
3. WHEN el User tiene Role igual a "Migrante" y perfil completo, THE Navigation_Service SHALL redirigir a Home_Screen
4. WHEN el User tiene Role igual a "Administrador" y perfil completo, THE Navigation_Service SHALL redirigir a Admin_Home_Screen
5. IF el User no tiene la propiedad Role definida, THEN THE Auth_System SHALL asignar "Migrante" como valor predeterminado

### Requisito 3: Persistencia del Estado de Autenticación con Rol

**User Story:** Como usuario autenticado, quiero que la aplicación recuerde mi sesión y me redirija a la pantalla correcta según mi rol cuando reabro la aplicación, para no tener que iniciar sesión cada vez.

#### Criterios de Aceptación

1. WHEN la aplicación se inicia, THE Auth_System SHALL verificar si existe un User autenticado
2. WHEN existe un User autenticado, THE Auth_System SHALL recuperar la propiedad Role del User
3. WHEN el User tiene Role igual a "Migrante", THE Navigation_Service SHALL redirigir a Home_Screen
4. WHEN el User tiene Role igual a "Administrador", THE Navigation_Service SHALL redirigir a Admin_Home_Screen
5. WHEN no existe un User autenticado, THE Navigation_Service SHALL mostrar Login_Screen

### Requisito 4: Validación de Roles Permitidos

**User Story:** Como desarrollador del sistema, quiero que solo se permitan roles válidos en el sistema, para mantener la integridad de los datos y evitar comportamientos inesperados.

#### Criterios de Aceptación

1. THE Auth_System SHALL reconocer únicamente dos valores válidos para Role: "Migrante" y "Administrador"
2. IF el User tiene un valor de Role diferente a los valores válidos, THEN THE Auth_System SHALL asignar "Migrante" como valor predeterminado
3. WHEN se crea un nuevo User mediante registro, THE Auth_System SHALL asignar "Migrante" como Role predeterminado
4. WHEN se completa el perfil de Google, THE Auth_System SHALL asignar "Migrante" como Role predeterminado

### Requisito 5: Manejo de Errores en Navegación Basada en Roles

**User Story:** Como usuario de la aplicación, quiero recibir mensajes claros cuando ocurra un error durante el proceso de inicio de sesión y redirección, para entender qué salió mal y poder intentarlo nuevamente.

#### Criterios de Aceptación

1. IF ocurre un error al recuperar el User después de la autenticación, THEN THE Auth_System SHALL mostrar un mensaje de error descriptivo
2. IF ocurre un error durante la navegación basada en roles, THEN THE Navigation_Service SHALL registrar el error y redirigir a Login_Screen
3. WHEN se muestra un error, THE Auth_System SHALL limpiar el estado de carga (loading state)
4. WHEN se muestra un error, THE Auth_System SHALL permitir al usuario intentar iniciar sesión nuevamente
5. THE Auth_System SHALL registrar todos los errores relacionados con roles en los logs para depuración

### Requisito 6: Integración con Auth_Notifier Existente

**User Story:** Como desarrollador del sistema, quiero que la funcionalidad de roles se integre sin problemas con el Auth_Notifier existente, para mantener la arquitectura limpia y evitar duplicación de código.

#### Criterios de Aceptación

1. THE Auth_Notifier SHALL mantener su estructura actual de AsyncNotifier<UserModel?>
2. WHEN Auth_Notifier actualiza el estado después del login, THE Auth_Notifier SHALL incluir la propiedad Role del User
3. THE Auth_Notifier SHALL exponer el User completo incluyendo Role a través de su estado
4. THE Navigation_Service SHALL escuchar cambios en authProvider para detectar autenticaciones exitosas
5. THE Navigation_Service SHALL acceder a la propiedad Role del User desde el estado de authProvider

### Requisito 7: Redirección Después de Completar Perfil de Google

**User Story:** Como usuario que inicia sesión por primera vez con Google, quiero ser redirigido a la pantalla correcta según mi rol después de completar mi información de perfil, para acceder directamente a las funcionalidades que me corresponden.

#### Criterios de Aceptación

1. WHEN el usuario completa su perfil después del primer inicio de sesión con Google, THE Auth_System SHALL asignar "Migrante" como Role predeterminado
2. WHEN el perfil se completa exitosamente, THE Auth_System SHALL actualizar el User con profileComplete igual a true
3. WHEN el perfil se completa exitosamente, THE Navigation_Service SHALL verificar el Role del User
4. WHEN el User tiene Role igual a "Migrante", THE Navigation_Service SHALL redirigir a Home_Screen
5. WHEN el User tiene Role igual a "Administrador", THE Navigation_Service SHALL redirigir a Admin_Home_Screen

