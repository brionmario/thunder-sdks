# flutter-b2c

Thunder Flutter B2C sample application. Demonstrates the full authentication lifecycle using the `thunder_flutter` SDK.

**Flow demonstrated (spec §17.5):**
1. App opens → unauthenticated state (sign-in screen)
2. User initiates sign-in → SDK starts app-native Flow Execution
3. User enters credentials → SDK submits to Thunder
4. Successful → authenticated state with display name, email, avatar (or initials fallback)
5. User taps Sign Out → session terminated, returns to sign-in screen

---

## Prerequisites

- Flutter 3.16+
- A running Thunder instance (see root [README](../../../../README.md))
- iOS 16+ or Android API 26+

---

## Setup

```bash
# 1. Copy and fill in your environment
cp .env.example .env

# 2. Install dependencies
flutter pub get

# 3. Start an iOS simulator (or connect a device)
open -a Simulator

# 4. Verify available Flutter targets
flutter devices

# 5. Run on a target device or simulator
flutter run -d <device-id>
```

### Notes for this monorepo sample

- The iOS integration uses the local Thunder SDK in this repo via CocoaPods path resolution.
- On first iOS run, Flutter will run `pod install` automatically and may take longer.
- If you want Flutter to pick the default available device, you can still run `flutter run`.

### Local HTTPS on iOS

- Thunder copies `server.cert` into this sample during the build flow for local development.
- When `THUNDER_BASE_URL` points to `https://localhost...`, the iOS sample uses that bundled certificate for localhost-only certificate pinning.
- This allows the sample to connect to a local Thunder instance over HTTPS without manually trusting the copied self-signed certificate in the iOS Simulator.
- This behavior is limited to `localhost` and is intended only for this sample app's local development flow.

### Environment variables (`.env`)

| Variable | Description |
|----------|-------------|
| `THUNDER_BASE_URL` | Base URL of your Thunder server (HTTPS) |
| `THUNDER_CLIENT_ID` | OAuth2 client ID registered in Thunder |
| `THUNDER_APP_ID` | Application UUID from Thunder console |
| `THUNDER_AFTER_SIGN_IN_URL` | Custom URL scheme callback (e.g. `io.thunder.b2c://callback`) |
| `THUNDER_AFTER_SIGN_OUT_URL` | Post-logout redirect URI |

> `.env` is gitignored. Never commit real credentials.

---

## Running tests

```bash
flutter test
```
