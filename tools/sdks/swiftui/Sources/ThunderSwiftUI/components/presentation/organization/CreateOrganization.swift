import SwiftUI
import Thunder

/// Form to create a new organization (spec §8.4 Presentation).
public struct ThunderCreateOrganization: View {
    @EnvironmentObject private var i18n: ThunderI18n
    public let onCreated: ((Organization) -> Void)?
    public let onError: ((String) -> Void)?

    public init(onCreated: ((Organization) -> Void)? = nil, onError: ((String) -> Void)? = nil) {
        self.onCreated = onCreated
        self.onError = onError
    }

    public var body: some View {
        BaseThunderCreateOrganization(onCreated: onCreated, onError: onError) { name, handle, isLoading, error, create in
            VStack(alignment: .leading, spacing: 12) {
                Text(i18n.resolve("createOrganization.title"))
                    .accessibilityAddTraits(.isHeader)
                if let error { Text(error).foregroundColor(.red) }
                TextField(i18n.resolve("createOrganization.name"), text: name)
                    .accessibilityLabel(i18n.resolve("createOrganization.name"))
                    .frame(minHeight: 44)
                TextField(i18n.resolve("createOrganization.handle"), text: handle)
                    .accessibilityLabel(i18n.resolve("createOrganization.handle"))
                    .frame(minHeight: 44)
                Button(i18n.resolve("createOrganization.submit")) { create() }
                    .disabled(isLoading)
                    .frame(minWidth: 44, minHeight: 44)
            }
            .padding()
        }
    }
}

/// Unstyled base variant (spec §8.3).
public struct BaseThunderCreateOrganization<Content: View>: View {
    @EnvironmentObject private var state: ThunderState
    public let onCreated: ((Organization) -> Void)?
    public let onError: ((String) -> Void)?
    public let content: (Binding<String>, Binding<String>, Bool, String?, () -> Void) -> Content

    @State private var name = ""
    @State private var handle = ""
    @State private var isLoading = false
    @State private var error: String?

    public init(
        onCreated: ((Organization) -> Void)? = nil,
        onError: ((String) -> Void)? = nil,
        @ViewBuilder content: @escaping (Binding<String>, Binding<String>, Bool, String?, () -> Void) -> Content
    ) {
        self.onCreated = onCreated
        self.onError = onError
        self.content = content
    }

    public var body: some View {
        content($name, $handle, isLoading, error, create)
    }

    private func create() {
        guard !name.isEmpty else { return }
        isLoading = true; error = nil
        Task {
            do {
                let org = try await state.client.createOrganization(
                    name: name,
                    handle: handle.isEmpty ? nil : handle
                )
                isLoading = false
                onCreated?(org)
            } catch {
                self.error = error.localizedDescription
                isLoading = false
                onError?(error.localizedDescription)
            }
        }
    }
}
