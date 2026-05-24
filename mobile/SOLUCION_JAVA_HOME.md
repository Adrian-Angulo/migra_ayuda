# 🔧 Solución: JAVA_HOME is not set

## ❌ PROBLEMA

```
ERROR: JAVA_HOME is not set and no 'java' command could be found in your PATH.
Please set the JAVA_HOME variable in your environment to match the
location of your Java installation.
```

---

## ✅ SOLUCIÓN RÁPIDA (Recomendada)

He actualizado el script `get-sha1.bat` para que configure JAVA_HOME automáticamente.

### **Ejecuta el script actualizado:**

```bash
.\get-sha1.bat
```

El script ahora:
1. ✅ Configura JAVA_HOME automáticamente
2. ✅ Ejecuta gradlew signingReport
3. ✅ Muestra el SHA-1

---

## 🎯 ALTERNATIVA: Script PowerShell

Si prefieres PowerShell, usa:

```powershell
.\get-sha1.ps1
```

---

## 🔧 SOLUCIÓN MANUAL (Si los scripts no funcionan)

### **Opción 1: Configurar JAVA_HOME temporalmente**

Ejecuta estos comandos en tu terminal:

```cmd
set JAVA_HOME=C:\Program Files\Android\Android Studio\jbr
set PATH=%JAVA_HOME%\bin;%PATH%
cd android
.\gradlew signingReport
```

### **Opción 2: Configurar JAVA_HOME permanentemente**

#### **Paso 1: Abrir Variables de Entorno**
1. Presiona `Win + R`
2. Escribe: `sysdm.cpl`
3. Presiona Enter
4. Ve a la pestaña **"Opciones avanzadas"**
5. Haz clic en **"Variables de entorno"**

#### **Paso 2: Crear JAVA_HOME**
1. En **"Variables del sistema"**, haz clic en **"Nueva"**
2. **Nombre de la variable:** `JAVA_HOME`
3. **Valor de la variable:** `C:\Program Files\Android\Android Studio\jbr`
4. Haz clic en **"Aceptar"**

#### **Paso 3: Actualizar PATH**
1. En **"Variables del sistema"**, busca **"Path"**
2. Selecciónala y haz clic en **"Editar"**
3. Haz clic en **"Nuevo"**
4. Agrega: `%JAVA_HOME%\bin`
5. Haz clic en **"Aceptar"** en todas las ventanas

#### **Paso 4: Reiniciar la terminal**
1. Cierra todas las terminales abiertas
2. Abre una nueva terminal
3. Ejecuta:
   ```bash
   cd c:\DEV\flutter\migra_ayuda\mobile\android
   .\gradlew signingReport
   ```

---

## 🎯 SOLUCIÓN ALTERNATIVA: Usar Android Studio

Si no quieres configurar JAVA_HOME:

### **Paso 1: Abrir en Android Studio**
1. Abre Android Studio
2. Abre el proyecto: `c:\DEV\flutter\migra_ayuda\mobile\android`

### **Paso 2: Ejecutar signingReport**
1. En el panel derecho, haz clic en **"Gradle"** (o **"Elephant"** icon)
2. Expande: **android → Tasks → android**
3. Haz doble clic en **signingReport**

### **Paso 3: Ver el SHA-1**
1. En la consola de Android Studio, busca:
   ```
   Variant: debug
   Config: debug
   Store: C:\Users\[TU_USUARIO]\.android\debug.keystore
   Alias: AndroidDebugKey
   SHA1: XX:XX:XX:XX:XX:XX:XX:XX:XX:XX:XX:XX:XX:XX:XX:XX:XX:XX:XX:XX
   ```
2. Copia el valor de **SHA1**

---

## 🔍 VERIFICAR QUE JAVA ESTÉ CONFIGURADO

Después de configurar JAVA_HOME, verifica:

```cmd
echo %JAVA_HOME%
```

Debería mostrar:
```
C:\Program Files\Android\Android Studio\jbr
```

Y ejecuta:
```cmd
java -version
```

Debería mostrar la versión de Java instalada.

---

## 📍 UBICACIONES DE JAVA DETECTADAS

En tu sistema, Java está instalado en:

1. **JDK de Android Studio (Recomendado):**
   ```
   C:\Program Files\Android\Android Studio\jbr
   ```

2. **JRE de Java:**
   ```
   C:\Program Files\Java\jre1.8.0_491
   ```

**Recomendación:** Usa el JDK de Android Studio porque es el que usa Flutter/Android.

---

## ⚠️ PROBLEMAS COMUNES

### **"El sistema no puede encontrar la ruta especificada"**

**Causa:** La ruta de Java es incorrecta.

**Solución:** Verifica que Android Studio esté instalado en:
```
C:\Program Files\Android\Android Studio
```

Si está en otra ubicación, actualiza la ruta en el script.

### **"gradlew no se reconoce como comando"**

**Causa:** No estás en el directorio correcto.

**Solución:** Asegúrate de estar en:
```
c:\DEV\flutter\migra_ayuda\mobile\android
```

### **"Permission denied"**

**Causa:** gradlew no tiene permisos de ejecución.

**Solución:** Ejecuta:
```bash
chmod +x gradlew
```

O en Windows:
```cmd
icacls gradlew /grant Everyone:F
```

---

## 🚀 DESPUÉS DE OBTENER EL SHA-1

1. **Copia el SHA-1** (la línea completa con los dos puntos)
   ```
   Ejemplo: 1A:2B:3C:4D:5E:6F:7G:8H:9I:0J:1K:2L:3M:4N:5O:6P:7Q:8R:9S:0T
   ```

2. **Ve a Firebase Console:**
   - https://console.firebase.google.com/
   - Selecciona tu proyecto "MigraAyuda"

3. **Agrega el SHA-1:**
   - Project Settings ⚙️ → Your apps → Android app
   - SHA certificate fingerprints → Add fingerprint
   - Pega tu SHA-1 → Save

4. **Descarga google-services.json actualizado**

5. **Reemplázalo en:**
   ```
   c:\DEV\flutter\migra_ayuda\mobile\android\app\google-services.json
   ```

6. **Limpia y reconstruye:**
   ```bash
   flutter clean
   flutter pub get
   flutter run
   ```

---

## ✅ CHECKLIST

- [ ] Ejecutar `get-sha1.bat` o `get-sha1.ps1`
- [ ] Copiar el valor de SHA1
- [ ] Agregar SHA-1 en Firebase Console
- [ ] Descargar google-services.json actualizado
- [ ] Reemplazar google-services.json en el proyecto
- [ ] Ejecutar `flutter clean && flutter pub get`
- [ ] Probar Google Sign-In

---

## 📞 AYUDA ADICIONAL

Si ninguna solución funciona:

1. **Verifica la instalación de Android Studio:**
   ```
   C:\Program Files\Android\Android Studio\jbr\bin\java.exe
   ```
   Este archivo debe existir.

2. **Usa el método de Android Studio** (no requiere configurar JAVA_HOME)

3. **Instala Java JDK manualmente:**
   - Descarga desde: https://www.oracle.com/java/technologies/downloads/
   - Instala y configura JAVA_HOME a la ruta de instalación

---

Solución creada con ❤️ para facilitar la configuración
