package io.thunder.sample.b2c

import android.os.Bundle
import androidx.activity.ComponentActivity
import androidx.activity.compose.setContent
import io.thunder.android.ThunderConfig
import io.thunder.compose.ThunderProvider

class MainActivity : ComponentActivity() {
    override fun onCreate(savedInstanceState: Bundle?) {
        super.onCreate(savedInstanceState)

        val config = ThunderConfig(
            baseUrl = BuildConfig.THUNDER_BASE_URL,
            clientId = BuildConfig.THUNDER_CLIENT_ID.takeIf { it.isNotBlank() },
        )

        setContent {
            ThunderProvider(config = config) {
                B2CApp(applicationId = BuildConfig.THUNDER_APPLICATION_ID)
            }
        }
    }
}
