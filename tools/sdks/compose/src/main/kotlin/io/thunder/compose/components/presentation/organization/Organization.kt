package io.thunder.compose.components.presentation.organization

import androidx.compose.foundation.text.BasicText
import androidx.compose.runtime.*
import androidx.compose.ui.Modifier
import androidx.compose.ui.semantics.contentDescription
import androidx.compose.ui.semantics.semantics
import io.thunder.android.Organization
import io.thunder.compose.LocalThunder

/** Read-only display of the current organization (spec §8.4 Presentation). */
@Composable
fun ThunderOrganization(modifier: Modifier = Modifier) {
    val state = LocalThunder.current
    val i18n = state.i18n
    BaseThunderOrganization(modifier = modifier) { org ->
        val label = org?.name ?: i18n.resolve("organization.unnamed")
        BasicText(label, modifier = Modifier.semantics { contentDescription = label })
    }
}

/** Unstyled base variant (spec §8.3). */
@Composable
fun BaseThunderOrganization(
    modifier: Modifier = Modifier,
    content: @Composable (Organization?) -> Unit,
) {
    val state = LocalThunder.current
    var org by remember { mutableStateOf<Organization?>(null) }

    LaunchedEffect(Unit) {
        org = runCatching { state.client.getCurrentOrganization() }.getOrNull()
    }

    content(org)
}
