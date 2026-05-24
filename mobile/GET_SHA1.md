# 🔐 Cómo Obtener el SHA-1 del Proyecto Mobile

## 📋 Resumen

Para configurar Google Sign-In en Firebase, necesitas el SHA-1 de tu keystore de Android.

---

## 🎯 MÉTODOS PARA OBTENER EL SHA-1

### **MÉTODO 1: Usando Gradle (Recomendado)**

#### **Opción A: Desde la terminal**

1. Abre una terminal en la carpeta del proyecto:
   ```bash
   cd c:\DEV\flutter\migra_ayuda\mobile
   ```

2. Ejecuta el comando de Gradle:
   ```bash
   cd android
   .\gradlew signingReport
   ```

3. Busca en la salida la sección **"Variant: debug"**:
   ```
   Variant: debug
   Config: debug
   Store: C:\Users\[TU_USUARIO]\.android\debug.keystore
   Alias: AndroidDebugKey
   MD5: XX:XX:XX:XX:XX:XX:XX:XX:XX:XX:XX:XX:XX:XX:XX:XX
   SHA1: XX:XX:XX:XX:XX:XX:XX:XX:XX:XX:XX:XX:XX:XX:XX:XX:XX:XX:XX:XX
   SHA-256: XX:XX:XX:XX:XX:XX:XX:XX:XX:XX:XX:XX:XX:XX:XX:XX:XX:XX:XX:XX:XX:XX:XX:XX:XX:XX:XX:XX:XX:XX:XX:XX
   ```

4. **Copia el valor de SHA1** (la línea que dice SHA1:)

#### **Opción B: Desde Android Studio**

1. Abre Android Studio
2. Abre el proyecto en `c:\DEV\flutter\migra_ayuda\mobile\android`
3. En el panel derecho, haz clic en **Gradle**
4. Navega a: `android → Tasks → android → signingReport`
5. Haz doble clic en `signingReport`
6. En la consola, busca el SHA1 en la sección "Variant: debug"

---

### **MÉTODO 2: Usando keytool (Alternativo)**

Si tienes Java instalado y configurado en tu PATH:

1. Abre PowerShell o CMD

2. Ejecuta el siguiente comando:
   ```powershell
   keytool -list -v -keystore "%USERPROFILE%\.android\debug.keystore" -alias androiddebugkey -storepass android -keypass android
   ```

3. Busca la línea que dice **"SHA1:"**:
   ```
   Certificate fingerprints:
        SHA1: XX:XX:XX:XX:XX:XX:XX:XX:XX:XX:XX:XX:XX:XX:XX:XX:XX:XX:XX:XX
        SHA256: XX:XX:XX:XX:XX:XX:XX:XX:XX:XX:XX:XX:XX:XX:XX:XX:XX:XX:XX:XX:XX:XX:XX:XX:XX:XX:XX:XX:XX:XX:XX:XX
   ```

4. **Copia el valor de SHA1**

---

### **MÉTODO 3: Usando Flutter (Si Java no está en PATH)**

1. Abre una terminal en la carpeta del proyecto:
   ```bash
   cd c:\DEV\flutter\migra_ayuda\mobile\android
   ```

2. Ejecuta:
   ```bash
   flutter pub run keytool -list -v -keystore "%USERPROFILE%\.android\debug.keystore" -alias androiddebugkey -storepass android -keypass android
   ```

---

## 📍 UBICACIÓN DEL KEYSTORE

Tu keystore de debug está ubicado en:
```
C:\Users\[TU_USUARIO]\.android\debug.keystore
```

**Verificado:** ✅ El keystore existe en tu sistema

---

## 🔧 CONFIGURAR SHA-1 EN FIREBASE

Una vez que tengas el SHA-1:

### **Paso 1: Ir a Firebase Console**
1. Abre [Firebase Console](https://console.firebase.google.com/)
2. Selecciona tu proyecto "MigraAyuda"

### **Paso 2: Configurar Android App**
1. Ve a **Project Settings** (⚙️ en la parte superior izquierda)
2. Desplázate hasta la sección **"Your apps"**
3. Selecciona tu app Android

### **Paso 3: Agregar SHA-1**
1. Desplázate hasta **"SHA certificate fingerprints"**
2. Haz clic en **"Add fingerprint"**
3. Pega tu SHA-1
4. Haz clic en **"Save"**

### **Paso 4: Descargar google-services.json actualizado**
1. Descarga el nuevo archivo `google-services.json`
2. Reemplaza el archivo en:
   ```
   c:\DEV\flutter\migra_ayuda\mobile\android\app\google-services.json
   ```

---

## 🎯 PARA PRODUCCIÓN

Cuando vayas a publicar la app, necesitarás también el SHA-1 de tu keystore de producción:

```bash
keytool -list -v -keystore [RUTA_A_TU_KEYSTORE_DE_PRODUCCION] -alias [TU_ALIAS]
```

Y agregarlo también en Firebase Console.

---

## ⚠️ PROBLEMAS COMUNES

### **"keytool no se reconoce como comando"**

**Solución 1:** Usar Gradle (Método 1)

**Solución 2:** Agregar Java al PATH:
1. Busca dónde está instalado Java (usualmente en `C:\Program Files\Java\jdk-XX\bin`)
2. Agrega esa ruta al PATH de Windows
3. Reinicia la terminal

**Solución 3:** Usar la ruta completa de keytool:
```powershell
"C:\Program Files\Java\jdk-XX\bin\keytool.exe" -list -v -keystore "%USERPROFILE%\.android\debug.keystore" -alias androiddebugkey -storepass android -keypass android
```

### **"JAVA_HOME is not set"**

**Solución:** Usar Gradle desde Android Studio (Método 1, Opción B)

### **"Keystore was tampered with, or password was incorrect"**

**Solución:** El keystore de debug usa estas credenciales por defecto:
- **Alias:** `androiddebugkey`
- **Store password:** `android`
- **Key password:** `android`

Si cambiaste estas credenciales, usa las tuyas.

---

## 📝 SCRIPT RÁPIDO

Crea un archivo `get-sha1.bat` en la carpeta `mobile` con este contenido:

```batch
@echo off
echo ========================================
echo Obteniendo SHA-1 del proyecto
echo ========================================
echo.

cd android
call gradlew signingReport

echo.
echo ========================================
echo Busca la linea que dice "SHA1:" arriba
echo ========================================
pause
```

Luego solo ejecuta:
```bash
.\get-sha1.bat
```

---

## 🔍 EJEMPLO DE SALIDA

Cuando ejecutes el comando correctamente, verás algo como:

```
Variant: debug
Config: debug
Store: C:\Users\adrian\.android\debug.keystore
Alias: AndroidDebugKey
MD5: A1:B2:C3:D4:E5:F6:G7:H8:I9:J0:K1:L2:M3:N4:O5:P6
SHA1: 1A:2B:3C:4D:5E:6F:7G:8H:9I:0J:1K:2L:3M:4N:5O:6P:7Q:8R:9S:0T
SHA-256: 1A2B3C4D5E6F7G8H9I0J1K2L3M4N5O6P7Q8R9S0T1U2V3W4X5Y6Z7A8B9C0D
Valid until: Friday, December 31, 2054
```

**El SHA-1 que necesitas es:** `1A:2B:3C:4D:5E:6F:7G:8H:9I:0J:1K:2L:3M:4N:5O:6P:7Q:8R:9S:0T`

---

## ✅ CHECKLIST

- [ ] Obtener SHA-1 del keystore de debug
- [ ] Agregar SHA-1 en Firebase Console
- [ ] Descargar google-services.json actualizado
- [ ] Reemplazar google-services.json en el proyecto
- [ ] Limpiar y reconstruir el proyecto
- [ ] Probar Google Sign-In

---

## 🚀 DESPUÉS DE CONFIGURAR

Una vez que agregues el SHA-1 en Firebase:

1. **Limpia el proyecto:**
   ```bash
   cd android
   .\gradlew clean
   ```

2. **Reconstruye:**
   ```bash
   flutter clean
   flutter pub get
   flutter run
   ```

3. **Prueba Google Sign-In** en tu dispositivo o emulador

---

## 📞 AYUDA ADICIONAL

Si sigues teniendo problemas:

1. Verifica que el paquete en `android/app/build.gradle` coincida con el de Firebase
2. Verifica que `google-services.json` esté en `android/app/`
3. Verifica que las dependencias de Firebase estén actualizadas
4. Limpia y reconstruye el proyecto completamente

---

Creado con ❤️ para facilitar la configuración de Google Sign-In
