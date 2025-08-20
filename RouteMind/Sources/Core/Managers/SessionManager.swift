import Foundation
import FirebaseAuth
import Combine

class SessionManager: ObservableObject {
    @Published var currentUser: User?
    @Published var isAuthenticated = false
    
    init() {
        // Listen for auth state changes
        Auth.auth().addStateDidChangeListener { [weak self] _, user in
            if let user = user {
                self?.currentUser = User(
                    id: user.uid,
                    email: user.email ?? "",
                    name: user.displayName ?? "User",
                    profileImageURL: user.photoURL?.absoluteString,
                    preferences: UserPreferences(),
                    createdAt: Date(),
                    lastLogin: Date()
                )
                self?.isAuthenticated = true
            } else {
                self?.currentUser = nil
                self?.isAuthenticated = false
            }
        }
    }
    
    func signOut() {
        do {
            try Auth.auth().signOut()
        } catch {
            print("Error signing out: \(error.localizedDescription)")
        }
    }
}
