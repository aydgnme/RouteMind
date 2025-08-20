import Foundation
import Combine

class SessionManager: ObservableObject {
    @Published var currentUser: User?
    @Published var isAuthenticated = false
    @Published var isLoading = false
    
    private let authService = AuthService.shared
    private let firestoreService = FirestoreService.shared
    private var cancellables = Set<AnyCancellable>()
    
    static let shared = SessionManager()
    
    private init() {
        setupSubscriptions()
    }
    
    private func setupSubscriptions() {
        authService.$currentUser
            .receive(on: DispatchQueue.main)
            .sink { [weak self] firebaseUser in
                self?.isAuthenticated = firebaseUser != nil
                
                // Fetch the app User model from Firestore when Firebase user changes
                if let firebaseUser = firebaseUser {
                    Task {
                        let result = await self?.firestoreService.fetchUser(userId: firebaseUser.uid)
                        await MainActor.run {
                            switch result {
                            case .success(let user):
                                self?.currentUser = user
                            case .failure:
                                self?.currentUser = nil
                            case .none:
                                self?.currentUser = nil
                            }
                        }
                    }
                } else {
                    self?.currentUser = nil
                }
            }
            .store(in: &cancellables)
    }
    
    func signIn(email: String, password: String) async -> Result<User, Error> {
        isLoading = true
        defer { isLoading = false }
        
        return await withCheckedContinuation { continuation in
            authService.signIn(email: email, password: password) { result in
                switch result {
                case .success(let firebaseUser):
                    // Fetch the app User from Firestore
                    Task {
                        let userResult = await self.firestoreService.fetchUser(userId: firebaseUser.uid)
                        continuation.resume(returning: userResult)
                    }
                case .failure(let error):
                    continuation.resume(returning: .failure(error))
                }
            }
        }
    }
    
    func signUp(email: String, password: String, name: String) async -> Result<User, Error> {
        isLoading = true
        defer { isLoading = false }
        
        return await withCheckedContinuation { continuation in
            authService.signUp(email: email, password: password, name: name) { result in
                continuation.resume(returning: result)
            }
        }
    }
    
    func signInWithGoogle() async -> Result<User, Error> {
        // This would need a presenting view controller, so we'll return an error for now
        return .failure(NSError(domain: "SessionManager", code: -1, userInfo: [NSLocalizedDescriptionKey: "Google Sign-In requires UI implementation"]))
    }
    
    func signInWithApple() async -> Result<User, Error> {
        // Apple Sign-In is commented out in AuthService, so return an error
        return .failure(NSError(domain: "SessionManager", code: -1, userInfo: [NSLocalizedDescriptionKey: "Apple Sign-In not implemented"]))
    }
    
    func signOut() -> Result<Void, Error> {
        authService.signOut()
        return .success(())
    }
    
    func resetPassword(email: String) async -> Result<Void, Error> {
        isLoading = true
        defer { isLoading = false }
        
        return await withCheckedContinuation { continuation in
            authService.resetPassword(email: email) { result in
                continuation.resume(returning: result)
            }
        }
    }
    
    func updateUserPreferences(_ preferences: User.UserPreferences) async -> Result<Void, Error> {
        guard let currentUser = currentUser else {
            return .failure(NSError(domain: "SessionManager", code: -1, userInfo: [NSLocalizedDescriptionKey: "No user logged in"]))
        }
        
        // Create a new User with updated preferences since properties are immutable
        let updatedUser = User(
            id: currentUser.id,
            email: currentUser.email,
            name: currentUser.name,
            profileImageURL: currentUser.profileImageURL,
            preferences: preferences,
            createdAt: currentUser.createdAt,
            lastLogin: Date()
        )
        
        let result = await firestoreService.updateUser(updatedUser)
        
        // Update local state if successful
        if case .success = result {
            await MainActor.run {
                self.currentUser = updatedUser
            }
        }
        
        return result
    }
}
