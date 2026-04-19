package io.thunder.compose.components.presentation.organization

import androidx.compose.foundation.layout.*
import androidx.compose.foundation.text.BasicText
import androidx.compose.foundation.text.BasicTextField
import androidx.compose.runtime.*
import androidx.compose.ui.Modifier
import androidx.compose.ui.unit.dp
import io.thunder.android.Organization
import io.thunder.compose.LocalThunder
import io.thunder.compose.components.actions.BaseThunderSignUpButton
import kotlinx.coroutines.launch

/** Form to create a new organization (spec §8.4 Presentation). */
@Composable
fun ThunderCreateOrganization(
    modifier: Modifier = Modifier,
    onCreated: ((Organization) -> Unit)? = null,
    onError: ((String) -> Unit)? = null,
) {
    val state = LocalThunder.current
    val i18n = state.i18n
    BaseThunderCreateOrganization(modifier = modifier, onCreated = onCreated, onError = onError) { name, handle, isLoading, error, create ->
        Column(modifier = Modifier.padding(16.dp), verticalArrangement = Arrangement.spacedBy(12.dp)) {
            BasicText(i18n.resolve("createOrganization.title"))
            error?.let { BasicText(it) }
            BasicTextField(
                value = name.value,
                onValueChange = { name.value = it },
                modifier = Modifier.fillMaxWidth().defaultMinSize(minHeight = 44.dp),
            )
            BasicTextField(
                value = handle.value,
                onValueChange = { handle.value = it },
                modifier = Modifier.fillMaxWidth().defaultMinSize(minHeight = 44.dp),
            )
            BaseThunderSignUpButton(label = i18n.resolve("createOrganization.submit"), modifier = Modifier.fillMaxWidth()) {
                if (!isLoading) create()
            }
        }
    }
}

/** Unstyled base variant (spec §8.3). */
@Composable
fun BaseThunderCreateOrganization(
    modifier: Modifier = Modifier,
    onCreated: ((Organization) -> Unit)? = null,
    onError: ((String) -> Unit)? = null,
    content: @Composable (name: MutableState<String>, handle: MutableState<String>, isLoading: Boolean, error: String?, create: () -> Unit) -> Unit,
) {
    val state = LocalThunder.current
    val scope = rememberCoroutineScope()
    val name = remember { mutableStateOf("") }
    val handle = remember { mutableStateOf("") }
    var isLoading by remember { mutableStateOf(false) }
    var error by remember { mutableStateOf<String?>(null) }

    val create = {
        if (name.value.isNotBlank()) {
            scope.launch {
                isLoading = true; error = null
                try {
                    val org = state.client.createOrganization(
                        name = name.value,
                        handle = handle.value.takeIf { it.isNotBlank() },
                    )
                    isLoading = false
                    onCreated?.invoke(org)
                } catch (e: Exception) {
                    error = e.message
                    isLoading = false
                    onError?.invoke(e.message ?: "Failed to create organization")
                }
            }
        }
    }

    Box(modifier = modifier) { content(name, handle, isLoading, error, create) }
}
