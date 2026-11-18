$ErrorActionPreference = 'Stop'

$apk = 'build\app\outputs\flutter-apk\app-release.apk'
if (-not (Test-Path $apk)) {
    throw "APK not found: $apk. Run scripts\build_apk.ps1 first."
}

adb devices
adb install -r $apk
