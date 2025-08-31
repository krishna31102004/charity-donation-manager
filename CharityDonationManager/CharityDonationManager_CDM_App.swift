import SwiftUI
import SwiftData

@main
struct CharityDonationManagerApp: App {
    @UIApplicationDelegateAdaptor(AppDelegate.self) var appDelegate
    var body: some Scene {
        WindowGroup {
            LaunchView()
        }
        .modelContainer(for: [FavoritePlace.self, DonationRecord.self, Profile.self, AppUser.self])
    }
}
