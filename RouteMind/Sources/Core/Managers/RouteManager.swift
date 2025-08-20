import Foundation
import MapKit
import Combine

@MainActor
class RouteManager: ObservableObject, @unchecked Sendable {
    @Published var recentRoutes: [Route] = []
    @Published var activeRoute: Route?
    @Published var isLoading = false
    @Published var error: Error?
    
    private let firestoreService = FirestoreService.shared
    private let routeService = RouteService.shared
    private var cancellables = Set<AnyCancellable>()
    
    static let shared = RouteManager()
    
    private init() {
        loadRecentRoutes()
    }
    
    func loadRecentRoutes() {
        guard let userId = SessionManager.shared.currentUser?.id else { return }
        
        isLoading = true
        Task {
            let result = await firestoreService.fetchRoutes(userId: userId)
            DispatchQueue.main.async {
                self.isLoading = false
                switch result {
                case .success(let routes):
                    self.recentRoutes = routes
                case .failure(let error):
                    self.error = error
                }
            }
        }
    }
    
    func createRoute(name: String, start: CLLocationCoordinate2D, end: CLLocationCoordinate2D, waypoints: [CLLocationCoordinate2D] = []) async -> Result<Route, Error> {
        isLoading = true
        defer { isLoading = false }
        
        // Calculate the route
        let routeResult = await routeService.calculateRoute(from: start, to: end)
        
        switch routeResult {
        case .success(let mkRoute):
            let route = Route(
                id: UUID().uuidString,
                userId: SessionManager.shared.currentUser?.id ?? "",
                name: name,
                startLocation: start,
                endLocation: end,
                waypoints: waypoints,
                polyline: mkRoute.polyline,
                estimatedDuration: mkRoute.expectedTravelTime,
                distance: mkRoute.distance,
                createdAt: Date(),
                isFavorite: false
            )
            
            // Save to Firestore
            let saveResult = await firestoreService.saveRoute(route)
            switch saveResult {
            case .success:
                DispatchQueue.main.async {
                    self.recentRoutes.insert(route, at: 0)
                    self.activeRoute = route
                }
                return .success(route)
            case .failure(let error):
                return .failure(error)
            }
            
        case .failure(let error):
            return .failure(error)
        }
    }
    
    func setActiveRoute(_ route: Route) {
        activeRoute = route
    }
    
    func clearActiveRoute() {
        activeRoute = nil
    }
    
    func deleteRoute(_ route: Route) {
        Task {
            let result = await firestoreService.deleteRoute(route)
            switch result {
            case .success:
                DispatchQueue.main.async {
                    self.recentRoutes.removeAll { $0.id == route.id }
                    if self.activeRoute?.id == route.id {
                        self.activeRoute = nil
                    }
                }
            case .failure(let error):
                self.error = error
            }
        }
    }
    
    func toggleFavorite(_ route: Route) {
        guard let index = recentRoutes.firstIndex(where: { $0.id == route.id }) else { return }
        
        var updatedRoute = route
        updatedRoute.isFavorite.toggle()
        
        // Update in memory
        recentRoutes[index] = updatedRoute
        if activeRoute?.id == route.id {
            activeRoute = updatedRoute
        }
        
        // Update in Firestore
        Task {
            await firestoreService.saveRoute(updatedRoute)
        }
    }
}
