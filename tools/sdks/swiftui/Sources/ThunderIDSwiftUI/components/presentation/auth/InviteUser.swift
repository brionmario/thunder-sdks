import SwiftUI

/// Form to invite a user by email to the current organization (spec §8.4 Presentation).
public struct ThunderInviteUser: View {
    @EnvironmentObject private var i18n: ThunderI18n
    public let onSent: (() -> Void)?
    public let onError: ((String) -> Void)?

    public init(onSent: (() -> Void)? = nil, onError: ((String) -> Void)? = nil) {
        self.onSent = onSent
        self.onError = onError
    }

    public var body: some View {
        BaseThunderInviteUser(onSent: onSent, onError: onError) { email, isLoading, error, send in
            VStack(alignment: .leading, spacing: 12) {
                Text(i18n.resolve("inviteUser.title"))
                    .accessibilityAddTraits(.isHeader)
                if let error { Text(error).foregroundColor(.red) }
                TextField(i18n.resolve("inviteUser.email"), text: email)
                    .accessibilityLabel(i18n.resolve("inviteUser.email"))
                    .frame(minHeight: 44)
                Button(isLoading
                       ? i18n.resolve("inviteUser.loading")
                       : i18n.resolve("inviteUser.submit")
                ) { send() }
                    .disabled(isLoading)
                    .frame(minWidth: 44, minHeight: 44)
            }
            .padding()
        }
    }
}

/// Unstyled base variant (spec §8.3).
public struct BaseThunderInviteUser<Content: View>: View {
    @EnvironmentObject private var state: ThunderState
    public let onSent: (() -> Void)?
    public let onError: ((String) -> Void)?
    public let content: (Binding<String>, Bool, String?, () -> Void) -> Content

    @State private var email = ""
    @State private var isLoading = false
    @State private var error: String?

    public init(
        onSent: (() -> Void)? = nil,
        onError: ((String) -> Void)? = nil,
        @ViewBuilder content: @escaping (Binding<String>, Bool, String?, () -> Void) -> Content
    ) {
        self.onSent = onSent
        self.onError = onError
        self.content = content
    }

    public var body: some View {
        content($email, isLoading, error, send)
    }

    private func send() {
        guard !email.isEmpty else { return }
        isLoading = true
        error = nil
        Task {
            do {
                try await state.client.inviteUser(email: email)
                isLoading = false
                onSent?()
            } catch {
                self.error = error.localizedDescription
                isLoading = false
                onError?(error.localizedDescription)
            }
        }
    }
}
