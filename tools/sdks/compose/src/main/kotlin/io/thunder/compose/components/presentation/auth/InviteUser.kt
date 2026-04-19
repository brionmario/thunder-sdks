package io.thunder.compose.components.presentation.auth

import androidx.compose.foundation.layout.*
import androidx.compose.foundation.text.BasicText
import androidx.compose.foundation.text.BasicTextField
import androidx.compose.runtime.*
import androidx.compose.ui.Modifier
import androidx.compose.ui.unit.dp
import io.thunder.compose.LocalThunder
import io.thunder.compose.components.actions.BaseThunderSignUpButton
import kotlinx.coroutines.launch

/** Form to invite a user by email (spec §8.4 Presentation). */
@Composable
fun ThunderInviteUser(
    modifier: Modifier = Modifier,
    onSent: (() -> Unit)? = null,
    onError: ((String) -> Unit)? = null,
) {
    val thunderState = LocalThunder.current
    val i18n = thunderState.i18n
    BaseThunderInviteUser(modifier = modifier, onSent = onSent, onError = onError) { email, isLoading, error, send ->
        Column(modifier = Modifier.padding(16.dp), verticalArrangement = Arrangement.spacedBy(12.dp)) {
            BasicText(i18n.resolve("inviteUser.title"))
            error?.let { BasicText(it) }
            BasicTextField(
                value = email.value,
                onValueChange = { email.value = it },
                modifier = Modifier.fillMaxWidth().defaultMinSize(minHeight = 44.dp),
            )
            BaseThunderSignUpButton(
                label = if (isLoading) i18n.resolve("inviteUser.loading") else i18n.resolve("inviteUser.submit"),
                modifier = Modifier.fillMaxWidth(),
            ) { if (!isLoading) send() }
        }
    }
}

/** Unstyled base variant (spec §8.3). */
@Composable
fun BaseThunderInviteUser(
    modifier: Modifier = Modifier,
    onSent: (() -> Unit)? = null,
    onError: ((String) -> Unit)? = null,
    content: @Composable (email: MutableState<String>, isLoading: Boolean, error: String?, send: () -> Unit) -> Unit,
) {
    val thunderState = LocalThunder.current
    val scope = rememberCoroutineScope()
    val email = remember { mutableStateOf("") }
    var isLoading by remember { mutableStateOf(false) }
    var error by remember { mutableStateOf<String?>(null) }

    val send = {
        if (email.value.isNotBlank()) {
            scope.launch {
                isLoading = true; error = null
                try {
                    thunderState.client.inviteUser(email = email.value)
                    isLoading = false
                    onSent?.invoke()
                } catch (e: Exception) {
                    error = e.message
                    isLoading = false
                    onError?.invoke(e.message ?: "Failed to send invite")
                }
            }
        }
    }

    Box(modifier = modifier) { content(email, isLoading, error, send) }
}
