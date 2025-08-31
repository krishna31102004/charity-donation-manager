import SwiftUI
import SwiftData

/// A refined login screen with a welcoming header, grouped form inputs, error
/// feedback, and clear navigation options. Utilizes rounded backgrounds and
/// accent-colored buttons to guide the user through signing in. Errors are
/// displayed below the form when login fails.
struct LoginView: View {
    @Environment(\.modelContext) private var context
    /// AuthViewModel handles authentication calls.
    @StateObject private var vm = AuthViewModel()
    /// User-entered email.
    @State private var email: String = ""
    /// User-entered password.
    @State private var password: String = ""
    /// Optional error message displayed when login fails.
    @State private var error: String?
    /// Field focus state to manage keyboard dismissal.
    @FocusState private var isFocused: Bool

    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(spacing: 24) {
                    // Header
                    Text("Welcome back")
                        .font(.largeTitle.bold())
                        .frame(maxWidth: .infinity, alignment: .leading)
                    // Form container
                    VStack(spacing: 12) {
                        TextField("Email", text: $email)
                            .textFieldStyle(.roundedBorder)
                            .textInputAutocapitalization(.never)
                            .keyboardType(.emailAddress)
                            .focused($isFocused)
                        SecureField("Password", text: $password)
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
                    // Login button
                    Button {
                        attemptLogin()
                    } label: {
                        Text("Log In")
                            .frame(maxWidth: .infinity)
                    }
                    .buttonStyle(.borderedProminent)
                    .disabled(email.trimmingCharacters(in: .whitespaces).isEmpty
                              || password.isEmpty)
                    // Links to register and forgot password
                    HStack {
                        NavigationLink("Create account") { RegisterView() }
                        Spacer()
                        NavigationLink("Forgot password?") { ForgotPasswordView() }
                    }
                    .font(.footnote)
                }
                .padding()
            }
            .background(Color(.systemGroupedBackground))
            .navigationBarTitleDisplayMode(.inline)
        }
    }

    /// Attempts to log in with the provided credentials. If authentication fails
    /// an error message is shown.
    private func attemptLogin() {
        error = nil
        do {
            try vm.login(email: email, password: password, context: context)
        } catch let loginError {
            error = "Invalid email or password"
        }
    }
}
