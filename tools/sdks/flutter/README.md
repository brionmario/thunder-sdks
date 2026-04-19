# Thunder Flutter SDK

Flutter SDK for integrating Thunder identity management into cross-platform iOS and Android applications.

**Layer:** Core Lib SDK  
**Package:** `thunder_flutter` (pub.dev)  
**Architecture:** Delegates all protocol operations (OAuth2/OIDC, token management, flow orchestration) to the native Thunder iOS and Android Platform SDKs via Flutter platform channels.

---

## Installation

```yaml
# pubspec.yaml
dependencies:
  thunder_flutter: ^0.1.0
```

```bash
flutter pub get
```

---

## Quick Start

### 1. Wrap your app with `ThunderProvider`

```dart
import 'package:thunder_flutter/thunder_flutter.dart';

void main() {
  runApp(
    ThunderProvider(
      config: ThunderConfig(
        baseUrl: 'https://your-thunder-instance.example.com',
        clientId: 'your-client-id',
        applicationId: 'your-app-id',
      ),
      child: const MyApp(),
    ),
  );
}
```

### 2. Access authentication state anywhere in the tree

```dart
class HomeScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final thunder = ThunderProvider.of(context);

    if (thunder.isLoading) return const CircularProgressIndicator();
    if (!thunder.isSignedIn) return const SignInScreen();

    final user = thunder.user!;
    return Column(
      children: [
        Text('Welcome, ${user.displayName ?? user.email ?? user.sub}'),
        ElevatedButton(
          onPressed: () async {
            await thunder.client.signOut();
            await thunder.refresh();
          },
          child: const Text('Sign Out'),
        ),
      ],
    );
  }
}
```

### 3. App-native sign-in

```dart
// Initiate the flow
final initResponse = await thunder.client.signIn(
  payload: EmbeddedSignInPayload(actionId: 'init'),
  request: EmbeddedFlowRequestConfig(applicationId: 'your-app-id'),
);

// Submit credentials
final result = await thunder.client.signIn(
  payload: EmbeddedSignInPayload(
    flowId: initResponse.flowId,
    actionId: 'basic_auth',
    inputs: {'username': 'user@example.com', 'password': 'secret'},
  ),
  request: EmbeddedFlowRequestConfig(applicationId: 'your-app-id'),
);
```

---

## Configuration Reference

| Field | Type | Required | Description |
|-------|------|----------|-------------|
| `baseUrl` | `String` | Yes | Thunder server base URL. Must be HTTPS. |
| `clientId` | `String?` | For redirect mode | OAuth2 client ID. |
| `scopes` | `List<String>` | No | Defaults to `['openid']`. |
| `afterSignInUrl` | `String?` | For redirect mode | Redirect URI registered in Thunder. |
| `applicationId` | `String?` | No | Thunder application UUID. |

---

## Architecture

```
Flutter (Dart)                    Native
┌─────────────────────┐          ┌──────────────────────┐
│ ThunderClient       │          │ Thunder iOS SDK       │
│ ThunderProvider     │ ──────── │ (Swift, Keychain)     │
│ Widgets             │ channel  ├──────────────────────┤
└─────────────────────┘          │ Thunder Android SDK  │
                                 │ (Kotlin, Keystore)   │
                                 └──────────────────────┘
```

No OAuth2/OIDC logic runs in Dart. All protocol operations (PKCE generation, token exchange, JWKS validation, token refresh) are handled by the native SDKs.

---

## Native SDK Dependencies

| Platform | SDK | Version |
|----------|-----|---------|
| iOS | `Thunder` (Swift Package) | `~> 0.1.0` |
| Android | `io.thunder:android` (Maven) | `0.1.0` |

---

## Security

Inherited from the native SDKs:
- **iOS:** Tokens stored in iOS Keychain
- **Android:** Tokens stored in EncryptedSharedPreferences (Android Keystore)
- PKCE (S256) mandatory in redirect mode
- ID token validation (JWKS signature, iss, aud, exp, nonce)
- Auto token refresh 60s before expiry
- HTTP baseUrl rejected at initialization

---

## Testing

```bash
flutter test
```

---

## API Reference

See [docs/content/sdks/flutter/](../../../docs/content/sdks/flutter/).

Full specification: [tools/sdks/specification/README.md](../../specification/README.md)
