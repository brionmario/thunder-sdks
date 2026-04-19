package io.thunder.compose.components.guards

import androidx.compose.runtime.Composable
import io.thunder.compose.LocalThunder

/** Renders [indicator] while the SDK is initializing or mid-operation (spec §8.4 Guards). */
@Composable
fun ThunderLoading(
    indicator: @Composable () -> Unit = {},
) {
    val state = LocalThunder.current
    if (state.isLoading) indicator()
}
