$ErrorActionPreference = 'Stop'

flutter clean
flutter pub get
flutter analyze
flutter test
flutter build apk --release

Write-Host 'APK: build\app\outputs\flutter-apk\app-release.apk'
