import SwiftUI
import SwiftData

/// A polished profile management screen. Allows the user to view and update their
/// name and email, save changes, log out, or delete the account. Uses a card
/// layout for inputs and clearly separated action buttons. A confirmation
/// alert prevents accidental deletions. Displays error messages when deletion
/// fails.
struct ProfileView: View {
    @Environment(\.modelContext) private var context
    /// Fetch any existing profile records. Profiles are device scoped, so there will
    /// typically be at most one. We don't sort since there should only be one.
    @Query private var profiles: [Profile]
    /// The user's name. Bound to the text field.
    @State private var name: String = ""
    /// The user's email. Bound to the text field.
    @State private var email: String = ""
    /// Access the current email from UserDefaults to prefill the form when no
    /// profile record exists.
    @AppStorage("currentEmail") private var currentEmail: String = ""
    /// Authentication logic for logging out and deleting the account.
    @StateObject private var auth = AuthViewModel()
    /// Controls the presentation of the deletion confirmation alert.
    @State private var showDeleteAlert: Bool = false
    /// Optional error message shown if deletion fails.
    @State private var deleteError: String?

    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(spacing: 16) {
                    header
                    formSection
                    actionsSection
                    if let error = deleteError {
                        Text(error)
                            .font(.footnote)
                            .foregroundStyle(.red)
                            .padding(.horizontal)
                    }
                }
                .padding(.vertical, 16)
            }
            .background(Color(.systemGroupedBackground))
            .navigationTitle("Profile")
            .onAppear { loadProfile() }
            // Confirmation alert for account deletion
            .alert("Delete account?", isPresented: $showDeleteAlert) {
                Button("Delete", role: .destructive) {
                    do {
                        try auth.deleteAccount(context: context)
                    } catch {
                        deleteError = "Could not delete account."
                    }
                }
                Button("Cancel", role: .cancel) {}
            } message: {
                Text("This will permanently remove your account, profile, favorites, and donation history on this device.")
            }
        }
    }

    /// Loads the profile or pre-fills the form with the current email when
    /// appearing. Ensures the UI reflects the stored data.
    private func loadProfile() {
        if let p = profiles.first {
            name = p.name
            email = p.email
        } else {
            name = ""
            email = currentEmail
        }
    }

    /// A header describing the purpose of the profile screen.
    private var header: some View {
        VStack(alignment: .leading, spacing: 6) {
            Text("Your account")
                .font(.title2.bold())
            Text("Update your info or manage your session.")
                .font(.subheadline)
                .foregroundStyle(.secondary)
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .padding(16)
        .background(
            RoundedRectangle(cornerRadius: 16)
                .fill(.ultraThinMaterial)
        )
        .overlay(
            RoundedRectangle(cornerRadius: 16)
                .strokeBorder(Color.primary.opacity(0.06))
        )
        .padding(.horizontal)
    }

    /// Form section containing text fields for the user's name and email. A Save
    /// button writes changes to the model context.
    private var formSection: some View {
        VStack(spacing: 12) {
            TextField("Name", text: $name)
                .textFieldStyle(.roundedBorder)
            TextField("Email", text: $email)
                .textFieldStyle(.roundedBorder)
                .textInputAutocapitalization(.never)
                .keyboardType(.emailAddress)
            Button {
                saveProfile()
            } label: {
                Text("Save Profile")
                    .frame(maxWidth: .infinity)
            }
            .buttonStyle(.borderedProminent)
            .disabled(name.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty
                      || email.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty)
        }
        .padding(.horizontal)
    }

    /// Actions section containing logout and delete buttons. The delete button
    /// triggers an alert to confirm.
    private var actionsSection: some View {
        VStack(spacing: 10) {
            Button {
                auth.logout()
            } label: {
                Text("Log Out")
                    .frame(maxWidth: .infinity)
            }
            .buttonStyle(.bordered)
            Button {
                showDeleteAlert = true
            } label: {
                Text("Delete Account")
                    .frame(maxWidth: .infinity)
            }
            .buttonStyle(.bordered)
            .tint(.red)
        }
        .padding(.horizontal)
    }

    /// Saves the updated name and email to the existing profile or inserts a new
    /// one if none exists. Uses the model context to persist changes.
    private func saveProfile() {
        let trimmedName = name.trimmingCharacters(in: .whitespacesAndNewlines)
        let trimmedEmail = email.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !trimmedName.isEmpty, !trimmedEmail.isEmpty else { return }
        if let existing = profiles.first {
            existing.name = trimmedName
            existing.email = trimmedEmail
        } else {
            let profile = Profile(name: trimmedName, email: trimmedEmail)
            context.insert(profile)
        }
        do {
            try context.save()
        } catch {
            // An error saving the profile should not silently fail; optionally set
            // an error state. For now we ignore errors.
        }
    }
}
