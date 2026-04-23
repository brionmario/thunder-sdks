package io.thunder.compose

import androidx.compose.runtime.*
import io.thunder.android.ThunderClient
import io.thunder.android.ThunderConfig
import io.thunder.compose.i18n.ThunderI18n
import kotlinx.coroutines.launch

/**
 * Provides Thunder auth state to all descendant composables via [LocalThunder] (spec §7.2).
 *
 * ```kotlin
 * ThunderProvider(config = ThunderConfig(baseUrl = "...", clientId = "...")) {
 *     MyApp()
 * }
 * ```
 */
@Composable
fun ThunderProvider(
    config: ThunderConfig,
    client: ThunderClient = remember { ThunderClient() },
    i18n: ThunderI18n = remember { ThunderI18n() },
    content: @Composable () -> Unit,
) {
    val state = remember(client, i18n) { ThunderState(client, i18n) }
    val scope = rememberCoroutineScope()

    LaunchedEffect(config) {
        state.initialize(config)
    }

    CompositionLocalProvider(LocalThunder provides state) {
        content()
    }
}
