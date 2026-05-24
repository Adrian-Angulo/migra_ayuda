# Script para obtener SHA-1 del proyecto MigraAyuda
Write-Host "========================================" -ForegroundColor Cyan
Write-Host "Obteniendo SHA-1 del proyecto MigraAyuda" -ForegroundColor Cyan
Write-Host "========================================" -ForegroundColor Cyan
Write-Host ""

# Configurar JAVA_HOME usando el JDK de Android Studio
$env:JAVA_HOME = "C:\Program Files\Android\Android Studio\jbr"
$env:PATH = "$env:JAVA_HOME\bin;$env:PATH"

Write-Host "JAVA_HOME configurado: $env:JAVA_HOME" -ForegroundColor Green
Write-Host ""

# Cambiar al directorio android
Set-Location -Path "android"

Write-Host "Ejecutando gradlew signingReport..." -ForegroundColor Yellow
Write-Host ""

# Ejecutar gradlew
& .\gradlew.bat signingReport

Write-Host ""
Write-Host "========================================" -ForegroundColor Cyan
Write-Host "BUSCA LA LINEA QUE DICE 'SHA1:' ARRIBA" -ForegroundColor Yellow
Write-Host "========================================" -ForegroundColor Cyan
Write-Host ""
Write-Host "Copia el valor del SHA1 y agregalo en:" -ForegroundColor White
Write-Host "Firebase Console > Project Settings > Your apps > Android app > SHA certificate fingerprints" -ForegroundColor White
Write-Host ""

# Volver al directorio anterior
Set-Location -Path ".."

Read-Host "Presiona Enter para salir"
