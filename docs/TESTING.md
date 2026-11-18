# Testing Plan

## 1. Static analysis and unit tests

```powershell
flutter analyze
flutter test
```

Unit tests cover:

- documented `POST /command` payload,
- `GET /health` parsing,
- non-2xx FastAPI `detail` errors,
- timeout messages,
- `POST /led/ON`,
- joystick-to-command mapping,
- diagonal dominant-axis behavior,
- settings URL building and persistence model,
- host/port validators.

## 2. Backend API tests from the app

Open **Diagnostics** and tap **Run safe checks**. Expected results:

| Check | Expected |
|---|---|
| Root endpoint | `200` or `2xx`, message shown |
| Health endpoint | `2xx`, status message shown |
| STOP command | `2xx`, command acknowledged |

Use the manual LED buttons to test:

- `POST /led/ON` turns the physical LED on and the UI shows `ON`.
- `POST /led/OFF` turns it off and the UI shows `OFF`.

If a check fails, the result shows HTTP status and error text.

## 3. Connection monitoring tests

1. Start backend with `uvicorn main:app --host 0.0.0.0 --port 8000`.
2. Open the app. Dashboard should show **BACKEND ONLINE**.
3. Stop the backend.
4. Within a few seconds the app should show **BACKEND OFFLINE** and an error message.
5. Confirm joystick movement is disabled.
6. Restart the backend.
7. Tap **Retry backend connection**.
8. Confirm the status returns online but the car does **not** move by itself.

## 4. Joystick tests

With wheels elevated:

1. Drag fully up → `FORWARD`, speed scales with distance.
2. Drag fully down → `BACKWARD`.
3. Drag left/right → `LEFT` / `RIGHT`.
4. Drag diagonally → dominant supported axis; note the UI limitation.
5. Release → joystick returns to center and `STOP` is sent.
6. Move joystick slowly near center → no command inside dead zone.
7. Change the speed slider while holding → next keepalive uses the new speed.

## 5. Emergency stop tests

1. Start movement, then tap **EMERGENCY STOP**.
2. Confirm STOP appears in diagnostics/logging and motors stop.
3. Confirm the joystick no longer sends movement.
4. Tap **RESET EMERGENCY STOP**.
5. Confirm the car remains stopped and only moves after a fresh joystick gesture.

## 6. Safety watchdog tests

These test the ESP32, not just the app:

1. Start movement.
2. Kill the Flutter app abruptly.
3. Confirm the ESP32 stops within ~700 ms.
3. Start movement and turn off Wi-Fi on the phone.
4. Confirm the ESP32 stops.
5. Start movement and stop the FastAPI backend.
6. Confirm the ESP32 stops when MQTT commands cease.
7. Power-cycle the ESP32 while a command would otherwise be active.
8. Confirm motors remain stopped after boot.

## 7. Build/install tests

```powershell
.\scripts\bootstrap_windows.ps1
.\scripts\build_apk.ps1
.\scripts\install_apk.ps1
```

Confirm the app launches, splash screen completes, and the bottom navigation has five tabs.

## 8. Expected limitations

- ESP32/MQTT/battery fields show `UNKNOWN` or `Unavailable` because your backend has no telemetry endpoint.
- Confirmed motor speed/direction are not available; the app shows last commanded values and labels them as local state.
- True diagonal commands are unavailable until the backend contract is extended.
