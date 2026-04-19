import SwiftUI
import ThunderSwiftUI

@main
struct ThunderB2CApp: App {
    private let config = ThunderConfig(
        baseUrl: ProcessInfo.processInfo.environment["THUNDER_BASE_URL"] ?? "",
        clientId: ProcessInfo.processInfo.environment["THUNDER_CLIENT_ID"]
    )

    var body: some Scene {
        WindowGroup {
            RootView()
                .thunderProvider(config: config)
        }
    }
}
