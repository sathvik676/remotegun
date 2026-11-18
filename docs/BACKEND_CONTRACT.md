# Backend API Contract

This project was built around the endpoints you supplied. No other endpoint is called by the app.

Base URL is configurable in the app. Example:

```text
http://192.168.1.5:8000
```

## Endpoints used

| Method | Path | Purpose |
|---|---|---|
| `GET` | `/` | Root availability check |
| `GET` | `/health` | Primary connection monitor |
| `POST` | `/command` | Movement command |
| `POST` | `/led/ON` | Turn LED on |
| `POST` | `/led/OFF` | Turn LED off |

## Movement request

```http
POST /command
Content-Type: application/json

{
  "command": "FORWARD",
  "speed": 150
}
```

Supported `command` values:

```text
FORWARD
BACKWARD
LEFT
RIGHT
STOP
```

The app sends `speed` as an integer from `0` to `255`. STOP is sent as:

```json
{
  "command": "STOP",
  "speed": 0
}
```

## LED requests

```http
POST /led/ON
```

```http
POST /led/OFF
```

No request body is sent.

## Response handling

The app treats any `2xx` response as success unless the JSON body explicitly contains `"success": false` or `"ok": false`.

It can read common FastAPI-style error bodies:

```json
{
  "detail": "Invalid command"
}
```

It also reads common success fields if present:

```json
{
  "ok": true,
  "message": "Command sent"
}
```

Non-JSON bodies are accepted but produce less informative status text.

## `/health` and optional telemetry

The connection monitor calls `/health` repeatedly. A minimal response is enough:

```json
{
  "status": "ok"
}
```

If you later choose to expose telemetry through `/health`, the app automatically parses these optional keys:

```json
{
  "status": "ok",
  "esp32Online": true,
  "mqttConnected": true,
  "batteryPercentage": 78,
  "motorSpeed": 150,
  "direction": "FORWARD"
}
```

Accepted aliases include `esp32_online`, `carOnline`, `deviceOnline`, `mqtt_connected`, `battery`, `battery_percent`, and a nested `telemetry` object.

If these fields are absent, the app shows `UNKNOWN` or `Unavailable`. It does not call a guessed telemetry route.

## CORS

A native Android app does not require browser CORS headers. FastAPI defaults are fine for this client. For Flutter Web you would need CORS configuration, but Web is not a target here.

## Authentication

No auth token is currently sent. If you expose the backend remotely, add authentication to the backend and then add a secure token-entry feature to the app. Do not embed backend or MQTT secrets in the APK.
