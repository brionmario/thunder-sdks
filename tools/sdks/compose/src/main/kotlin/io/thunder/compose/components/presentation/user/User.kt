package io.thunder.compose.components.presentation.user

import androidx.compose.foundation.text.BasicText
import androidx.compose.runtime.Composable
import androidx.compose.ui.Modifier
import androidx.compose.ui.semantics.contentDescription
import androidx.compose.ui.semantics.semantics
import io.thunder.android.User
import io.thunder.compose.LocalThunder

/** Read-only display of the current user (spec §8.4 Presentation). */
@Composable
fun ThunderUser(modifier: Modifier = Modifier) {
    val state = LocalThunder.current
    val i18n = state.i18n
    BaseThunderUser(modifier = modifier) { user ->
        val label = user?.displayName ?: user?.username ?: i18n.resolve("user.anonymous")
        BasicText(label, modifier = Modifier.semantics { contentDescription = label })
    }
}

/** Unstyled base variant (spec §8.3). */
@Composable
fun BaseThunderUser(
    modifier: Modifier = Modifier,
    content: @Composable (User?) -> Unit,
) {
    val state = LocalThunder.current
    content(state.user)
}
