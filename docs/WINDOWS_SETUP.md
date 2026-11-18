# Windows 11 Setup

## 1. Install Flutter

1. Download the Flutter SDK from `https://docs.flutter.dev/get-started/install/windows`.
2. Extract it to a short path such as `C:\src\flutter`.
3. Add this to your user `PATH`:
   ```text
   C:\src\flutter\bin
   ```
4. Verify:
   ```powershell
   flutter --version
   ```

## 2. Install Android tooling

1. Install Android Studio.
2. In Android Studio, open **Tools → SDK Manager** and install:
   - Android SDK Platform 35 or the platform reported by `flutter doctor`
   - Android SDK Build-Tools
   - Android Platform Tools
3. Install JDK 17. Android Studio includes one; otherwise install a JDK 17 distribution and set `JAVA_HOME`.
4. Accept licenses:
   ```powershell
   flutter doctor --android-licenses
   ```
5. Verify:
   ```powershell
   flutter doctor -v
   ```

Resolve every item marked `[X]` before building.

## 3. Prepare this project

Run:

```powershell
.\scripts\bootstrap_windows.ps1
```

This script:

- creates a temporary Flutter Android scaffold,
- copies the missing binary Gradle wrapper files into `android/`,
- preserves the custom Gradle, manifest, and theme files already in this project,
- runs `flutter pub get`.

If PowerShell blocks scripts, run:

```powershell
Set-ExecutionPolicy -Scope CurrentUser RemoteSigned
```

## 4. Connect an Android phone

1. Enable **Developer options** on the phone.
2. Enable **USB debugging**.
3. Connect the phone by USB.
4. Accept the RSA debugging prompt.
5. Verify:
   ```powershell
   adb devices
   ```
6. The phone must be on the same Wi-Fi network as the laptop.

You can also use the Android emulator. The emulator alias for the host laptop is `10.0.2.2`, which is the default server host in this app.

## 5. Build

```powershell
.\scripts\build_apk.ps1
```

This runs `flutter clean`, `flutter pub get`, `flutter analyze`, `flutter test`, and `flutter build apk --release`.

## 6. Install

With the phone connected and unlocked:

```powershell
.\scripts\install_apk.ps1
```

Alternatively, copy the APK to the phone and open it. Android may ask you to allow installation from unknown sources.

## Troubleshooting

| Problem | Fix |
|---|---|
| `flutter: command not found` | Add Flutter `bin` to `PATH` and restart PowerShell. |
| Gradle cannot find Java 17 | Set `JAVA_HOME` to a JDK 17 install. |
| Android license errors | Run `flutter doctor --android-licenses`. |
| `adb device unauthorized` | Unlock the phone and accept the debugging prompt. |
| APK installs but shows offline | Check the server IP in Settings and Windows Firewall. |
| HTTP requests blocked | The app manifest enables cleartext HTTP for LAN use. Prefer HTTPS for remote use. |
