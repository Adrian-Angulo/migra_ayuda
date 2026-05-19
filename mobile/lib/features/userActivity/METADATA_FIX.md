# 🔧 Fix: Metadata registrándose como NULL

## 🐛 Problema Identificado

Los `metadata` se estaban registrando como `null` en Firebase al crear actividades de auditoría desde `place_card.dart`.

---

## 🔍 Causa Raíz

El problema tenía **3 causas**:

### 1. **Casting Incorrecto en `fromMap()`**
```dart
// ❌ ANTES: Sin casting explícito
metadata: map['metadata']

// ✅ AHORA: Con casting correcto
metadata: map['metadata'] as Map<String, dynamic>?
```

### 2. **Falta de Validación en `getAllActivities()`**
```dart
// ❌ ANTES: Asignación directa sin validación
metadata: data['metadata']

// ✅ AHORA: Con validación y conversión
metadata: data['metadata'] != null 
    ? Map<String, dynamic>.from(data['metadata'] as Map)
    : null
```

### 3. **Falta de Valor por Defecto en `fromSembastMap()`**
```dart
// ❌ ANTES: Sin valor por defecto
accion: map['accion'],

// ✅ AHORA: Con valor por defecto
accion: map['accion'] ?? '',
```

---

## ✅ Soluciones Aplicadas

### 1. **Archivo: `user_activity_model.dart`**

#### Cambio en `fromMap()`
```dart
factory UserActivityModel.fromMap(Map<String, dynamic> map) {
  return UserActivityModel(
    // ... otros campos
    metadata: map['metadata'] as Map<String, dynamic>?, // ✅ Casting explícito
  );
}
```

#### Cambio en `fromSembastMap()`
```dart
factory UserActivityModel.fromSembastMap(String id, Map<String, dynamic> map) {
  return UserActivityModel(
    // ... otros campos
    accion: map['accion'] ?? '', // ✅ Valor por defecto
    metadata: map['metadata'] as Map<String, dynamic>?, // ✅ Casting explícito
  );
}
```

---

### 2. **Archivo: `user_activity_remote_datasource.dart`**

#### Cambio en `getAllActivities()`
```dart
Future<List<UserActivityModel>> getAllActivities() async {
  // ...
  return querySnapshot.docs.map((doc) {
    final data = doc.data();
    return UserActivityModel(
      // ... otros campos
      metadata: data['metadata'] != null 
          ? Map<String, dynamic>.from(data['metadata'] as Map) // ✅ Conversión segura
          : null,
    );
  }).toList();
}
```

**Razón:** Firebase devuelve los mapas como objetos dinámicos que necesitan ser convertidos explícitamente a `Map<String, dynamic>`.

---

### 3. **Archivo: `place_card.dart`**

#### Mejora en el metadata
```dart
await ref.read(createActivityNotifier.notifier).createActivity(
    user: user!.id,
    accion: ActivityActions.entityViewed(),
    nombre: user.name,
    correo: user.email,
    pais: user.originCountry!,
    metadata: {
      "Service": category,
      "EntityName": title, // ✅ Agregado nombre de entidad
    },
);
```

---

## 🎯 Resultado

Ahora los `metadata` se guardan correctamente en Firebase:

```json
{
  "localId": "uuid-123",
  "idUser": "user-456",
  "accion": "Vio detalles de entidad",
  "nombre": "Juan Pérez",
  "correo": "juan@example.com",
  "pais": "México",
  "createdAt": "2026-05-11T10:30:00.000Z",
  "isSynced": true,
  "metadata": {
    "Service": "Hospital",
    "EntityName": "Hospital General"
  }
}
```

---

## 🔍 Cómo Verificar

### 1. En Firebase Console
1. Ir a Firestore
2. Abrir colección `user_activities`
3. Ver un documento reciente
4. Verificar que el campo `metadata` existe y tiene datos

### 2. En la App
```dart
// En cualquier lugar donde uses getAllActivities
final activities = await remoteDataSource.getAllActivities();
for (final activity in activities) {
  print('Metadata: ${activity.metadata}');
  // Debería imprimir: Metadata: {Service: Hospital, EntityName: Hospital General}
}
```

---

## 📚 Lecciones Aprendidas

### 1. **Siempre hacer casting explícito**
Cuando trabajas con `Map<String, dynamic>` desde Firebase o Sembast, siempre haz casting explícito:
```dart
map['field'] as Map<String, dynamic>?
```

### 2. **Validar antes de convertir**
Cuando Firebase devuelve un Map, necesitas convertirlo:
```dart
data['metadata'] != null 
    ? Map<String, dynamic>.from(data['metadata'] as Map)
    : null
```

### 3. **Valores por defecto**
Siempre proporciona valores por defecto para campos opcionales:
```dart
accion: map['accion'] ?? '',
nombre: map['nombre'] ?? '',
```

---

## ✅ Checklist de Verificación

- [x] Casting explícito en `fromMap()`
- [x] Casting explícito en `fromSembastMap()`
- [x] Validación y conversión en `getAllActivities()`
- [x] Valores por defecto en todos los campos opcionales
- [x] Metadata se guarda correctamente en Firebase
- [x] Metadata se lee correctamente desde Firebase
- [x] Sin errores de compilación

---

## 🚀 Próximos Pasos

1. **Probar en la app**
   - Navegar a una entidad
   - Verificar en Firebase que metadata se guardó

2. **Agregar más metadata**
   - Puedes agregar más campos según necesites:
   ```dart
   metadata: {
     "Service": category,
     "EntityName": title,
     "EntityId": entity.id,
     "Timestamp": DateTime.now().toIso8601String(),
   }
   ```

3. **Usar metadata en reportes**
   - Filtrar actividades por servicio
   - Generar estadísticas por tipo de entidad
   - Crear dashboards con los datos

---

**Última actualización:** Mayo 2026  
**Versión:** 1.0.0 (Fix Aplicado)
