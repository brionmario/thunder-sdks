# ThunderSwiftUI SDK

Core Lib SDK for iOS and macOS — drop-in SwiftUI components for Thunder identity management.

**Layer:** Core Lib  
**Package:** `ThunderSwiftUI` (Swift Package Manager)  
**Depends on:** Thunder iOS Platform SDK (`tools/sdks/ios/`)

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
        ThunderSignedIn {
            ThunderUserDropdown()
        } fallback: {
            ThunderSignInButton()
        }
    }
}
```

## Components

### Actions
| Component | Description |
|-----------|-------------|
| `ThunderSignInButton` / `BaseThunderSignInButton` | Starts redirect sign-in |
| `ThunderSignOutButton` / `BaseThunderSignOutButton` | Signs out and refreshes state |
| `ThunderSignUpButton` / `BaseThunderSignUpButton` | Starts sign-up flow |

### Flow
| Component | Description |
|-----------|-------------|
| `ThunderCallback` / `BaseThunderCallback` | Handles OAuth2 redirect callback URL |

### Guards
| Component | Description |
|-----------|-------------|
| `ThunderSignedIn` | Renders children only when authenticated |
| `ThunderSignedOut` | Renders children only when unauthenticated |
| `ThunderLoading` | Renders indicator while loading |

### Presentation
| Component | Description |
|-----------|-------------|
| `ThunderSignIn` / `BaseThunderSignIn` | App-native sign-in form (Flow Execution API) |
| `ThunderSignUp` / `BaseThunderSignUp` | App-native sign-up form |
| `ThunderAcceptInvite` / `BaseThunderAcceptInvite` | Accept an organization invitation |
| `ThunderInviteUser` / `BaseThunderInviteUser` | Invite a user by email |
| `ThunderUser` / `BaseThunderUser` | Current user display |
| `ThunderUserDropdown` / `BaseThunderUserDropdown` | Avatar chip with profile/sign-out menu |
| `ThunderUserProfile` / `BaseThunderUserProfile` | Editable user profile form |
| `ThunderOrganization` / `BaseThunderOrganization` | Current organization display |
| `ThunderOrganizationList` / `BaseThunderOrganizationList` | List of user's organizations |
| `ThunderOrganizationProfile` / `BaseThunderOrganizationProfile` | Current org details |
| `ThunderOrganizationSwitcher` / `BaseThunderOrganizationSwitcher` | Switch active organization |
| `ThunderCreateOrganization` / `BaseThunderCreateOrganization` | Create a new organization |
| `ThunderLanguageSwitcher` / `BaseThunderLanguageSwitcher` | Switch UI locale |

## Customization

Every component has a `Base*` unstyled variant. Pass a `@ViewBuilder` closure to render your own UI while the Base component manages state:

```swift
BaseThunderSignIn(applicationId: "my-app") { signInState in
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
