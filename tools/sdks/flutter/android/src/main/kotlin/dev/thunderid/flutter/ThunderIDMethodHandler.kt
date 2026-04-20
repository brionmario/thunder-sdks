package dev.thunderid.flutter

import android.content.Context
import io.flutter.plugin.common.MethodChannel.Result
import dev.thunderid.android.*
import dev.thunderid.android.auth.PKCEManager

/**
 * Routes Flutter method channel calls to the native Android ThunderClient (spec §7.1).
 * All OAuth2/OIDC and token management logic lives in the Thunder Android SDK.
 */
class ThunderIDMethodHandler(private val context: Context) {
    private val client = ThunderClient()

    suspend fun handle(method: String, args: Map<String, Any?>, result: Result) {
        try {
            when (method) {
                "initialize" -> {
                    val config = buildConfig(args)
                    val storage = EncryptedStorageAdapter(context)
                    result.success(client.initialize(config, storage))
                }
                "reInitialize" -> {
                    result.success(client.reInitialize(
                        baseUrl = args["baseUrl"] as? String,
                        clientId = args["clientId"] as? String
                    ))
                }
                "signIn" -> {
                    @Suppress("UNCHECKED_CAST")
                    val payloadMap = args["payload"] as? Map<String, Any?> ?: emptyMap()
                    @Suppress("UNCHECKED_CAST")
                    val requestMap = args["request"] as? Map<String, Any?> ?: emptyMap()
                    val response = client.signIn(buildPayload(payloadMap), buildFlowRequest(requestMap))
                    result.success(encodeFlowResponse(response))
                }
                "buildSignInUrl" -> {
                    result.success(client.buildSignInUrl())
                }
                "handleRedirectCallback" -> {
                    val url = args["url"] as? String ?: ""
                    val user = client.handleRedirectCallback(url)
                    result.success(encodeUser(user))
                }
                "signOut" -> {
                    result.success(client.signOut())
                }
                "isSignedIn" -> {
                    result.success(client.isSignedIn())
                }
                "signUp" -> {
                    @Suppress("UNCHECKED_CAST")
                    val payloadMap = args["payload"] as? Map<String, Any?>
                    @Suppress("UNCHECKED_CAST")
                    val requestMap = args["request"] as? Map<String, Any?>
                    val response = client.signUp(
                        payload = payloadMap?.let { buildPayload(it) },
                        request = requestMap?.let { buildFlowRequest(it) }
                    )
                    result.success(encodeFlowResponse(response))
                }
                "getAccessToken" -> {
                    result.success(client.getAccessToken())
                }
                "exchangeToken" -> {
                    @Suppress("UNCHECKED_CAST")
                    val configMap = args["config"] as? Map<String, Any?> ?: emptyMap()
                    result.success(encodeTokenResponse(client.exchangeToken(buildTokenExchangeConfig(configMap))))
                }
                "decodeJwtToken" -> {
                    val token = args["token"] as? String ?: ""
                    result.success(client.decodeJwtToken(token))
                }
                "clearSession" -> {
                    client.clearSession()
                    result.success(null)
                }
                "getUser" -> {
                    result.success(encodeUser(client.getUser()))
                }
                "getUserProfile" -> {
                    val profile = client.getUserProfile()
                    result.success(mapOf("id" to profile.id, "claims" to emptyMap<String, Any>()))
                }
                "updateUserProfile" -> {
                    @Suppress("UNCHECKED_CAST")
                    val payload = args["payload"] as? Map<String, Any> ?: emptyMap()
                    val user = client.updateUserProfile(payload, args["userId"] as? String)
                    result.success(encodeUser(user))
                }
                "getAllOrganizations" -> {
                    val response = client.getAllOrganizations()
                    result.success(mapOf(
                        "organizations" to response.organizations.map { encodeOrganization(it) },
                        "totalCount" to response.totalCount
                    ))
                }
                "getMyOrganizations" -> {
                    result.success(client.getMyOrganizations().map { encodeOrganization(it) })
                }
                "getCurrentOrganization" -> {
                    result.success(client.getCurrentOrganization()?.let { encodeOrganization(it) })
                }
                "switchOrganization" -> {
                    @Suppress("UNCHECKED_CAST")
                    val orgMap = args["organization"] as? Map<String, Any?> ?: emptyMap()
                    val org = Organization(id = orgMap["id"] as? String ?: "", name = orgMap["name"] as? String ?: "")
                    result.success(encodeTokenResponse(client.switchOrganization(org)))
                }
                "getFlowMeta" -> {
                    val appId = args["applicationId"] as? String ?: ""
                    val language = args["language"] as? String ?: "en-US"
                    result.success(client.getFlowMeta(appId, language))
                }
                else -> result.notImplemented()
            }
        } catch (e: IAMException) {
            result.error(e.code.value, e.message, null)
        } catch (e: Exception) {
            result.error("UNKNOWN_ERROR", e.message, null)
        }
    }

    private fun buildConfig(args: Map<String, Any?>): ThunderConfig {
        val baseUrl = args["baseUrl"] as? String
            ?: throw IAMException(IAMErrorCode.INVALID_CONFIGURATION, "baseUrl is required")
        @Suppress("UNCHECKED_CAST")
        val validationMap = args["tokenValidation"] as? Map<String, Any?>
        val validation = TokenValidationConfig(
            validate = validationMap?.get("validate") as? Boolean ?: true,
            validateIssuer = validationMap?.get("validateIssuer") as? Boolean ?: true,
            clockTolerance = validationMap?.get("clockTolerance") as? Int ?: 0
        )
        @Suppress("UNCHECKED_CAST")
        return ThunderConfig(
            baseUrl = baseUrl,
            clientId = args["clientId"] as? String,
            scopes = (args["scopes"] as? List<String>) ?: listOf("openid"),
            afterSignInUrl = args["afterSignInUrl"] as? String,
            afterSignOutUrl = args["afterSignOutUrl"] as? String,
            applicationId = args["applicationId"] as? String,
            tokenValidation = validation
        )
    }

    @Suppress("UNCHECKED_CAST")
    private fun buildPayload(map: Map<String, Any?>): EmbeddedSignInPayload = EmbeddedSignInPayload(
        flowId = map["flowId"] as? String,
        actionId = map["actionId"] as? String ?: "",
        inputs = (map["inputs"] as? Map<String, String>) ?: emptyMap()
    )

    private fun buildFlowRequest(map: Map<String, Any?>): EmbeddedFlowRequestConfig {
        val flowTypeStr = map["flowType"] as? String ?: "AUTHENTICATION"
        val flowType = FlowType.values().firstOrNull { it.value == flowTypeStr } ?: FlowType.AUTHENTICATION
        return EmbeddedFlowRequestConfig(
            applicationId = map["applicationId"] as? String ?: "",
            flowType = flowType
        )
    }

    private fun buildTokenExchangeConfig(map: Map<String, Any?>): TokenExchangeRequestConfig = TokenExchangeRequestConfig(
        subjectToken = map["subjectToken"] as? String ?: "",
        subjectTokenType = map["subjectTokenType"] as? String ?: "",
        requestedTokenType = map["requestedTokenType"] as? String,
        audience = map["audience"] as? String
    )

    private fun encodeUser(user: User) = mapOf(
        "sub" to user.sub, "email" to user.email,
        "displayName" to user.displayName, "username" to user.username,
        "profilePicture" to user.profilePicture, "isNewUser" to user.isNewUser
    )

    private fun encodeFlowResponse(r: EmbeddedFlowResponse) = mapOf(
        "flowId" to r.flowId, "flowStatus" to r.flowStatus.name,
        "stepId" to r.stepId, "type" to r.type,
        "data" to r.data?.let { encodeFlowStepData(it) },
        "assertion" to r.assertion, "failureReason" to r.failureReason
    )

    private fun encodeFlowStepData(data: FlowStepData) = mapOf(
        "actions" to data.actions?.map { action ->
            mapOf(
                "id" to action.id.ifEmpty { action.ref ?: action.nextNode ?: "submit" },
                "ref" to action.ref,
                "nextNode" to action.nextNode,
                "type" to action.type,
                "label" to action.label
            )
        },
        "inputs" to data.inputs?.map { input ->
            mapOf(
                "name" to input.name,
                "type" to input.type,
                "required" to input.required
            )
        },
        "meta" to data.meta
    )

    private fun encodeOrganization(o: Organization) = mapOf("id" to o.id, "name" to o.name, "handle" to o.handle)

    private fun encodeTokenResponse(r: TokenResponse) = mapOf(
        "accessToken" to r.accessToken, "tokenType" to r.tokenType,
        "expiresIn" to r.expiresIn, "refreshToken" to r.refreshToken,
        "idToken" to r.idToken, "scope" to r.scope
    )
}
