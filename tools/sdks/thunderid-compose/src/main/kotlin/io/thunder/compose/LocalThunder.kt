package io.thunder.compose

import androidx.compose.runtime.compositionLocalOf

/** CompositionLocal for ThunderState — consume via [LocalThunder.current]. */
val LocalThunder = compositionLocalOf<ThunderState> {
    error("No ThunderProvider found in the composition. Wrap your root composable with ThunderProvider { }.")
}
