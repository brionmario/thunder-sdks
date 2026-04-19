import SwiftUI
import Thunder

/// Displays the current organization's details (spec §8.4 Presentation).
public struct ThunderOrganizationProfile: View {
    public init() {}

    public var body: some View {
        BaseThunderOrganizationProfile { org, isLoading, error in
            if let error {
                Text(error)
            } else if let org {
                VStack(alignment: .leading, spacing: 4) {
                    Text(org.name)
                        .accessibilityLabel(org.name)
                    if let handle = org.handle {
                        Text(handle)
                    }
                }
            }
        }
    }
}

/// Unstyled base variant (spec §8.3).
public struct BaseThunderOrganizationProfile<Content: View>: View {
    @EnvironmentObject private var state: ThunderState
    public let content: (Organization?, Bool, String?) -> Content

    @State private var org: Organization?
    @State private var isLoading = false
    @State private var error: String?

    public init(@ViewBuilder content: @escaping (Organization?, Bool, String?) -> Content) {
        self.content = content
    }

    public var body: some View {
        content(org, isLoading, error)
            .task { await load() }
    }

    private func load() async {
        isLoading = true
        do {
            org = try await state.client.getCurrentOrganization()
        } catch { self.error = error.localizedDescription }
        isLoading = false
    }
}
