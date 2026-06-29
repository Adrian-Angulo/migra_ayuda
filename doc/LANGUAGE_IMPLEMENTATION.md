# 🌐 Implementación de Idioma Dinámico

## 📋 Resumen

Se ha implementado un sistema de idioma dinámico que permite:
- ✅ Cambiar el idioma en tiempo real
- ✅ Persistir la selección del usuario
- ✅ Redirigir automáticamente si no se ha seleccionado idioma
- ✅ Manejo robusto de estados (loading, error, data)

---

## 🔄 Flujo de Navegación

```
App Start
    ↓
Splash Screen (cargando idioma guardado)
    ↓
¿Idioma guardado?
    ├─ NO → Language Screen → Guardar idioma → Onboarding
    └─ SÍ → ¿Vio Onboarding?
              ├─ NO → Onboarding Screen → Login
              └─ SÍ → Login Screen
```

---

## 🏗️ Arquitectura Implementada

### **1. Router (app_router_mobile.dart)**

El router ahora:
- Observa el estado del idioma (`languageProvider`)
- Observa el estado del onboarding (`onboardingProvider`)
- Redirige automáticamente según el estado

**Lógica de redirección:**

```dart
languageAsync.when(
  data: (locale) {
    // Si no hay idioma → ir a selección
    if (locale == null) return Routes.selectLanguaje;
    
    // Si hay idioma pero no vio onboarding → ir a onboarding
    if (!seeOnboarding) return Routes.onboarding;
    
    // Si completó todo → ir a login
    if (currentPath == Routes.splash) return Routes.loginMovil;
    
    return null; // Mantener ruta actual
  },
  loading: () => Routes.splash, // Mostrar splash mientras carga
  error: (_, __) => Routes.selectLanguaje, // Fallback a selección
);
```

### **2. Main.dart**

El main ahora:
- Usa `languageAsync.when()` para manejar todos los estados
- Agrega un `key` al MaterialApp para forzar rebuild cuando cambia el idioma
- Muestra loading/error states apropiados

**Cambio de idioma dinámico:**

```dart
MaterialApp.router(
  key: ValueKey(locale?.languageCode ?? 'default'), // ← Fuerza rebuild
  locale: locale ?? const Locale('es'),
  // ...
)
```

---

## 🎯 Cómo Funciona el Cambio Dinámico

### **Cuando el usuario cambia el idioma:**

1. **Usuario selecciona idioma** → `LanguageScreen` o `LanguageBottomSheet`
2. **Se llama** → `ref.read(languageProvider.notifier).changeLanguage('en')`
3. **Provider actualiza estado** → `state = AsyncData(Locale('en'))`
4. **Main.dart detecta cambio** → `ref.watch(languageProvider)` se dispara
5. **MaterialApp se reconstruye** → Gracias al `key: ValueKey(locale?.languageCode)`
6. **Toda la app cambia de idioma** → Automáticamente

### **Flujo de datos:**

```
User Action
    ↓
LanguageNotifier.changeLanguage()
    ↓
Repository.saveLanguage()
    ↓
DataSource.saveLanguageCode()
    ↓
SharedPreferences
    ↓
State Update (AsyncData)
    ↓
MaterialApp Rebuild
    ↓
UI actualizada con nuevo idioma
```

---

## 📁 Archivos Modificados

### **1. app_router_mobile.dart**
- ✅ Corregido error de variable no definida
- ✅ Agregada lógica de redirección basada en estado
- ✅ Manejo de estados loading/error

### **2. main.dart**
- ✅ Idioma ahora es reactivo con `.when()`
- ✅ Agregado `key` para forzar rebuild
- ✅ Agregados estados de loading y error
- ✅ Limpiado import no usado

---

## 🧪 Cómo Probar

### **Escenario 1: Primera vez (sin idioma guardado)**
1. Abrir la app
2. Debería mostrar Splash → Language Screen
3. Seleccionar idioma
4. Debería ir a Onboarding

### **Escenario 2: Cambio de idioma en runtime**
1. Ir a configuración (donde esté el LanguageBottomSheet)
2. Cambiar idioma
3. La app debería cambiar inmediatamente sin reiniciar

### **Escenario 3: App con idioma guardado**
1. Cerrar y reabrir la app
2. Debería cargar el idioma guardado
3. Debería ir directamente a la pantalla correspondiente

---

## 🔧 Mantenimiento Futuro

### **Agregar un nuevo idioma:**

1. Agregar locale en `main.dart`:
```dart
supportedLocales: const [
  Locale('es'), 
  Locale('en'),
  Locale('fr'), // ← Nuevo idioma
],
```

2. Agregar opción en `LanguageScreen` y `LanguageBottomSheet`:
```dart
LanguageOption(
  flag: '🇫🇷',
  name: 'Français',
  subtitle: 'French',
  isSelected: selected == 'fr',
  onTap: () => setState(() => selected = 'fr'),
),
```

3. Agregar traducciones en `l10n/`

### **Cambiar el flujo de navegación:**

Modificar la lógica en `app_router_mobile.dart` dentro del `redirect`:

```dart
// Ejemplo: Saltar onboarding si ya seleccionó idioma
if (locale != null && currentPath == Routes.splash) {
  return Routes.loginMovil; // ← Ir directo a login
}
```

---

## ✅ Principios Aplicados

- **Single Responsibility**: Cada capa tiene una responsabilidad clara
- **Dependency Inversion**: Router depende de providers (abstracciones)
- **Open/Closed**: Fácil agregar nuevos idiomas sin modificar lógica core
- **Pragmatismo**: Usa herramientas existentes (AsyncValue, GoRouter)

---

## 📊 Beneficios

1. **Reactivo**: El idioma cambia en toda la app automáticamente
2. **Robusto**: Maneja loading, error y data states
3. **Persistente**: El idioma se guarda y carga automáticamente
4. **Simple**: No hay lógica compleja, solo verificaciones claras
5. **Mantenible**: Fácil de entender y modificar

---

## 🐛 Troubleshooting

### **El idioma no cambia:**
- Verificar que el `key` esté en el MaterialApp
- Verificar que el provider esté siendo watched correctamente

### **La app no redirige:**
- Verificar que el `languageProvider` esté retornando el estado correcto
- Revisar la lógica de redirección en el router

### **Error al guardar idioma:**
- Verificar que SharedPreferences esté inicializado
- Revisar permisos de la app

---

Implementado con ❤️ siguiendo Clean Architecture y principios SOLID
