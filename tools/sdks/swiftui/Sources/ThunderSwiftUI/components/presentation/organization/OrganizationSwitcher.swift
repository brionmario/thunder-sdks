import SwiftUI
import Thunder

/// Picker to switch the active organization (spec §8.4 Presentation).
public struct ThunderOrganizationSwitcher: View {
    @EnvironmentObject private var i18n: ThunderI18n

    public init() {}

    public var body: some View {
        BaseThunderOrganizationSwitcher { orgs, current, isSwitching, error, switchOrg in
            VStack(alignment: .leading, spacing: 0) {
                if orgs.isEmpty {
                    Text(i18n.resolve("organizationSwitcher.empty"))
                } else {
                    ForEach(orgs, id: \.id) { org in
                        Button {
                            if !isSwitching { Task { await switchOrg(org) } }
                        } label: {
                            HStack {
                                Text(org.name)
                                if org.id == current?.id {
                                    Spacer()
                                    Image(systemName: "checkmark")
                                }
                            }
                        }
                        .accessibilityLabel(org.name)
                        .accessibilityAddTraits(org.id == current?.id ? .isSelected : [])
                        .frame(minWidth: 44, minHeight: 44)
                        .disabled(isSwitching)
                    }
                }
                if let error { Text(error).foregroundColor(.red) }
            }
        }
    }
}

/// Unstyled base variant (spec §8.3).
public struct BaseThunderOrganizationSwitcher<Content: View>: View {
    @EnvironmentObject private var state: ThunderState
    public let content: ([Organization], Organization?, Bool, String?, (Organization) async -> Void) -> Content

    @State private var orgs: [Organization] = []
    @State private var current: Organization?
    @State private var isSwitching = false
    @State private var error: String?

    public init(
        @ViewBuilder content: @escaping ([Organization], Organization?, Bool, String?, (Organization) async -> Void) -> Content
    ) {
        self.content = content
    }

    public var body: some View {
        content(orgs, current, isSwitching, error, switchOrg)
            .task { await load() }
    }

    private func load() async {
        isSwitching = true
        async let myOrgs = state.client.getMyOrganizations()
        async let cur = state.client.getCurrentOrganization()
        orgs = (try? await myOrgs) ?? []
        current = try? await cur
        isSwitching = false
    }

    private func switchOrg(_ org: Organization) async {
        isSwitching = true; error = nil
        do {
            _ = try await state.client.switchOrganization(org)
            current = org
            await state.refresh()
        } catch { self.error = error.localizedDescription }
        isSwitching = false
    }
}
