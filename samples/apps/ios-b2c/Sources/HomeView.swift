import SwiftUI
import ThunderSwiftUI

/// Authenticated home screen — shows user profile and sign-out.
struct HomeView: View {
    @State private var showProfile = false

    var body: some View {
        NavigationStack {
            VStack(spacing: 24) {
                ThunderUserDropdown(onProfileTap: { showProfile = true })
                    .padding(.trailing)
                    .frame(maxWidth: .infinity, alignment: .trailing)

                ThunderOrganizationSwitcher()
                    .padding()

                Spacer()

                ThunderSignOutButton()
                    .padding()
            }
            .navigationTitle("Home")
            .sheet(isPresented: $showProfile) {
                ThunderUserProfile()
                    .padding()
            }
        }
    }
}
