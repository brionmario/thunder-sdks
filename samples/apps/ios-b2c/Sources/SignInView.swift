import SwiftUI
import ThunderSwiftUI

/// Unauthenticated landing screen — drives the embedded sign-in flow.
struct SignInView: View {
    private let applicationId = ProcessInfo.processInfo.environment["THUNDER_APPLICATION_ID"] ?? ""

    var body: some View {
        NavigationStack {
            ThunderSignIn(applicationId: applicationId)
                .navigationTitle("Sign in")
        }
    }
}
