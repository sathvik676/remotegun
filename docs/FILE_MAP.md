# File Map

## Root

| File | Purpose |
|---|---|
| `pubspec.yaml` | Flutter dependencies and asset configuration. |
| `analysis_options.yaml` | Flutter lint rules. |
| `README.md` | Main setup, architecture, and build guide. |

## `lib/main.dart`

- Initializes SharedPreferences, providers, repositories, and the API client.
- Mounts the provider tree and the Material 3 dark theme.
- Wires teardown (`dispose`, client closing) for clean lifecycle management.

## `lib/utils/`

| File | Purpose |
|---|---|
| `constants.dart` | App strings, default host/port/speed, API paths, storage keys. |
| `app_theme.dart` | Premium dark theme, gradients, `CardTheme`, colors. |
| `validators.dart` | Host, port, and base-path validation for settings. |

## `lib/models/`

| File | Purpose |
|---|---|
| `api_result.dart` | Normalized HTTP result with JSON parsing and success/message helpers. |
| `app_settings.dart` | Backend URL parts, URI construction, serialization. |
| `connection_state.dart` | `ConnectionStatus` enum and labels. |
| `movement_command.dart` | Movement enums and JSON payload shape. |
| `led_state.dart` | LED state enum and label helpers. |
| `backend_health.dart` | Parses `/health` and optional telemetry aliases. |
| `diagnostics_result.dart` | Stored diagnostic run entries. |
| `telemetry.dart` | UI-facing telemetry snapshot. |

## `lib/services/`

| File | Purpose |
|---|---|
| `api_client.dart` | HTTP client with timeouts, exception mapping, JSON decoding. |
| `backend_repository.dart` | Typed calls to the four documented endpoints. |
| `settings_repository.dart` | SharedPreferences load/save for server settings. |

## `lib/providers/`

| File | Purpose |
|---|---|
| `settings_provider.dart` | Settings state, persistence, defaults. |
| `connection_provider.dart` | Health polling, retries, exponential backoff, connectivity status. |
| `car_control_provider.dart` | Joystick processing, speed state, command throttling, keepalive, watchdog, emergency stop, LED calls. |
| `telemetry_provider.dart` | Derives dashboard/telemetry UI state from health + local command state. |
| `diagnostics_provider.dart` | Manual API diagnostics, LED checks, result history. |

## `lib/screens/`

| File | Purpose |
|---|---|
| `splash_screen.dart` | Animated splash/launch screen. |
| `dashboard_screen.dart` | Main dashboard, status cards, emergency stop, quick actions. |
| `car_control_screen.dart` | Joystick, speed, LED, emergency stop, and connection gating. |
| `telemetry_screen.dart` | Telemetry view with unavailable states and data-source notes. |
| `settings_screen.dart` | Backend URL/port/path/scheme editor and save/test flow. |
| `diagnostics_screen.dart` | Safe endpoint checks, LED test buttons, result log. |

## `lib/widgets/`

| File | Purpose |
|---|---|
| `app_shell.dart` | Bottom navigation shell plus app-lifecycle STOP handling. |
| `app_card.dart` | Styled card container. |
| `connection_status_chip.dart` | Animated connection/status badge. |
| `status_card.dart` | Dashboard status tile. |
| `direction_display.dart` | Direction and speed summary. |
| `speed_control.dart` | Speed slider UI. |
| `led_control_card.dart` | LED toggle card. |
| `emergency_stop.dart` | Emergency stop button and reset flow. |
| `joystick.dart` | Custom joystick widget and gesture handling. |

## Tests

| File | Purpose |
|---|---|
| `test/api_client_test.dart` | HTTP request/response behavior. |
| `test/command_mapper_test.dart` | Joystick-to-command mapping. |
| `test/server_settings_test.dart` | URL building, settings serialization, validators. |

## Android and scripts

| File | Purpose |
|---|---|
| `android/app/src/main/AndroidManifest.xml` | Internet permission, cleartext traffic, app label, launcher activity. |
| `android/app/build.gradle` | Android build settings and signing for release debug fallback. |
| `android/settings.gradle` | Plugin repositories and Flutter plugin loader. |
| `android/build.gradle` | Project-level repositories and build directories. |
| `android/gradle.properties` | Gradle memory and AndroidX flags. |
| `scripts/bootstrap_windows.ps1` | Generates missing Gradle wrapper files and launcher icon resources, then runs `flutter pub get`. |
| `scripts/build_apk.ps1` | Clean, test, analyze, release APK build. |
| `scripts/install_apk.ps1` | Install release APK through `adb`. |
| `docs/*.md` | Operator and implementation documentation. |
