import SwiftUI
import Thunder

/// Drives the invited-user-registration flow for a given invitation code (spec §8.4 Presentation).
public struct ThunderAcceptInvite: View {
    @EnvironmentObject private var i18n: ThunderI18n
    public let invitationCode: String
    public let applicationId: String
    public let onComplete: (() -> Void)?
    public let onError: ((String) -> Void)?

    public init(
        invitationCode: String,
        applicationId: String,
        onComplete: (() -> Void)? = nil,
        onError: ((String) -> Void)? = nil
    ) {
        self.invitationCode = invitationCode
        self.applicationId = applicationId
        self.onComplete = onComplete
        self.onError = onError
    }

    public var body: some View {
        BaseThunderAcceptInvite(
            invitationCode: invitationCode,
            applicationId: applicationId,
            onComplete: onComplete,
            onError: onError
        ) { signUpState in
            VStack(alignment: .leading, spacing: 12) {
                Text(i18n.resolve("acceptInvite.title"))
                    .accessibilityAddTraits(.isHeader)
                if let error = signUpState.error {
                    Text(error).foregroundColor(.red)
                }
                ForEach(signUpState.inputs, id: \.name) { input in
                    if input.type == "password" {
                        SecureField(input.name, text: signUpState.binding(for: input.name))
                            .frame(minHeight: 44)
                    } else {
                        TextField(input.name, text: signUpState.binding(for: input.name))
                            .frame(minHeight: 44)
                    }
                }
                ForEach(signUpState.actions, id: \.id) { action in
                    Button(action.label ?? i18n.resolve("acceptInvite.submit")) {
                        signUpState.submit(actionId: action.id)
                    }
                    .disabled(signUpState.isLoading)
                    .frame(minWidth: 44, minHeight: 44)
                }
            }
            .padding()
        }
    }
}

/// Unstyled base variant (spec §8.3). Reuses ThunderSignUpState for field/action management.
public struct BaseThunderAcceptInvite<Content: View>: View {
    @EnvironmentObject private var state: ThunderState
    public let invitationCode: String
    public let applicationId: String
    public let onComplete: (() -> Void)?
    public let onError: ((String) -> Void)?
    public let content: (ThunderSignUpState) -> Content

    @StateObject private var signUpState = ThunderSignUpState(submit: { _, _, _ in })

    public init(
        invitationCode: String,
        applicationId: String,
        onComplete: (() -> Void)? = nil,
        onError: ((String) -> Void)? = nil,
        @ViewBuilder content: @escaping (ThunderSignUpState) -> Content
    ) {
        self.invitationCode = invitationCode
        self.applicationId = applicationId
        self.onComplete = onComplete
        self.onError = onError
        self.content = content
    }

    public var body: some View {
        content(signUpState).task { await initFlow() }
    }

    private func initFlow() async {
        signUpState.isLoading = true
        defer { signUpState.isLoading = false }
        do {
            let payload = EmbeddedSignInPayload(
                actionId: "__initiate__",
                inputs: ["invitationCode": invitationCode]
            )
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
            let msg = response.failureReason ?? "Could not accept invite"
            signUpState.error = msg
            onError?(msg)
        }
    }
}
