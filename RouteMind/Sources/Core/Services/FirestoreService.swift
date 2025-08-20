import Foundation
import FirebaseFirestore

class FirestoreService {
    static let shared = FirestoreService()
    
    private let db = Firestore.firestore()
    
    private init() {}
    
    // MARK: - User Operations
    
    func saveUser(_ user: User) async -> Result<Void, Error> {
        do {
            try db.collection("users").document(user.id).setData(from: user)
            return .success(())
        } catch {
            return .failure(error)
        }
    }
    
    func fetchUser(userId: String) async -> Result<User, Error> {
        do {
            let document = try await db.collection("users").document(userId).getDocument()
            let user = try document.data(as: User.self)
            return .success(user)
        } catch {
            return .failure(error)
        }
    }
    
    func updateUser(_ user: User) async -> Result<Void, Error> {
        do {
            try db.collection("users").document(user.id).setData(from: user, merge: true)
            return .success(())
        } catch {
            return .failure(error)
        }
    }
    
    // MARK: - Route Operations
    
    func saveRoute(_ route: Route) async -> Result<Void, Error> {
        do {
            try db.collection("routes").document(route.id).setData(from: route)
            return .success(())
        } catch {
            return .failure(error)
        }
    }
    
    func fetchRoutes(userId: String) async -> Result<[Route], Error> {
        do {
            let snapshot = try await db.collection("routes")
                .whereField("userId", isEqualTo: userId)
                .order(by: "createdAt", descending: true)
                .getDocuments()
            
            let routes = try snapshot.documents.map { document in
                try document.data(as: Route.self)
            }
            
            return .success(routes)
        } catch {
            return .failure(error)
        }
    }
    
    func deleteRoute(_ route: Route) async -> Result<Void, Error> {
        do {
            try await db.collection("routes").document(route.id).delete()
            return .success(())
        } catch {
            return .failure(error)
        }
    }
    
    // MARK: - Break Point Operations
    
    func saveBreakPoint(_ breakPoint: BreakPoint) async -> Result<Void, Error> {
        do {
            try db.collection("breakPoints").document(breakPoint.id).setData(from: breakPoint)
            return .success(())
        } catch {
            return .failure(error)
        }
    }
    
    func fetchBreakPoints(routeId: String) async -> Result<[BreakPoint], Error> {
        do {
            let snapshot = try await db.collection("breakPoints")
                .whereField("routeId", isEqualTo: routeId)
                .order(by: "scheduledTime", descending: false)
                .getDocuments()
            
            let breakPoints = try snapshot.documents.map { document in
                try document.data(as: BreakPoint.self)
            }
            
            return .success(breakPoints)
        } catch {
            return .failure(error)
        }
    }
    
    func updateBreakPoint(_ breakPoint: BreakPoint) async -> Result<Void, Error> {
        do {
            try db.collection("breakPoints").document(breakPoint.id).setData(from: breakPoint, merge: true)
            return .success(())
        } catch {
            return .failure(error)
        }
    }
    
    // MARK: - Exercise History Operations
    
    func saveExerciseResult(_ result: ExerciseResult) async -> Result<Void, Error> {
        do {
            try db.collection("exerciseHistory").document(result.id).setData(from: result)
            return .success(())
        } catch {
            return .failure(error)
        }
    }
    
    func fetchExerciseHistory(userId: String) async -> Result<[ExerciseResult], Error> {
        do {
            let snapshot = try await db.collection("exerciseHistory")
                .whereField("userId", isEqualTo: userId)
                .order(by: "startTime", descending: true)
                .getDocuments()
            
            let history = try snapshot.documents.map { document in
                try document.data(as: ExerciseResult.self)
            }
            
            return .success(history)
        } catch {
            return .failure(error)
        }
    }
}
