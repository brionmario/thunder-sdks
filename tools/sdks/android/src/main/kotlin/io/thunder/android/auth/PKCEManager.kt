package io.thunder.android.auth

import android.util.Base64
import java.security.MessageDigest
import java.security.SecureRandom

/**
 * Generates and manages PKCE parameters per RFC 7636 (spec §11.2).
 * S256 only. code_verifier held in memory, cleared after exchange.
 */
internal class PKCEManager {
    var codeVerifier: String? = null
        private set

    fun generate(): Pair<String, String> {
        val verifier = generateVerifier()
        val challenge = deriveChallenge(verifier)
        codeVerifier = verifier
        return verifier to challenge
    }

    fun clearVerifier() {
        codeVerifier = null
    }

    private fun generateVerifier(): String {
        val bytes = ByteArray(64)
        SecureRandom().nextBytes(bytes)
        return Base64.encodeToString(bytes, Base64.URL_SAFE or Base64.NO_PADDING or Base64.NO_WRAP)
    }

    private fun deriveChallenge(verifier: String): String {
        val digest = MessageDigest.getInstance("SHA-256").digest(verifier.toByteArray(Charsets.US_ASCII))
        return Base64.encodeToString(digest, Base64.URL_SAFE or Base64.NO_PADDING or Base64.NO_WRAP)
    }
}
