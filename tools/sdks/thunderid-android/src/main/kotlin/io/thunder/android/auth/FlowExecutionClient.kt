package io.thunder.android.auth

import io.thunder.android.EmbeddedFlowResponse
import io.thunder.android.FlowType
import io.thunder.android.http.HttpClient

/**
 * Drives the Thunder Flow Execution API for app-native sign-in, sign-up, and recovery (spec §6.1–6.3).
 */
internal class FlowExecutionClient(private val httpClient: HttpClient) {

    suspend fun initiate(applicationId: String, flowType: FlowType): EmbeddedFlowResponse {
        val body = mapOf(
            "applicationId" to applicationId,
            "flowType" to flowType.value,
            "verbose" to true
        )
        return httpClient.post("/flow/execute", body, requiresAuth = false)
    }

    suspend fun submit(flowId: String, actionId: String, inputs: Map<String, String>): EmbeddedFlowResponse {
        val body = submitBody(flowId, actionId).toMutableMap()
        body["verbose"] = true
        if (inputs.isNotEmpty()) body["inputs"] = inputs
        return httpClient.post("/flow/execute", body, requiresAuth = false)
    }

    internal fun submitBody(flowId: String, actionId: String): Map<String, Any> = mapOf(
        "executionId" to flowId,
        "action" to actionId
    )
}
