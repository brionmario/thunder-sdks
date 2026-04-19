package io.thunder.compose.components.presentation.organization

import androidx.compose.foundation.clickable
import androidx.compose.foundation.layout.*
import androidx.compose.foundation.text.BasicText
import androidx.compose.runtime.*
import androidx.compose.ui.Modifier
import androidx.compose.ui.semantics.contentDescription
import androidx.compose.ui.semantics.semantics
import androidx.compose.ui.unit.dp
import io.thunder.android.Organization
import io.thunder.compose.LocalThunder

/** Lists organizations the signed-in user belongs to (spec §8.4 Presentation). */
@Composable
fun ThunderOrganizationList(
    modifier: Modifier = Modifier,
    onOrganizationTap: ((Organization) -> Unit)? = null,
) {
    val state = LocalThunder.current
    val i18n = state.i18n
    BaseThunderOrganizationList(modifier = modifier) { orgs, isLoading, error ->
        when {
            isLoading -> {}
            orgs.isEmpty() -> BasicText(i18n.resolve("organizationList.empty"))
            else -> Column {
                orgs.forEach { org ->
                    BasicText(
                        org.name,
                        modifier = Modifier
                            .defaultMinSize(minHeight = 44.dp)
                            .clickable { onOrganizationTap?.invoke(org) }
                            .semantics { contentDescription = org.name },
                    )
                }
            }
        }
    }
}

/** Unstyled base variant (spec §8.3). */
@Composable
fun BaseThunderOrganizationList(
    modifier: Modifier = Modifier,
    content: @Composable (List<Organization>, Boolean, String?) -> Unit,
) {
    val state = LocalThunder.current
    var orgs by remember { mutableStateOf<List<Organization>>(emptyList()) }
    var isLoading by remember { mutableStateOf(false) }
    var error by remember { mutableStateOf<String?>(null) }

    LaunchedEffect(Unit) {
        isLoading = true
        try { orgs = state.client.getMyOrganizations() }
        catch (e: Exception) { error = e.message }
        isLoading = false
    }

    Box(modifier = modifier) { content(orgs, isLoading, error) }
}
