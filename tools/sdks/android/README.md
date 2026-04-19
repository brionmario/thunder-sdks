# Thunder Android SDK

Kotlin SDK for integrating Thunder identity management into Android applications.

**Layer:** Platform SDK  
**Group ID:** `io.thunder` / Artifact: `android`  
**Min SDK:** API 26 (Android 8.0)

---

## Installation

### Gradle (build.gradle.kts)

```kotlin
dependencies {
    implementation("io.thunder:android:0.1.0")
}
```

---

## Quick Start

```kotlin
import io.thunder.android.*

// 1. Initialize once (e.g., in Application.onCreate)
val client = ThunderClient()
client.initialize(
    ThunderConfig(
        baseUrl = "https://your-thunder-instance.example.com",
        clientId = "your-client-id"
    ),
    storage = EncryptedStorageAdapter(context)
)

// 2. App-native sign-in
val initResponse = client.signIn(
    payload = EmbeddedSignInPayload(actionId = "init"),
    request = EmbeddedFlowRequestConfig(applicationId = "your-app-id")
)

// Submit credentials
val result = client.signIn(
    payload = EmbeddedSignInPayload(
        flowId = initResponse.flowId,
        actionId = "basic_auth",
        inputs = mapOf("username" to "user@example.com", "password" to "secret")
    ),
    request = EmbeddedFlowRequestConfig(applicationId = "your-app-id")
)

// 3. Get the authenticated user
val user = client.getUser()
println(user.displayName ?: user.email ?: user.sub)

// 4. Sign out
client.signOut()
```

---

## Configuration Reference

| Field | Type | Required | Description |
|-------|------|----------|-------------|
| `baseUrl` | `String` | Yes | Thunder server base URL. Must be HTTPS. |
| `clientId` | `String?` | For redirect mode | OAuth2 client ID. |
| `scopes` | `List<String>` | No | Defaults to `["openid"]`. |
| `afterSignInUrl` | `String?` | For redirect mode | Redirect URI registered in Thunder. |
| `storage` | `StorageAdapter?` | Yes | Use `EncryptedStorageAdapter(context)` for production. |

See the [full specification](../../specification/README.md) for all options.

---

## Security

- Tokens are stored in **EncryptedSharedPreferences** backed by the Android Keystore.
- PKCE (`S256`) is mandatory in redirect mode; the `code_verifier` is held in memory only.
- ID tokens are validated against the server's JWKS (signature, `iss`, `aud`, `exp`, `nonce`).
- Access tokens auto-refresh 60 seconds before expiry.
- Refresh tokens rotate atomically on use.
- HTTP `baseUrl` values are rejected at initialization.

---

## Custom Storage

```kotlin
class MyStorage : StorageAdapter {
    override fun store(key: String, value: String) { ... }
    override fun retrieve(key: String): String? = ...
    override fun delete(key: String) { ... }
    override fun clear() { ... }
}
```

---

## Testing

```bash
./gradlew test
```

Target: 80%+ coverage.

---

## API Reference

See [docs/content/sdks/android/](../../../docs/content/sdks/android/) for the full API reference.

Full specification: [tools/sdks/specification/README.md](../../specification/README.md)
