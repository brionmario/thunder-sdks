import Foundation

/// Drives the Thunder Flow Execution API for app-native sign-in, sign-up, and recovery (spec §6.1–6.3).
final class FlowExecutionClient {
    private let httpClient: HTTPClient

    init(httpClient: HTTPClient) {
        self.httpClient = httpClient
    }

    func initiate(applicationId: String, flowType: FlowType) async throws -> EmbeddedFlowResponse {
        let body: [String: Any] = [
            "applicationId": applicationId,
            "flowType": flowType.rawValue,
            "verbose": true
        ]
        return try await httpClient.post(path: "/flow/execute", body: body, requiresAuth: false)
    }

    func submit(flowId: String, actionId: String, inputs: [String: String]) async throws -> EmbeddedFlowResponse {
        var body = submitBody(flowId: flowId, actionId: actionId)
        body["verbose"] = true
        if !inputs.isEmpty {
            body["inputs"] = inputs
        }
        return try await httpClient.post(path: "/flow/execute", body: body, requiresAuth: false)
    }

    func submitBody(flowId: String, actionId: String) -> [String: Any] {
        [
            "flowId": flowId,
            "action": actionId
        ]
    }
}
