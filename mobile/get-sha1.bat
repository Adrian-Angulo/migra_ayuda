@echo off
echo ========================================
echo Obteniendo SHA-1 del proyecto MigraAyuda
echo ========================================
echo.

REM Configurar JAVA_HOME usando el JDK de Android Studio
set JAVA_HOME=C:\Program Files\Android\Android Studio\jbr
set PATH=%JAVA_HOME%\bin;%PATH%

echo JAVA_HOME configurado: %JAVA_HOME%
echo.

cd android
echo Ejecutando gradlew signingReport...
echo.
call gradlew signingReport

echo.
echo ========================================
echo BUSCA LA LINEA QUE DICE "SHA1:" ARRIBA
echo ========================================
echo.
echo Copia el valor del SHA1 y agregalo en:
echo Firebase Console ^> Project Settings ^> Your apps ^> Android app ^> SHA certificate fingerprints
echo.
pause
