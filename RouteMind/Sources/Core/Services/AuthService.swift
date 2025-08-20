import Foundation
import FirebaseAuth
import FirebaseCore
import GoogleSignIn
import AuthenticationServices
import CryptoKit

final class AuthService: ObservableObject {
    
    static let shared = AuthService()
    
    @Published var currentUser: FirebaseAuth.User? = Auth.auth().currentUser

    private var currentNonce: String?

    // MARK: - Email/Password Sign Up
    func signUp(email: String, password: String, name: String, completion: @escaping (Result<User, Error>) -> Void) {
        Auth.auth().createUser(withEmail: email, password: password) { authResult, error in
            if let error = error {
                return completion(.failure(error))
            }

            guard let user = authResult?.user else {
                return completion(.failure(NSError(domain: "AuthService", code: 0, userInfo: [NSLocalizedDescriptionKey: "No user returned"])))
            }

            let newUser = User(
                uuid: user.uid,
                email: user.email ?? email,
                name: name,
                profilePictureURL: nil,
                preferences: self.defaultPreferences(),
                createdAt: Date(),
                updatedAt: Date()
            )

            // Save to Firestore
            FirestoreService.shared.saveUser(user: newUser) { result in
                switch result {
                case .success:
                    self.currentUser = user
                    completion(.success(newUser))
                case .failure(let error):
                    completion(.failure(error))
                }
            }
        }
    }

    // MARK: - Email/Password Sign In
    func signIn(email: String, password: String, completion: @escaping (Result<FirebaseAuth.User, Error>) -> Void) {
        Auth.auth().signIn(withEmail: email, password: password) { authResult, error in
            if let error = error {
                return completion(.failure(error))
            }

            guard let user = authResult?.user else {
                return completion(.failure(NSError(domain: "AuthService", code: 1, userInfo: [NSLocalizedDescriptionKey: "Authentication failed."])))
            }

            self.currentUser = user
            completion(.success(user))
        }
    }

    // MARK: - Google Sign-In
    func signInWithGoogle(presentingViewController: UIViewController, completion: @escaping (Result<FirebaseAuth.User, Error>) -> Void) {
        guard let clientID = FirebaseApp.app()?.options.clientID else {
            completion(.failure(NSError(domain: "AuthService", code: 2, userInfo: [NSLocalizedDescriptionKey: "Missing Google Client ID"])))
            return
        }

        let config = GIDConfiguration(clientID: clientID)
        GIDSignIn.sharedInstance.configuration = config

        GIDSignIn.sharedInstance.signIn(withPresenting: presentingViewController) { result, error in
            if let error = error {
                completion(.failure(error))
                return
            }

            guard let user = result?.user,
                  let idToken = user.idToken?.tokenString else {
                completion(.failure(NSError(domain: "AuthService", code: 3, userInfo: [NSLocalizedDescriptionKey: "Google authentication failed."])))
                return
            }
            
            let accessToken = user.accessToken.tokenString

            let credential = GoogleAuthProvider.credential(withIDToken: idToken, accessToken: accessToken)

            Auth.auth().signIn(with: credential) { authResult, error in
                if let error = error {
                    completion(.failure(error))
                    return
                }

                guard let user = authResult?.user else {
                    completion(.failure(NSError(domain: "AuthService", code: 4, userInfo: [NSLocalizedDescriptionKey: "User not found after Google Sign-In."])))
                    return
                }

                self.currentUser = user
                completion(.success(user))
            }
        }
    }

    // MARK: - Apple Sign-In
    /*
    func handleAppleSignIn(result: ASAuthorization, completion: @escaping (Result<FirebaseAuth.User, Error>) -> Void) {
        guard let appleIDCredential = result.credential as? ASAuthorizationAppleIDCredential else {
            completion(.failure(NSError(domain: "AppleAuth", code: -1, userInfo: [NSLocalizedDescriptionKey: "Invalid Apple credential."])))
            return
        }

        guard let nonce = currentNonce else {
            completion(.failure(NSError(domain: "AppleAuth", code: -2, userInfo: [NSLocalizedDescriptionKey: "Missing nonce."])))
            return
        }

        guard let identityTokenData = appleIDCredential.identityToken,
              let idTokenString = String(data: identityTokenData, encoding: .utf8) else {
            completion(.failure(NSError(domain: "AppleAuth", code: -3, userInfo: [NSLocalizedDescriptionKey: "Unable to fetch identity token."])))
            return
        }

        // Use the correct OAuthProvider credential method
        let credential = OAuthProvider.credential(withProviderID: "apple.com",
                                                idToken: idTokenString,
                                                rawNonce: nonce)

        Auth.auth().signIn(with: credential) { authResult, error in
            if let error = error {
                completion(.failure(error))
                return
            }

            guard let user = authResult?.user else {
                completion(.failure(NSError(domain: "AppleAuth", code: -4, userInfo: [NSLocalizedDescriptionKey: "Apple Sign-In failed."])))
                return
            }

            self.currentUser = user
            completion(.success(user))
        }
    }

    func createNonce() -> String {
        let charset: [Character] =
            Array("0123456789ABCDEFGHIJKLMNOPQRSTUVXYZabcdefghijklmnopqrstuvwxyz-._")
        var result = ""
        var remainingLength = 32

        while remainingLength > 0 {
            let randoms: [UInt8] = (0 ..< 16).map { _ in
                var random: UInt8 = 0
                _ = SecRandomCopyBytes(kSecRandomDefault, 1, &random)
                return random
            }

            randoms.forEach { random in
                if remainingLength == 0 {
                    return
                }

                if random < charset.count {
                    result.append(charset[Int(random)])
                    remainingLength -= 1
                }
            }
        }

        currentNonce = result
        return result
    }*/

    // MARK: - Password Reset
    func resetPassword(email: String, completion: @escaping (Result<Void, Error>) -> Void) {
        Auth.auth().sendPasswordReset(withEmail: email) { error in
            if let error = error {
                completion(.failure(error))
            } else {
                completion(.success(()))
            }
        }
    }

    // MARK: - Sign Out
    func signOut() {
        do {
            try Auth.auth().signOut()
            currentUser = nil
        } catch {
            print("Error signing out: \(error.localizedDescription)")
        }
    }

    // MARK: - Get Current User
    func getCurrentUser() -> FirebaseAuth.User? {
        return Auth.auth().currentUser
    }

    // MARK: - Default Preferences (Example)
    private func defaultPreferences() -> UserPreferences {
        return UserPreferences(
            preferredBreakInterval: 3600,
            exercisePreferences: ExercisePreferences(
                preferredCategories: [],
                preferredDifficulty: nil,
                preferredDurationRange: 300...900
            ),
            poiPreferences: POIPreferences(
                preferredTypes: [],
                preferredRadius: 5000
            ),
            notificationSettings: NotificationSettings(
                enableNotifications: true,
                notificationFrequency: 1800,
                soundEnabled: true,
                vibrationEnabled: true
            )
        )
    }
}
