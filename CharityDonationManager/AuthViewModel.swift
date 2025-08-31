import Foundation
import SwiftData
import CryptoKit

@MainActor
final class AuthViewModel: ObservableObject {
    enum AuthError: Error { case invalid, exists }

    private func hash(_ s: String) -> String {
        let d = Data(s.utf8)
        let h = SHA256.hash(data: d)
        return h.map { String(format: "%02x", $0) }.joined()
    }

    func register(name: String, email: String, password: String, context: ModelContext) throws {
        let e = email.lowercased()
        let fd = FetchDescriptor<AppUser>(predicate: #Predicate { $0.email == e })
        if let _ = try? context.fetch(fd).first { throw AuthError.exists }
        let u = AppUser(email: e, name: name, passwordHash: hash(password))
        context.insert(u)
        try context.save()
        UserDefaults.standard.set(true, forKey: "isLoggedIn")
        UserDefaults.standard.set(e, forKey: "currentEmail")
    }

    func login(email: String, password: String, context: ModelContext) throws {
        let e = email.lowercased()
        let fd = FetchDescriptor<AppUser>(predicate: #Predicate { $0.email == e })
        guard let u = try? context.fetch(fd).first else { throw AuthError.invalid }
        if u.passwordHash != hash(password) { throw AuthError.invalid }
        UserDefaults.standard.set(true, forKey: "isLoggedIn")
        UserDefaults.standard.set(e, forKey: "currentEmail")
    }

    func reset(email: String, newPassword: String, context: ModelContext) throws {
        let e = email.lowercased()
        let fd = FetchDescriptor<AppUser>(predicate: #Predicate { $0.email == e })
        guard let u = try? context.fetch(fd).first else { throw AuthError.invalid }
        u.passwordHash = hash(newPassword)
        try? context.save()
    }

    func deleteAccount(context: ModelContext) throws {
        guard let e = UserDefaults.standard.string(forKey: "currentEmail")?.lowercased() else { throw AuthError.invalid }
        if let u = try? context.fetch(FetchDescriptor<AppUser>(predicate: #Predicate { $0.email == e })).first {
            context.delete(u)
        } else {
            throw AuthError.invalid
        }
        for p in (try? context.fetch(FetchDescriptor<Profile>())) ?? [] { context.delete(p) }
        for f in (try? context.fetch(FetchDescriptor<FavoritePlace>())) ?? [] { context.delete(f) }
        for d in (try? context.fetch(FetchDescriptor<DonationRecord>())) ?? [] { context.delete(d) }
        try context.save()
        logout()
    }

    func logout() {
        UserDefaults.standard.set(false, forKey: "isLoggedIn")
        UserDefaults.standard.removeObject(forKey: "currentEmail")
    }
}
