# ESP32 Local Safety Watchdog

The Flutter app has a watchdog, but it must **not** be the only safety mechanism. The ESP32 must stop the motors if valid movement commands stop arriving, regardless of why they stopped: app crash, phone offline, backend crash, MQTT disconnect, or Wi-Fi loss.

## Required firmware behavior

1. On boot, stop all motors.
2. Only `FORWARD`, `BACKWARD`, `LEFT`, and `RIGHT` update `lastValidCommandMs`.
3. `STOP` immediately stops motors and clears the active movement flag.
4. In `loop()`, if a movement is active and:
   ```cpp
   millis() - lastValidCommandMs > COMMAND_TIMEOUT_MS
   ```
   call `stopMotors()` immediately.
5. On Wi-Fi disconnect or MQTT disconnect, call `stopMotors()`.
6. On invalid command, malformed payload, or MQTT reconnect, call `stopMotors()`.
7. Use a timeout around 600–900 ms. The app sends a keepalive command about every 300 ms while the joystick is active.
8. Keep the watchdog independent of the mobile app and backend logic.

## Suggested Arduino-style skeleton

Adapt pin names and motor geometry to your IBT-2/BTS7960 wiring.

```cpp
const unsigned long COMMAND_TIMEOUT_MS = 700;

unsigned long lastValidCommandMs = 0;
bool movementActive = false;

void stopMotors() {
  // Set all PWM outputs to 0 and set direction pins safe.
  setAllMotors(0, true);
  movementActive = false;
}

void setAllMotors(int pwm, bool forward) {
  // Apply the same PWM to all four IBT-2 modules through your motor mapping.
  // Example:
  // analogWrite(PWM_LEFT, pwm);
  // digitalWrite(IN_LEFT_A, forward ? HIGH : LOW);
  // digitalWrite(IN_LEFT_B, forward ? LOW : HIGH);
  // ...
}

void applyMovement(const String& command, int speed) {
  speed = constrain(speed, 0, 255);

  if (command == "STOP") {
    stopMotors();
    return;
  }

  if (speed <= 0) {
    stopMotors();
    return;
  }

  if (command == "FORWARD") {
    setAllMotors(speed, true);
  } else if (command == "BACKWARD") {
    setAllMotors(speed, false);
  } else if (command == "LEFT") {
    // Replace with your differential/steering mapping.
    setLeftMotors(speed, false);
    setRightMotors(speed, true);
  } else if (command == "RIGHT") {
    setLeftMotors(speed, true);
    setRightMotors(speed, false);
  } else {
    stopMotors();
    return;
  }

  lastValidCommandMs = millis();
  movementActive = true;
}

void setup() {
  stopMotors();
  // Initialize Wi-Fi and MQTT here.
}

void loop() {
  // Reconnect callbacks should call stopMotors() when Wi-Fi/MQTT drops.

  if (movementActive &&
      millis() - lastValidCommandMs > COMMAND_TIMEOUT_MS) {
    stopMotors();
  }

  // Run your MQTT client loop here.
}
```

## Important integration note

The app deliberately repeats the active command every ~300 ms so the ESP32 can distinguish an active joystick from a stale command. Make sure your backend forwards these repeated commands to MQTT rather than deduplicating them. Deduplication is acceptable for identical payloads in most APIs, but it would defeat a command-arrival watchdog.

## Physical failsafe

For a real vehicle, also consider:

- hardware E-stop that cuts motor power,
- current sensing on the IBT-2 modules,
- temperature monitoring,
- a separate firmware-level max runtime per command,
- current-limited power supply,
- bench testing with wheels elevated.
