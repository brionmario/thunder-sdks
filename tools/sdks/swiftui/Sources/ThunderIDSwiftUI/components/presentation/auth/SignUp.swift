import SwiftUI
import ThunderID

/// App-native sign-up form. Drives the Flow Execution API registration loop (spec §8.4 Presentation).
public struct ThunderSignUp: View {
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
        BaseThunderSignUp(applicationId: applicationId, onComplete: onComplete, onError: onError) { signUpState in
            VStack(alignment: .leading, spacing: 12) {
                Text(i18n.resolve("signUp.title"))
                    .accessibilityAddTraits(.isHeader)
                if let error = signUpState.error {
                    Text(error).foregroundColor(.red)
                }
                ForEach(signUpState.inputs, id: \.name) { input in
                    if input.type == "password" {
                        SecureField(input.name, text: signUpState.binding(for: input.name))
                            .accessibilityLabel(input.name)
                            .frame(minHeight: 44)
                    } else {
                        TextField(input.name, text: signUpState.binding(for: input.name))
                            .accessibilityLabel(input.name)
                            .frame(minHeight: 44)
                    }
                }
                ForEach(signUpState.actions, id: \.id) { action in
                    Button(action.label ?? i18n.resolve("signUp.submit")) {
                        signUpState.submit(actionId: action.id)
                    }
                    .disabled(signUpState.isLoading)
                    .frame(minWidth: 44, minHeight: 44)
                }
                if signUpState.isLoading {
                    Text(i18n.resolve("signUp.loading"))
                }
            }
            .padding()
        }
    }
}

/// Mutable state passed to the BaseThunderSignUp builder.
@MainActor
public final class ThunderSignUpState: ObservableObject {
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
        Binding(get: { self.fieldValues[name] ?? "" }, set: { self.fieldValues[name] = $0 })
    }

    public func submit(actionId: String) { submitAction(actionId, fieldValues, flowId) }

    func update(from response: EmbeddedFlowResponse) {
        flowId = response.flowId
        inputs = response.data?.inputs ?? []
        actions = response.data?.actions ?? []
    }
}

/// Unstyled base variant (spec §8.3).
public struct BaseThunderSignUp<Content: View>: View {
    @EnvironmentObject private var state: ThunderState
    public let applicationId: String
    public let onComplete: (() -> Void)?
    public let onError: ((String) -> Void)?
    public let content: (ThunderSignUpState) -> Content

    @StateObject private var signUpState = ThunderSignUpState(submit: { _, _, _ in })

    public init(
        applicationId: String,
        onComplete: (() -> Void)? = nil,
        onError: ((String) -> Void)? = nil,
        @ViewBuilder content: @escaping (ThunderSignUpState) -> Content
    ) {
        self.applicationId = applicationId
        self.onComplete = onComplete
        self.onError = onError
        self.content = content
    }

    public var body: some View {
        content(signUpState)
            .task { await initFlow() }
    }

    private func initFlow() async {
        signUpState.isLoading = true
        defer { signUpState.isLoading = false }
        do {
            let response = try await state.client.signUp()
            await handleResponse(response)
        } catch {
            signUpState.error = error.localizedDescription
            onError?(error.localizedDescription)
        }
    }

    private func submit(actionId: String, inputs: [String: String], flowId: String?) async {
        signUpState.isLoading = true
        defer { signUpState.isLoading = false }
        do {
            let payload = EmbeddedSignInPayload(flowId: flowId, actionId: actionId, inputs: inputs)
            let response = try await state.client.signUp(payload: payload)
            await handleResponse(response)
        } catch {
            signUpState.error = error.localizedDescription
            onError?(error.localizedDescription)
        }
    }

    private func handleResponse(_ response: EmbeddedFlowResponse) async {
        switch response.flowStatus {
        case .complete:
            await state.refresh()
            onComplete?()
        case .promptOnly:
            signUpState.update(from: response)
        case .error:
            let msg = response.failureReason ?? "Sign-up failed"
            signUpState.error = msg
            onError?(msg)
        }
    }
}
