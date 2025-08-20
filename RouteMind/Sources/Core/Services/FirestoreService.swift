import Foundation
import FirebaseFirestore
import CoreLocation

final class FirestoreService {
    
    static let shared = FirestoreService()
    
    private let db = Firestore.firestore()
    
    private init() {}
    
    // MARK: - User
    
    func saveUser(user: User, completion: @escaping (Result<Void, Error>) -> Void) {
        do {
            try db.collection("users")
                .document(user.uuid)
                .setData(from: user, merge: true) { error in
                    if let error = error {
                        completion(.failure(error))
                    } else {
                        completion(.success(()))
                    }
                }
        } catch {
            completion(.failure(error))
        }
    }
    
    func fetchUser(userId: String, completion: @escaping (Result<User, Error>) -> Void) {
        db.collection("users").document(userId).getDocument { snapshot, error in
            if let error = error {
                completion(.failure(error))
                return
            }

            do {
                if let user = try snapshot?.data(as: User.self) {
                    completion(.success(user))
                } else {
                    completion(.failure(NSError(domain: "FirestoreService", code: 0, userInfo: [NSLocalizedDescriptionKey: "User not found."])))
                }
            } catch {
                completion(.failure(error))
            }
        }
    }
    
    // You can extend this service with saveRoute, fetchRoutes, etc. if needed
    func saveRoute(route: Route, completion: @escaping (Result<Void, Error>) -> Void) {
    }
        
}
