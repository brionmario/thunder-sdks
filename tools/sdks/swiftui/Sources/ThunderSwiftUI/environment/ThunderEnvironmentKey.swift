import SwiftUI

/// Environment key for the Thunder auth state (spec §7.2).
struct ThunderStateKey: EnvironmentKey {
    static let defaultValue: ThunderState? = nil
}

public extension EnvironmentValues {
    var thunderState: ThunderState? {
        get { self[ThunderStateKey.self] }
        set { self[ThunderStateKey.self] = newValue }
    }
}
