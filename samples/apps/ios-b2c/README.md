# Thunder iOS B2C Sample

Demonstrates a native iOS B2C flow using the ThunderSwiftUI SDK:

- Unauthenticated → embedded sign-in form (Flow Execution API)
- Authenticated → user avatar dropdown, organization switcher, editable profile sheet
- Sign-out → returns to sign-in screen

## Setup

```bash
cp .env.example .env
# Edit .env with your Thunder base URL, client ID, and application ID
```

## Run

Open in Xcode via `Package.swift` and run on an iOS 16+ simulator or device.

## SDK used

`ThunderSwiftUI` at `tools/sdks/swiftui/` — depends on the `Thunder` iOS Platform SDK at `tools/sdks/ios/`.
