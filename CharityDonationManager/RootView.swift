import SwiftUI

/// The main entry point after login. Presents the four primary tabs of the app
/// with consistent icons and labels. Uses the system accent color for selected
/// tabs. Each tab hosts a navigation stack for its respective view.
struct RootView: View {
    var body: some View {
        TabView {
            DiscoverView()
                .tabItem {
                    Label("Discover", systemImage: "mappin.and.ellipse")
                }
            FavoritesView()
                .tabItem {
                    Label("Favorites", systemImage: "star")
                }
            DonationHistoryView()
                .tabItem {
                    Label("History", systemImage: "clock.arrow.circlepath")
                }
            ProfileView()
                .tabItem {
                    Label("Profile", systemImage: "person.crop.circle")
                }
        }
        .tint(.accentColor)
    }
}
