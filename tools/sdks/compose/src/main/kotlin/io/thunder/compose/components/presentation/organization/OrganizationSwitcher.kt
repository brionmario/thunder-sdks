package io.thunder.compose.components.presentation.organization

import androidx.compose.foundation.clickable
import androidx.compose.foundation.layout.*
import androidx.compose.foundation.text.BasicText
import androidx.compose.runtime.*
import androidx.compose.ui.Modifier
import androidx.compose.ui.semantics.*
import androidx.compose.ui.unit.dp
import io.thunder.android.Organization
import io.thunder.compose.LocalThunder
import kotlinx.coroutines.launch

/** Picker to switch the active organization (spec §8.4 Presentation). */
@Composable
fun ThunderOrganizationSwitcher(modifier: Modifier = Modifier) {
    val state = LocalThunder.current
    val i18n = state.i18n
    BaseThunderOrganizationSwitcher(modifier = modifier) { orgs, current, isSwitching, error, switchOrg ->
        Column {
            if (orgs.isEmpty()) BasicText(i18n.resolve("organizationSwitcher.empty"))
            orgs.forEach { org ->
                BasicText(
                    org.name,
                    modifier = Modifier
                        .defaultMinSize(minHeight = 44.dp)
                        .clickable(enabled = !isSwitching) { switchOrg(org) }
                        .semantics {
                            contentDescription = org.name
                            selected = org.id == current?.id
                        },
                )
            }
            error?.let { BasicText(it) }
        }
    }
}

/** Unstyled base variant (spec §8.3). */
@Composable
fun BaseThunderOrganizationSwitcher(
    modifier: Modifier = Modifier,
    content: @Composable (List<Organization>, Organization?, Boolean, String?, (Organization) -> Unit) -> Unit,
) {
    val state = LocalThunder.current
    val scope = rememberCoroutineScope()
    var orgs by remember { mutableStateOf<List<Organization>>(emptyList()) }
    var current by remember { mutableStateOf<Organization?>(null) }
    var isSwitching by remember { mutableStateOf(false) }
    var error by remember { mutableStateOf<String?>(null) }

    LaunchedEffect(Unit) {
        isSwitching = true
        orgs = runCatching { state.client.getMyOrganizations() }.getOrDefault(emptyList())
        current = runCatching { state.client.getCurrentOrganization() }.getOrNull()
        isSwitching = false
    }

    val switchOrg = { org: Organization ->
        scope.launch {
            isSwitching = true; error = null
            try {
                state.client.switchOrganization(org)
                current = org
                state.refresh()
            } catch (e: Exception) { error = e.message }
            isSwitching = false
        }
    }

    Box(modifier = modifier) { content(orgs, current, isSwitching, error) { switchOrg(it) } }
}
