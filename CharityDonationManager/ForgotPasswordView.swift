import SwiftUI
import SwiftData

/// A refreshed screen for resetting a user's password. Collects the account
/// email and a new password (with confirmation), displays feedback messages,
/// and uses a card-style layout. Checks that the new passwords match before
/// attempting the reset.
struct ForgotPasswordView: View {
    @Environment(\.modelContext) private var context
    /// Authentication model used to reset passwords.
    @StateObject private var vm = AuthViewModel()
    /// User-entered email address.
    @State private var email: String = ""
    /// The new password entered by the user.
    @State private var password: String = ""
    /// Confirmation of the new password.
    @State private var confirm: String = ""
    /// Optional feedback message shown after attempting a reset (success or error).
    @State private var message: String?

    var body: some View {
        ScrollView {
            VStack(spacing: 24) {
                Text("Reset password")
                    .font(.largeTitle.bold())
                    .frame(maxWidth: .infinity, alignment: .leading)
                VStack(spacing: 12) {
                    TextField("Email", text: $email)
                        .textFieldStyle(.roundedBorder)
                        .textInputAutocapitalization(.never)
                        .keyboardType(.emailAddress)
                    SecureField("New Password", text: $password)
                        .textFieldStyle(.roundedBorder)
                    SecureField("Confirm New Password", text: $confirm)
                        .textFieldStyle(.roundedBorder)
                }
                .padding(16)
                .background(
                    RoundedRectangle(cornerRadius: 16)
                        .fill(Color(.secondarySystemBackground))
                )
                // Feedback message, if any
                if let m = message {
                    Text(m)
                        .font(.footnote)
                        .foregroundStyle(m == "Password updated" ? .green : .red)
                        .frame(maxWidth: .infinity, alignment: .leading)
                }
                Button {
                    attemptReset()
                } label: {
                    Text("Update Password")
                        .frame(maxWidth: .infinity)
                }
                .buttonStyle(.borderedProminent)
                .disabled(!isFormValid)
                Spacer()
            }
            .padding()
        }
        .background(Color(.systemGroupedBackground))
        .navigationBarTitleDisplayMode(.inline)
    }

    /// Validates the form: email and passwords must be non-empty and the new
    /// password must match the confirmation.
    private var isFormValid: Bool {
        let trimmedEmail = email.trimmingCharacters(in: .whitespacesAndNewlines)
        let trimmedPassword = password.trimmingCharacters(in: .whitespacesAndNewlines)
        let trimmedConfirm = confirm.trimmingCharacters(in: .whitespacesAndNewlines)
        return !trimmedEmail.isEmpty
            && !trimmedPassword.isEmpty
            && trimmedPassword == trimmedConfirm
    }

    /// Attempts to reset the user's password. Sets a feedback message based on
    /// success or failure.
    private func attemptReset() {
        message = nil
        guard isFormValid else {
            message = "Fill all fields and match passwords"
            return
        }
        do {
            try vm.reset(email: email, newPassword: password, context: context)
            message = "Password updated"
        } catch {
            message = "Account not found"
        }
    }
}
