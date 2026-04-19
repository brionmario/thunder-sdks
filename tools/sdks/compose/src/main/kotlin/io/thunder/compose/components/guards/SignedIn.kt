package io.thunder.compose.components.guards

import androidx.compose.runtime.Composable
import io.thunder.compose.LocalThunder

/** Renders [content] only when the user is authenticated (spec §8.4 Guards). */
@Composable
fun ThunderSignedIn(
    fallback: @Composable () -> Unit = {},
    content: @Composable () -> Unit,
) {
    val state = LocalThunder.current
    if (state.isSignedIn) content() else fallback()
}
