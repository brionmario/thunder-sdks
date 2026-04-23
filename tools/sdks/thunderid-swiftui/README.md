# ThunderSwiftUI SDK

Core Lib SDK for iOS and macOS — drop-in SwiftUI components for Thunder identity management.

**Layer:** Core Lib  
**Package:** `ThunderSwiftUI` (Swift Package Manager)  
**Depends on:** Thunder iOS Platform SDK (`tools/sdks/thunderid-ios/`)

## Installation

Add to your `Package.swift`:

```swift
.package(url: "https://github.com/your-org/thunder-swiftui", from: "0.1.0"),
```

Or via Xcode → File → Add Package Dependencies.

## Quick start

```swift
import ThunderSwiftUI

@main struct MyApp: App {
    var body: some Scene {
        WindowGroup {
            ContentView()
                .thunderProvider(config: ThunderConfig(
                    baseUrl: "https://auth.example.com",
                    clientId: "your-client-id"
                ))
        }
    }
}

struct ContentView: View {
    var body: some View {
        SignedIn {
            UserDropdown()
        } fallback: {
            SignInButton()
        }
    }
}
```

## Components

### Actions
| Component | Description |
|-----------|-------------|
| `SignInButton` / `BaseSignInButton` | Starts redirect sign-in |
| `SignOutButton` / `BaseSignOutButton` | Signs out and refreshes state |
| `SignUpButton` / `BaseSignUpButton` | Starts sign-up flow |

### Flow

| Component                   | Description                          |
|-----------------------------|--------------------------------------|
| `Callback` / `BaseCallback` | Handles OAuth2 redirect callback URL |

### Guards
| Component | Description |
|-----------|-------------|
| `SignedIn` | Renders children only when authenticated |
| `SignedOut` | Renders children only when unauthenticated |
| `Loading` | Renders indicator while loading |

### Presentation
| Component | Description |
|-----------|-------------|
| `SignIn` / `BaseSignIn` | App-native sign-in form (Flow Execution API) |
| `SignUp` / `BaseSignUp` | App-native sign-up form |
| `UserObject` / `BaseUserObject` | Current user display |
| `UserDropdown` / `BaseUserDropdown` | Avatar chip with profile/sign-out menu |
| `UserProfile` / `BaseUserProfile` | Editable user profile form |
| `LanguageSwitcher` / `BaseLanguageSwitcher` | Switch UI locale |

## Customization

Every component has a `Base*` unstyled variant. Pass a `@ViewBuilder` closure to render your own UI while the Base component manages state:

```swift
BaseSignIn(applicationId: "my-app") { signInState in
    // Build your completely custom sign-in UI here
    ForEach(signInState.inputs, id: \.name) { input in
        MyCustomTextField(label: input.name, binding: signInState.binding(for: input.name))
    }
}
```

## Accessibility

All components meet WCAG 2.1 AA: minimum 44×44 pt tap targets, `.accessibilityLabel()`, `.accessibilityHint()` on interactive elements.

## i18n

```swift
let i18n = ThunderI18n(
    bundles: ["fr-FR": ["signIn.button": "Se connecter"]],
    language: "fr-FR"
)

ContentView()
    .thunderProvider(config: config, i18n: i18n)
```
