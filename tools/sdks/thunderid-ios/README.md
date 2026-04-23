# Thunder iOS SDK

Swift SDK for integrating Thunder identity management into iOS and macOS applications.

**Layer:** Platform SDK  
**Package:** `Thunder` (Swift Package Manager)  
**Platforms:** iOS 16+, macOS 13+

---

## Installation

### Swift Package Manager

```swift
// Package.swift
dependencies: [
    .package(url: "https://github.com/asgardeo/thunder", from: "0.1.0")
]
```

Or add via Xcode: **File → Add Package Dependencies** and enter the repository URL.

---

## Quick Start

```swift
import Thunder

// 1. Initialize once (e.g., in your App struct or AppDelegate)
let client = ThunderClient()
try await client.initialize(config: ThunderConfig(
    baseUrl: "https://your-thunder-instance.example.com",
    clientId: "your-client-id",
    afterSignInUrl: "myapp://callback"
))

// 2. App-native sign-in
let initResponse = try await client.signIn(
    payload: EmbeddedSignInPayload(actionId: "init"),
    request: EmbeddedFlowRequestConfig(applicationId: "your-app-id")
)

// Submit credentials
let result = try await client.signIn(
    payload: EmbeddedSignInPayload(
        flowId: initResponse.flowId,
        actionId: "basic_auth",
        inputs: ["username": "user@example.com", "password": "secret"]
    ),
    request: EmbeddedFlowRequestConfig(applicationId: "your-app-id")
)

// 3. Get the authenticated user
let user = try await client.getUser()
print(user.displayName ?? user.email ?? user.sub)

// 4. Sign out
try await client.signOut()
```

---

## Operational Modes

**App-Native (recommended for iOS):** Fully API-driven authentication via the Flow Execution API. No browser redirects.

**Redirect-Based:** Use `buildSignInURL()` to get an authorization URL and open it in `ASWebAuthenticationSession`. Call `handleRedirectCallback(url:)` when the app receives the callback.

---

## Configuration Reference

| Field | Type | Required | Description |
|-------|------|----------|-------------|
| `baseUrl` | `String` | Yes | Thunder server base URL. Must be HTTPS. |
| `clientId` | `String?` | For redirect mode | OAuth2 client ID. |
| `scopes` | `[String]` | No | Defaults to `["openid"]`. |
| `afterSignInUrl` | `String?` | For redirect mode | Redirect URI registered in Thunder. |
| `afterSignOutUrl` | `String?` | No | Post-logout redirect URI. |
| `applicationId` | `String?` | No | Thunder application UUID. |
| `storage` | `StorageAdapter?` | No | Custom storage. Defaults to iOS Keychain. |

See the [full specification](../../specification/README.md) for all options.

---

## Security

- Tokens are stored in the **iOS Keychain** by default.
- PKCE (`S256`) is mandatory in redirect mode; the `code_verifier` is held in memory only.
- ID tokens are validated against the server's JWKS endpoint (signature, `iss`, `aud`, `exp`, `nonce`).
- Access tokens are refreshed automatically 60 seconds before expiry.
- Refresh tokens are rotated atomically on use.
- HTTP `baseUrl` values are rejected at initialization.

---

## Custom Storage

```swift
struct MyCustomStorage: StorageAdapter {
    func store(key: String, value: String) throws { ... }
    func retrieve(key: String) -> String? { ... }
    func delete(key: String) { ... }
    func clear() { ... }
}

try await client.initialize(
    config: ThunderConfig(baseUrl: "https://...", clientId: "..."),
    storage: MyCustomStorage()
)
```

---

## Testing

```bash
swift test
```

Target: 80%+ coverage. Run against a local Thunder instance for integration tests.

---

## API Reference

See [docs/content/sdks/ios/](../../../docs/content/sdks/ios/) for the full API reference.
