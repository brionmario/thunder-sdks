# Thunder Android B2C Sample

Demonstrates a native Android B2C flow using the Thunder Compose SDK:

- Unauthenticated → embedded sign-in form (Flow Execution API)
- Authenticated → user avatar dropdown, organization switcher, editable profile screen
- Sign-out → returns to sign-in screen

## Setup

Copy `.env.example` to `local.properties` and add your Thunder credentials:

```
THUNDER_BASE_URL=https://localhost:8090
THUNDER_CLIENT_ID=your-client-id
THUNDER_APPLICATION_ID=your-application-id
```

## Run

Open in Android Studio, sync Gradle, and run on an API 24+ emulator or device.

## SDK used

`io.thunder.compose` at `tools/sdks/compose/` — depends on the `io.thunder.android` Platform SDK at `tools/sdks/android/`.
