package io.thunder.compose

import androidx.compose.runtime.*
import io.thunder.android.ThunderClient
import io.thunder.android.ThunderConfig
import io.thunder.android.User
import io.thunder.compose.i18n.ThunderI18n

/** Reactive auth state for Compose. Held inside [rememberThunderState]. */
@Stable
class ThunderState(
    val client: ThunderClient,
    val i18n: ThunderI18n,
) {
    var user by mutableStateOf<User?>(null)
        internal set
    var isLoading by mutableStateOf(false)
        internal set
    var isInitialized by mutableStateOf(false)
        internal set
    var error by mutableStateOf<String?>(null)
        internal set

    val isSignedIn: Boolean get() = user != null

    internal suspend fun initialize(config: ThunderConfig) {
        isLoading = true
        try {
            client.initialize(config)
            val signedIn = runCatching { client.isSignedIn() }.getOrDefault(false)
            user = if (signedIn) runCatching { client.getUser() }.getOrNull() else null
            isInitialized = true
            error = null
        } catch (e: Exception) {
            error = e.message
        } finally {
            isLoading = false
        }
    }

    suspend fun refresh() {
        if (!isInitialized) return
        isLoading = true
        try {
            val signedIn = client.isSignedIn()
            user = if (signedIn) client.getUser() else null
            error = null
        } catch (e: Exception) {
            error = e.message
        } finally {
            isLoading = false
        }
    }

    fun setLocale(locale: String) {
        i18n.setLocale(locale)
    }
}
