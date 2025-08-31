import SwiftUI
import SwiftData

/// A modern registration screen that collects the user's name, email, and
/// password. Uses rounded text fields grouped in a card, displays an error
/// message when input is invalid or registration fails, and provides a clear
/// sign-up button. Ensures password and confirmation match before attempting
/// registration.
struct RegisterView: View {
    @Environment(\.modelContext) private var context
    /// Authentication model used to create new users.
    @StateObject private var vm = AuthViewModel()
    /// User-entered name.
    @State private var name: String = ""
    /// User-entered email.
    @State private var email: String = ""
    /// User-entered password.
    @State private var password: String = ""
    /// User-entered confirmation password.
    @State private var confirm: String = ""
    /// Optional error message displayed when registration fails.
    @State private var error: String?

    var body: some View {
        ScrollView {
            VStack(spacing: 24) {
                Text("Create account")
                    .font(.largeTitle.bold())
                    .frame(maxWidth: .infinity, alignment: .leading)
                VStack(spacing: 12) {
                    TextField("Name", text: $name)
                        .textFieldStyle(.roundedBorder)
                    TextField("Email", text: $email)
                        .textFieldStyle(.roundedBorder)
                        .textInputAutocapitalization(.never)
                        .keyboardType(.emailAddress)
                    SecureField("Password", text: $password)
                        .textFieldStyle(.roundedBorder)
                    SecureField("Confirm Password", text: $confirm)
                        .textFieldStyle(.roundedBorder)
                }
                .padding(16)
                .background(
                    RoundedRectangle(cornerRadius: 16)
                        .fill(Color(.secondarySystemBackground))
                )
                // Error message, if any
                if let err = error {
                    Text(err)
                        .font(.footnote)
                        .foregroundStyle(.red)
                        .frame(maxWidth: .infinity, alignment: .leading)
                }
                Button {
                    attemptRegister()
                } label: {
                    Text("Sign Up")
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

    /// Returns true if the registration form is valid: all fields are non-empty
    /// and the passwords match.
    private var isFormValid: Bool {
        let trimmedName = name.trimmingCharacters(in: .whitespacesAndNewlines)
        let trimmedEmail = email.trimmingCharacters(in: .whitespacesAndNewlines)
        let trimmedPassword = password.trimmingCharacters(in: .whitespacesAndNewlines)
        let trimmedConfirm = confirm.trimmingCharacters(in: .whitespacesAndNewlines)
        return !trimmedName.isEmpty
            && !trimmedEmail.isEmpty
            && !trimmedPassword.isEmpty
            && trimmedPassword == trimmedConfirm
    }

    /// Attempts to register a new user. Sets an error message on failure.
    private func attemptRegister() {
        error = nil
        guard isFormValid else {
            error = "Fill all fields and match passwords"
            return
        }
        do {
            try vm.register(name: name, email: email, password: password, context: context)
        } catch let loginError {
            error = "Email already exists"
        }
    }
}
