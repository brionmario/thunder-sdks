import SwiftUI
import Thunder

/// ViewModifier that injects ThunderState into the environment (spec §7.2).
struct ThunderProviderModifier: ViewModifier {
    let config: ThunderConfig
    @StateObject private var state: ThunderState

    init(config: ThunderConfig, i18n: ThunderI18n) {
        self.config = config
        _state = StateObject(wrappedValue: ThunderState(client: ThunderClient(), i18n: i18n))
    }

    func body(content: Content) -> some View {
        content
            .environment(\.thunderState, state)
            .environmentObject(state)
            .environmentObject(state.i18n)
            .task { await state.initialize(config: config) }
    }
}

public extension View {
    /// Injects Thunder auth state into the SwiftUI environment.
    ///
    /// ```swift
    /// ContentView()
    ///     .thunderProvider(config: ThunderConfig(baseUrl: "...", clientId: "..."))
    /// ```
    func thunderProvider(config: ThunderConfig, i18n: ThunderI18n = ThunderI18n()) -> some View {
        modifier(ThunderProviderModifier(config: config, i18n: i18n))
    }
}
