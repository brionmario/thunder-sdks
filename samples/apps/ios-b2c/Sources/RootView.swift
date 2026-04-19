import SwiftUI
import ThunderSwiftUI

/// Entry point. Routes between sign-in and home based on auth state.
struct RootView: View {
    var body: some View {
        ThunderLoading { ProgressView("Loading…") }

        ThunderSignedIn { HomeView() }
        ThunderSignedOut { SignInView() }
    }
}
