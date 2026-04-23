import SwiftUI
import ThunderID

/// Full app-native sign-in form. Drives the Flow Execution API loop (spec §8.4 Presentation).
public struct SignIn: View {
    @EnvironmentObject private var state: ThunderState
    @EnvironmentObject private var i18n: ThunderI18n
    public let applicationId: String
    public let onComplete: (() -> Void)?
    public let onError: ((String) -> Void)?

    public init(
        applicationId: String,
        onComplete: (() -> Void)? = nil,
        onError: ((String) -> Void)? = nil
    ) {
        self.applicationId = applicationId
        self.onComplete = onComplete
        self.onError = onError
    }

    public var body: some View {
        BaseSignIn(applicationId: applicationId, onComplete: onComplete, onError: onError) { signInState in
            VStack(alignment: .leading, spacing: 12) {
                Text(i18n.resolve("signIn.title"))
                    .accessibilityAddTraits(.isHeader)
                if let error = signInState.error {
                    Text(error).foregroundColor(.red)
                }
                ForEach(signInState.inputs, id: \.name) { input in
                    if input.type == "password" {
                        SecureField(input.name, text: signInState.binding(for: input.name))
                            .accessibilityLabel(input.name)
                            .frame(minHeight: 44)
                    } else {
                        TextField(input.name, text: signInState.binding(for: input.name))
                            .accessibilityLabel(input.name)
                            .frame(minHeight: 44)
                    }
                }
                ForEach(signInState.actions, id: \.id) { action in
                    Button(action.label ?? i18n.resolve("signIn.submit")) {
                        signInState.submit(actionId: action.id)
                    }
                    .disabled(signInState.isLoading)
                    .accessibilityLabel(action.label ?? i18n.resolve("signIn.submit"))
                    .frame(minWidth: 44, minHeight: 44)
                }
                if signInState.isLoading {
                    Text(i18n.resolve("signIn.loading"))
                }
            }
            .padding()
        }
    }
}

/// State container passed to the BaseSignIn builder.
@MainActor
public final class SignInState: ObservableObject {
    @Published public private(set) var inputs: [FlowInput] = []
    @Published public private(set) var actions: [FlowAction] = []
    @Published public private(set) var isLoading: Bool = false
    @Published public private(set) var error: String?

    private var fieldValues: [String: String] = [:]
    private var flowId: String?
    let submitAction: (String, [String: String], String?) -> Void

    init(submit: @escaping (String, [String: String], String?) -> Void) {
        self.submitAction = submit
    }

    public func binding(for name: String) -> Binding<String> {
        Binding(
            get: { self.fieldValues[name] ?? "" },
            set: { self.fieldValues[name] = $0 }
        )
    }

    public func submit(actionId: String) {
        submitAction(actionId, fieldValues, flowId)
    }

    func update(from response: EmbeddedFlowResponse) {
        flowId = response.flowId
        inputs = response.data?.inputs ?? []
        actions = response.data?.actions ?? []
    }
}

/// Unstyled base variant (spec §8.3).
public struct BaseSignIn<Content: View>: View {
    @EnvironmentObject private var state: ThunderState
    public let applicationId: String
    public let onComplete: (() -> Void)?
    public let onError: ((String) -> Void)?
    public let content: (SignInState) -> Content

    @StateObject private var signInState = SignInState(submit: { _, _, _ in })

    public init(
        applicationId: String,
        onComplete: (() -> Void)? = nil,
        onError: ((String) -> Void)? = nil,
        @ViewBuilder content: @escaping (SignInState) -> Content
    ) {
        self.applicationId = applicationId
        self.onComplete = onComplete
        self.onError = onError
        self.content = content
    }

    public var body: some View {
        content(signInState)
            .task { await initFlow() }
    }

    private func initFlow() async {
        signInState.isLoading = true
        defer { signInState.isLoading = false }
        do {
            let request = EmbeddedFlowRequestConfig(applicationId: applicationId, flowType: .authentication)
            let payload = EmbeddedSignInPayload(actionId: "__initiate__")
            let response = try await state.client.signIn(payload: payload, request: request)
            await handleResponse(response)
        } catch {
            signInState.error = error.localizedDescription
            onError?(error.localizedDescription)
        }
    }

    private func submit(actionId: String, inputs: [String: String], flowId: String?) async {
        signInState.isLoading = true
        defer { signInState.isLoading = false }
        do {
            let payload = EmbeddedSignInPayload(flowId: flowId, actionId: actionId, inputs: inputs)
            let request = EmbeddedFlowRequestConfig(applicationId: applicationId, flowType: .authentication)
            let response = try await state.client.signIn(payload: payload, request: request)
            await handleResponse(response)
        } catch {
            signInState.error = error.localizedDescription
            onError?(error.localizedDescription)
        }
    }

    private func handleResponse(_ response: EmbeddedFlowResponse) async {
        switch response.flowStatus {
        case .complete:
            await state.refresh()
            onComplete?()
        case .promptOnly:
            signInState.update(from: response)
        case .error:
            let msg = response.failureReason ?? "Sign-in failed"
            signInState.error = msg
            onError?(msg)
        }
    }
}
