# Proposed Backend Enhancements — Not Implemented

I did **not** modify your FastAPI backend or invent endpoints that the app calls. The Flutter app uses only the endpoints you supplied.

The following enhancements are optional. Each requires your approval before backend changes are made.

## 1. Telemetry endpoint

Current state: no telemetry endpoint exists. The app displays unavailable/unknown values.

Proposed addition:

```http
GET /telemetry
```

Example response:

```json
{
  "esp32Online": true,
  "mqttConnected": true,
  "batteryPercentage": 78,
  "motorSpeed": 150,
  "direction": "FORWARD",
  "updatedAt": "2026-11-18T10:15:00Z"
}
```

After approval, the app can be updated to poll this endpoint instead of relying on optional fields in `/health`.

## 2. True diagonal or vector movement

Current contract supports only:

```text
FORWARD, BACKWARD, LEFT, RIGHT, STOP
```

The joystick supports diagonal gestures, but diagonal input is mapped to the dominant axis.

Two possible backend extensions:

### Option A — explicit diagonal commands

```text
FORWARD_LEFT
FORWARD_RIGHT
BACKWARD_LEFT
BACKWARD_RIGHT
```

Request:

```json
{
  "command": "FORWARD_RIGHT",
  "speed": 180
}
```

### Option B — vector command

```json
{
  "command": "VECTOR",
  "x": 0.8,
  "y": -0.4,
  "speed": 180
}
```

Option B is cleaner but requires ESP32-side interpretation and a clearly defined coordinate system.

## 3. Preserve repeated command keepalives

The app repeats the active movement command roughly every 300 ms so the ESP32 watchdog can detect stale commands. Confirm that FastAPI forwards every valid command to MQTT rather than deduplicating identical payloads.

## 4. Authentication for remote access

The current app sends no auth header. For internet access, add backend authentication before exposing the service.

Possible approach:

```http
Authorization: Bearer <token>
```

The token would be entered by the user in Settings and stored with platform-secure storage. MQTT credentials must remain server-side.

## 5. Command acknowledgment from ESP32

If you want the dashboard to show confirmed motor state rather than last commanded state, add a backend-to-ESP32 request/response flow or a telemetry topic that publishes actual motor PWM and direction.

## 6. Rate limiting and command validation

For remote use, add:

- maximum command rate,
- strict enum validation,
- speed bounds validation,
- per-device authorization,
- logging of emergency-stop events.

## Approval needed

If you want any of these implemented, tell me which items to add and provide or authorize access to the FastAPI source. I will then update the backend, ESP32 firmware contract, and Flutter client consistently.
