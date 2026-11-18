# CLOUD CAR — Flutter Android Control App

A complete Flutter Android application for controlling an ESP32 robotic car through your existing Python FastAPI backend.

The app **does not connect to MQTT**. It talks only to FastAPI over REST. MQTT credentials remain on the backend and ESP32.

## What is included

- Professional dark Material 3 dashboard.
- Six screens: splash, dashboard, car control, telemetry, settings, diagnostics.
- Virtual joystick with continuous command keepalive, dead zone, magnitude-based speed, dominant-axis mapping, and STOP on release.
- Speed slider, 0–255, default 150.
- Latched emergency stop with explicit reset.
- LED ON/OFF buttons using `POST /led/ON` and `POST /led/OFF`.
- Backend health monitoring with automatic retry and exponential backoff.
- Request timeouts, clear errors, offline gating of movement, and no automatic movement after reconnect.
- Local motion watchdog and app-background STOP.
- SharedPreferences-backed server settings.
- Unit tests for command mapping, settings, and HTTP client behavior.
- Windows 11 build/install scripts.

## Important design decisions

1. **Only documented endpoints are used**
   - `GET /`
   - `GET /health`
   - `POST /command`
   - `POST /led/ON`
   - `POST /led/OFF`

2. **Telemetry is not invented**
   - Your backend currently has no telemetry endpoint.
   - The telemetry screen displays “Unavailable” / “Unknown” by default.
   - If you later add optional fields to `GET /health`, the app parses them automatically.

3. **Diagonal input limitation**
   - Your backend supports only `FORWARD`, `BACKWARD`, `LEFT`, `RIGHT`, and `STOP`.
   - The joystick supports diagonal gestures, but a diagonal vector is resolved to the dominant axis because there is no documented diagonal/vector command. See `docs/BACKEND_ENHANCEMENTS.md`.

4. **Safety is layered**
   - The app sends STOP on joystick release, emergency stop, app backgrounding, disconnect, and local watchdog expiry.
   - The ESP32 must independently stop motors when valid commands stop arriving. See `docs/ESP32_WATCHDOG.md`.

## Architecture

```text
Flutter App (REST client)
        ↓
FastAPI Backend :8000
        ↓
Mosquitto MQTT Broker
        ↓
ESP32 + IBT-2/BTS7960 motor driver
        ↓
Four DC geared motors
```

Clean architecture layers used in `lib/`:

| Folder | Responsibility |
|---|---|
| `models/` | Typed data structures and JSON/DTO parsing |
| `services/` | HTTP, repository abstraction, SharedPreferences storage |
| `providers/` | App state with `provider` + `ChangeNotifier` |
| `screens/` | Full-page UI |
| `widgets/` | Reusable UI components |
| `utils/` | Theme, constants, validators, command mapping |

## Quick start on Windows 11

1. Install Flutter SDK, Android Studio, Android SDK Platform, and JDK 17.
2. Add Flutter’s `bin` folder to `PATH`.
3. Run:
   ```powershell
   flutter doctor --android-licenses
   flutter doctor
   ```
4. Generate the missing binary Gradle wrapper files:
   ```powershell
   .\scripts\bootstrap_windows.ps1
   ```
5. Build the APK:
   ```powershell
   .\scripts\build_apk.ps1
   ```
6. Install on a connected phone:
   ```powershell
   .\scripts\install_apk.ps1
   ```

The APK is written to:

```text
build\app\outputs\flutter-apk\app-release.apk
```

## Connect phone and laptop

Your backend must listen on all interfaces, not only localhost:

```powershell
uvicorn main:app --host 0.0.0.0 --port 8000
```

Find the laptop LAN IP:

```powershell
ipconfig
```

Look for `IPv4 Address`, usually `192.168.x.x`.

Open the settings screen in the app and enter:

```text
Protocol: http
Server IP: 192.168.1.5        ← replace with your laptop IP
Port: 8000
```

Then tap **Save and test connection**.

Important: `localhost` on the Android phone refers to the phone itself, not your laptop. For the Android emulator only, use `10.0.2.2`.

See `docs/NETWORKING.md` for firewall setup and remote internet options.

## Testing

Run unit tests:

```powershell
flutter test
```

Run static analysis:

```powershell
flutter analyze
```

Use the **Diagnostics** screen to test:

- `GET /`
- `GET /health`
- `POST /command` with `STOP`
- `POST /led/ON`
- `POST /led/OFF`

See `docs/TESTING.md` for a full checklist.

## Documentation

- `docs/WINDOWS_SETUP.md` — Windows 11 toolchain setup
- `docs/NETWORKING.md` — LAN and remote access
- `docs/BACKEND_CONTRACT.md` — exact API assumptions
- `docs/ESP32_WATCHDOG.md` — required firmware safety watchdog
- `docs/TESTING.md` — unit and hardware test plan
- `docs/FILE_MAP.md` — explanation of every important file
- `docs/BACKEND_ENHANCEMENTS.md` — proposed backend changes, not implemented

## Build output

The first release build uses debug signing so it is easy to install for testing. Before publishing, replace this with a real keystore in `android/app/build.gradle`.

## Safety warning

This is a robotic vehicle. Test with wheels off the ground first. Keep a physical power disconnect available. Do not expose the backend to the public internet without authentication, TLS, rate limiting, and an independent ESP32 failsafe.
