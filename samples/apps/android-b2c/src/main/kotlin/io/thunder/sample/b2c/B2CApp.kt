package io.thunder.sample.b2c

import androidx.compose.foundation.layout.*
import androidx.compose.runtime.*
import androidx.compose.ui.Modifier
import androidx.compose.ui.unit.dp
import io.thunder.compose.components.guards.ThunderLoading
import io.thunder.compose.components.guards.ThunderSignedIn
import io.thunder.compose.components.guards.ThunderSignedOut
import io.thunder.compose.components.presentation.auth.ThunderSignIn
import io.thunder.compose.components.presentation.organization.ThunderOrganizationSwitcher
import io.thunder.compose.components.presentation.user.ThunderUserDropdown
import io.thunder.compose.components.presentation.user.ThunderUserProfile
import io.thunder.compose.components.actions.ThunderSignOutButton

/** Root composable. Routes between sign-in and home based on auth state. */
@Composable
fun B2CApp(applicationId: String) {
    var showProfile by remember { mutableStateOf(false) }

    ThunderLoading { /* show a spinner; use CircularProgressIndicator in a real app */ }

    ThunderSignedOut {
        SignInScreen(applicationId = applicationId)
    }

    ThunderSignedIn {
        if (showProfile) {
            ProfileScreen(onBack = { showProfile = false })
        } else {
            HomeScreen(onProfileTap = { showProfile = true })
        }
    }
}

@Composable
private fun SignInScreen(applicationId: String) {
    Box(modifier = Modifier.fillMaxSize().padding(16.dp)) {
        ThunderSignIn(applicationId = applicationId)
    }
}

@Composable
private fun HomeScreen(onProfileTap: () -> Unit) {
    Column(modifier = Modifier.fillMaxSize().padding(16.dp)) {
        Row(modifier = Modifier.fillMaxWidth(), horizontalArrangement = Arrangement.End) {
            ThunderUserDropdown(onProfileTap = onProfileTap)
        }
        Spacer(modifier = Modifier.height(24.dp))
        ThunderOrganizationSwitcher()
        Spacer(modifier = Modifier.weight(1f))
        ThunderSignOutButton(modifier = Modifier.fillMaxWidth())
    }
}

@Composable
private fun ProfileScreen(onBack: () -> Unit) {
    Column(modifier = Modifier.fillMaxSize().padding(16.dp)) {
        ThunderUserProfile(onSaved = onBack)
    }
}
