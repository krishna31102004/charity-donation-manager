import SwiftUI

/// A simple launch router that chooses between the login flow and the main
/// application based on the user's authentication state. Sets a uniform
/// background color to blend with the rest of the app.
struct LaunchView: View {
    /// Determines whether the user is signed in. Uses AppStorage so that
    /// changes are reflected immediately across views.
    @AppStorage("isLoggedIn") private var isLoggedIn: Bool = false

    var body: some View {
        Group {
            if isLoggedIn {
                RootView()
            } else {
                LoginView()
            }
        }
        .background(Color(.systemGroupedBackground))
    }
}
