/// ThunderSwiftUI — Core Lib SDK for iOS / macOS (spec §2.5).
///
/// Drop-in SwiftUI components for Thunder identity management.
/// Depends on the Thunder iOS Platform SDK; never imports UIKit.
///
/// Usage:
/// ```swift
/// import ThunderSwiftUI
///
/// @main struct MyApp: App {
///     var body: some Scene {
///         WindowGroup {
///             ContentView()
///                 .thunderProvider(config: ThunderConfig(baseUrl: "...", clientId: "..."))
///         }
///     }
/// }
/// ```
@_exported import Thunder
