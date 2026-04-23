# Thunder Compose SDK

Core Lib SDK for Android — drop-in Jetpack Compose components for Thunder identity management.

**Layer:** Core Lib  
**Package:** `io.thunder.compose` (Gradle library, Kotlin)  
**Depends on:** Thunder Android Platform SDK (`tools/sdks/thunderid-android/`)

## Installation

In your app's `build.gradle.kts`:

```kotlin
dependencies {
    implementation("io.thunder:compose:0.1.0")
}
```

## Quick start

```kotlin
import io.thunder.compose.ThunderProvider
import io.thunder.compose.components.guards.ThunderSignedIn
import io.thunder.compose.components.guards.ThunderSignedOut
import io.thunder.compose.components.actions.ThunderSignInButton
import io.thunder.compose.components.presentation.user.ThunderUserDropdown

@Composable
fun App() {
    ThunderProvider(config = ThunderConfig(baseUrl = "https://auth.example.com", clientId = "your-client-id")) {
        ThunderSignedIn {
            ThunderUserDropdown()
        }
        ThunderSignedOut {
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
| `ThunderSignedIn` | Renders content only when authenticated |
| `ThunderSignedOut` | Renders content only when unauthenticated |
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

Every component has a `Base*` unstyled variant:

```kotlin
BaseThunderSignIn(applicationId = "my-app") { signInState ->
    // Build your completely custom sign-in UI
    signInState.inputs.forEach { input ->
        MyTextField(label = input.name, value = signInState.fieldValue(input.name)) {
            signInState.setField(input.name, it)
        }
    }
    signInState.actions.forEach { action ->
        MyButton(action.label ?: "Continue") { signInState.submit(action.id) }
    }
}
```

## Accessibility

All components meet WCAG 2.1 AA: minimum 44dp tap targets, `contentDescription` semantics on all interactive elements.

## i18n

```kotlin
val i18n = ThunderI18n(
    bundles = mapOf("fr-FR" to mapOf("signIn.button" to "Se connecter")),
    language = "fr-FR",
    context = context,
)

ThunderProvider(config = config, i18n = i18n) { ... }
```
