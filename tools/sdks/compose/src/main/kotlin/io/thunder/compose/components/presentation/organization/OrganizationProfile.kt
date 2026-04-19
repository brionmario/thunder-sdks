package io.thunder.compose.components.presentation.organization

import androidx.compose.foundation.layout.Column
import androidx.compose.foundation.text.BasicText
import androidx.compose.runtime.*
import androidx.compose.ui.Modifier
import io.thunder.android.Organization
import io.thunder.compose.LocalThunder

/** Displays the current organization's details (spec §8.4 Presentation). */
@Composable
fun ThunderOrganizationProfile(modifier: Modifier = Modifier) {
    BaseThunderOrganizationProfile(modifier = modifier) { org, _, error ->
        when {
            error != null -> BasicText(error)
            org != null -> Column {
                BasicText(org.name)
                org.handle?.let { BasicText(it) }
            }
            else -> {}
        }
    }
}

/** Unstyled base variant (spec §8.3). */
@Composable
fun BaseThunderOrganizationProfile(
    modifier: Modifier = Modifier,
    content: @Composable (Organization?, Boolean, String?) -> Unit,
) {
    val state = LocalThunder.current
    var org by remember { mutableStateOf<Organization?>(null) }
    var isLoading by remember { mutableStateOf(false) }
    var error by remember { mutableStateOf<String?>(null) }

    LaunchedEffect(Unit) {
        isLoading = true
        try { org = state.client.getCurrentOrganization() }
        catch (e: Exception) { error = e.message }
        isLoading = false
    }

    Box(modifier = modifier) { content(org, isLoading, error) }
}
