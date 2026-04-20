import SwiftUI
import ThunderID

/// Read-only display of the current organization (spec §8.4 Presentation).
public struct ThunderOrganization: View {
    @EnvironmentObject private var i18n: ThunderI18n

    public init() {}

    public var body: some View {
        BaseThunderOrganization { org in
            Text(org?.name ?? i18n.resolve("organization.unnamed"))
                .accessibilityLabel(org?.name ?? i18n.resolve("organization.unnamed"))
        }
    }
}

/// Unstyled base variant (spec §8.3).
public struct BaseThunderOrganization<Content: View>: View {
    @EnvironmentObject private var state: ThunderState
    public let content: (Organization?) -> Content

    @State private var org: Organization?

    public init(@ViewBuilder content: @escaping (Organization?) -> Content) {
        self.content = content
    }

    public var body: some View {
        content(org)
            .task {
                org = try? await state.client.getCurrentOrganization()
            }
    }
}
