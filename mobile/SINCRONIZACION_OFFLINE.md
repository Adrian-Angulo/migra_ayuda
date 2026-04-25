# 📱 Sistema de Sincronización Offline-First

## ✅ Implementación Completada

### **Arquitectura**
```
Firebase (Remoto) ←→ Sembast (Local) ←→ UI
         ↓                ↓              ↓
    Fuente remota    Caché local    Datos mostrados
```

### **Estrategia: Cache-First**
1. **Lectura**: Siempre lee primero del caché (Sembast) - INSTANTÁNEO
2. **Actualización**: Si hay internet, actualiza desde Firebase en background
3. **Escritura**: Guarda primero en caché, luego sincroniza con Firebase

---

## 🔄 Sincronización Automática

### **1. Actualización Periódica (cada 30 segundos)**
- El `StreamProvider` verifica Firebase cada 30 segundos
- Actualiza el caché automáticamente
- Detecta nuevos datos y muestra banner

### **2. Detección de Nuevos Datos**
- Compara el número de entidades actual vs. nuevas
- Si hay más entidades, muestra banner: **"Nuevos servicios disponibles"**
- Banner desaparece al actualizar

### **3. Recarga al Volver del Background**
- Detecta cuando la app vuelve a estar activa
- Verifica automáticamente si hay datos nuevos
- Muestra banner si encuentra cambios

### **4. Métodos Manuales de Actualización**
- **Botón Refresh** en el header (icono circular)
- **Pull-to-Refresh** (deslizar hacia abajo en la lista)
- **Botón "Actualizar"** en el banner de nuevos datos

---

## 🎨 Banner de Nuevos Datos

### **Características**
- ✅ Color teal suave con borde
- ✅ Icono de información
- ✅ Texto: "Nuevos servicios disponibles"
- ✅ Botón "Actualizar" integrado
- ✅ Clickeable (todo el banner actualiza)
- ✅ Se oculta automáticamente al actualizar

### **Cuándo Aparece**
- Cuando se detectan más entidades que las actuales
- Solo si ya había datos cargados previamente
- Cada 30 segundos o al volver del background

### **Cuándo Desaparece**
- Al presionar "Actualizar"
- Al hacer pull-to-refresh
- Al presionar el botón refresh del header
- Automáticamente después de actualizar

---

## 📊 Flujo de Datos

### **Carga Inicial**
```
1. App inicia
2. Lee caché (Sembast) → Muestra datos INSTANTÁNEAMENTE
3. Si hay internet → Obtiene de Firebase
4. Actualiza caché con datos frescos
5. UI se actualiza automáticamente
```

### **Agregar Nueva Entidad (desde panel admin)**
```
1. Admin agrega entidad en Firebase
2. Después de 30 segundos (o al volver a la app):
   - App verifica Firebase
   - Detecta nueva entidad
   - Muestra banner "Nuevos servicios disponibles"
3. Usuario presiona "Actualizar"
4. Datos se sincronizan
5. Nueva entidad aparece en la lista
```

### **Modo Offline**
```
1. Sin internet
2. Lee solo del caché (Sembast)
3. Muestra banner naranja: "Modo offline"
4. Todas las operaciones funcionan localmente
5. Al recuperar internet → Sincroniza automáticamente
```

---

## 🔧 Componentes Técnicos

### **Providers**
- `entitiesStreamProvider`: Stream que emite entidades cada 30s
- `getAllEntitiesUsecaseProvider`: Caso de uso para obtener entidades
- `connectionStatusProvider`: Estado de conexión en tiempo real

### **Datasources**
- `EntityLocalDataSource`: Sembast (caché local)
- `EntityRemoteDataSource`: Firebase (fuente remota)

### **Repository**
- `EntityRepositoryImpl`: Implementa estrategia offline-first
- Maneja sincronización entre local y remoto

### **Variables de Estado**
- `_hasNewData`: Indica si hay datos nuevos disponibles
- `_currentDataCount`: Contador de entidades actuales
- `_isControllerAttached`: Estado del DraggableScrollableSheet

---

## 🎯 Casos de Uso

### **Usuario Normal**
1. Abre la app → Ve datos instantáneamente (caché)
2. Cada 30s → Datos se actualizan automáticamente
3. Si hay nuevos → Ve banner y puede actualizar

### **Sin Conexión**
1. Abre la app → Ve datos del caché
2. Banner naranja: "Modo offline"
3. Puede ver todos los datos guardados
4. Al recuperar internet → Sincroniza automáticamente

### **Admin Agrega Entidad**
1. Admin agrega en panel web
2. Móvil detecta cambio (máx 30s)
3. Muestra banner "Nuevos servicios disponibles"
4. Usuario actualiza y ve la nueva entidad

---

## ⚡ Optimizaciones

### **Performance**
- Lectura del caché es instantánea (< 50ms)
- Actualización en background no bloquea UI
- Stream periódico no afecta rendimiento

### **Batería**
- Verificación cada 30s es eficiente
- Solo consulta Firebase cuando hay conexión
- Se detiene cuando la app está en background

### **Datos**
- Solo descarga cuando hay cambios
- Caché reduce uso de datos móviles
- Funciona completamente offline

---

## 🐛 Debugging

### **Ver Logs**
Los logs en consola muestran:
- ✅ Sembast Database inicializada
- ✅ SyncService inicializado
- 🌐 Conexión a internet detectada
- 📵 Sin conexión a internet - Modo offline
- 🔄 Sincronizando entidades...
- ✅ Entidades sincronizadas: X registros

### **Verificar Caché**
El caché se guarda en:
- Android: `/data/data/com.example.migra_ayuda/files/migra_ayuda.db`
- iOS: `Documents/migra_ayuda.db`

---

## 📝 Notas Importantes

1. **Primera Carga**: Requiere internet para obtener datos iniciales
2. **Sincronización**: Máximo 30 segundos de delay
3. **Banner**: Solo aparece si hay MÁS entidades que antes
4. **Offline**: Funciona completamente sin internet después de la primera carga
5. **Conflictos**: Usa estrategia "last-write-wins"

---

## 🚀 Próximas Mejoras (Opcionales)

- [ ] Sincronización en tiempo real con Firebase Realtime Database
- [ ] Notificaciones push para nuevos servicios
- [ ] Sincronización selectiva por categoría
- [ ] Compresión de imágenes para caché
- [ ] Limpieza automática de caché antiguo
