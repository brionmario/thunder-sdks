import SwiftUI
import Thunder

/// Lists organizations the signed-in user belongs to (spec §8.4 Presentation).
public struct ThunderOrganizationList: View {
    @EnvironmentObject private var i18n: ThunderI18n
    public let onOrganizationTap: ((Organization) -> Void)?

    public init(onOrganizationTap: ((Organization) -> Void)? = nil) {
        self.onOrganizationTap = onOrganizationTap
    }

    public var body: some View {
        BaseThunderOrganizationList { orgs, isLoading, error in
            if isLoading {
                EmptyView()
            } else if orgs.isEmpty {
                Text(i18n.resolve("organizationList.empty"))
            } else {
                VStack(alignment: .leading, spacing: 0) {
                    ForEach(orgs, id: \.id) { org in
                        Button(org.name) { onOrganizationTap?(org) }
                            .accessibilityLabel(org.name)
                            .frame(minWidth: 44, minHeight: 44)
                    }
                }
            }
        }
    }
}

/// Unstyled base variant (spec §8.3).
public struct BaseThunderOrganizationList<Content: View>: View {
    @EnvironmentObject private var state: ThunderState
    public let content: ([Organization], Bool, String?) -> Content

    @State private var orgs: [Organization] = []
    @State private var isLoading = false
    @State private var error: String?

    public init(@ViewBuilder content: @escaping ([Organization], Bool, String?) -> Content) {
        self.content = content
    }

    public var body: some View {
        content(orgs, isLoading, error)
            .task { await load() }
    }

    private func load() async {
        isLoading = true
        do {
            orgs = try await state.client.getMyOrganizations()
        } catch { self.error = error.localizedDescription }
        isLoading = false
    }
}
