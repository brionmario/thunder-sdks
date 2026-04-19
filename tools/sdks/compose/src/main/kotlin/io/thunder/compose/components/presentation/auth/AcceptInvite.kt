package io.thunder.compose.components.presentation.auth

import androidx.compose.foundation.layout.*
import androidx.compose.foundation.text.BasicText
import androidx.compose.foundation.text.BasicTextField
import androidx.compose.runtime.*
import androidx.compose.ui.Modifier
import androidx.compose.ui.unit.dp
import io.thunder.android.*
import io.thunder.compose.LocalThunder
import io.thunder.compose.ThunderState
import io.thunder.compose.components.actions.BaseThunderSignUpButton
import kotlinx.coroutines.launch

/** Drives the invited-user-registration flow for a given invitation code (spec §8.4 Presentation). */
@Composable
fun ThunderAcceptInvite(
    invitationCode: String,
    modifier: Modifier = Modifier,
    onComplete: (() -> Unit)? = null,
    onError: ((String) -> Unit)? = null,
) {
    val thunderState = LocalThunder.current
    val i18n = thunderState.i18n
    BaseThunderAcceptInvite(invitationCode = invitationCode, modifier = modifier, onComplete = onComplete, onError = onError) { state ->
        Column(modifier = Modifier.padding(16.dp), verticalArrangement = Arrangement.spacedBy(12.dp)) {
            BasicText(i18n.resolve("acceptInvite.title"))
            state.error?.let { BasicText(it) }
            state.inputs.forEach { input ->
                BasicTextField(
                    value = state.fieldValue(input.name),
                    onValueChange = { state.setField(input.name, it) },
                    modifier = Modifier.fillMaxWidth().defaultMinSize(minHeight = 44.dp),
                )
            }
            state.actions.forEach { action ->
                BaseThunderSignUpButton(label = action.label ?: i18n.resolve("acceptInvite.submit")) {
                    state.submit(action.id)
                }
            }
        }
    }
}

/** Unstyled base variant (spec §8.3). Reuses [ThunderSignUpState]. */
@Composable
fun BaseThunderAcceptInvite(
    invitationCode: String,
    modifier: Modifier = Modifier,
    onComplete: (() -> Unit)? = null,
    onError: ((String) -> Unit)? = null,
    content: @Composable (ThunderSignUpState) -> Unit,
) {
    val thunderState = LocalThunder.current
    val scope = rememberCoroutineScope()
    val state = remember { ThunderSignUpState() }

    state.onSubmit = { actionId ->
        scope.launch {
            state.isLoading = true; state.error = null
            try {
                val payload = EmbeddedSignInPayload(flowId = state.flowId, actionId = actionId, inputs = state.fields())
                val response = thunderState.client.signUp(payload = payload)
                handleAcceptResponse(response, state, thunderState, onComplete, onError)
            } catch (e: Exception) {
                state.error = e.message
                onError?.invoke(e.message ?: "Could not accept invite")
            } finally { state.isLoading = false }
        }
    }

    LaunchedEffect(invitationCode) {
        state.isLoading = true
        try {
            val payload = EmbeddedSignInPayload(actionId = "__initiate__", inputs = mapOf("invitationCode" to invitationCode))
            val response = thunderState.client.signUp(payload = payload)
            handleAcceptResponse(response, state, thunderState, onComplete, onError)
        } catch (e: Exception) {
            state.error = e.message
            onError?.invoke(e.message ?: "Could not accept invite")
        } finally { state.isLoading = false }
    }

    Box(modifier = modifier) { content(state) }
}

private suspend fun handleAcceptResponse(
    response: EmbeddedFlowResponse,
    state: ThunderSignUpState,
    thunderState: ThunderState,
    onComplete: (() -> Unit)?,
    onError: ((String) -> Unit)?,
) {
    when (response.flowStatus) {
        FlowStatus.COMPLETE -> { thunderState.refresh(); onComplete?.invoke() }
        FlowStatus.PROMPT_ONLY -> state.update(response)
        FlowStatus.ERROR -> { state.error = response.failureReason; onError?.invoke(response.failureReason ?: "Failed") }
    }
}
